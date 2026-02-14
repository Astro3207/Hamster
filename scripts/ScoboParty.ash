import hamster

int richmin() {
	int out = 999;
	foreach part in rich_takes
		out = min(out, richard(part));
	return out;
}

string maybe(string it) {
	return (it.to_item().available_amount() > 0) ? ", equip " + it : "";
}

void slow_sewer() {
	if (visit_url("clan_hobopolis.php?place=2").contains_text("clan_hobopolis.php?place=3"))
		return;
	set_auto_attack(1);
	set_property("requireSewerTestItems", "false");
	set_property("choiceAdventure198", 1);
	set_property("choiceAdventure199", 1);
	set_property("choiceAdventure197", 1);
	repeat {
		foreach sk in $skills[smooth movement, the sonata of sneakiness, hide from seekers]
			if (sk.to_effect().have_effect() < 1)
				use_skill(sk);
		maximize("-com,equip code binder" + maybe("june cleaver") + maybe("mafia thumb ring"), false);
		adventure(1, $location[A Maze of Sewer Tunnels], "attack; repeat;");
	} until (get_property("lastEncounter") == "At Last!");
}

void gather_part(string part) {
	if (!(my_adventures() > 0 && (mapimage() < 25 || mapimage() == 125) && richmin() < goal))
		return;
	buffer macro;
	string max_on, result;
	boolean[skill] buffs;
	if (!(rich_takes contains part))
		abort("dunno how to make "+part+" for Richard");
	if (part == "skins") {
		set_auto_attack(1);
		macro.append("attack; repeat;");
		buffs = $skills[carol of the bulls,blood frenzy,song of the north];
		max_on = "-familiar,-100 ml, weapon damage percent" + maybe("june cleaver") + maybe("mafia thumb ring");
	}
	else {
		if (have_effect(roles[part].spirit_of_ele.to_effect()) == 0)
			use_skill(roles[part].spirit_of_ele);
		set_auto_attack($skill[stuffed mortar shell].to_int());
		macro.append("item seal tooth;");
		buffs = $skills[carol of the hells,song of sauce];
		max_on = "-familiar,-100 ml, spell damage percent" + maybe("june cleaver") + maybe("mafia thumb ring");
	}
	foreach sk in buffs
		if (sk.have_skill() && sk.to_effect().have_effect() < 1)
			use_skill(sk);
	maximize(max_on, false);
	write_ccs(macro, "auto_parts");
	set_ccs("auto_parts");
	result = cli_execute("adv 1 town square");
	if (result.contains_text("Normal hobo") && !(result.contains_text(rich_takes[part])))
		abort("Richard didn't take a part?");
}

void gather_all(int goal) {
	foreach part in rich_takes
		if (richard(part) < goal)
			gather_part(part);
}

void scobo(int many) {
	if (many > 0)
		visit_url("clan_hobopolis.php?preaction=simulacrum&place=3&qty="+many);
}

void main() {
	try {
		slow_sewer();
		set_property("choiceAdventure200", 2);
		set_property("choiceAdventure225", 3);
		set_property("choiceAdventure230", 2);
		set_property("choiceAdventure272", 2);
		while (my_adventures() > 0 && (mapimage() < 25 || mapimage() == 125)) {
			gather_all(1);
			scobo(1);
		}
	}
	finally {
		set_auto_attack(0);
		use_skill($skill[spirit of nothing]);
		set_property("choiceAdventure200", 0);
		set_property("choiceAdventure225", 0);
		set_property("choiceAdventure230", 0);
		set_property("choiceAdventure272", 0);
		set_property("choiceAdventure198", 0);
		set_property("choiceAdventure199", 0);
		set_property("choiceAdventure197", 0);
		set_property("requireSewerTestItems", "true");
	}
}
