extends Node

signal load_start(loading_screen)	## Triggered when an asset begins loading
signal scene_added(loaded_scene:Node,loading_screen)	## Triggered right after asset is added to SceneTree but before transition animation finishes
signal load_complete(loaded_scene:Node)	## Triggered when loading has completed

signal _content_finished_loading(content)	## internal - triggered when content is loaded and final data handoff and transition out begins
signal _content_invalid(content_path:String)	## internal - triggered when attempting to load invalid content (e.g. an asset does not exist or path is incorrect)
signal _content_failed_to_load(content_path:String)	## internal - triggered when loading has started but failed to complete

var _loading_screen_scene:PackedScene = preload("res://Scenes/LoadingScreen/LoadingScreen.tscn")	## reference to loading screen PackedScene
var _loading_screen:LoadingScreen	## internal - reference to loading screen instance
var _transition:String	## internal - transition being used for current load
var _content_path:String	## internal - stores the path to the asset SceneManager is trying to load
var _load_progress_timer:Timer	## internal - Timer used to check in on load progress
var _load_scene_into:Node	## internal - Node into which we're loading the new scene, defaults to [code]get_tree().root[/code] if left [code]null[/null] 
var _scene_to_unload:Node	## internal - Node we're unloading. In almost all cases, SceneManager will be used to swap between two scenes - after all that it the primary focus. However, passing in [code]null[/code] for the scene to unload will skip the unloading process and simply add the new scene. This isn't recommended, as it can have some adverse affects depending on how it is used, but it does work. Use with caution :)
var _loading_in_progress:bool = false	## internal - used to block SceneManager from attempting to load two things at the same time
var _should_monitor_load_status:bool = false

func swap_scenes(scene_to_load:String, load_into:Node=null, scene_to_unload:Node=null, transition_type:String="fade_to_black") -> void:
	
	if _loading_in_progress:
		push_warning("SceneManager is already loading something")
		return
	
	_loading_in_progress = true
	if load_into == null: load_into = get_tree().root
	_load_scene_into = load_into
	_scene_to_unload = scene_to_unload
	
	_add_loading_screen(transition_type)
	_load_content(scene_to_load)

func _ready() -> void:
	_content_invalid.connect(_on_content_invalid)
	_content_failed_to_load.connect(_on_content_failed_to_load)
	_content_finished_loading.connect(_on_content_finished_loading)

func _process(delta: float) -> void:
	if _should_monitor_load_status:
		_monitor_load_status()

func _add_loading_screen(transition_type:String="fade_to_black"):
	# using "no_in_transition" as the transition name when skipping a transition felt... weird
	# dunno if this solution is better, but it's only one line so I can live with this one-off
	# An alternative would be to store strating animations in a dictionary and swap them for the animation name
	# it removes this one-off, but adds a step elsewhere - all about preference.
	_transition = "no_to_transition" if transition_type == "no_transition" else transition_type
	_loading_screen = _loading_screen_scene.instantiate() as LoadingScreen
	get_tree().root.add_child(_loading_screen)
	_loading_screen.start_transition(_transition)
	
func _load_content(content_path:String) -> void:
	
	load_start.emit(_loading_screen)
		
	_content_path = content_path
	var loader = ResourceLoader.load_threaded_request(content_path, "", true)
	if not ResourceLoader.exists(content_path) or loader == null:
		_content_invalid.emit(content_path)
		return 		
	
	if _load_progress_timer:
		_load_progress_timer.queue_free()
	
	_load_progress_timer = Timer.new()
	_load_progress_timer.wait_time = 0.1
	_load_progress_timer.timeout.connect(_monitor_load_status)
	
	get_tree().root.add_child(_load_progress_timer)
	_load_progress_timer.start()

## internal - checks in on loading status - this can also be done with a while loop, but I found that ran too fast
## and ended up skipping over the loading display. 
func _monitor_load_status() -> void:
	var load_progress = []
	var load_status = ResourceLoader.load_threaded_get_status(_content_path, load_progress)

	match load_status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			if _loading_screen != null:
				_loading_screen.update_bar(load_progress[0] * 100) # 0.1
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			_content_invalid.emit(_content_path)
			_load_progress_timer.stop()
			_should_monitor_load_status = false
			return
		ResourceLoader.THREAD_LOAD_FAILED:
			printerr("error: Failed to load resource: '%s'" % [_content_path])
			_load_progress_timer.stop()
			_should_monitor_load_status = false
			return
		ResourceLoader.THREAD_LOAD_LOADED:
			_load_progress_timer.stop()
			_load_progress_timer.queue_free()
			_content_finished_loading.emit(ResourceLoader.load_threaded_get(_content_path).instantiate())
			_should_monitor_load_status = false
			return # this last return isn't necessary but I like how the 3 dead ends stand out as similar

## internal - fires when content has begun loading but failed to complete
func _on_content_failed_to_load(path:String) -> void:
	printerr("error: Failed to load resource: '%s'" % [path])	

## internal - fires when attemption to load invalid content (e.g. content does not exist or path is incorrect)
func _on_content_invalid(path:String) -> void:
	printerr("error: Cannot load resource: '%s'" % [path])

func _on_content_finished_loading(incoming_scene) -> void:
	var outgoing_scene = _scene_to_unload	# NEW > can't use current_scene anymore
	
	# if our outgoing_scene has data to pass, give it to our incoming_scene
	if outgoing_scene != null:	
		if outgoing_scene.has_method("get_data") and incoming_scene.has_method("receive_data"):
			incoming_scene.receive_data(outgoing_scene.get_data())
	
	# load the incoming into the designated node
	_load_scene_into.add_child(incoming_scene)
		# listen for this if you want to perform tasks on the scene immeidately after adding it to the tree
	# ex: moveing the HUD back up to the top of the stack
	scene_added.emit(incoming_scene,_loading_screen)
	

		# Remove the old scene
	if _scene_to_unload != null and _scene_to_unload.is_inside_tree() and _scene_to_unload != get_tree().root: 
		_scene_to_unload.queue_free()
	
	# called right after scene is added to tree (presuming _ready has fired)
	# ex: do some setup before player gains control (I'm using it to position the player) 
	if incoming_scene.has_method("init_scene"): 
		incoming_scene.init_scene()
	
	# probably not necssary since we split our _content_finished_loading but it won't hurt to have an extra check
	if _loading_screen != null:
		_loading_screen.finish_transition()
		
		# Wait or loading animation to finish
		await _loading_screen.anim_player.animation_finished

	# if your incoming scene implements init_scene() > call it here
	# ex: I'm using it to enable control of the player (they're locked while in transition)
	if incoming_scene.has_method("start_scene"): 
		incoming_scene.start_scene()
	
	# load is complete, free up SceneManager to load something else and report load_complete signal
	_loading_in_progress = false
	load_complete.emit(incoming_scene)
