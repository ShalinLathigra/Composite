extends Area2D


func receive_hit(damage : int, trauma : float):
	$"../../player".receive_hit(damage, trauma)
