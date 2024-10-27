extends Node2D

var enemy01 = preload("res://scenes/characters/enemy_01.tscn")

var rng = RandomNumberGenerator.new()
@export var levelSize = 0
var levelArray : Array = [preload("res://scenes/level/shop.tscn"),
						preload("res://scenes/level/stage_1.tscn"),
						preload("res://scenes/level/stage_2.tscn"),
						preload("res://scenes/level/stage_3.tscn")]
var checkpoint : Object = preload("res://scenes/level/checkpoint.tscn")

var levelCordinates : Dictionary = {0 : Vector2(200, 0), 
						1 : Vector2(264, 0),
						2 : Vector2(168, -48),
						3 : Vector2(232, 0)}

var levelResult : Array
var levelResultCord : Array
var levelSpawned : bool = false
var spawnposition : Vector2 = Vector2(496,0)

var total_tries : int = 5

func _ready():
	var lastLevel = null
	
	if levelSize <= 0:
		print("ERROR : LEVEL SIZE IS TOO SMALL")
		print("SETTING LEVEL SIZE TO 6")
		levelSize = 6
	
	for level in levelSize:
		
		var randLevel : int = _randomLevel(levelArray)
		
		#stops duplication
		if (randLevel == lastLevel):
			randLevel += 1
			if (randLevel >= levelArray.size()):
				randLevel -= 2
		
		#addlevel to lastlevel to avoid duplication
		lastLevel = randLevel
		
		levelResult.append(randLevel)
		
	
	print(levelResult)
	

func _process(delta):
	$Tries.text = str(total_tries)
	$Label2.text = str(levelResult)

func _spawnLevel(level : Object, cordinates : Vector2):
	var instance : Object = level.instantiate()
	instance.position = cordinates
	add_child(instance)
	var enemy : Object = enemy01.instantiate()
	enemy.position = cordinates
	add_sibling(enemy)

func _addCordinates(cordinates: Vector2):
	spawnposition += cordinates

func _randomLevel(levelList : Array) -> int:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	return (rng.randi_range(1, levelList.size())) - 1


func _on__pressed00():
	changeLevel(0)

func _on__pressed01():
	changeLevel(1)

func _on__pressed02():
	changeLevel(2)

func _on__pressed03():
	changeLevel(3)

func _on__pressed04():
	changeLevel(4)

func changeLevel(i : int):
	if not total_tries <= 0:
		total_tries -= 1
		var new_level = _randomLevel(levelArray)
		levelResult[i] = new_level
	
	print(levelResult)

func _on_button_pressed():
	if levelSpawned == false:
		levelSpawned = true
		
		for level in levelResult:
			_spawnLevel(levelArray[level], spawnposition)
			
			for cord in levelCordinates:
				if (level == cord):
					_addCordinates(levelCordinates[cord])
			
		
