extends Node
## Monta uma tela (720x1280) num SubViewport e salva a foto.  Args: --tela=<nome> --foto=<arquivo.png>
func _ready() -> void:
	var tela := "tela-inicial"; var foto := ""
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--tela="): tela = a.trim_prefix("--tela=")
		if a.begins_with("--foto="): foto = a.trim_prefix("--foto=")
	var c := SubViewportContainer.new(); c.stretch = false; c.size = Vector2(720, 1280); c.scale = Vector2(0.5, 0.5); add_child(c)
	var vp := SubViewport.new(); vp.size = Vector2i(720, 1280); vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS; c.add_child(vp)
	var t: Control = load("res://telas.gd").new(); t.size = Vector2(720, 1280); t.set("qual", tela); vp.add_child(t)
	await get_tree().create_timer(2.6).timeout
	await RenderingServer.frame_post_draw
	if foto != "": vp.get_texture().get_image().save_png(foto); get_tree().quit()
