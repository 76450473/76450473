extends SceneTree
## Local review server: shows the user's review page (美术资产/审核页面.html + its images) in the
## browser and receives the verdicts as 美术资产/复审结果.json. Pure Godot, no Python/Node needed.
##   godot --headless --path . --script res://tools/review_server.gd -- --root <abs path of 美术资产> [--port 8765] [--no-open] [--minutes 240]
## Pass an ABSOLUTE --root (Godot changes its working directory to the project with --path).
## Binds 127.0.0.1 only and tries port..port+10, then prints "REVIEW_URL http://127.0.0.1:<port>/"
## and opens the browser (unless --no-open). Run it in the background and wait for ONE of:
##   REVIEW_SUBMITTED <abs path of 复审结果.json>   (the user pressed submit; exits 0.5 s later)
##   REVIEW_TIMEOUT                                (--minutes passed without a submit; 0 = never)
## Routes: GET / = 审核页面.html · GET /<url-encoded path> = file under --root · GET /api/ping =
## {"ok":true} · POST /api/review (needs header X-Chimera-Review: 1, Origin absent or same-origin,
## a JSON object with an "items" object, <= 5 MB) is saved byte-for-byte via tmp + rename.
## Every request needs Host 127.0.0.1:<port> or localhost:<port> (blocks DNS rebinding). Paths
## with "..", dot/hidden segments, backslashes, ":" or absolute paths are refused (403).
## Loop design: driven by SceneTree._process, NOT a blocking OS.delay_msec loop in _initialize. The
## engine main loop keeps running normally (quit() exits with its code, prints are flushed), headless
## frames already sleep ~7 ms between iterations so idle CPU is ~0, and every frame re-polls ALL
## connections while bytes keep moving (bounded to 10 ms) so multi-MB PNGs stream at full speed.
## Sockets are non-blocking: browser pre-connects that send nothing never block other requests and
## are dropped after 15 s idle.

const HOST := "127.0.0.1"
const PORT_TRIES := 11
const INDEX_FILE := "审核页面.html"
const RESULT_FILE := "复审结果.json"
const MAX_BODY := 5 * 1024 * 1024
const MAX_HEAD := 32 * 1024
const MAX_CONNS := 64
const CHUNK := 256 * 1024
const IDLE_MS := 15000
const LINGER_MS := 2000
const QUIT_DELAY_MS := 500
const PUMP_BUDGET_MS := 10
const JSON_TYPE := "application/json; charset=utf-8"
const BAD_CHARS: Array[String] = ["\\", ":", "*", "?", "\"", "<", ">", "|"]
const TYPES := {
	"html": "text/html; charset=utf-8", "htm": "text/html; charset=utf-8",
	"png": "image/png", "jpg": "image/jpeg", "jpeg": "image/jpeg", "webp": "image/webp",
	"gif": "image/gif", "svg": "image/svg+xml", "ico": "image/x-icon",
	"json": JSON_TYPE, "js": "text/javascript; charset=utf-8", "mjs": "text/javascript; charset=utf-8",
	"css": "text/css; charset=utf-8", "txt": "text/plain; charset=utf-8", "md": "text/plain; charset=utf-8",
}
const REASONS := {
	200: "OK", 400: "Bad Request", 403: "Forbidden", 404: "Not Found", 405: "Method Not Allowed",
	411: "Length Required", 413: "Payload Too Large", 431: "Request Header Fields Too Large",
	500: "Internal Server Error", 501: "Not Implemented",
}

enum { READING, WRITING, LINGERING }


## One client connection: READING the request -> WRITING the response -> LINGERING until the
## client closes (draining stray input so the close never resets an unread response).
class Conn:
	var peer: StreamPeerTCP
	var state := 0
	var buf := PackedByteArray()
	var scan := 0
	var head_end := -1
	var body_len := 0
	var method := ""
	var target := ""
	var headers := {}
	var out := PackedByteArray()
	var sent := 0
	var last_ms := 0
	var done_ms := 0
	var submit := false


var _root := ""
var _port := 8765
var _open := true
var _minutes := 240.0
var _server: TCPServer = null
var _conns: Array[Conn] = []
var _start_ms := 0
var _quit_at := -1
var _submitted := false
var _done := false


func _initialize() -> void:
	if not _parse_args(OS.get_cmdline_user_args()):
		printerr("usage: review_server.gd -- --root <abs path of 美术资产> [--port 8765] [--no-open] [--minutes 240]")
		_finish(2)
		return
	if not FileAccess.file_exists(_root.path_join(INDEX_FILE)):
		printerr("review_server: warning: %s is missing in %s" % [INDEX_FILE, _root])
	var first := _port
	for p in range(first, mini(first + PORT_TRIES, 65536)):
		var s := TCPServer.new()
		if s.listen(p, HOST) == OK:
			_server = s
			_port = p
			break
	if _server == null:
		printerr("review_server: no free port in %d-%d" % [first, first + PORT_TRIES - 1])
		_finish(1)
		return
	_start_ms = Time.get_ticks_msec()
	var url := "http://%s:%d/" % [HOST, _port]
	print("REVIEW_URL ", url)
	if _open:
		OS.shell_open(url)


func _process(_delta: float) -> bool:
	if _done:
		return false
	var t0 := Time.get_ticks_msec()
	while _pump() and Time.get_ticks_msec() - t0 < PUMP_BUDGET_MS:
		pass
	var now := Time.get_ticks_msec()
	if _quit_at >= 0:
		# wait for in-flight responses (e.g. a second click) but never more than 2.5 s extra
		if now >= _quit_at and (not _busy() or now >= _quit_at + 2500):
			_finish(0)
	elif _minutes > 0.0 and now - _start_ms >= int(_minutes * 60000.0):
		print("REVIEW_TIMEOUT")
		_finish(0)
	return false


func _finalize() -> void:
	_close_all()


func _parse_args(args: PackedStringArray) -> bool:
	var i := 0
	while i < args.size():
		var a := args[i]
		var key := a
		var val := ""
		if a.begins_with("--") and a.contains("="):
			key = a.get_slice("=", 0)
			val = a.substr(key.length() + 1)
		elif a == "--root" or a == "--port" or a == "--minutes":
			if i + 1 >= args.size():
				return false
			i += 1
			val = args[i]
		match key:
			"--root":
				_root = val
			"--port":
				if not val.is_valid_int() or val.to_int() < 1 or val.to_int() > 65535:
					return false
				_port = val.to_int()
			"--minutes":
				if not val.is_valid_float():
					return false
				_minutes = val.to_float()
			"--no-open":
				_open = false
			_:
				printerr("review_server: unknown argument ", a)
				return false
		i += 1
	_root = _root.strip_edges().replace("\\", "/").simplify_path()
	while _root.length() > 1 and _root.ends_with("/") and not _root.ends_with(":/"):
		_root = _root.substr(0, _root.length() - 1)
	if _root == "" or not _root.is_absolute_path():
		printerr("review_server: --root must be an ABSOLUTE path, got '%s'" % _root)
		return false
	if not DirAccess.dir_exists_absolute(_root):
		printerr("review_server: --root folder does not exist: ", _root)
		return false
	return true


## Accepts new clients and advances every connection once. Returns true if any bytes moved.
func _pump() -> bool:
	var moved := false
	var now := Time.get_ticks_msec()
	while _server != null and _server.is_connection_available():
		if _conns.size() >= MAX_CONNS and not _evict_idle():
			break
		var c := Conn.new()
		c.peer = _server.take_connection()
		c.last_ms = now
		_conns.append(c)
		moved = true
	var keep: Array[Conn] = []
	for c in _conns:
		var r := _step(c, now)
		if r < 0:
			c.peer.disconnect_from_host()
			if c.submit:  # the file is already saved even if the browser vanished
				c.submit = false
				_on_submitted()
			continue
		if r > 0:
			moved = true
		keep.append(c)
	_conns = keep
	return moved


## -1 = drop the connection, 0 = nothing happened, 1 = progress.
func _step(c: Conn, now: int) -> int:
	match c.state:
		READING:
			c.peer.poll()
			if c.peer.get_status() != StreamPeerTCP.STATUS_CONNECTED:
				return -1
			var n := c.peer.get_available_bytes()
			if n <= 0:
				return -1 if now - c.last_ms > IDLE_MS else 0
			var r := c.peer.get_partial_data(mini(n, CHUNK))
			var err: int = r[0]
			if err != OK:
				return -1
			var data: PackedByteArray = r[1]
			c.buf.append_array(data)
			c.last_ms = now
			_parse(c)
			return 1
		WRITING:
			# no poll() here: a client that half-closed after its request must still get the answer
			var total := c.out.size()
			var moved := false
			while c.sent < total:
				var piece := c.out.slice(c.sent, mini(c.sent + CHUNK, total))
				var r := c.peer.put_partial_data(piece)
				var err: int = r[0]
				if err != OK:
					return -1
				var k: int = r[1]
				c.sent += k
				if k > 0:
					moved = true
					c.last_ms = now
				if k < piece.size():
					break  # socket buffer full; continue on the next pass
			if c.sent >= total:
				c.state = LINGERING
				c.done_ms = now
				c.out = PackedByteArray()
				if c.submit:
					c.submit = false
					_on_submitted()
				return 1
			if moved:
				return 1
			return -1 if now - c.last_ms > IDLE_MS else 0
		_:
			c.peer.poll()
			if c.peer.get_status() != StreamPeerTCP.STATUS_CONNECTED or now - c.done_ms > LINGER_MS:
				return -1
			var n := c.peer.get_available_bytes()
			if n > 0:
				var _discard := c.peer.get_partial_data(mini(n, CHUNK))
			return 0


## Drops the oldest connection that has not sent a byte yet (a speculative browser pre-connect).
func _evict_idle() -> bool:
	for i in _conns.size():
		var c := _conns[i]
		if c.state == READING and c.buf.is_empty():
			c.peer.disconnect_from_host()
			_conns.remove_at(i)
			return true
	return false


func _busy() -> bool:
	for c in _conns:
		if c.state == WRITING or (c.state == READING and not c.buf.is_empty()):
			return true
	return false


## Waits for "\r\n\r\n", parses the head once, then waits for Content-Length body bytes.
func _parse(c: Conn) -> void:
	if c.head_end < 0:
		while true:
			var i := c.buf.find(13, c.scan)
			if i < 0:
				c.scan = c.buf.size()
				break
			if i + 3 >= c.buf.size():
				c.scan = i
				break
			if c.buf[i + 1] == 10 and c.buf[i + 2] == 13 and c.buf[i + 3] == 10:
				c.head_end = i + 4
				break
			c.scan = i + 1
		if c.head_end < 0 or c.head_end > MAX_HEAD:
			if c.buf.size() > MAX_HEAD or c.head_end > MAX_HEAD:
				_error(c, 431, "request head larger than %d bytes" % MAX_HEAD)
			return
		if not _parse_head(c):
			return
	if c.buf.size() - c.head_end < c.body_len:
		return
	_handle(c, c.buf.slice(c.head_end, c.head_end + c.body_len))


func _parse_head(c: Conn) -> bool:
	var lines := c.buf.slice(0, c.head_end - 4).get_string_from_utf8().split("\r\n")
	var parts := lines[0].split(" ", false)
	if parts.size() != 3 or not parts[2].begins_with("HTTP/1."):
		_error(c, 400, "bad request line")
		return false
	c.method = parts[0]
	c.target = parts[1]
	for k in range(1, lines.size()):
		var line := lines[k]
		var colon := line.find(":")
		if colon <= 0:
			_error(c, 400, "bad header line")
			return false
		var name := line.substr(0, colon).strip_edges().to_lower()
		var value := line.substr(colon + 1).strip_edges()
		if c.headers.has(name):
			value = str(c.headers[name]) + ", " + value
		c.headers[name] = value
	if c.headers.has("transfer-encoding"):
		_error(c, 501, "chunked request bodies are not supported; send Content-Length")
		return false
	var cl := _header(c, "content-length")
	if cl == "":
		if c.method == "POST":
			_error(c, 411, "Content-Length required")
			return false
		return true
	if not cl.is_valid_int() or cl.begins_with("+") or cl.begins_with("-"):
		_error(c, 400, "bad Content-Length")
		return false
	if cl.length() > 9 or cl.to_int() > MAX_BODY:
		_error(c, 413, "body larger than 5 MB")
		return false
	c.body_len = cl.to_int()
	return true


func _header(c: Conn, name: String) -> String:
	var v: String = c.headers.get(name, "")
	return v


func _handle(c: Conn, body: PackedByteArray) -> void:
	var host := _header(c, "host").to_lower()
	if host != "%s:%d" % [HOST, _port] and host != "localhost:%d" % _port:
		_error(c, 403, "bad Host header (use http://%s:%d/)" % [HOST, _port])
		return
	var path := c.target
	for sep: String in ["?", "#"]:
		var cut := path.find(sep)
		if cut >= 0:
			path = path.substr(0, cut)
	if not path.begins_with("/"):
		_error(c, 400, "bad request target")
		return
	if path == "/api/review":
		if c.method != "POST":
			_error(c, 405, "use POST", "Allow: POST\r\n")
			return
		_review(c, body)
		return
	if c.method != "GET" and c.method != "HEAD":
		_error(c, 405, "method not allowed", "Allow: GET, HEAD\r\n")
		return
	if path == "/api/ping":
		_send(c, 200, JSON_TYPE, JSON.stringify({"ok": true}).to_utf8_buffer())
		return
	if path.begins_with("/api/"):
		_error(c, 404, "unknown API")
		return
	var rel := INDEX_FILE
	if path != "/":
		rel = _safe_rel(url_decode(path))
		if rel == "":
			_error(c, 403, "forbidden path")
			return
	var full := _root.path_join(rel)
	if DirAccess.dir_exists_absolute(full) or not FileAccess.file_exists(full):
		_error(c, 404, "not found: " + rel)
		return
	var data := FileAccess.get_file_as_bytes(full)
	if data.is_empty() and FileAccess.get_open_error() != OK:
		_error(c, 500, "cannot read: " + rel)
		return
	var ctype: String = TYPES.get(rel.get_extension().to_lower(), "application/octet-stream")
	_send(c, 200, ctype, data)


func _review(c: Conn, body: PackedByteArray) -> void:
	if _header(c, "x-chimera-review") != "1":
		_error(c, 403, "missing X-Chimera-Review header")
		return
	var origin := _header(c, "origin").to_lower()
	if origin != "" and origin != "http://%s:%d" % [HOST, _port] and origin != "http://localhost:%d" % _port:
		_error(c, 403, "cross-origin request refused")
		return
	var text := body.get_string_from_utf8()
	if text.begins_with("﻿"):
		text = text.substr(1)
	if text.strip_edges() == "":
		_error(c, 400, "empty body")
		return
	var json := JSON.new()
	if json.parse(text) != OK:
		_error(c, 400, "invalid JSON: %s (line %d)" % [json.get_error_message(), json.get_error_line() + 1])
		return
	var data: Variant = json.data
	var items: Variant = null
	if data is Dictionary:
		var d: Dictionary = data
		items = d.get("items")
	if not (items is Dictionary):
		_error(c, 400, "body must be a JSON object with an \"items\" object")
		return
	var path := _root.path_join(RESULT_FILE)
	var problem := _write_atomic(path, body)
	if problem != "":
		_error(c, 500, problem)
		return
	var verdicts: Dictionary = items
	print("review_server: saved %d verdict(s) to %s" % [verdicts.size(), path])
	c.submit = true
	_send(c, 200, JSON_TYPE, JSON.stringify({"ok": true}).to_utf8_buffer())


## Writes to a temp file next to the target, then renames it over the target.
func _write_atomic(path: String, bytes: PackedByteArray) -> String:
	var tmp := "%s.tmp%d" % [path, OS.get_process_id()]
	var f := FileAccess.open(tmp, FileAccess.WRITE)
	if f == null:
		return "cannot write %s (error %d)" % [tmp, FileAccess.get_open_error()]
	var ok := f.store_buffer(bytes)
	f.close()
	if not ok or FileAccess.get_file_as_bytes(tmp).size() != bytes.size():
		DirAccess.remove_absolute(tmp)
		return "cannot write %s (disk full?)" % tmp
	if DirAccess.rename_absolute(tmp, path) != OK:
		DirAccess.remove_absolute(path)  # some platforms refuse to rename over an existing file
		if DirAccess.rename_absolute(tmp, path) != OK:
			DirAccess.remove_absolute(tmp)
			return "cannot rename %s -> %s" % [tmp, path]
	return ""


func _on_submitted() -> void:
	if _submitted:
		return
	_submitted = true
	print("REVIEW_SUBMITTED ", _root.path_join(RESULT_FILE))
	_quit_at = Time.get_ticks_msec() + QUIT_DELAY_MS


func _error(c: Conn, code: int, msg: String, extra := "") -> void:
	print("review_server: %d %s %s (%s)" % [code, c.method, c.target.left(200), msg])
	_send(c, code, JSON_TYPE, JSON.stringify({"ok": false, "error": msg}).to_utf8_buffer(), extra)


func _send(c: Conn, code: int, ctype: String, body: PackedByteArray, extra := "") -> void:
	var reason: String = REASONS.get(code, "Error")
	var head := "HTTP/1.1 %d %s\r\n" % [code, reason]
	head += "Content-Type: %s\r\nContent-Length: %d\r\n" % [ctype, body.size()]
	head += "Cache-Control: no-store\r\nConnection: close\r\nX-Content-Type-Options: nosniff\r\n"
	head += extra + "\r\n"
	c.out = head.to_utf8_buffer()
	if c.method != "HEAD":
		c.out.append_array(body)
	c.sent = 0
	c.buf = PackedByteArray()
	c.state = WRITING


## Percent-decodes a URL path as UTF-8 (upper- or lower-case hex; "+" stays "+").
## Returns "" for malformed escapes, %00 or invalid UTF-8.
static func url_decode(s: String) -> String:
	var src := s.to_utf8_buffer()
	var out := PackedByteArray()
	var i := 0
	while i < src.size():
		var b: int = src[i]
		if b != 37:  # '%'
			out.append(b)
			i += 1
			continue
		if i + 2 >= src.size():
			return ""
		var hi := _hex(src[i + 1])
		var lo := _hex(src[i + 2])
		if hi < 0 or lo < 0 or hi * 16 + lo == 0:
			return ""
		out.append(hi * 16 + lo)
		i += 3
	var text := out.get_string_from_utf8()
	if text.contains("�") or text.to_utf8_buffer() != out:
		return ""
	return text


static func _hex(b: int) -> int:
	if b >= 48 and b <= 57:
		return b - 48
	if b >= 65 and b <= 70:
		return b - 55
	if b >= 97 and b <= 102:
		return b - 87
	return -1


## "/待复审/a.png" -> "待复审/a.png"; "" if the path could leave --root or is otherwise unsafe.
static func _safe_rel(decoded: String) -> String:
	if decoded.length() < 2 or not decoded.begins_with("/"):
		return ""
	var rel := decoded.substr(1)
	for ch in BAD_CHARS:
		if rel.contains(ch):
			return ""
	for i in rel.length():
		var u := rel.unicode_at(i)
		if u < 32 or u == 127:
			return ""
	for seg: String in rel.split("/"):
		if seg == "" or seg.begins_with(".") or seg.ends_with(".") or seg != seg.strip_edges():
			return ""
	if rel.is_absolute_path():
		return ""
	return rel


func _close_all() -> void:
	for c in _conns:
		c.peer.disconnect_from_host()
	_conns.clear()
	if _server != null:
		_server.stop()
		_server = null


func _finish(code: int) -> void:
	_done = true
	_close_all()
	quit(code)
