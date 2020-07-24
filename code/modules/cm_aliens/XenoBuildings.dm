/obj/structure/alien
	name = "alien building"
	desc = "Building that's alien"
	icon = 'icons/Xeno/Buildings.dmi'
	icon_state = "sunken"
	density = TRUE
	pixel_x = -16

	var/xeno_tag = null				//see misc.dm

	var/health = 500
	var/maxHealth = 500

	var/dying = 0
	var/last_heal = 0
	var/heal = 40

/obj/structure/alien/New()
	. = ..()
	processing_objects.Add(src)
	if(xeno_tag)
		var/datum/hive_status/hive = hive_datum[XENO_HIVE_NORMAL]
		hive.xeno_buildings[xeno_tag]++

/obj/structure/alien/Dispose()
	. = ..()
	processing_objects.Remove(src)
	if(xeno_tag)
		var/datum/hive_status/hive = hive_datum[XENO_HIVE_NORMAL]
		hive.xeno_buildings[xeno_tag]--

/obj/structure/alien/process()
	if(dying)
		if(locate(/obj/effect/alien/weeds) in src.loc)
			dying = 0
		health = max(0, health-25)
		if(health <= 0)
			die()
			return 0
	if(health > maxHealth)
		health = maxHealth
	if(!(locate(/obj/effect/alien/weeds) in src.loc))
		dying = 1

	update_icon()

	if(world.time >= last_heal + heal && health < maxHealth && !dying)
		health += 5						//slowly regenerate on weed
		last_heal = world.time
	return 1

/obj/structure/alien/ex_act(severity)
	switch(severity)
		if(1)
			die()
		if(2,3)
			health -= rand(200 * (4-severity))
			healthcheck()

/obj/structure/alien/bullet_act(obj/item/projectile/P)
	health -= max(0, P.damage)
	bullet_ping(P)
	healthcheck()

/obj/structure/alien/proc/healthcheck()
	if(health <= 0)
		die()
		return
	if(health>=maxHealth)
		health = maxHealth

/obj/structure/alien/proc/die()
	visible_message("<span class='xenodanger'>[src] explodes into bloody gore!</span>")
	xgibs(src.loc)
	destroy()

//Sunken Colony
/obj/structure/alien/sunken
	name = "Sunken Colony"
	desc = "A living stationary organism that strikes from below with its powerful claw."
	pixel_y = -8

	var/last_strike = 0

	xeno_tag = SUNKEN_COLONY

/obj/structure/alien/sunken/update_icon()
	if(health <= maxHealth/2)
		icon_state = "s_weak"
	else
		icon_state = "sunken"

/obj/structure/alien/sunken/process()
	. = ..()
	if(!.)
		return

	if(last_strike + 20 > world.time)
		return

	var/turf/target = get_target()
	strike(target)

/obj/structure/alien/sunken/proc/get_target()
	var/list/targets = list()

	for(var/atom/targ in orange(7, src))
		if(istype(get_turf(targ), /turf/open/shuttle))
			continue
		if(ishuman(targ))
			var/mob/living/carbon/human/H = targ
			if(locate(/obj/item/alien_embryo) in H)
				continue
			if(!H.stat)
				targets += get_turf(H)
		else if(isVehicle(targ))
			if(isMech(targ))
				targets += get_turf(targ)
			else if(isTank(targ))
				var/obj/vehicle/multitile/hitbox/cm_armored/Tank = targ
				if(Tank.root.health == 0)
					continue
				targets += get_turf(targ)

	return pick(targets)

/obj/structure/alien/sunken/proc/strike(turf/target)
	if(!istype(target))
		return 0
	if(!target)
		return 0

	visible_message("<span class='xenodanger'>[src] is about to strike!</span>")
	flick("s_hitting",src)

	var/obj/effect/impaler/I = rnew(/obj/effect/impaler, target)
	sleep(10)
	I.strike()
	sleep(5)
	cdel(I)

	return 1

/obj/effect/impaler
	name = "impaling chitin"
	icon = 'icons/Xeno/Buildings.dmi'
	icon_state = "s_incoming"
	var/damage = 120

/obj/effect/impaler/proc/strike()
	icon_state = "strike"
	for(var/mob/living/carbon/L in src.loc)
		to_chat(L, "<span class='danger'>You've been hit by [src] from below!</span>")
		var/datum/limb/affecting = L.get_limb(pick("r_leg", "l_leg"))
		var/armor_block = L.run_armor_check(affecting, "melee")
		L.apply_damage(damage, BRUTE, affecting, armor_block) //This should slicey dicey
		L.updatehealth()

	playsound(loc, "alien_bite", 25, 1)

	var/obj/vehicle/V = locate(/obj/vehicle) in src.loc
	if(V)									//Good against slow-moving targets
		if(isTank(V))
			var/obj/vehicle/multitile/hitbox/cm_armored/Tank = V
			var/obj/vehicle/multitile/root/cm_armored/ROOT = Tank.root
			ROOT.take_damage_type(damage, "abstract")
		if(isMech(V))
			var/obj/vehicle/walker/W = V
			W.take_damage(damage, "abstract")


//Healer
/obj/structure/alien/healer
	name = "Wither Flower"
	desc = "A disgusting biological horror, humming with eerie sound."
	icon_state = "healer"
	health = 250
	maxHealth = 250
	xeno_tag = WITHER_FLOWER
	pixel_x = 0

	var/last_message = 0

/obj/structure/alien/healer/New()
	. = ..()
	SetLuminosity(2)

/obj/structure/alien/healer/Dispose()
	. = ..()
	SetLuminosity(0)

/obj/structure/alien/healer/process()
	. = ..()
	if(!.)
		return
	if(last_message + 40 > world.time)
		return

	last_message = world.time

	for(var/mob/living/L in range(1, src))
		if(isXeno(L))
			var/mob/living/carbon/Xenomorph/X = L
			to_chat(X, "<span class='xenonotice'>You feel soothing light mending your wounds...</span>")
			//I'm deeply sorry
			X.adjustBruteLoss(-25)
			X.adjustFireLoss(-25)
			X.adjustOxyLoss(-25)
			X.adjustToxLoss(-25)
			X.updatehealth()
		else if(ishuman(L))					//hazardous
			var/mob/living/carbon/human/H = L
			to_chat(H, "<span class='danger'>[src]'s light hurts!</span>")
			H.adjustFireLoss(25)