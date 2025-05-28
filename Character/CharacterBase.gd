extends CharacterBody3D

@export var max_health: int = 100
var current_health: int = 100

func take_damage(amount: int):
	current_health -= amount
	print("Ouch! HP: ", current_health)
	if current_health <= 0:
		die()

func die():
	print("RIP monkey :(")
	queue_free()
