extends Control

const MAIN_SCENE = "res://main.tscn"

@onready var start_btn: Button = $VBoxContainer/StartButton
@onready var settings_btn: Button = $VBoxContainer/SettingsButton
@onready var exit_btn: Button = $VBoxContainer/ExitButton
@onready var settings_panel: Control = $SettingsPanel
@onready var cursor_blink: Timer = $CursorBlinkTimer

# Settings controls
@onready var music_slider: HSlider = $SettingsPanel/PanelBG/SettingsVBox/MusicRow/MusicSlider
@onready var sfx_slider: HSlider = $SettingsPanel/PanelBG/SettingsVBox/SFXRow/SFXSlider
@onready var fullscreen_btn: Button = $SettingsPanel/PanelBG/SettingsVBox/FullscreenRow/FullscreenToggle
@onready var music_val: Label = $SettingsPanel/PanelBG/SettingsVBox/MusicRow/MusicVal
@onready var sfx_val: Label = $SettingsPanel/PanelBG/SettingsVBox/SFXRow/SFXVal

var selected_index: int = 0
var menu_items: Array = []
var blink_visible: bool = true

# Audio bus indices
var music_bus := AudioServer.get_bus_index("Music")
var sfx_bus := AudioServer.get_bus_index("SFX")

func _ready() -> void:
	menu_items = [start_btn, settings_btn, exit_btn]
	settings_panel.hide()
	_update_selection()
	cursor_blink.start()
	_load_settings()

func _input(event: InputEvent) -> void:
	if settings_panel.visible:
		if event.is_action_pressed("ui_cancel"):
			settings_panel.hide()
		return
	if event.is_action_pressed("ui_down"):
		selected_index = (selected_index + 1) % menu_items.size()
		_update_selection()
	elif event.is_action_pressed("ui_up"):
		selected_index = (selected_index - 1 + menu_items.size()) % menu_items.size()
		_update_selection()
	elif event.is_action_pressed("ui_accept"):
		menu_items[selected_index].emit_signal("pressed")

func _update_selection() -> void:
	for i in range(menu_items.size()):
		if i == selected_index:
			menu_items[i].add_theme_color_override("font_color", Color(1, 0.878, 0.2))
		else:
			menu_items[i].remove_theme_color_override("font_color")

# ── Button callbacks ──────────────────────────────────────────

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_SCENE)

func _on_settings_button_pressed() -> void:
	settings_panel.show()

func _on_exit_button_pressed() -> void:
	get_tree().quit()

func _on_close_button_pressed() -> void:
	settings_panel.hide()

# ── Cursor blink ──────────────────────────────────────────────

func _on_cursor_blink_timer_timeout() -> void:
	blink_visible = !blink_visible
	for i in range(menu_items.size()):
		if i == selected_index:
			if blink_visible:
				menu_items[i].text = "> " + _base_label(i) + " <"
			else:
				menu_items[i].text = "  " + _base_label(i) + "  "

func _base_label(index: int) -> String:
	match index:
		0: return "START GAME"
		1: return "SETTINGS"
		2: return "EXIT"
	return ""

# ── Settings ──────────────────────────────────────────────────

func _load_settings() -> void:
	# Load saved values or use defaults
	var music_vol = 8.0
	var sfx_vol = 8.0
	var is_fullscreen = false

	if FileAccess.file_exists("user://settings.cfg"):
		var file = FileAccess.open("user://settings.cfg", FileAccess.READ)
		music_vol = file.get_float()
		sfx_vol = file.get_float()
		is_fullscreen = file.get_8() == 1
		file.close()

	music_slider.value = music_vol
	sfx_slider.value = sfx_vol
	music_val.text = str(int(music_vol))
	sfx_val.text = str(int(sfx_vol))
	_apply_music_volume(music_vol)
	_apply_sfx_volume(sfx_vol)

	if is_fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		fullscreen_btn.text = "ON"
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		fullscreen_btn.text = "OFF"

func _save_settings() -> void:
	var file = FileAccess.open("user://settings.cfg", FileAccess.WRITE)
	file.store_float(music_slider.value)
	file.store_float(sfx_slider.value)
	file.store_8(1 if fullscreen_btn.text == "ON" else 0)
	file.close()

func _apply_music_volume(value: float) -> void:
	if music_bus >= 0:
		if value == 0:
			AudioServer.set_bus_mute(music_bus, true)
		else:
			AudioServer.set_bus_mute(music_bus, false)
			AudioServer.set_bus_volume_db(music_bus, linear_to_db(value / 10.0))

func _apply_sfx_volume(value: float) -> void:
	if sfx_bus >= 0:
		if value == 0:
			AudioServer.set_bus_mute(sfx_bus, true)
		else:
			AudioServer.set_bus_mute(sfx_bus, false)
			AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(value / 10.0))

func _on_music_slider_value_changed(value: float) -> void:
	music_val.text = str(int(value))
	_apply_music_volume(value)
	_save_settings()

func _on_sfx_slider_value_changed(value: float) -> void:
	sfx_val.text = str(int(value))
	_apply_sfx_volume(value)
	_save_settings()

func _on_fullscreen_toggle_pressed() -> void:
	if fullscreen_btn.text == "OFF":
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		fullscreen_btn.text = "ON"
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		fullscreen_btn.text = "OFF"
	_save_settings()
