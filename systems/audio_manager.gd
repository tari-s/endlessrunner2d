extends Node
class_name AudioManager

# ============================================================================
# EXPORTS
# ============================================================================

@export var game_over_sound: AudioStream
@export var multiplier_sound: AudioStream
@export var jet_engine_sound: AudioStream

# ============================================================================
# PRIVATE VARIABLES
# ============================================================================

var _sfx_player: AudioStreamPlayer
var _engine_player: AudioStreamPlayer

# ============================================================================
# LIFECYCLE METHODS
# ============================================================================

func _ready():
	# Setup SFX Player
	_sfx_player = AudioStreamPlayer.new()
	add_child(_sfx_player)
	
	# Setup Jet Engine Player
	_engine_player = AudioStreamPlayer.new()
	add_child(_engine_player)
	if jet_engine_sound:
		_engine_player.stream = jet_engine_sound
		if _engine_player.stream is AudioStreamMP3:
			_engine_player.stream.loop = true

# ============================================================================
# PUBLIC API - Sound Effects
# ============================================================================

func play_sfx(sound: AudioStream):
	if sound and _sfx_player:
		_sfx_player.stream = sound
		_sfx_player.play()

func play_game_over():
	play_sfx(game_over_sound)

func play_multiplier():
	play_sfx(multiplier_sound)

# ============================================================================
# PUBLIC API - Engine Sound
# ============================================================================

func start_engine():
	if _engine_player and jet_engine_sound:
		if not _engine_player.playing:
			_engine_player.play()

func stop_engine():
	if _engine_player:
		_engine_player.stop()
