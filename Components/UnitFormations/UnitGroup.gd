extends Node2D
class_name UnitGroup

# From previous work, unitGroups need access to pathfinding, these handle the high level group movement
# Formations also need to set state/behaviour.
# If not currently attacking, 
#	Move towards highest priority control point
# 	Need logic for switching from move to attack, and from attack to move
# 		Calculate priority of attack for each unit.
#			Base on distance to each priority + 
#			player's progress through the level + 
#			
#		Each unit in a formation should pay attention to locations of other units in the formation.
#			Get nearest node to i.
#			If node is in front of i relative to i's desired path:
#				i should slow down
#			else:
#				i should angle vel this frame slightly to one side.

onready var units = []
onready var num_units = 0
onready var next_priority = 0

		
enum {
	BROKEN,
	FORMING,
	FORMED,
}

onready var meta_state = BROKEN
onready var group_state = GLOBAL.IDLE

export (bool) var friendly = false

onready var target = null
	
func add_unit(u : NodePath):
	if not u in units:
		var n : Unit = get_node(u)
		n.priority = next_priority
		next_priority += 1
		units.push_back(u)
		
func _physics_process(delta):
	
	match(group_state):
		GLOBAL.IDLE:
	# if the group_state is idle, then check meta_state.
	# 	if meta_state is broken, define unit form_up positions. Set meta_state == forming
	#	If meta_state is forming, move units along path towards form_up spots
	#	If meta_state is formed, then your state is able to change again. level_manager can update you.
			pass
		GLOBAL.RUN:
	# If state is move, then units will generate paths to the end point.
	#	when units reach the end point, they send a signal to the formation, which tells them where they should be 
	#	in the area around them.This is based on priority. lowest priority is nearest the point, 
	#	highest priority is on exterior of point
	#	Once location is reached, do a quick attack check.
			pass
		GLOBAL.CHASE:
	# If state is attack: 
	# 	Determine nearest unit based on priority.
	#		Units that are being attacked already are higher than those that are not being attacked at all
	#		Units with more than 4 targets get significantly lower priority
	#		Units with low relative health get higher priority than full
	#		Units that are near > Units that are far
	# 	Once target is determined, Set unit's target + unit's state to Chase
	#		Turn off 
			pass
			
			
	# I could also just give units a leadership value which represents how many units will come with them
	#	Then you can pick a single unit, send it over, and the game will automatically give a few other units the same command.
	#	Enemy units can have a similar structure, where there are LEADER units and FOLLOWER units.
	#		Follower units will follow their leader, but if an unfriendly leader is nearby & their morale breaks they may just follow the other one.
	#	In this case, follower units will advance behind their leader
	#		When leader says "start fighting", they all start fighting.
	
	# Outside of combat, player defines their leader units and followers for each leader.
	#	Inside combat, player can issue commands to a leader by pressing a keys to select group/action, then clicking
	# to determine behaviour.
	pass
