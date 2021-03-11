extends Node2D

onready var active : bool = true

var selected : Unit = null
var source_list : UnitList = null

onready var leads = [
	$Lead1,
	$Lead2,
	$Lead3,
	]

func _ready():
	get_node(GLOBAL.player).global_position = $Player.global_position
	for lead in leads:
		lead.connect_select_func(self, "select_func")
		lead.connect_drop_func(self, "drop_func")
		lead.set_active(true)
		
	$SpareList.connect_select_func(self, "select_func")
	$SpareList.connect_drop_func(self, "drop_func")
	$SpareList.set_active(true)
	
	populate_lists_from_PlayerData()
	
func set_active(a):
	active = a
	visible = active
	$StartButton.disabled = !active
	GLOBAL.time_factor = 0.0
	
	if (a):
		for lead in leads:
			lead.update_list()
		$SpareList.update_list()
	
func populate_lists_from_PlayerData():
	var spares = PlayerData.spare_units
	$SpareList.set_unit_array(spares)
	$SpareList.update_list()
	var i = 0
	for lead in PlayerData.leaders:
		var target = leads[i]
		target.populate_with(lead)
		i += 1
		target.update_list()
	
func _process(delta):
	if (selected):
		selected.global_position = get_global_mouse_position()

func select_func(source : UnitList, u : Unit):
	var t = selected
	if (selected in get_children()):
		remove_child(selected)
	if (t):
		source.add_unit(t) 
	selected = null
	source_list = null
	
	if(u):
		selected = u
		source_list = source
		add_child(selected)

func drop_func(source : UnitList):
	if (selected and source):
		if not source.is_full():
			remove_child(selected)
			source.add_unit(selected)
			source.update_list()
			selected = null
			source_list = null
			return

# PLAY LEVEL
func _on_StartButton_pressed():
	var p_followers = []
	for lead in leads:
		if (lead.is_full()):
			lead.remove_child(lead.unit_list[0])
			var l_node = lead.unit_list[0]
			var l_followers = lead.get_followers()
			for follower in l_followers:
				lead.get_node("UnitList2").remove_child(follower)
			l_node.set_followers(l_followers)
			p_followers.push_back(l_node)
	PlayerData.leaders = p_followers
	PlayerData.set_leads_spawn_positions()
	get_node(GLOBAL.world).advance_stage()
