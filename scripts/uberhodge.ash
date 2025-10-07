int mapimage() {
	string town_map = visit_url("clan_hobopolis.php?place=2");
	int mapnumber;
	matcher matcher_mapnumber = create_matcher("Town Square \\(picture #(\\d+)(o?)\\)", town_map); 
	if (matcher_mapnumber.find())
		mapnumber += matcher_mapnumber.group(1).to_int();
	return mapnumber;
}
visit_url("account.php?am=1&action=flag_aabosses&value=1&ajax=1");

if (mapimage() != 25){
    if (!user_confirm("Looks like Hodge is not up, continue?")){
        abort();
    }
}
if (!have_skill($skill[Grease Up])){
    print("Looks like you are missing the skill this script is designed for. To get grease up, you will need to buy and use Now You're Cooking With Grease which will set you back " + mall_price( $item[Now You\'re Cooking With Grease] ) + " meat", "blue");
    abort("Missing skill grease up");
}
cli_execute("maximize -1000 Stackable Mana Cost, mp");
int cost = (((mp_cost( $skill[Grease Up] )-6) * 3901)/10) * npc_price( $item[Doc Galaktik\'s Invigorating Tonic] );
if (!user_confirm ("This will cost an estimated " + cost + " meat (not including jewel-eyed wizard hat) and one pocket wish. For cost savings see the wiki for Skill MP Cost Modifiers and NPC Store Price Modifiers and completing Doc Galaktik's Quest. Continue with buffing up?")){
    abort();
} else {
    cli_execute("genie effect arcane in the brain; use natural magick candle");
    if (can_equip($item[Wand of Oscus]) && (item_amount($item[Wand of Oscus]) > 0 || have_equipped($item[Wand of Oscus])) && can_equip($item[Oscus's dumpster waders]) && (item_amount($item[Oscus's dumpster waders]) > 0 || have_equipped($item[Oscus's dumpster waders])) && can_equip($item[Oscus's pelt]) && (item_amount($item[Oscus's pelt]) > 0 || have_equipped($item[Oscus's pelt]))){
        cli_execute("maximize mp -pants -acc3 - offhand; equip acc3 Oscus's pelt; equip Oscus's dumpster waders; equip Wand of Oscus");
    } else {
        cli_execute("maximize mp");
    }
}
while (have_effect($effect[Takin\' It Greasy]) < 39010){
    if (my_mp() < my_maxmp()){
        int potions_to_use = (my_maxmp() - my_mp())/11;
        if (item_amount($item[designer sweatpants]) > 0){
            equip($item[designer sweatpants]);
            cli_execute("acquire " + potions_to_use + " doc galaktik's invig");
            if (can_equip($item[Wand of Oscus]) && (item_amount($item[Wand of Oscus]) > 0 || have_equipped($item[Wand of Oscus])) && can_equip($item[Oscus's dumpster waders]) && (item_amount($item[Oscus's dumpster waders]) > 0 || have_equipped($item[Oscus's dumpster waders])) && can_equip($item[Oscus's pelt]) && (item_amount($item[Oscus's pelt]) > 0 || have_equipped($item[Oscus's pelt]))){
                cli_execute("maximize mp -pants -acc3 - offhand; equip acc3 Oscus's pelt; equip Oscus's dumpster waders; equip Wand of Oscus");
            } else {
                cli_execute("maximize mp");
            }
        }
        cli_execute("use " + potions_to_use + " doc galaktik's invig");
    }
    int to_cast = min(((max(0,39010-have_effect($effect[Takin\' It Greasy])))/10),my_mp()/15);
    cli_execute("cast " + to_cast +" Grease Up");
}
cli_execute("maximize init");
set_auto_attack("Unleash the Greash");
if (mapimage() == 25){
    visit_url("adventure.php?snarfblat=167");
    run_choice(1);
} else {
    print ("Ready 1 hit KO hodge", "green");
}
set_auto_attack(0);
