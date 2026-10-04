extends TestCase
## Art studio rules (StudioCore): key file, request shaping, money, selection, review state machine.

const KEY := "sk-test-0123456789abcdefghijklmnop"


func _entries() -> Array:
	return ArtManifest.build(db)


func _e(id: String) -> Dictionary:
	return ArtManifest.by_id(_entries())[id]


func test_key_file_plain_bom_crlf_and_settings() -> void:
	var r := StudioCore.parse_key_file("﻿" + KEY + "\r\n")
	check_eq(r.key, KEY, "plain key with BOM + CRLF")
	check((r.errors as PackedStringArray).is_empty(), "no errors")
	r = StudioCore.parse_key_file("# my key\nOPENAI_API_KEY=\"%s\"\nmodel=gpt-image-1-mini\nquality=HIGH\nn=2\nbudget=$5\nproxy=http://127.0.0.1:7890\nbase_url=https://relay.example.com/\n" % KEY)
	check_eq(r.key, KEY, "key= form, quotes stripped")
	check_eq(r.settings.model, "gpt-image-1-mini", "model")
	check_eq(r.settings.quality, "high", "quality lowercased")
	check_eq(r.settings.n, 2, "n int")
	check_eq(r.settings.budget, 5.0, "budget strips $")
	check_eq(r.settings.base_url, "https://relay.example.com/v1", "relay root gets /v1")
	r = StudioCore.parse_key_file("key：" + KEY)
	check_eq(r.key, KEY, "full-width colon")
	r = StudioCore.parse_key_file("Bearer " + KEY)
	check_eq(r.key, KEY, "Bearer prefix stripped")


func test_key_file_errors_never_echo_the_key() -> void:
	check(not (StudioCore.parse_key_file("").errors as PackedStringArray).is_empty(), "empty file is an error")
	check(not (StudioCore.parse_key_file("sk-short").errors as PackedStringArray).is_empty(), "short key")
	var bad := StudioCore.parse_key_file("sk-abc 我的key 0123456789abcdef")
	check(not (bad.errors as PackedStringArray).is_empty(), "spaces/CJK rejected")
	for e: String in bad.errors:
		check(not e.contains("sk-abc"), "error text does not contain the key")
	check(not (StudioCore.parse_key_file(KEY + "\nquality=ultra").errors as PackedStringArray).is_empty(), "bad setting reported")
	check(not (StudioCore.parse_key_file(KEY + "\nproxy=socks5://1.2.3.4:1080").errors as PackedStringArray).is_empty(), "socks proxy unsupported")
	check(not (StudioCore.parse_key_file("relaykey0123456789abcdefgh").warnings as PackedStringArray).is_empty(), "non sk- key warns about base_url")


func test_utf16_key_file_decodes() -> void:
	var b := PackedByteArray([0xFF, 0xFE])
	b.append_array(KEY.to_utf16_buffer())
	check_eq(StudioCore.parse_key_file(StudioCore.decode_text(b)).key, KEY, "UTF-16 LE with BOM")


func test_settings_merge_and_proxy() -> void:
	var s := StudioCore.effective_settings({"quality": "low"}, {"n": 4}, {"HTTPS_PROXY": "http://10.0.0.2:8080"})
	check_eq(s.quality, "low", "file setting")
	check_eq(s.n, 4, "override wins")
	check_eq(s.proxy, "http://10.0.0.2:8080", "env proxy used")
	check_eq(StudioCore.parse_proxy("http://user:pw@127.0.0.1:7890/"), {"host": "127.0.0.1", "port": 7890}, "proxy with auth + slash")
	check(StudioCore.parse_proxy("127.0.0.1").is_empty(), "no port -> invalid")
	check_eq(StudioCore.host_of("https://api.openai.com/v1"), "api.openai.com", "host_of")


func test_sizes_backgrounds_and_prompts() -> void:
	check_eq(StudioCore.api_size("1:1"), "1024x1024", "square")
	check_eq(StudioCore.api_size("16:9"), "1536x1024", "landscape")
	check_eq(StudioCore.api_size("3:1"), "1536x1024", "wide")
	check_eq(StudioCore.api_size("5:7"), "1024x1536", "portrait")
	var part := _e("part_sac")
	check_eq(StudioCore.api_background(part), "transparent", "parts are cut out with alpha")
	check_eq(StudioCore.api_background(_e("icon_energy")), "transparent", "icons too")
	check_eq(StudioCore.api_background(_e("bg_swamp")), "opaque", "scenes opaque")
	check_eq(StudioCore.api_background(_e("card_frame")), "opaque", "hollow frame keeps white fill")
	var p := StudioCore.gpt_prompt(part, "", false)
	check(not p.contains("pure white background"), "white backdrop phrase replaced")
	check(p.contains("transparent background"), "asks for transparency")
	check(p.contains("\nAvoid: ") and p.contains("watermark"), "negatives folded into Avoid:")
	check(StudioCore.gpt_prompt(_e("icon_energy"), "", false).contains("transparent background"), "black backdrop replaced")
	check(StudioCore.gpt_prompt(_e("card_frame"), "", false).contains("pure white"), "hollow frame prompt untouched")
	check(StudioCore.gpt_prompt(_e("bg_swamp"), "", false).contains("16:9 crop"), "crop hint for cover assets")
	check(StudioCore.gpt_prompt(part, "", true).begins_with(StudioCore.REF_PREFIX), "style-reference preamble")
	check(StudioCore.gpt_prompt(part, "a totally new prompt", false).begins_with("a totally new prompt"), "override replaces manifest prompt")


func test_refs_only_from_same_group_and_never_self() -> void:
	var by_id := ArtManifest.by_id(_entries())
	var approved := {"body_biped": "a/body_biped.png", "icon_energy": "a/icon_energy.png", "part_sac": "a/part_sac.png", "bg_swamp": "a/bg_swamp.png"}
	var anchors: Array = db.art.anchor_batch
	var refs := StudioCore.pick_refs(by_id["part_sac"], approved, by_id, anchors, 2)
	check_eq(refs, ["a/body_biped.png"], "creature refs: same group, not itself")
	check_eq(StudioCore.pick_refs(by_id["icon_stat_hp"], approved, by_id, anchors, 2), ["a/icon_energy.png"], "icon refs")
	check(StudioCore.pick_refs(by_id["bg_glacier"], approved, by_id, anchors, 2).is_empty(), "scenes never use refs")


func test_cost_estimate_and_usage() -> void:
	var one := StudioCore.estimate_usd("gpt-image-1", "medium", "1024x1024", 1, 0, 400)
	check(one > 0.04 and one < 0.05, "medium square ~= $0.042 (got %.4f)" % one)
	check(StudioCore.estimate_usd("gpt-image-1", "medium", "1536x1024", 3, 0, 400) > 3.0 * one, "non-square costs more")
	check(StudioCore.estimate_usd("gpt-image-1-mini", "medium", "1024x1024", 1, 0, 400) < one, "mini cheaper")
	check(StudioCore.estimate_usd("gpt-image-1", "medium", "1024x1024", 1, 2, 400) > one, "refs add input cost")
	var u := StudioCore.usage_usd("gpt-image-1", {"output_tokens": 1056, "input_tokens": 100, "input_tokens_details": {"text_tokens": 100, "image_tokens": 0}}, 9.0)
	check(absf(u - 0.0427) < 0.001, "usage -> usd (got %.4f)" % u)
	check_eq(StudioCore.usage_usd("gpt-image-1", {}, 0.5), 0.5, "no usage -> estimate")


func test_anchor_batch_ids_exist() -> void:
	var by_id := ArtManifest.by_id(_entries())
	var anchors: Array = db.art.get("anchor_batch", [])
	check_eq(anchors.size(), 6, "6 style anchors")
	for id: String in anchors:
		check(by_id.has(id), "anchor %s is a real asset" % id)


func test_selection_rules() -> void:
	var entries := _entries()
	var anchors: Array = db.art.anchor_batch
	var assets := {
		"part_sac": {"status": "candidates", "round": 1},
		"body_biped": {"status": "approved", "round": 1},
		"icon_energy": {"status": "claude_redo", "round": 3},
		"part_spear": {"status": "user_rejected", "round": 2},
	}
	var present := {"part_eye_compound": true}
	var r := StudioCore.select(entries, "anchor", assets, anchors, present, false, 3)
	var ids: Array = []
	for e: Dictionary in r.entries:
		ids.append(e.id)
	check(ids.has("body_hexapod") and ids.has("bg_swamp"), "missing anchors selected")
	check(not ids.has("part_sac"), "pending first pass skipped")
	check(not ids.has("body_biped"), "approved skipped")
	check(not ids.has("part_eye_compound"), "already in the game skipped")
	r = StudioCore.select(entries, "part_eye_compound, body_biped", assets, anchors, present, false, 3)
	check_eq((r.entries as Array).size(), 2, "explicitly named ids are regenerated")
	r = StudioCore.select(entries, "redo", assets, anchors, present, false, 3)
	ids.clear()
	for e: Dictionary in r.entries:
		ids.append(e.id)
	check(ids.has("part_spear"), "user rejection is redone")
	check(not ids.has("icon_energy"), "Claude redo capped at max rounds")
	r = StudioCore.select(entries, "p1 nonsense_id", assets, anchors, present, false, 3)
	check_eq(r.unknown, ["nonsense_id"], "unknown token reported")
	check((r.entries as Array).size() > 30, "p1 selects the P1 list")


func test_first_pass_state_machine() -> void:
	var st := StudioCore.new_state()
	StudioCore.record_gen(st, "part_sac", ["part_sac__r1_1.png", "part_sac__r1_2.png", "part_sac__r1_3.png"], "p", 0.13, "gpt-image-1", [], "t")
	var a := StudioCore.asset(st, "part_sac")
	check_eq(a.status, "candidates", "after gen")
	check_eq(int(a.round), 1, "round 1")
	check(absf(float(st.spent_usd) - 0.13) < 1e-6, "spend recorded")
	var cands: Array = a.candidates
	var bad := StudioCore.apply_verdict(st, "part_sac", {"pick": 7}, cands, 3, "t")
	check(not bool(bad.ok), "pick out of range refused")
	var redo := StudioCore.apply_verdict(st, "part_sac", {"redo": "背景有阴影", "prompt": "new p"}, cands, 3, "t")
	check(bool(redo.ok), "redo accepted")
	check_eq(a.status, "claude_redo", "status redo")
	check_eq((redo.to_reject as Array).size(), 3, "all candidates rejected")
	check_eq(a.prompt, "new p", "prompt override stored")
	StudioCore.record_gen(st, "part_sac", ["part_sac__r2_1.png", "part_sac__r2_2.png"], "p2", 0.1, "gpt-image-1", [], "t")
	check_eq(int(a.round), 2, "round 2")
	var pick := StudioCore.apply_verdict(st, "part_sac", {"pick": 2.0, "alt": "候选/part_sac__r2_1.png", "note": "好"}, a.candidates, 3, "t")
	check(bool(pick.ok), "pick by float index + alt by path")
	check_eq(a.status, "user_review", "goes to the user")
	check_eq(a.pick, "part_sac__r2_2.png", "pick resolved")
	check_eq(a.alt, "part_sac__r2_1.png", "alt resolved")
	check_eq(pick.to_review, ["part_sac__r2_2.png", "part_sac__r2_1.png"], "both moved to review")
	var again := StudioCore.apply_verdict(st, "part_sac", {"pick": 1}, [], 3, "t")
	check(not bool(again.ok), "no second pick while user reviews")


func test_redo_cap_forces_a_pick() -> void:
	var st := StudioCore.new_state()
	for r in 3:
		StudioCore.record_gen(st, "icon_energy", ["icon_energy__r%d_1.png" % (r + 1)], "p", 0.0, "m", [], "t")
		if r < 2:
			StudioCore.apply_verdict(st, "icon_energy", {"redo": "x"}, ["icon_energy__r%d_1.png" % (r + 1)], 3, "t")
	var res := StudioCore.apply_verdict(st, "icon_energy", {"redo": "still bad"}, ["icon_energy__r3_1.png"], 3, "t")
	check(not bool(res.ok), "fourth round refused")
	check(str(res.msg).contains("pick"), "tells Claude to pick instead")


func test_user_review_state_machine() -> void:
	var st := StudioCore.new_state()
	StudioCore.record_gen(st, "part_sac", ["a.png", "b.png", "c.png"], "p", 0.0, "m", [], "t")
	StudioCore.apply_verdict(st, "part_sac", {"pick": "b.png", "alt": "c.png"}, ["a.png", "b.png", "c.png"], 3, "t")
	var ok := StudioCore.apply_user(st, "part_sac", {"decision": "approve", "choice": "alt"}, "t")
	check_eq(ok.approve, "c.png", "alt chosen")
	check_eq(ok.reject, ["b.png"], "the other one rejected")
	check_eq(StudioCore.asset(st, "part_sac").status, "approved", "approved")
	check(not bool(StudioCore.apply_user(st, "part_sac", {"decision": "reject"}, "t").ok), "decided items ignored")
	StudioCore.record_gen(st, "icon_energy", ["i1.png"], "p", 0.0, "m", [], "t")
	StudioCore.apply_verdict(st, "icon_energy", {"pick": 1}, ["i1.png"], 3, "t")
	var no := StudioCore.apply_user(st, "icon_energy", {"decision": "reject", "comment": "太复杂"}, "t")
	check_eq(no.reject, ["i1.png"], "rejected file")
	var a := StudioCore.asset(st, "icon_energy")
	check_eq(a.status, "user_rejected", "user_rejected")
	check_eq(a.user_comment, "太复杂", "comment kept for Claude")
	check_eq(StudioCore.next_round(a), 1, "a rejection starts a new cycle")
	StudioCore.record_gen(st, "icon_energy", ["i2.png"], "p", 0.0, "m", [], "t")
	check_eq(int(a.round), 1, "cycle round restarts")
	check_eq(int(a.gens), 2, "generation counter keeps counting (file names never collide)")
	check_eq(StudioCore.counts(st).approved, 1, "counts")


func test_page_data_shape() -> void:
	var st := StudioCore.new_state()
	StudioCore.record_gen(st, "part_sac", ["x.png", "y.png"], "the prompt", 0.0, "m", [], "t")
	StudioCore.apply_verdict(st, "part_sac", {"pick": 1, "note": "推荐理由"}, ["x.png", "y.png"], 3, "t")
	var d := StudioCore.page_data(_entries(), st, {}, {"part_sac": "待复审/试装/part_sac.png"}, {"art_parts": "待复审/试装/art_parts.png"}, "gpt-image-1", "now")
	check_eq((d.items as Array).size(), 1, "one item")
	var it: Dictionary = d.items[0]
	check_eq(it.pick, "待复审/x.png", "pick path relative to 美术资产/")
	check_eq(it.alt, "", "no alt")
	check_eq(it.screen, "art_parts", "part -> parts page")
	check_eq(it.prompt, "the prompt", "prompt actually sent")
	check_eq(it.category_cn, "部件", "category label")
	check_eq(int(d.progress.total), _entries().size(), "progress total")


func test_api_errors_are_explained() -> void:
	var conn := StudioCore.explain_error(HTTPRequest.RESULT_CANT_RESOLVE, 0, {}, "api.openai.com", "gpt-image-1")
	check(bool(conn.fatal) and str(conn.msg).contains("proxy="), "connection failure suggests a proxy")
	check(bool(StudioCore.explain_error(0, 401, {}, "h", "m").fatal), "401 fatal")
	var verify := StudioCore.explain_error(0, 403, {"error": {"message": "Your organization must be verified to use the model"}}, "h", "gpt-image-1")
	check(str(verify.msg).contains("Verify"), "org verification explained")
	var quota := StudioCore.explain_error(0, 429, {"error": {"code": "insufficient_quota", "message": "You exceeded your current quota"}}, "h", "m")
	check(bool(quota.fatal), "quota fatal")
	var rate := StudioCore.explain_error(0, 429, {"error": {"code": "rate_limit_exceeded", "message": "Rate limit reached"}}, "h", "m")
	check(bool(rate.retry) and not bool(rate.fatal), "rate limit retried")
	var mod := StudioCore.explain_error(0, 400, {"error": {"code": "moderation_blocked", "message": "rejected by the safety system"}}, "h", "m")
	check(not bool(mod.fatal) and not bool(mod.retry), "moderation: rewrite prompt")
	var param := StudioCore.explain_error(0, 400, {"error": {"code": "unknown_parameter", "message": "Unknown parameter: 'moderation'."}}, "h", "m")
	check_eq(param.get("drop_param", ""), "moderation", "unsupported optional param dropped")
	check(bool(StudioCore.explain_error(0, 503, {}, "h", "m").retry), "5xx retried")


func test_file_helpers() -> void:
	check_eq(StudioCore.candidate_name("part_sac", 2, 3, "png"), "part_sac__r2_3.png", "candidate name")
	check_eq(StudioCore.id_of_candidate("候选/part_sac__r2_3.png"), "part_sac", "id from candidate")
	var img := Image.create(4, 4, false, Image.FORMAT_RGBA8)
	check_eq(StudioCore.image_ext(img.save_png_to_buffer()), "png", "png magic")
	check_eq(StudioCore.image_ext(img.save_jpg_to_buffer()), "jpg", "jpg magic")
	check_eq(StudioCore.image_ext(img.save_webp_to_buffer()), "webp", "webp magic")
	check_eq(StudioCore.image_ext(PackedByteArray([1, 2, 3])), "", "unknown")


func test_claude_can_withdraw_or_annotate_after_trial() -> void:
	var st := StudioCore.new_state()
	StudioCore.record_gen(st, "part_sac", ["a.png", "b.png"], "p", 0.0, "m", [], "t")
	StudioCore.apply_verdict(st, "part_sac", {"pick": 1, "alt": 2, "note": "n1"}, ["a.png", "b.png"], 3, "t")
	var note := StudioCore.apply_verdict(st, "part_sac", {"note": "装上去偏小，通过后可以调大"}, [], 3, "t")
	check(bool(note.ok), "note update while user reviews")
	check_eq(StudioCore.asset(st, "part_sac").claude_note, "装上去偏小，通过后可以调大", "note replaced")
	var w := StudioCore.apply_verdict(st, "part_sac", {"redo": "试装后发现上色看不出虫族"}, [], 3, "t")
	check(bool(w.ok) and bool(w.from_review), "withdraw from review")
	check_eq(w.to_reject, ["a.png", "b.png"], "pick + alt rejected from 待复审/")
	check_eq(StudioCore.asset(st, "part_sac").status, "claude_redo", "back to redo")
	check_eq(StudioCore.next_round(StudioCore.asset(st, "part_sac")), 2, "next round continues the cycle")


func test_proxy_bypass_for_local_and_no_proxy() -> void:
	check(not StudioCore.should_proxy("127.0.0.1:18080", ""), "loopback never proxied")
	check(not StudioCore.should_proxy("localhost:8080", ""), "localhost never proxied")
	check(not StudioCore.should_proxy("[::1]:8080", ""), "ipv6 loopback never proxied")
	check(StudioCore.should_proxy("api.openai.com", ""), "remote host proxied")
	check(not StudioCore.should_proxy("api.openai.com", "localhost,.openai.com"), "NO_PROXY suffix")
	check(not StudioCore.should_proxy("relay.example.com", "*"), "NO_PROXY *")
	check(StudioCore.should_proxy("notopenai.com", "openai.com"), "suffix must match a label boundary")

