/datum/action/xeno_action/plant_weeds
	name = "Plant Weeds (75)"
	action_icon_state = "plant_weeds"
	plasma_cost = 75

/datum/action/xeno_action/plant_weeds/action_activate()
	var/mob/living/carbon/Xenomorph/X = owner
	if(!X.check_state()) return

	var/turf/T = X.loc

	if(!istype(T))
		to_chat(X, "<span class='warning'>You can't do that here.</span>")
		return

	if(!T.is_weedable())
		to_chat(X, "<span class='warning'>Bad place for a garden!</span>")
		return

	if(locate(/obj/effect/alien/weeds/node) in T)
		to_chat(X, "<span class='warning'>There's a pod here already!</span>")
		return

	if(X.check_plasma(75))
		X.use_plasma(75)
		X.visible_message("<span class='xenonotice'>\The [X] regurgitates a pulsating node and plants it on the ground!</span>", \
		"<span class='xenonotice'>You regurgitate a pulsating node and plant it on the ground!</span>", null, 5)
		new /obj/effect/alien/weeds/node(X.loc, src, X)
		playsound(X.loc, "alien_resin_build", 25)

/datum/action/xeno_action/plant_spawner
	name = "Plant Colony (500)"
	action_icon_state = "dug_spawner"
	plasma_cost = 500

/datum/action/xeno_action/plant_spawner/action_activate()
	var/mob/living/carbon/Xenomorph/X = owner
	if(!X.check_state()) return

	var/turf/T = X.loc

	if(!istype(T) || X.z == 3 || istype(T, /turf/open/floor/plating/almayer))
		to_chat(X, "<span class='warning'>You can't do that here.</span>")
		return

	var/obj/structure/alien_spawner/SPW = locate() in view(25)
	if(SPW)
		to_chat(X, "<span class='warning'>There is tunnel nearby!</span>")
		return

	if(!T.is_weedable())
		to_chat(X, "<span class='warning'>Bad place for a colony!</span>")
		return

	if(locate(/obj/effect/alien/weeds) in T)
		X.use_plasma(500)
		X.visible_message("<span class='xenonotice'>\The [X] dug a tunnel on the ground!</span>", \
		"<span class='xenonotice'>You dug a tunnel on the ground!</span>", null, 5)
		new /obj/structure/alien_spawner(X.loc)
		return
	else
		to_chat(X, "<span class='warning'>We can dig a tunnel only in weed's presense!</span>")
		return

// Choose Resin
/datum/action/xeno_action/choose_resin
	name = "Choose Resin Structure"
	action_icon_state = "resin wall"
	plasma_cost = 0

/datum/action/xeno_action/choose_resin/action_activate()
	var/mob/living/carbon/Xenomorph/X = owner
	if(!X.check_state())
		return
	switch(X.selected_resin)
		if("resin door")
			X.selected_resin = "resin wall"
		if("resin wall")
			X.selected_resin = "resin nest"
		if("resin nest")
			X.selected_resin = "sticky resin"
		if("sticky resin")
			X.selected_resin = "resin door"
		else
			return //something went wrong

	to_chat(X, "<span class='notice'>You will now build <b>[X.selected_resin]\s</b> when secreting resin.</span>")
	//update the button's overlay with new choice
	button.overlays.Cut()
	button.overlays += image('icons/mob/actions.dmi', button, X.selected_resin)


// Secrete Resin
/datum/action/xeno_action/activable/secrete_resin
	name = "Secrete Resin (75)"
	action_icon_state = "secrete_resin"
	ability_name = "secrete resin"
	var/resin_plasma_cost = 75

/datum/action/xeno_action/activable/secrete_resin/use_ability(atom/A)
	var/mob/living/carbon/Xenomorph/X = owner
	X.build_resin(A, resin_plasma_cost)

/datum/action/xeno_action/activable/corrosive_acid/drone
	name = "Corrosive Acid (75)"
	acid_plasma_cost = 75
	acid_type = /obj/effect/xenomorph/acid/weak

/datum/action/xeno_action/activable/transfer_plasma
	name = "Transfer Plasma"
	action_icon_state = "transfer_plasma"
	ability_name = "transfer plasma"
	var/plasma_transfer_amount = 50
	var/transfer_delay = 20
	var/max_range = 2

/datum/action/xeno_action/activable/transfer_plasma/use_ability(atom/A)
	var/mob/living/carbon/Xenomorph/X = owner
	X.xeno_transfer_plasma(A, plasma_transfer_amount, transfer_delay, max_range)