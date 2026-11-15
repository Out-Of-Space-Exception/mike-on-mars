extends Node
## Builds a screen (720x1280) in a SubViewport and saves the photo.  Args: --tela=<name> --foto=<file.png>
func _ready() -> void:
	var screen_name := "tela-inicial"; var photo := ""
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--tela="): screen_name = a.trim_prefix("--tela=")
		if a.begins_with("--foto="): photo = a.trim_prefix("--foto=")
	var c := SubViewportContainer.new(); c.stretch = false; c.size = Vector2(720, 1280); c.scale = Vector2(0.5, 0.5); add_child(c)
	var vp := SubViewport.new(); vp.size = Vector2i(720, 1280); vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS; c.add_child(vp)
	var t: Control = load("res://telas.gd").new(); t.size = Vector2(720, 1280); t.set("screen_name", screen_name); vp.add_child(t)
	await get_tree().create_timer(2.6).timeout
	await RenderingServer.frame_post_draw
	if photo != "": vp.get_texture().get_image().save_png(photo); get_tree().quit()
