extends Area2D


func receive_hit(damage : int, trauma : float):
	$"../../Player".receive_hit(damage, trauma)
