extends RefCounted
## Test-only setup for model, presentation and history tests.
## Real input/location authorization is covered by operations_integration.gd.
static func edit(game, action: String, slot: int, kind: String) -> Dictionary:
	var result: Dictionary = game.session.edit(action, slot, kind, game.player.pose())
	if result.has("error"):
		push_error("UI fixture edit failed: %s / %d / %s / %s" % [action,slot,kind,result.error])
		game.get_tree().quit(1)
		return result
	game.station.sync_facilities(result.state)
	game._refresh()
	return result

static func cancel_draft(game) -> void:
	game.session.cancel_draft()
	game.station.sync_facilities(game.session.preview().state)
	game.terminal.clear_notice()
	game._refresh()
