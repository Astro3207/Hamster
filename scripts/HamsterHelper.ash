record role {
	string ele;
	modifier ele_mod;
	skill spirit_of_ele;
	skill atk_spell;
};
role[string] roles = {
	"skins":	new role("",		$modifier[lantern],				$skill[spirit of nothing],		$skill[Wassail]),
	"boots":	new role("hot",		$modifier[hot spell damage],	$skill[spirit of cayenne],		$skill[Conjure Relaxing Campfire]),
	"skulls":	new role("spooky",	$modifier[spooky spell damage],	$skill[spirit of wormwood],		$skill[Creepy Lullaby]),
	"eyes":		new role("cold",	$modifier[cold spell damage],	$skill[spirit of peppermint],	$skill[Maximum Chill]),
	"crotches":	new role("sleaze",	$modifier[sleaze spell damage],	$skill[spirit of bacon grease],	$skill[Inappropriate Backrub]),
	"guts":		new role("stench",	$modifier[stench spell damage],	$skill[spirit of garlic],		$skill[Mudbath]),
};

set_property("parts_collection", user_prompt("The express purpose of this script is to help you set up your outfit and mood before running Hamster.ash. Note that mood will not be taken into account unless the effects are active while running the script. Also not that outfits that have recently changed will not be updated in mafia unless you log out and in once after changing. To begin, what part are you looking to get? \n boots --> hot \n eyes --> cold \n guts --> stench \n skulls --> spooky \n crotches --> sleaze \n skins --> physical", roles));
set_property("hamster_spell", user_prompt("What spell will you be using? Unfortunately this script only supports stuffed mortar shell, 30mp hobopolis spells, and 120mp hobopolis spells hamster.ash defaults to stuffed mortar shells unless you are collecting skins or don't have stuffed mortar shell or flavour of magic. If you'd like more spells DM me on discord @weaksauce3207, it's actually very little effort to add myst spells but no point in doing so if there's no interest", $strings[stuffed mortar shell, 30mp, 120mp]));
if (get_property("parts_collection") == "skins" && get_property("hamster_spell") == "stuffed mortar shell"){
    abort("Please note that there is no way to guarantee collecting a skin with stuffed mortar shell");
}

int estimated_spelldmg, base_spellD;
float spelldmgp_value, myst_boost;
if (get_property("hamster_spell") == "stuffed mortar shell"){
    base_spellD = 32;
    myst_boost = 0.5;
} else if (get_property("hamster_spell") == "30mp"){
    base_spellD = 10;
    myst_boost = 0.1;
} else if (get_property("hamster_spell") == "120mp"){
    base_spellD = 35;
    myst_boost = 0.35;
}
if (!(outfit(get_property("parts_collection")))) {
    print(`No outfit named {get_property("parts_collection")} (capitalization matters), wearing a generic outfit`, "blue");
    waitq(3);
    estimated_spelldmg = ((numeric_modifier($modifier[Spell Damage Percent]) + 100)/100) * (base_spellD + (myst_boost * my_buffedstat($stat[mysticality])) + numeric_modifier(roles[get_property("parts_collection")].ele_mod) + numeric_modifier($modifier[spell damage])) * max(0.50,(1-(numeric_modifier($modifier[monster level])*0.004)));
    spelldmgp_value = ((((numeric_modifier($modifier[Spell Damage Percent]) + 100 + 100)/100) * (base_spellD + (myst_boost * my_buffedstat($stat[mysticality])) + numeric_modifier($modifier[spell damage]) + numeric_modifier(roles[get_property("parts_collection")].ele_mod))) - estimated_spelldmg)/((((numeric_modifier($modifier[Spell Damage Percent]) + 100)/100) * (base_spellD + (myst_boost * (my_buffedstat($stat[mysticality])+100)) + numeric_modifier($modifier[spell damage]) + numeric_modifier(roles[get_property("parts_collection")].ele_mod))* max(0.50,(1-(numeric_modifier($modifier[monster level])*0.004)))) - estimated_spelldmg);
    maximize(`2.8 {roles[get_property("parts_collection")].ele} spell damage, {spelldmgp_value} spell damage percent, mys, -999999 lantern`, false);
}
estimated_spelldmg = ((numeric_modifier($modifier[Spell Damage Percent]) + 100)/100) * (base_spellD + (myst_boost * my_buffedstat($stat[mysticality])) + numeric_modifier(roles[get_property("parts_collection")].ele_mod) + numeric_modifier($modifier[spell damage])) * max(0.50,(1-(numeric_modifier($modifier[monster level])*0.004)));
set_property("currentMood", get_property("parts_collector"));
print(`Setting mood named {get_property("parts_collection")} (capitalization matters), again you will need to execute your mood for the effects to be taken into consideration`, "blue");
if (my_buffedstat($stat[moxie]) < ($monster[normal hobo].monster_attack() + 10))
    print("You have " + my_buffedstat($stat[moxie]) + " moxie, but you need at least " + ($monster[normal hobo].monster_attack() + 10) + " moxie to safely adventure at town square");
if (estimated_spelldmg > ($monster[normal hobo].monster_hp() + 100)){
    print("You are expected to do " + estimated_spelldmg + " damage when casting the spell, while you need to deal " + ($monster[normal hobo].monster_hp() + 100) + " damage to guarentee a hobo part from normal hobos. Congrats, you're all set!");
} else {
    print("You are expected to do " + estimated_spelldmg + " damage when casting the spell, while you need to deal " + ($monster[normal hobo].monster_hp() + 100) + " damage to guarentee a hobo part from normal hobos. Consider making a mood, buy better equipment, or choosing another spell");
    int myst_desired = ((($monster[normal hobo].monster_hp() + 100)/(max(0.50,(1-(numeric_modifier($modifier[monster level])*0.004)))*(((numeric_modifier($modifier[Spell Damage Percent]) + 100)/100)))-base_spellD)/myst_boost) - my_buffedstat($stat[mysticality]);
    print("You could increase your mysticality by " + myst_desired);
    int spell_percent_desired = ((($monster[normal hobo].monster_hp() + 100)/(max(0.50,(1-(numeric_modifier($modifier[monster level])*0.004)))*(base_spellD + (myst_boost * my_buffedstat($stat[mysticality])) + numeric_modifier($modifier[spell damage]) + numeric_modifier(roles[get_property("parts_collection")].ele_mod)))) - ((numeric_modifier($modifier[Spell Damage Percent]) + 100)/100))*100;
    print("Or you could increase your spell damage percent by " + spell_percent_desired);
    print("Or you could also run -mL but the calculations are a little too complex to be desired right now");
}
