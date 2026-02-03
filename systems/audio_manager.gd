extends Node
class_name AudioManager

# Audio Resources
@export var game_over_sound: AudioStream
@export var multiplier_sound: AudioStream
@export var jet_engine_sound: AudioStream

# Audio Players
var sfx_player: AudioStreamPlayer
var engine_player: AudioStreamPlayer

func _ready():
	# Setup SFX Player
	sfx_player = AudioStreamPlayer.new()
	add_child(sfx_player)
	
	# Setup Jet Engine Player
	engine_player = AudioStreamPlayer.new()
	add_child(engine_player)
	if jet_engine_sound:
		engine_player.stream = jet_engine_sound
		if engine_player.stream is AudioStreamMP3:
			engine_player.stream.loop = true

func play_sfx(sound: AudioStream):
	if sound and sfx_player:
		sfx_player.stream = sound
		sfx_player.play()

func play_game_over():
	play_sfx(game_over_sound)

func play_multiplier():
	play_sfx(multiplier_sound)

func start_engine():
	if engine_player and jet_engine_sound:
		if not engine_player.playing:
			engine_player.play()

func stop_engine():
	if engine_player:
		engine_player.stop()
