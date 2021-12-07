extends KinematicBody2D

var cellScene = preload("res://Scenes/Snake/Cell.tscn")

var foodScene = preload("res://Scenes/Food/Food.tscn")
var food
var foodPosition
var isFoodSpawned = false

const WIDTH = 160
const HEIGHT = 96

var rng = RandomNumberGenerator.new()

var canMove = true

var tileSize = 8
var up = Vector2(0, -tileSize)
var down = Vector2(0, tileSize)
var left = Vector2(-tileSize, 0)
var right = Vector2(tileSize, 0)

var direction = right

var cellList
var nextPositions = []


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
	
	if canMove and direction:
		move()
		eatFood()
#		colorSnake()
		
		canMove = false
		yield(get_tree().create_timer(0.2), "timeout")
		canMove = true
	
	spawnFood()


func updateNextPositions():
	nextPositions.append(nextPositions[-1] + direction)
	
#	Check if snake passes through walls
	if nextPositions[-1].x < 0:
		nextPositions[-1].x = WIDTH - 8
		
	elif nextPositions[-1].x >= WIDTH:
		nextPositions[-1].x = 0
		
	elif nextPositions[-1].y < 0:
		nextPositions[-1].y = HEIGHT - 8 
		
	elif nextPositions[-1].y >= HEIGHT:
		nextPositions[-1].y = 0
	
#	nextPositions will always be one index bigger than the list of current cells
	if nextPositions.size() > cellList.size() + 1:
		nextPositions.remove(0)


func move():
	var currentPositions = []
	for cell in cellList:
		currentPositions.append(cell.position)
		
	updateNextPositions()
	
	var index = 1
	for cell in cellList:
		cell.position = nextPositions[-index]

		index += 1
	
#	If next head possition is currently in the list of cells, that means that head collided.
#	Has a small bug where the collission is checked before the head is updated

	if currentPositions.has(nextPositions[-1]):
			get_tree().paused = true
			yield(get_tree().create_timer(1.5), "timeout")
			var _scene = get_tree().change_scene("res://Scenes/MainMenu/Menu.tscn")
			get_tree().paused = false


func increaseSize():
	var cell = cellScene.instance()
	cell.add_to_group("snakeBody")
#	Since the nextPositions is one index bigger we can set the new cell to last position in the chain
	cell.position = nextPositions[0]
	self.add_child(cell)
	
#	Update list of cells since new cell was added
	cellList = get_tree().get_nodes_in_group("snakeBody")


func spawnFood():
	if not isFoodSpawned:
		rng.randomize()
		var x = rng.randi_range(0, 19) * 8
		var y = rng.randi_range(0, 11) * 8
		
		foodPosition = Vector2(x, y)
		
		if not nextPositions.has(foodPosition):
			print(foodPosition)
			
			food = foodScene.instance()
			food.position = foodPosition
			
			get_parent().add_child(food)
			
			isFoodSpawned = true


func eatFood():
	if cellList[0].position == foodPosition:
		food.queue_free()
		
		increaseSize()
		isFoodSpawned = false


# Simple function to add a gradient to the snake. Stopped to work for some reason
func colorSnake():
	var color = 1
	for cell in cellList:
		cell.get_node("Sprite").modulate = Color(color, color, color)
		color += 0.2
