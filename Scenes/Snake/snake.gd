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
		colorSnake()
		
		canMove = false
		yield(get_tree().create_timer(0.2), "timeout")
		canMove = true
	
	spawnFood()


func updateNextPositions():
	nextPositions.append(nextPositions[-1] + direction)
	
	if nextPositions[-1].x < 0:
		nextPositions[-1].x = WIDTH
		
	elif nextPositions[-1].x >= WIDTH:
		nextPositions[-1].x = 0
		
	elif nextPositions[-1].y < 0:
		nextPositions[-1].y = HEIGHT
		
	elif nextPositions[-1].y >= HEIGHT:
		nextPositions[-1].y = 0
	
	
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

	if currentPositions.has(nextPositions[-1]):
			print('died')
			get_tree().paused = true


func increaseSize():
	var cell = cellScene.instance()
	cell.add_to_group("snakeBody")
	cell.position = nextPositions[0]
	self.add_child(cell)
	
	cellList = get_tree().get_nodes_in_group("snakeBody")


func spawnFood():
	if not isFoodSpawned:
		rng.randomize()
		var x = rng.randi_range(0, 19) * 8
		var y = rng.randi_range(0, 11) * 8
		
		foodPosition = Vector2(x, y)
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


func colorSnake():
	var color = 1
	for cell in cellList:
		cell.get_node("Sprite").modulate = Color(color, color, color)
		color += 0.1
