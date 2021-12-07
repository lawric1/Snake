extends KinematicBody2D

var canMove = true

var tileSize = 8
var up = Vector2(0, -tileSize)
var down = Vector2(0, tileSize)
var left = Vector2(-tileSize, 0)
var right = Vector2(tileSize, 0)

var direction = right

var cellList
var nextPositions = []
var nextHeadPosition


func _ready():
	cellList = get_tree().get_nodes_in_group("snakeBody")

	for cell in cellList:
		nextPositions.append(cell.position)
	
func _physics_process(_delta):
	if Input.is_action_pressed("ui_up") and direction != down:
		direction = up
	elif Input.is_action_pressed("ui_down") and direction != up:
		direction = down
	elif Input.is_action_pressed("ui_left") and direction != right:
		direction = left
	elif Input.is_action_pressed("ui_right") and direction != left:
		direction = right
	
	if canMove:
		move()
		
		canMove = false
		yield(get_tree().create_timer(0.2), "timeout")
		canMove = true

func updateNextPositions():
	var screenSize = OS.get_window_size()
	var width = screenSize[0] / 4
	var height = screenSize[1] / 4
	
	nextPositions.append(nextPositions[-1] + direction)
	
	
	if nextPositions[-1].x < 0:
		nextPositions[-1].x = width - 8
		
	if nextPositions[-1].x >= width:
		nextPositions[-1].x = 0
		
	if nextPositions[-1].y < 0:
		nextPositions[-1].y = height - 8
		
	if nextPositions[-1].y >= height:
		nextPositions[-1].y = 0
	
		
	nextPositions.remove(0)
	
	
func move():
	updateNextPositions()
	
	var index = 1
	for cell in cellList:
		cell.position = nextPositions[-index]

		index += 1
	
	
	print(nextPositions[-1])
	
	
