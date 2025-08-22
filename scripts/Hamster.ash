record role {
	string ele;
	modifier ele_mod;
	skill spirit_of_ele;
	skill atk_spell;
};
role[string] roles = {
	"skins":	new role("",		$modifier[none],				$skill[spirit of nothing],		$skill[stuffed mortar shell]),
	"boots":	new role("hot",		$modifier[hot spell damage],	$skill[spirit of cayenne],		$skill[stuffed mortar shell]),
	"skulls":	new role("spooky",	$modifier[spooky spell damage],	$skill[spirit of wormwood],		$skill[stuffed mortar shell]),
	"eyes":		new role("cold",	$modifier[cold spell damage],	$skill[spirit of peppermint],	$skill[stuffed mortar shell]),
	"crotches":	new role("sleaze",	$modifier[sleaze spell damage],	$skill[spirit of bacon grease],	$skill[stuffed mortar shell]),
	"guts":		new role("stench",	$modifier[stench spell damage],	$skill[spirit of garlic],		$skill[stuffed mortar shell]),
	"scarehobo":new role("",		$modifier[none],				$skill[spirit of nothing],		$skill[stuffed mortar shell]),
	"cagebot":	new role("",		$modifier[none],				$skill[spirit of nothing],		$skill[stuffed mortar shell])
};
string[string] rich_takes = {
	"skins":	"Richard takes a hobo skin",
	"boots":	"Richard takes a charred hobo boots",
	"skulls":	"Richard takes a creepy hobo skull",
	"eyes":		"Richard takes a frozen hobo eyeballs",
	"crotches":	"Richard takes a hobo crotch",
	"guts":		"Richard takes a stinking hobo guts"
};
item[class] instruments = {
	$class[Seal Clubber]:	$item[sealskin drum],
	$class[Turtle Tamer]:	$item[washboard shield],
	$class[Pastamancer]:	$item[spaghetti-box banjo],
	$class[Sauceror]:		$item[marinara jug],
	$class[Disco Bandit]:	$item[makeshift castanets],
	$class[Accordion Thief]:$item[left-handed melodica]
};
string town_map, rlogs;
int estimated_spelldmg, spelldmgp_value, start_adv, end_adv, adv_spent;

string LastAdvTxt() {
	string lastlog = session_logs(1)[0];
	int nowmark = max(lastlog.last_index_of(`[{my_turncount()}]`), lastlog.last_index_of(`[{my_turncount()}]`));
	return lastlog.substring(nowmark);
}

int mapimage() {
	town_map = visit_url("clan_hobopolis.php?place=2");
	int mapnumber;
	matcher matcher_mapnumber = create_matcher("Town Square \\(picture #(\\d+)(o?)\\)", town_map); 
	if (matcher_mapnumber.find())
		mapnumber += matcher_mapnumber.group(1).to_int();
	return mapnumber;
}

boolean tent_open() {
	town_map = visit_url("clan_hobopolis.php?place=2");
	matcher matcher_mapnumber = create_matcher("Town Square \\(picture #(\\d+)(o?)\\)", town_map); 
	matcher_mapnumber.find();
	return matcher_mapnumber.group(2).contains_text("o");
}

int grates_opened() {
	rlogs = visit_url("clan_raidlogs.php");
	matcher sewer_grate_matcher = create_matcher("\\bopened\\s+(\\d+)\\s+sewer grates?", rlogs);
	int sewer_grate_turns = 0;
	while (sewer_grate_matcher.find())
		sewer_grate_turns += sewer_grate_matcher.group(1).to_int();
	return sewer_grate_turns;
}

int num_mosh() {
	rlogs = visit_url("clan_raidlogs.php");
	int mosh_num;
	matcher mosh_turns = create_matcher("started (.+?) mosh pits? in the tent \\((\\d+) turn", rlogs);
	if (mosh_turns.find())
		mosh_num += mosh_turns.group(2).to_int();
	return mosh_num;
}

int richard(string part) {
	string[string] match_strings = {
		"skins":	"Richard has <b>(\\d+)</b> hobo skin(s)",
		"boots":	"Richard has <b>(\\d+)</b> pair(s)? of charred hobo boot(s)?",
		"skulls":	"Richard has <b>(\\d+)</b> creepy hobo skull(s)?",
		"eyes":		"Richard has <b>(\\d+)</b> pair(s)? of frozen hobo eyes?",
		"crotches":	"Richard has <b>(\\d+)</b> hobo crotch(es)?",
		"guts":		"Richard has <b>(\\d+)</b> pile(s)? of stinking hobo guts"
	};
	if (!(match_strings contains part))
		abort(`richard has no count for {part}s`);
	string richard = visit_url("clan_hobopolis.php?place=3&action=talkrichard&whichtalk=3");
	int part_count = 0;
	matcher m = match_strings[part].create_matcher(richard);
	if (m.find())
		part_count += m.group(1).to_int();
	return part_count;
}

void setup() {
	buffer ccs = "if hasskill Spring Away \n"
			+ "skill spring away \n"
		+ "endif \n"
		+ "if hasskill Blow the Green Candle! \n"
			+ "skill Blow the Green Candle \n"
		+ "endif \n"
		+ "if hasskill creepy grin \n"
			+ "skill screepy grin \n"
		+ "endif \n"
		+ "if hasskill feel hatred \n"
			+ "skill feel hatred \n"
		+ "endif \n"
		+ "if hasskill Give Your Opponent the Stinkeye \n"
			+ "skill Give Your Opponent the Stinkeye \n"
		+ "endif \n"
		+ "if hasskill Summon Mayfly Swarm \n"
			+ "skill summon mayfly swarm \n"
		+ "endif \n"
		+ "if hasskill Throw Latte on Opponent \n"
			+ "skill throw latte on opponent \n"
		+ "endif \n"
		+ "if hasskill Snokebomb \n"
			+ "skill snokebomb \n"
		+ "endif \n"
		+ "skill cleesh \n"
		+ "attack with weapon";
	write_ccs(ccs, "cleesh free runaway");
	set_property("battleAction", "custom combat script");
	set_auto_attack(0);

	switch (to_int(get_property("initialized"))) {
		case 0:
		case 1:
			set_property("sewer_progress", 100); //saying that there's 100 chieftans until sewers is cleared
			if (!user_confirm("You are currently in the clan "+get_clan_name()+" is the correct?"))
				abort();
			set_property("is_mosher", user_confirm("Are you the mosher?"));
			set_property("parts_collection", user_prompt("What part will you be collecting?", roles));
			if (get_property("parts_collection") == "")
				abort();
			set_property("IveGotThis", "false");
			set_property("adv_checked", "false");
			set_property("people_staged" , "0");
			set_property("moshed" , "false");
			set_property("people_unstaged" , "0");
			set_property("tent_stage", "unstarted");
			set_property("hpAutoRecovery", 0.5);
			set_property("hpAutoRecoveryTarget", 0.95);
			set_property("mpAutoRecovery", 0.25);
			set_property("mpAutoRecoveryTarget", 0.75);
			set_property("chatbotScriptStorage", get_property("chatbotScript"));
			set_property("chatbotScript", "HamsterChat.ash");
			cli_execute("/switch hobopolis");
			set_property("initialized", 4); //to skip future initializations
			break;
		case 2:
			set_property("sewer_progress", 100); //saying that there's 100 chieftans until sewers is cleared
			break;
		case 3:
			set_property("is_mosher", user_confirm("Are you the mosher?"));
			set_property("parts_collection", user_prompt("What part will you be collecting?", roles));
			if (get_property("parts_collection") == "")
				abort();
			set_property("initialized", 4);
	}
	cli_execute("unequip offhand");
	if (get_property("is_mosher") != "true" && get_property("parts_collection") != "cagebot")
		foreach cl, it in instruments
			if (my_class() == cl && item_amount(it) < 1)
				abort("Missing your class instrument? To reset your role (e.g. to mosher or cagebot), type \"set initialized = 3\"");
	if (!have_skill($skill[CLEESH]))
		abort("Having CLEESH is essential, and my data says you don't");
}

void sewer() {
	int sewer_progress = to_int(get_property("sewer_progress"));
	start_adv = my_adventures();
	town_map = visit_url("clan_hobopolis.php?place=2");
	if (contains_text(town_map , "clan_hobopolis.php?place=3")) { //checking if sewers is already cleared
		print("The Maze of Sewer Tunnels is already clear, skipping sewers", "orange") ;
		set_property("initialized", 2);
		return;
	}
	set_property("lucky_sewers", user_confirm("Do you want to clover all the way through the sewers?"));

	if (get_property("lucky_sewers") == "false") {
		set_property("HalfnHalf", user_confirm("Do you want to clover through the final 10% of the sewers?"));
		set_ccs ("cleesh free runaway");
		foreach f in $familiars[peace turkey, disgeist, left-hand man, disembodied hand]
			if (f.have_familiar()) {
				f.use_familiar();
				break;
			}
		if (get_property("parts_collection") == "cagebot") {
			maximize("-combat", false);
			rlogs = visit_url("clan_raidlogs.php");
			if (rlogs.contains_text("stared at an empty cage for a while"))
				abort("someone else is already caged");
			set_property("choiceAdventure211", 0);
			set_property("choiceAdventure212", 0);
			set_property("choiceAdventure198", 3);
			set_property("choiceAdventure199", 2);
			set_property("choiceAdventure197", 2);
			repeat {
				set_property ("choiceAdventure198" , grates_opened() < 9 ? "3" : "2");
				adventure(1, $location[A Maze of Sewer Tunnels]);
				if (get_property("_lastCombatLost") == "true")
					abort("It appears you lost the last combat, look into that");
			} until (last_choice() == 211 || last_choice() == 212);
		}
		if (!user_confirm("Press yes when you know cagebot is caged"))
			abort();
		set_property("choiceAdventure198", 1);
		set_property("choiceAdventure199", 1);
		set_property("choiceAdventure197", 1);
		maximize("-combat", false);
		repeat {
			int[item] testitems = {
				$item[sewer wad]:				1,
				$item[unfortunate dumplings]:	1,
				$item[bottle of Ooze-O]:		1,
				$item[gatorskin umbrella]:		1,
				$item[oil of oiliness]:			3
			};
			foreach it, q in testitems
				retrieve_item(q, it);
			if (grates_opened() < 9) {
				set_property("choiceAdventure198", 3);
				set_property("choiceAdventure199", 2);
				set_property("choiceAdventure197", 2);
			}
			else {
				set_property("choiceAdventure198", 1);
				set_property("choiceAdventure199", 1);
				set_property("choiceAdventure197", 1);
				maximize("-combat, equip hobo code binder, equip gatorskin umbrella", false);
			}
			string visit_sewers = visit_url("adventure.php?snarfblat=166");
			int sewer_choice = 0;
			matcher matcher_sewer_choice = create_matcher("whichchoice value=(\\d+)", visit_sewers);
			if (matcher_sewer_choice.find() && get_property("choiceAdventure198") == "1") {
				sewer_choice += to_int(matcher_sewer_choice.group(1));
				string sewer_noncom = visit_url("choice.php?whichchoice="+ sewer_choice +"&option=1");
				int[string] progress = {
					"You head down the 'shortcut' tunnel.": 1,
					"This ladder just goes in a big circle.": 3,
					"You head toward the Egress.": 5,
					"These will indubitably satisfy my refined appetite": 1,
					"He grabs the wad and runs away": 1,
					"He finds a bottle of Ooze-O": 1,
					"you douse yourself with oil of oiliness": 1,
					"your gatorskin umbrella allows you to pass beneath the sewagefall without incident": 1,
					"looks like somebody else opened this grate from the other side": 5
				};
				foreach encounter, contributes in progress
					if (sewer_noncom.contains_text(encounter))
						sewer_progress -= contributes;
				set_property("sewer_progress", sewer_progress);
			}
			else if (contains_text(visit_sewers, "Round 1"))
				run_combat();
			else {
				run_choice(-1);
				run_combat();
			}
			if (get_property("_lastCombatLost") == "true") //KoL Mafia detected that the last combat was lost so that the script is aborted and a whole bunch of adventures aren't wasted
				abort ("It appears you lost the last combat, look into that");
			if (sewer_progress <= 10 && get_property("HalfnHalf") == "true") {
				set_property("lucky_sewers", "true");
				set_property("adv_checked", "true");
				break;
			}
		} until (get_property("lastEncounter") == "At Last!");
	}

	if (get_property("lucky_sewers") == "true") {
		if (get_property("parts_collection") == "cagebot")
			abort("There's no point in doing lucky while being a cagebot? To reset your role (ie mosher or cagebot) type \"set initialized = 3\"");
		if (item_amount($item[11-leaf clover]) < sewer_progress) { //checks if there is enough clovers
			print("Not enough clovers?", "orange");
			abort ("If you've already cleared some of the sewers manually, type set sewer_progress = how many sewers adventures are left");
		}
		if (my_buffedstat($stat[moxie]) < ($monster[C. H. U. M. chieftain].monster_attack() + 10) && get_property("IveGotThis") != "true")
			abort ("Buffed moxie should be at least "+ ($monster[C. H. U. M. chieftain].monster_attack() + 10) +" to guarentee a safe passage. Contact organizers for help. If you are confident in your skillz type \"set IveGotThis = true\"");
		if (my_adventures() < 270 && get_property("adv_checked") != "true") { //I'm approximating that 140 adventures are needed for the entire run
			set_property("adv_checked", "true");
			abort("I would recommend having at least 270 adventures before starting");
		}
		else
			set_property("adv_checked", "true"); //setting it so that the adventure check only happens once
		if (!outfit ("sewers")) {
			print("No outfit named sewers (capitalization matters), wearing a generic outfit", "blue");
			waitq(3);
			maximize("weapon damage", false);
		}
		if (!set_ccs("sewers")) {
			print("No custom combat script, setting auto attack to weapon");
			waitq(3);
			set_property("battleAction", "attack with weapon");
		}
		repeat { //using 11-leaf clover before adventuring in sewers once
			if ((have_effect($effect[Lucky!]) == 0) && item_amount($item[11-leaf clover]) > 0)
				cli_execute("use 11-leaf clover");
			else
				abort("Lacking clovers????");
			adventure(1, $location[A Maze of Sewer Tunnels]);
			if (get_property("_lastCombatLost") == "true") //KoL Mafia detected that the last combat was lost so that the script is aborted and a whole bunch of adventures aren't wasted
				abort ("It appears you lost the last combat, look into that");
			sewer_progress -= 1; //doing some calculations on how many chieftans are left
			set_property("sewer_progress", sewer_progress);
			print("C.H.U.M Chieftans left: " + sewer_progress, "orange");
			town_map = visit_url("clan_hobopolis.php?place=2");
		} until (contains_text(town_map , "clan_hobopolis.php?place=3") || to_int(get_property("sewer_progress")) <= 0); //checks if town map is open or the calculations say there are 0 chieftains left
		print("Sewers shouuuuuld be complete, I think", "orange");
		set_property("battleAction", "custom combat script");
	}
	print((start_adv - my_adventures()) + " adventures spent in the sewers");
}

// dress up to overkill and make scobo parts
void prep(string override) {
	if (!(roles contains get_property("parts_collection")))
		abort("wait, what are you collecting?");
	if ($strings[scarehobo, cagebot] contains get_property("parts_collection") && override == get_property("parts_collection"))
		return;
	string remember = get_property("parts_collection");
	try {
		if (get_property("parts_collection") != override)
			set_property("parts_collection", override);
		if (!(outfit(get_property("parts_collection")))) {
			print(`No outfit named {get_property("parts_collection")} (capitalization matters), wearing a generic outfit`, "blue");
			waitq(3);
			estimated_spelldmg = ((numeric_modifier($modifier[Spell Damage Percent]) + 100)/100) * (35 + (0.35 * my_buffedstat($stat[mysticality])) + numeric_modifier(roles[get_property("parts_collection")].ele_mod) + numeric_modifier($modifier[spell damage])) * max(0.50,(1-(numeric_modifier($modifier[monster level])*0.004)));
			spelldmgp_value = ((((numeric_modifier($modifier[Spell Damage Percent]) + 100 + 100)/100) * (35 + (0.35 * my_buffedstat($stat[mysticality])) + numeric_modifier($modifier[spell damage]) + numeric_modifier($modifier[hot spell damage]))) - estimated_spelldmg)/((((numeric_modifier($modifier[Spell Damage Percent]) + 100)/100) * (35 + (0.35 * (my_buffedstat($stat[mysticality])+100)) + numeric_modifier($modifier[spell damage]) + numeric_modifier($modifier[hot spell damage]))) - estimated_spelldmg);
			maximize(`2.8 {roles[get_property("parts_collection")].ele} spell damage, {spelldmgp_value} spell damage percent, mys, -1000 lantern`, false);
		}
		estimated_spelldmg = ((numeric_modifier($modifier[Spell Damage Percent]) + 100)/100) * (35 + (0.35 * my_buffedstat($stat[mysticality])) + numeric_modifier(roles[get_property("parts_collection")].ele_mod) + numeric_modifier($modifier[spell damage])) * max(0.50,(1-(numeric_modifier($modifier[monster level])*0.004)));
		if (have_skill($skill[Flavour of Magic]))
			use_skill(roles[get_property("parts_collection")].spirit_of_ele);
		if (!set_ccs(get_property("parts_collection"))) {
			print(`No custom combat script named {get_property("parts_collection")} (capitalization matters), setting auto attack to {roles[get_property("parts_collection")].atk_spell}`, "blue");
			waitq(3);
			if (!have_skill(roles[get_property("parts_collection")].atk_spell))
				abort(`Missing skill {roles[get_property("parts_collection")].atk_spell}, please set a ccs named {get_property("parts_collector")}`);
			else
				set_property("battleAction", roles[get_property("parts_collection")].atk_spell);
		}
		set_property("currentMood", get_property("parts_collector"));
		if ((estimated_spelldmg < ($monster[normal hobo].monster_hp() + 100) || my_buffedstat($stat[moxie]) < ($monster[normal hobo].monster_attack() + 10)) && get_property("IveGotThis") != "true") {
			if (estimated_spelldmg < ($monster[normal hobo].monster_hp() + 100))
				print("You are expected to do " + estimated_spelldmg + " damage when casting the hobopolis spell, while you need to deal " + ($monster[normal hobo].monster_hp() + 100) + " damage to guarentee a hobo part from normal hobos.");
			if (my_buffedstat($stat[moxie]) < ($monster[normal hobo].monster_attack() + 10))
				print("You have " + my_buffedstat($stat[moxie]) + " moxie, but you need at least " + ($monster[normal hobo].monster_attack() + 10) + " moxie to safely adventure at town square");
			abort("It seems you failed one of the stat checks. Condider creating mood that boosts spell damage percent, mainstat, or minimizes ML. If you would like to skip this safety check type \"IveGotThis = true\", but I wouldn't reccomend it TBH");
		}
	}
	finally
		if (get_property("parts_collection") != remember)
			set_property("parts_collection", remember);
}
void prep() {
	prep(get_property("parts_collection"));
}

// clearing the first half of town square
void phase_one() {
	set_property("initialized", 2);
	set_property("choiceAdventure230", "2"); //Skipping binder purchase
	set_property("choiceAdventure272", "2"); //skipping marketplace
	set_property("choiceAdventure230", "2"); //shouldn't ever happen but leaving Hodgeman alone
	set_property("choiceAdventure225", "0"); //stopping if A Tent is encountered
	int start_adv = my_adventures();

	if (mapimage() <= 6) { //phase 1 collect 106 hobo parts
		if (roles contains get_property("parts_collection") && !($strings[scarehobo, cagebot] contains get_property("parts_collection"))) {
			prep();
			int parts_left = 106 - richard("boots");
			while (richard("boots") < 106) {
				adventure(1, $location[Hobopolis Town Square]);
				if (get_property("_lastCombatLost") == "true") //KoL Mafia detected that the last combat was lost so that the script is aborted and a whole bunch of adventures aren't wasted
					abort ("It appears you lost the last combat, look into that");
				if (!LastAdvTxt().contains_text(rich_takes[get_property("parts_collection")]))
					abort(rich_takes[get_property("parts_collection")].replace_string("takes", "failed to take"));
				parts_left = 106 - richard("boots");
				print("Boots left to collect: " + parts_left);
			}
		}

		set_property("battleAction", "custom combat script");
		set_property("currentMood", "apathetic");
		while (richard("boots") < 106 || richard("eyes") < 106 || richard("guts") < 106 || richard("skulls") < 106 || richard("crotches") < 106 || richard("skins") < 106 || mapimage() <= 6) {
			foreach thing in $strings[skins, boots, skulls, eyes, crotches, guts]
			if (richard(thing) < 106)
				print(`Looks we are short {106 - richard(thing)} {thing}{thing == "crotch"?"e":""}s`);
			print("Not all parts have been collected, waiting");
			waitq(5);
			if (richard("boots") >= 106 && richard("eyes") >= 106 && richard("guts") >= 106 && richard("skulls") >= 106 && richard("crotches") >= 106 && richard("skins") >= 106 && mapimage() <= 6)
				break;
		}
		print(`{start_adv - my_adventures()} adventures spend collecting parts`);
	}
}

// scobomaker opens the first tent
void phase_two() {
	if (get_property("parts_collection") != "scarehobo") {
		while (!tent_open()) {
			print("Tent not opened yet, waiting for designated person to open it");
			waitq(5);
		}
		return;
	}

	int scobo_used = 0;
	int manual_hobos_killed = 0;
	int start_adv = my_adventures();
	if (mapimage() < 9) {
		print("Letting other people's script catch up");
		waitq(15);
		rlogs = visit_url("clan_raidlogs.php");
		matcher manual_hobos = create_matcher("\\bdefeated\\s+Normal hobo x\\s+(\\d+)", rlogs);
		while (manual_hobos.find()) {
			manual_hobos_killed += (manual_hobos.group(1)).to_int();
		}
		scobo_used = ceil(1375-manual_hobos_killed)/10;
		visit_url("clan_hobopolis.php?preaction=simulacrum&place=3&qty="+ scobo_used);
	}
	while (mapimage() < 12) {
		if (min(richard("boots"), richard("eyes"), richard("guts"), richard("skulls"), richard("crotches"), richard("skins")) >= 1) {
			visit_url("clan_hobopolis.php?preaction=simulacrum&place=3&qty=1");
			scobo_used += 1;
		} else {
			repeat {
				foreach part in roles
					if (!($strings[scarehobo, cagebot] contains part) && richard(part) == 0) {
						prep(part);
						adventure(1, $location[Hobopolis Town Square]);
						if (!contains_text(LastAdvTxt(), rich_takes[part]))
							abort(`Richard failed to take {part}`);
						if (get_property("_lastCombatLost") == "true")
							abort ("It appears you lost the last combat, look into that");
						break;
					}
				set_property("battleAction", "custom combat script");
				set_property("currentMood", "boots");
				if (mapimage() >= 12)
					break;
			} until (min(richard("boots"), richard("eyes"), richard("guts"), richard("skulls"), richard("crotches"), richard("skins")) >= 1);
		}
	}
	print("Town Square image is currently at " + mapimage(), "blue");
	print(scobo_used + " scarehobos used, average is " + floor(1375-manual_hobos_killed)/8, "blue");
	if (mapimage() == 12 && get_property("tent_stage") != "stage1") {
		set_property("tent_stage", "started");
		int scobo_to_use = 0;
		if (get_property("scobo_needed") == "")
			foreach n, needed in int[int]{11:60, 10:44, 9:28, 8:12, 7:0} {
				int total = 0;
				foreach part in roles
					if (!($strings[scarehobo, cagebot] contains part))
						total += min(n, richard(part));
				if (total >= needed) {
					scobo_to_use = n;
					set_property("scobo_needed", `{n}`);
					break;
				}
			}
		else
			scobo_to_use = to_int(get_property("scobo_needed"));
		foreach part in roles if (!($strings[scarehobo, cagebot] contains part))
			while (richard(part) < scobo_to_use) {
				prep(part);
				adventure(1, $location[Hobopolis Town Square]);
				if (!contains_text(LastAdvTxt(), rich_takes[part]))
					abort(`Richard failed to take {part}`);
				if (get_property("_lastCombatLost") == "true")
					abort ("It appears you lost the last combat, look into that");
			}
//		set_property("battleAction", "custom combat script");
//		set_property("currentMood", "");
		set_property("scobo_needed", "");
		visit_url("clan_hobopolis.php?preaction=simulacrum&place=3&qty="+scobo_to_use);
		set_property("tent_stage", "stage1");
	}
	if (mapimage() == 12 && get_property("tent_stage") == "stage1") {
		while (!tent_open()) {
			foreach part in roles if (!($strings[scarehobo, cagebot] contains part))
				if (richard(part) == min(richard("boots"), richard("eyes"), richard("guts"), richard("skulls"), richard("crotches"), richard("skins"))) {
					prep(part);
					adventure(1, $location[Hobopolis Town Square]);
					if (!contains_text(LastAdvTxt(), rich_takes[part]))
						abort(`Richard failed to take {part}`);
					if (get_property("_lastCombatLost") == "true")
						abort ("It appears you lost the last combat, look into that");
				}
		}
		end_adv = my_adventures();
		adv_spent = start_adv - end_adv;
		print(adv_spent + " adventures spend opening the next tent");
//		set_property("battleAction", "custom combat script");
//		set_property("currentMood", "");
		set_property ("tent_stage", "finished");
	}
}

// everyone alternates between working and reopening the tent
void phase_three() {
		foreach f in $familiars[peace turkey, disgeist, left-hand man, disembodied hand]
		if (f.have_familiar()) {
			f.use_familiar();
			break;
		}
	maximize("-combat", false);
	repeat {
		if (tent_open()) {
			start_adv = my_adventures();
			foreach cl, it in instruments
				if (my_class() == cl && get_property("is_mosher") != "true" && !maximize(`-combat, equip {it}`, false))
					abort("failed to equip a hobo instrument...");
			set_ccs ("cleesh free runaway");
			int TS_noncom = 0;
			string town_square = visit_url("adventure.php?snarfblat=167");
			matcher matcher_TS_noncom = create_matcher("whichchoice value=(\\d+)", town_square); 
			if (matcher_TS_noncom.find())
				TS_noncom += matcher_TS_noncom.group(1).to_int();
			else
				run_combat();
			if (TS_noncom == 272) {
				print("At marketplace");
				run_choice(2);
			} 
			if (TS_noncom == 225) {
				if (get_property("is_mosher") != "true") {
					run_choice(1);
					while (get_property("moshed") != "true") {
						print("At tent, waiting for others to stage and mosher", "blue");
						waitq(10);
					}
					run_choice(1);
					cli_execute("/hobopolis off stage");
				}
				if (get_property("is_mosher") == "true") {
					while (to_int(get_property("people_staged")) < 6) {
						print("At tent, waiting until everyone is staged before moshing", "blue");
						print("If there is an incorrect count on the number of people staged, type \"set people_staged = #\"", "blue");
						waitq(5);
					}
					run_choice(2);
					run_choice(2);
					cli_execute("/hobopolis moshed");
				}
			}
			end_adv = my_adventures();
			adv_spent = start_adv - end_adv;
			print(adv_spent + " adventures spend doing mosh");
			print(num_mosh() + " mosh(es) executed", "blue");
		}
		if (!tent_open()) {
			while (to_int(get_property("people_unstaged")) < 6 && get_property("moshed") == "true") {
				print("waiting for everyone to get off stage");
				waitq(5);
			}
			if (get_property("parts_collection") != "scarehobo"){
				set_property("people_staged", "0");
				set_property("moshed", "false");
			}
			start_adv = my_adventures();
			if (get_property("parts_collection") == "scarehobo") {
				if (get_property("tent_stage") != "stage1") {
					set_property("tent_stage", "started");
					int scobo_to_use = 0;
					if (get_property("scobo_needed") == "")
						foreach n, needed in int[int]{10:60, 9:44, 8:28, 7:12, 6:0} { // keys 1 less than last time
							int total = 0;
							foreach part in roles
								if (!($strings[scarehobo, cagebot] contains part))
									total += min(n, richard(part));
							if (total >= needed) {
								scobo_to_use = n;
								set_property("scobo_needed", `{n}`);
								break;
							}
						}
					else
						scobo_to_use = to_int(get_property("scobo_needed"));
					foreach part in roles if (!($strings[scarehobo, cagebot] contains part))
						while (richard(part) < scobo_to_use) {
							prep(part);
							adventure(1, $location[Hobopolis Town Square]);
							if (!contains_text(LastAdvTxt(), rich_takes[part]))
								abort(`Richard failed to take {part}`);
							if (get_property("_lastCombatLost") == "true")
								abort ("It appears you lost the last combat, look into that");
						}
//					set_property("battleAction", "custom combat script");
//					set_property("currentMood", "boots");
					set_property("scobo_needed","");
					visit_url("clan_hobopolis.php?preaction=simulacrum&place=3&qty="+scobo_to_use);
					set_property("tent_stage", "stage1");
				}
				if (get_property("tent_stage") == "stage1") {
					cli_execute("/switch hobopolis");
					while (!tent_open()) {
						if (richard("boots") == min(richard("boots"), richard("eyes"), richard("guts"), richard("skulls"), richard("crotches"), richard("skins"))) {
							prep();
							adventure(1, $location[Hobopolis Town Square]);
							if (!contains_text(LastAdvTxt(), "Richard takes a charred hobo boots")) {
								abort ("Richard failed to get boots, look into that");
							}
						} else if (richard("eyes") == min(richard("boots"), richard("eyes"), richard("guts"), richard("skulls"), richard("crotches"), richard("skins"))) {
						prep();
							adventure(1, $location[Hobopolis Town Square]);
							if (!contains_text(LastAdvTxt(), "Richard takes a frozen hobo eyeballs")) {
								abort ("Richard failed to get eyes, look into that");
							}
						} else if (richard("guts") == min(richard("boots"), richard("eyes"), richard("guts"), richard("skulls"), richard("crotches"), richard("skins"))) {
							prep();
							adventure(1, $location[Hobopolis Town Square]);
							if (!contains_text(LastAdvTxt(), "Richard takes a stinking hobo guts")) {
								abort ("Richard failed to get guts, look into that");
							}
						} else if (richard("skulls") == min(richard("boots"), richard("eyes"), richard("guts"), richard("skulls"), richard("crotches"), richard("skins"))) {
							prep();
							adventure(1, $location[Hobopolis Town Square]);
							if (!contains_text(LastAdvTxt(), "Richard takes a creepy hobo skull")) {
								abort ("Richard failed to get skull, look into that");
							}
						} else if (richard("crotches") == min(richard("boots"), richard("eyes"), richard("guts"), richard("skulls"), richard("crotches"), richard("skins"))) {
							prep();
							adventure(1, $location[Hobopolis Town Square]);
							if (!contains_text(LastAdvTxt(), "Richard takes a hobo crotch")) {
								abort ("Richard failed to get crotches, look into that");
							}
						} else if (richard("skins") == min(richard("boots"), richard("eyes"), richard("guts"), richard("skulls"), richard("crotches"), richard("skins"))) {
							prep();
							adventure(1, $location[Hobopolis Town Square]);
							if (!contains_text(LastAdvTxt(), "Richard takes a hobo skin")) {
								abort ("Richard failed to get skins, look into that");
							}
						}
						set_property("battleAction", "custom combat script");
						set_property("currentMood", "boots");
						if (num_mosh() >= 8 && min(richard("boots"), richard("eyes"), richard("guts"), richard("skulls"), richard("crotches"), richard("skins")) >= 1) {
							visit_url("clan_hobopolis.php?preaction=simulacrum&place=3&qty="+ min(richard("boots"), richard("eyes"), richard("guts"), richard("skulls"), richard("crotches"), richard("skins")));
						}
						if (get_property("_lastCombatLost") == "true"){ //KoL Mafia detected that the last combat was lost so that the script is aborted and a whole bunch of adventures aren't wasted
							abort ("It appears you lost the last combat, look into that");
						}
					}
					set_property ("tent_stage", "finished");
				}
				end_adv = my_adventures();
				adv_spent = start_adv - end_adv;
				print(adv_spent + " adventures spend opening the next tent");
			} else {
				while (!tent_open() || mapimage() < 25) {
					print("Waiting for tent to open");
					waitq(10);
				}
			}
		}
	} until (mapimage() >= 25 && mapimage() != 125);
}

void main() {
	setup();
	sewer();
	phase_one();
	phase_two();
	phase_three();
	if (mapimage() == 25 || mapimage() == 26) {
		set_property("initialized" ,"1");
		set_property("chatbotScript", get_property("chatbotScriptStorage"));
		set_property("battleAction", "custom combat script");
		set_property("currentMood", "apathetic");
	}
}
