class_name Main extends Control

@onready var button: Button = $Button
@onready var label_mode: Label = $LabelMode
@onready var timer_pause: Timer = $TimerPause
@onready var timer_work: Timer = $TimerWork
@onready var label_pause: Label = $LabelPause
@onready var label_work: Label = $LabelWork
@onready var time_left: Label = $TimeLeft
@onready var audio_slider: HSlider = $AudioSlider
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var pause: LineEdit = $Pause
@onready var work: LineEdit = $Work


@export var pause_time : int 
@export var work_time : int
@export var mode = "Work"

# program start
func _ready() -> void:
	load_settings()
	timer_work.wait_time = 60
	timer_pause.wait_time = 60
	label_mode.text = "Mode: %s" %mode
	
	
	
	label_visibility(true, false)

# main loop
func _physics_process(_delta: float) -> void:
	label_mode.text = "Mode: %s" %mode
	display_time_left()
	audio_stream_player.volume_db = audio_slider.value


# save
func save_settings():
	var save_game = ConfigFile.new()
	save_game.set_value("Settings", "work_time", work.text)
	save_game.set_value("Settings", "pause_time", pause.text)
	save_game.set_value("Settings", "audio", audio_stream_player.volume_db)
	save_game.save("user://save.cfg")
	print("saved")

# load
func load_settings():
	print("Loaded")
	var save_game = ConfigFile.new()
	var result = save_game.load("user://save.cfg")
	
	if result == OK:
		work.text = save_game.get_value("Settings", "work_time", work.text)
		pause.text = save_game.get_value("Settings", "pause_time", pause.text)
		audio_slider.value = save_game.get_value("Settings", "audio", audio_stream_player.volume_db)
	else:
		print("error")


# shows how much time is left
func display_time_left():
	var work_time_left = timer_work.time_left
	var pause_time_left = timer_pause.time_left
	
	var work_seconds = int(work_time_left)
	var pause_seconds = int(pause_time_left) 
	
	var work_minutes = work_seconds / 60
	var pause_minutes = pause_seconds / 60
	
	var work_hours = work_minutes / 60
	var pause_hours = pause_minutes / 60
	
	if mode == "Work":
		time_left.text =  str(work_hours) + ":" + str(work_minutes % 60) + ":" + str(work_seconds % 60 )
	else:
		time_left.text =  str(pause_hours) + ":" + str(pause_minutes % 60) + ":" + str(pause_seconds % 60 )
	
	
# start timer	
func start_timer():		
	pause_time = int(pause.text) * 60
	work_time = int(work.text) * 60
	
	timer_work.wait_time = work_time
	timer_pause.wait_time = pause_time
	button.text = "X"
	
	if mode == "Work":
		timer_work.start()
	else:
		timer_pause.start()
	
	
# stop timer		
func stop_timer():
	timer_pause.stop()
	timer_work.stop()
	button.text = "Go"
	
	
# on button press either run or stop the timer
func _on_button_pressed() -> void:
	save_settings()
	if button.text == "Go":
		label_visibility(false, true)	
		start_timer()		
	else:	
		label_visibility(true, false)	
		stop_timer()


# set visibility
func label_visibility(boolean, boolean2):
	#label visibility
	label_pause.visible = boolean
	label_work.visible = boolean
	
	#input box visibility 
	pause.visible = boolean
	work.visible = boolean
	
	#timer visibility 
	time_left.visible = boolean2


# work mode timer
func _on_timer_work_timeout() -> void:
	mode = "Pause"
	timer_pause.start()
	audio_stream_player.play()
	
#pause mode timer
func _on_timer_pause_timeout() -> void:
	mode = "Work"
	timer_work.start()
