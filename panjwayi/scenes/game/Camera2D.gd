extends Camera2D

var fixed_toggle_point = Vector2(0,0)

var currently_moving_map = false

const MIN = Vector2(-64, -64)
const MAX = Vector2(64, 64*9)

func _process(delta):
    if Input.is_mouse_button_pressed(BUTTON_MIDDLE):
        # This happens once 'move_map' is pressed
        if( !currently_moving_map ):
            var ref = get_viewport().get_mouse_position()
            fixed_toggle_point = ref
            currently_moving_map = true
        # This happens while 'move_map' is pressed
        move_map_around()
    else:
        currently_moving_map = false

func _input(event):
	if Input.is_action_just_pressed("ui_zoom_out"):
		zoom *= 0.95
	if Input.is_action_just_pressed("ui_zoom_in"):
		zoom *= 1.05
	zoom.x = clamp(zoom.x, 0.75, 1.5)
	zoom.y = clamp(zoom.y, 0.75, 1.5)
	
# moves the map around just like in the editor
func move_map_around():
	var ref = get_viewport().get_mouse_position()
	self.global_position.x -= (ref.x - fixed_toggle_point.x)
	self.global_position.y -= (ref.y - fixed_toggle_point.y)
	self.global_position.x = clamp(self.global_position.x, MIN.x, MAX.x)
	self.global_position.y = clamp(self.global_position.y, MIN.y, MAX.y)
	fixed_toggle_point = ref
