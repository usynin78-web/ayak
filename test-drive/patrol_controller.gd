extends Node

@export var cube: CharacterBody2D

@export var points: Array[Marker2D]

var current := 0


func _ready():

 cube.move_to(points[0].global_position)


func _process(_delta):

 if cube.navigation.is_navigation_finished():

  current += 1

  if current >= points.size():
   current = 0

  print("Следующая точка:", current)

  cube.move_to(points[current].global_position)
