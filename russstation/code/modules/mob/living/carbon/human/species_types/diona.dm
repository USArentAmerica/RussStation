/datum/species/diona
	// An amalgamation of a number of diona nymphs becomes a gestalt that appears similar to other bipedal organics
	name = "Diona"
	id = "diona"
	sexes = 0
	species_traits = list(NOBLOOD, NOEYESPRITES, NO_UNDERWEAR)
	inherent_traits = list(
		TRAIT_NOBREATH,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTLOWPRESSURE,
	)
	mutant_bodyparts = list("diona_hair" = "diona_bracket")
	damage_overlay_type = "" // dionas don't have blood
	burnmod = 1.5 // take more damage from lasers
	heatmod = 2 // take more damage from fire
	speedmod = 5 // very slow
	meat = /obj/item/food/meat/slab/human/mutant/plant
	disliked_food = MEAT | DAIRY
	liked_food = VEGETABLES | FRUIT | GRAIN
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | RACE_SWAP | ERT_SPAWN

/datum/species/diona/random_name(gender,unique,lastname)
	if(unique)
		return random_unique_diona_name()

	var/randname = diona_name()

	if(lastname)
		randname += " [lastname]"

	return randname

/datum/species/diona/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	C.draw_russ_parts()  //changes icons to be fetched from russstation/icons/mob/mutant_bodyparts.dmi
	. = ..()
	C.faction |= "plants"
	C.faction |= "vines"

/datum/species/diona/on_species_loss(mob/living/carbon/C, datum/species/old_species, pref_load)
	C.draw_russ_parts(TRUE)  //icon path is reset to default
	. = ..()
	C.faction -= "plants"
	C.faction -= "vines"

/datum/species/diona/spec_life(mob/living/carbon/human/H)
	if(H.stat == DEAD)
		return
	var/light_amount = 0 //how much light there is in the place, affects receiving nutrition and healing
	if(isturf(H.loc)) //else, there's considered to be no light
		var/turf/T = H.loc
		light_amount = min(1,T.get_lumcount()) - 0.5
		H.adjust_nutrition(light_amount * 10)
		if(H.nutrition > NUTRITION_LEVEL_ALMOST_FULL)
			H.set_nutrition(NUTRITION_LEVEL_ALMOST_FULL)
		if(light_amount > 0.2) //if there's enough light, heal
			H.heal_overall_damage(2,1, 0, BODYPART_ORGANIC)

	if(H.nutrition < NUTRITION_LEVEL_STARVING + 50)
		H.take_overall_damage(2,0)

/datum/species/diona/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.type == /datum/reagent/toxin/plantbgone)
		H.adjustToxLoss(3)
		H.reagents.remove_reagent(chem.type, REAGENTS_METABOLISM)
		return TRUE

/datum/species/diona/on_hit(obj/projectile/P, mob/living/carbon/human/H)
	switch(P.type)
		if(/obj/projectile/energy/floramut)
			if(prob(15))
				H.AddComponent(/datum/component/irradiated)
				H.Paralyze(100)
				H.visible_message(
					span_warning("[H] writhes in pain as [H.p_their()] vacuoles boil."),
					span_userdanger("You writhe in pain as your vacuoles boil!"),
					span_hear("You hear the crunching of leaves."),
				)
				if(prob(80))
					H.easy_random_mutate(NEGATIVE+MINOR_NEGATIVE)
				else
					H.easy_random_mutate(POSITIVE)
				H.random_mutate_unique_identity()
				H.random_mutate_unique_features()
				H.domutcheck()
			else
				H.adjustFireLoss(rand(5,15))
				H.show_message(span_userdanger("The radiation beam singes you!"))
		if(/obj/projectile/energy/florayield)
			H.set_nutrition(min(H.nutrition+30, NUTRITION_LEVEL_FULL))
