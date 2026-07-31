extends Node2D

var turrent = null
var occupied = false

var initial_switch:bool = false
var can_distract:bool = false

var health:int = 100
var self_damage:int = 10

@onready var ice_cream = $ice_cream

@onready var melt_timer = $melt_timer
@onready var melt_bar = $melt_bar

@onready var distract_area = $Distract_area

func disable_all_switch_areas():
	for child in get_children():
		if child is Area2D and (child.name!='check' and child.name!='Distract_area' and child.name!="ice_cream_area"):
			child.monitoring = false
			child.monitorable=false
			
func enable_all_switch_areas():
	if !initial_switch: 
		initial_switch = true
		melt_timer.start()
		can_distract = true #on placing loop, this function is called so can_distract is made true
		for area in distract_area.get_overlapping_areas():
			if area.is_in_group("distractable"):
				var parent = area.get_parent()
				parent.get_distracted(position)

	for child in get_children():
		if child is Area2D and (child.name!='check' and child.name!='Distract_area' and child.name!="ice_cream_area"):
			child.set_deferred("monitoring", true)
			child.set_deferred("monitorable", true)

#i am not even sure how the fuck this is even working
#i am startint to think this doesn't do anything but am too scared to remove it
func _on_check_area_entered(area):
	occupied = true

func _on_check_area_exited(area):
	occupied = false

func recieve_damage(hitpoints):
	health = max(0,health-hitpoints)
	melt_bar.value = health
	match health:
		20:ice_cream.frame=3
		40:ice_cream.frame = 2
		80:ice_cream.frame = 1
	if health<=0:
		if can_distract:
			ice_cream.frame = 4
			can_distract = false
			melt_timer.stop()
			stop_distraction()

func _on_distract_area_area_entered(area):
	if area.is_in_group("distractable") and can_distract:
		var parent = area.get_parent()
		parent.get_distracted(position)

func stop_distraction():
	for area in distract_area.get_overlapping_areas():
		if area.is_in_group("distractable"):
			var parent = area.get_parent()
			parent.stop_distraction()

func _on_melt_timer_timeout():
	recieve_damage(self_damage)
	melt_timer.start()
