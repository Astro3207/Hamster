int mapimage() {
	string town_map = visit_url("clan_hobopolis.php?place=2");
	int mapnumber;
	matcher matcher_mapnumber = create_matcher("Town Square \\(picture #(\\d+)(o?)\\)", town_map); 
	if (matcher_mapnumber.find())
		mapnumber += matcher_mapnumber.group(1).to_int();
	return mapnumber;
}

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
if (item_amount($item[designer sweatpants]) > 0){
    equip($item[designer sweatpants]);
}
int cost = (((mp_cost( $skill[Grease Up] )-6) * 3901)/10) * npc_price( $item[Doc Galaktik\'s Invigorating Tonic] );
if (!user_confirm ("This will cost an estimated " + cost + " meat (not including jewel-eyed wizard hat) and one pocket wish. For cost savings see the wiki for Skill MP Cost Modifiers and NPC Store Price Modifiers. Continue with buffing up?")){
    abort();
} else {
    cli_execute("genie effect arcane in the brain; use natural magick candle");
}
while (have_effect($effect[Takin\' It Greasy]) < 39010){
    if (my_mp() < my_maxmp()){
        if (item_amount($item[designer sweatpants]) > 0){
            equip($item[designer sweatpants]);
        }
        int potions_to_use = (my_maxmp() - my_mp())/11;
        cli_execute("use " + potions_to_use + " doc galaktik's invig");
    }
    cli_execute("maximize -1000 Stackable Mana Cost, mp");
    int to_cast = min(((39010-have_effect($effect[Takin\' It Greasy]))/10),my_mp()/15);
    cli_execute("cast " + to_cast +" Grease Up");
}
cli_execute("maximize init");
set_auto_attack("Unleash the Greash");
if (mapimage() == 25){
    print("Once I get confirmation that this works, will directly fight hodge, until then you will have to enter combat manually");
} else {
    print ("Ready 1 hit KO hodge", "green");
}
