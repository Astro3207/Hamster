import varargs;

string[string] settings ={
	"help": "false",
	"roles": "false",
	"sewers": "false",
	"sewucky" : "false",
	"lucky" : "false",
	"tent": "false",
	"boots": "0",
	"eyes": "0",
	"guts": "0",
	"skulls": "0",
	"crotches": "0",
	"skins": "0",
	"MTR" : get_property("HaMTR")
};
record role {
	string ele;
	modifier ele_mod;
	skill spirit_of_ele;
	skill atk_spell;
};
role[string] roles = {
	"skins":	new role("",		$modifier[lantern],				$skill[spirit of nothing],		$skill[toynado]),
	"boots":	new role("hot",		$modifier[hot spell damage],	$skill[spirit of cayenne],		$skill[awesome balls of fire]),
	"skulls":	new role("spooky",	$modifier[spooky spell damage],	$skill[spirit of wormwood],		$skill[raise backup dancer]),
	"eyes":		new role("cold",	$modifier[cold spell damage],	$skill[spirit of peppermint],	$skill[snowclone]),
	"crotches":	new role("sleaze",	$modifier[sleaze spell damage],	$skill[spirit of bacon grease],	$skill[grease lightning]),
	"guts":		new role("stench",	$modifier[stench spell damage],	$skill[spirit of garlic],		$skill[eggsplosion]),
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
string sewer_image = visit_url("clan_hobopolis.php");
string chatbotScriptStorage = get_property("chatbotScript");
string autoSatisfyWithClosetStorage = get_property("autoSatisfyWithCloset");
int base_spellD;
float spelldmgp_value, myst_boost;

string LastAdvTxt() {
	string lastlog = session_logs(1)[0];
	int nowmark = max(lastlog.last_index_of(`[{my_turncount()}]`), lastlog.last_index_of(`[{my_turncount()}]`));
	if (nowmark == -1){
		waitq(3);
		lastlog = session_logs(1)[0];
		nowmark = max(lastlog.last_index_of(`[{my_turncount()}]`), lastlog.last_index_of(`[{my_turncount()}]`));
	}
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
	matcher sewer_grate_matcher = create_matcher("opened a?(\\d+)? sewer grates? \\((\\d+) turn", rlogs);
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

boolean avoid_gear(){
	boolean bad_gear = false;
	foreach eli in $items[double-ice box, enchanted fire extinguisher, Gazpacho's Glacial Grimoire, witch's bra, Codex of Capsaicin Conjuration, Ol' Scratch's ash can, Ol' Scratch's manacles, Snapdragon pistil, Chester's Aquarius medallion, Engorged Sausages and You, Sinful Desires, slime-covered staff, Necrotelicomnicon, The Necbromancer's Stein, Cookbook of the Damned, Wand of Oscus]{
		if ( have_equipped( eli ))
			cli_execute("unequip " + eli);
		if (item_amount( eli ) > 0){
			put_closet( item_amount( eli ), eli);
			bad_gear = true;
		}
	}
	return bad_gear;
}

void post_adv(){
	if (get_property("_lastCombatLost") == "true")
		abort("It appears you lost the last combat, look into that");
	if (my_adventures() == 0)
		abort("Ran out of adventures");
	if (my_inebriety() > inebriety_limit() || (my_inebriety() == inebriety_limit() && my_familiar() == $familiar[stooper]))
		abort("Looks like you are overdrunk or nearly there with stooper equipped, use a spice melange or something?");
}

float estimated_spelldmg(){
	float estimate;
	if (get_auto_attack() == 1005){
		float SC_bonus;
		if (my_class() == $class[seal clubber]){
			SC_bonus = 1.3;
		} else{
			SC_bonus = 1.25;
		}
		estimate = (floor((my_buffedstat($stat[muscle])*SC_bonus)-$monster[normal hobo].base_defense) + numeric_modifier("weapon damage")) * ((max(numeric_modifier("weapon damage percent"),0) + 100)/100) * max(0.50,(1-(numeric_modifier($modifier[monster level])*0.004)));
	} else {
		estimate = ((numeric_modifier($modifier[Spell Damage Percent]) + 100)/100) * (base_spellD + (myst_boost * my_buffedstat($stat[mysticality])) + numeric_modifier(roles[get_property("parts_collection")].ele_mod) + numeric_modifier($modifier[spell damage])) * max(0.50,(1-(numeric_modifier($modifier[monster level])*0.004)));
	}
	return estimate;
}

void setup() {
	buffer ccs = "if hasskill snokebomb; skill snokebomb; endif;if !monstername frog && !monstername newt && !monstername salamander; skill CLEESH; endif; attack;";
	write_ccs(ccs, "cleesh free runaway");
	if (have_skill($skill[stuffed mortar shell])){
		if (item_amount($item[seal tooth]) == 0)
			cli_execute("acquire seal tooth");
		buffer auto_parts = "if hasskill stuffed mortar shell; skill stuffed mortar shell; endif; use seal tooth;";
			write_ccs(auto_parts, "auto_parts");
	}
	set_property("battleAction", "custom combat script");
	if (settings.get_bool("MTR")){
		set_property("HaMTR", "true");
	} else {
		set_property("HaMTR", "false");
	}

	if (settings.get_bool("sewers") == false){
		if (settings.get_bool("help") == true){
			print_html("<b><font color=0000ff>hamster roles</font color=0000ff></b> will allow you to change your role and keep running");
			print_html("<b><font color=0000ff>hamster MTR=[true|false]</font color=0000ff></b> if set to true an override for mafia thumb ring to acc3 will be put in");
			print_html("<font color=0000ff><b>hamster <i>parts=int</i></font color=0000ff></b> options are:[boots | eyes | guts | skulls | crotches | skins] will allow you to collect the specified number of parts");
			print_html("<font color=0000ff><b>hamster sewers</b></font color=0000ff> will complete sewers (no grates and no lucky) and exit. Probably not the best bang for your buck for personal use.");
			print_html("<font color=0000ff><b>hamster sewucky</b></font color=0000ff> will use lucky to complete the last 10 explorations. Costs on average 5 clovers+adventures to save 1 trncount per person or up to 7 in total.");
			print_html("<font color=0000ff><b>hamster lucky</b></font color=0000ff> uses lucky to complete all of sewers. Costs 100 clovers+adentures to save 8-9 turncount per person or up to 57 in total.");
			print_html("<font color=0000ff><b>hamster tent</b></font color=0000ff> will use 1 scobo at a time and making parts as necessary until tent is open. Intended to be used if you aren't sure how many kills until the next tent");
			exit;
		}

		if (avoid_gear())
			print("Putting away gear that may change the element of your attack");
		
		if (!contains_text(visit_url("clan_basement.php?fromabove=1"), "opengrate.gif"))
			abort("Either you are in a choice or hobopolis isn't open yet");
			
		if ((get_property("initialized") == "1") || get_property("initialized") == ""){
			if (contains_text(sewer_image,"otherimages/hobopolis/sewer3.gif")){
				if (user_confirm("The script has detected that you have not been given a role and you have already started sewers. Press yes to continue to assign your role, press no to abort and figure out what happened") == false) {
					abort();
				}
			}
		} else if(contains_text(sewer_image,"otherimages/hobopolis/sewer1.gif") && !contains_text(sewer_image, "otherimages/hobopolis/sewer3.gif")){
			if (user_confirm("The script has detected that your last hamster run may have been incomplete, press yes if you have not adventured in sewers yet and need to set up, press no if you have already set up")){
				set_property("initialized", 1);
			}
		}

		if (settings.get_bool("roles"))
			set_property("initialized", "3");

		set_property("chatbotScript", "HamsterChat.ash");
		set_property("autoSatisfyWithCloset", "false");
		switch (to_int(get_property("initialized"))) {
			case 0:
			case 1:
				set_property("sewer_progress", 100); //saying that there's 100 chieftans until sewers is clearedW
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
				set_property("scobo_needed", "");
				set_property("hpAutoRecovery", 0.5);
				set_property("hpAutoRecoveryTarget", 0.95);
				set_property("mpAutoRecovery", 0.25);
				set_property("mpAutoRecoveryTarget", 0.75);
				cli_execute("chat");
				cli_execute("/switch hobopolis");
				set_property("initialized", 4); //to skip future initializations
				break;
			case 2:
				if (contains_text(sewer_image, "otherimages/hobopolis/sewer3.gif") && !contains_text(sewer_image, "otherimages/hobopolis/deeper.gif"))
					break;
				set_property("sewer_progress", 100); //saying that there's 100 chieftans until sewers is cleared
				break;
			case 3:
				set_property("is_mosher", user_confirm("Are you the mosher?"));
				set_property("parts_collection", user_prompt("What part will you be collecting?", roles));
				if (get_property("parts_collection") == "")
					abort();
				set_property("initialized", 4);
		}
		if (get_property("is_mosher") != "true" && get_property("parts_collection") != "cagebot"){
			foreach cl, it in instruments{
				try {
					if (my_class() == cl && closet_amount( it ) > 0)
						take_closet( 1 , it );
				} finally {
					if (my_class() == cl && item_amount(it) < 1 && equipped_item($slot[off-hand]) != it)
						abort("Missing your class instrument? To reset your role (e.g. to mosher or cagebot), type hamster roles");
				}
			}
		}
	}
	if (!have_skill($skill[CLEESH]))
		abort("Having CLEESH is essential, and my data says you don't");
}

void sewer() {
	int sewer_progress = to_int(get_property("sewer_progress"));
	town_map = visit_url("clan_hobopolis.php?place=2");
	if (contains_text(town_map , "clan_hobopolis.php?place=3")) { //checking if sewers is already cleared
		print("The Maze of Sewer Tunnels is already clear, skipping sewers", "orange") ;
		set_property("initialized", 2);
		return;
	}
	if (!user_confirm("You are currently in the clan "+get_clan_name()+" is the correct?"))
		abort();

	if (settings.get_bool("lucky") == false) {
		set_auto_attack(0015);
		set_ccs ("cleesh free runaway");
		familiar famrem = my_familiar();
		foreach f in $familiars[peace turkey, disgeist, left-hand man, disembodied hand]
			if (f.have_familiar()) {
				f.use_familiar();
				break;
			}
		if (get_property("parts_collection") == "cagebot") {
			maximize("-combat", false);
			if (settings.get_bool("MTR"))
				equip($item[Mafia Thumb Ring], $slot[acc3]);
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
				post_adv();
			} until (last_choice() == 211 || last_choice() == 212);
		}
		if (!user_confirm("Press yes when you know cagebot is caged \n one person can say /w ASSbot cage " + get_clan_name()))
			abort();
		set_property("choiceAdventure198", 1);
		set_property("choiceAdventure199", 1);
		set_property("choiceAdventure197", 1);
		maximize("-combat", false);
		if (settings.get_bool("MTR"))
			equip($item[Mafia Thumb Ring], $slot[acc3]);
		repeat {
			if (sewer_progress <= 10 && settings.get_bool("sewucky") == true) {
				break;
			}
			int[item] testitems = {
				$item[sewer wad]:				1,
				$item[unfortunate dumplings]:	1,
				$item[bottle of Ooze-O]:		1,
				$item[gatorskin umbrella]:		1,
				$item[oil of oiliness]:			3
			};
			foreach it, q in testitems
				retrieve_item(q, it);
			if (grates_opened() < 9 && settings.get_bool("sewers") == false) {
				set_property("choiceAdventure198", 3);
				set_property("choiceAdventure199", 2);
				set_property("choiceAdventure197", 2);
			}
			else {
				set_property("choiceAdventure198", 1);
				set_property("choiceAdventure199", 1);
				set_property("choiceAdventure197", 1);
				maximize("-combat, equip hobo code binder, equip gatorskin umbrella", false);
				if (settings.get_bool("MTR"))
					equip($item[Mafia Thumb Ring], $slot[acc3]);
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
			post_adv();
		} until (get_property("lastEncounter") == "At Last!");
		use_familiar(famrem);
	}

	if (settings.get_bool("lucky") == true || (settings.get_bool("sewucky") == true && sewer_progress <= 10)) {
		if (get_property("parts_collection") == "cagebot")
			abort("There's no point in doing lucky while being a cagebot? To reset your role (ie mosher or cagebot) type hamster roles");
		if (item_amount($item[11-leaf clover]) < sewer_progress) { //checks if there is enough clovers
			print("Not enough clovers? You have " + item_amount($item[11-leaf clover]) + " clovers, but you will need " + sewer_progress + " to clear the sewers with just clovers", "orange");
			abort ("If you've already cleared some of the sewers manually, type set sewer_progress = how many sewers adventures are left");
		}
		if (my_buffedstat($stat[moxie]) < ($monster[C. H. U. M. chieftain].monster_attack() + 10) && get_property("IveGotThis") != "true")
			abort ("Buffed moxie should be at least "+ ($monster[C. H. U. M. chieftain].monster_attack() + 10) +" to guarentee a safe passage. Contact organizers for help. If you are confident in your skillz type \"set IveGotThis = true\"");
		if (!outfit ("sewers")) {
			print("No outfit named sewers (capitalization matters), wearing a generic outfit", "blue");
			waitq(3);
			maximize("weapon damage", false);
			if (settings.get_bool("MTR"))
				equip($item[Mafia Thumb Ring], $slot[acc3]);
		}
		set_auto_attack(0);
		if (!set_ccs("sewers")) {
			print("No custom combat script, setting auto attack to weapon", "blue");
			waitq(3);
			set_property("battleAction", "attack with weapon");
		}
		repeat { //using 11-leaf clover before adventuring in sewers once
			if ((have_effect($effect[Lucky!]) == 0)){
				if (item_amount($item[11-leaf clover]) > 0){
					cli_execute("use 11-leaf clover");
				} else {
					print("The script has detected that you have " + have_effect($effect[Lucky!]) + " turns of Lucky! while you have " + item_amount($item[11-leaf clover]) + " 11-leaf clovers");
					abort("Lacking clovers????");
				}
			}
			adventure(1, $location[A Maze of Sewer Tunnels]);
			post_adv();
			if (contains_text(get_property("_lastCombatActions"),"sk15"))
				abort ("Last combat detected CLEESH against CHUM Chieftan, look into that");
			sewer_progress -= 1; //doing some calculations on how many chieftans are left
			set_property("sewer_progress", sewer_progress);
			print("C.H.U.M Chieftans left: " + sewer_progress, "orange");
			town_map = visit_url("clan_hobopolis.php?place=2");
			if(get_property("sewer_progress") == "0"){
				adventure(1, $location[A Maze of Sewer Tunnels]);
				if (get_property("lastEncounter") != "At Last!")
					abort("Excpected At Last! instead got" + get_property("lastEncounter"));
			}
		} until (contains_text(town_map , "clan_hobopolis.php?place=3") || to_int(get_property("sewer_progress")) <= 0); //checks if town map is open or the calculations say there are 0 chieftains left
		print("Sewers complete! (I think)", "orange");
		set_property("battleAction", "custom combat script");
	}
	set_auto_attack(0);
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
		if (have_skill($skill[Flavour of Magic]))
			use_skill(roles[get_property("parts_collection")].spirit_of_ele);
		if (!set_ccs(get_property("parts_collection"))) {
			if (!contains_text(override,"s"))
				waitq(3);
			print(`No custom combat script named {get_property("parts_collection")} (capitalization matters) or stuffed mortar shell, setting auto attack to stuffed mortar shell (or hobopolis skill if you don\'t have that)`, "blue");
			if (!set_ccs("auto_parts") || !have_skill($skill[Flavour of Magic]) || get_property("parts_collection") == "skins"){
				if (!have_skill(roles[get_property("parts_collection")].atk_spell)){
					abort(`Missing skill {roles[get_property("parts_collection")].atk_spell}, please set a ccs named {get_property("parts_collection")}`);
				} else {
					base_spellD = 10;
					myst_boost = 0.1;
					set_auto_attack(to_int(roles[get_property("parts_collection")].atk_spell));
				}
			} else {
				set_property("battleAction", "custom combat script");
				if (get_auto_attack() != 3007)
					set_auto_attack(3007);
				base_spellD = 32;
				myst_boost = 0.5;
			}
		} else {
			print("Since you have a ccs set the stat check will not be accurate since I don't know what spell you chose", "blue");
			set_auto_attack(0);
			base_spellD = 30;
			myst_boost = 0.3;
			set_property("battleAction", "custom combat script");
		}
		set_property("currentMood", get_property("parts_collection"));
		mood_execute(1);
		if (settings.get_bool("MTR"))
			equip($item[Mafia Thumb Ring], $slot[acc3]);
		if ((estimated_spelldmg() < ($monster[normal hobo].monster_hp() + 100))){
			if (!(outfit(get_property("parts_collection")))) {
				print(`No outfit named {get_property("parts_collection")} (capitalization matters), wearing a generic outfit`, "blue");
				if (!contains_text(override,"s"))
					waitq(3);
				spelldmgp_value = ((((numeric_modifier($modifier[Spell Damage Percent]) + 100 + 100)/100) * (base_spellD + (myst_boost * my_buffedstat($stat[mysticality])) + numeric_modifier($modifier[spell damage]) + numeric_modifier(roles[get_property("parts_collection")].ele_mod))) - estimated_spelldmg())/((((numeric_modifier($modifier[Spell Damage Percent]) + 100)/100) * (base_spellD + (myst_boost * (my_buffedstat($stat[mysticality])+100)) + numeric_modifier($modifier[spell damage]) + numeric_modifier(roles[get_property("parts_collection")].ele_mod))* max(0.50,(1-(numeric_modifier($modifier[monster level])*0.004)))) - estimated_spelldmg());
				maximize(`2.8 {roles[get_property("parts_collection")].ele} spell damage, {spelldmgp_value} spell damage percent, mys, -999999 lantern`, false);
				if (settings.get_bool("MTR"))
					equip($item[Mafia Thumb Ring], $slot[acc3]);
			}
		}
		if (avoid_gear())
			print("Oops! Looks like you still had gear that may change the element of your attack, putting away now. If you failed the stat check you can rerun.", "olive");
		if ((estimated_spelldmg() < ($monster[normal hobo].monster_hp() + 100) || my_buffedstat($stat[moxie]) < ($monster[normal hobo].monster_attack() + 10)) && get_property("IveGotThis") != "true") {
			if (estimated_spelldmg() < ($monster[normal hobo].monster_hp() + 100))
				print("You are expected to do " + estimated_spelldmg() + " damage when casting the hobopolis spell, while you need to deal " + ($monster[normal hobo].monster_hp() + 100) + " damage to guarentee a hobo part from normal hobos.");
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

void partial_parts(){
    foreach part in roles {
		if (part == "cagebot" || part == "scarehobo")
			continue;
        if (settings.get_int(part) > 0){
            set_property("partialParts", "true");
            int parts_count = settings.get_int(part) + richard(part);
            prep(part);
            int parts_left = parts_count - richard(part);
            while (richard(part) < parts_count) {
                adventure(1, $location[Hobopolis Town Square]);
                post_adv();
                if (!LastAdvTxt().contains_text(rich_takes[part]) && last_monster() == $monster[normal hobo])
                    abort(rich_takes[part].replace_string("takes", "failed to take"));
                parts_left = parts_count - richard(part);
                print(part + " left to collect: " + parts_left);
            }
            set_property("battleAction", "custom combat script");
            set_property("currentMood", "apathetic");
        }
    }
    if (to_boolean(get_property("partialParts"))){
        set_property("partialParts", "false");
        exit;
    }
}

// clearing the first half of town square
void collections() {
	set_property("initialized", 2);
	set_property("choiceAdventure230", "2"); //Skipping binder purchase
	set_property("choiceAdventure272", "2"); //skipping marketplace
	set_property("choiceAdventure230", "2"); //shouldn't ever happen but leaving Hodgeman alone
	set_property("choiceAdventure225", "0"); //stopping if A Tent is encountered
	if (my_adventures() < 165 && get_property("adv_checked") != "true") { //I'm approximating that 140 adventures are needed for the entire run
		set_property("adv_checked", "true");
		abort("I would recommend having at least 165 adventures from this point on");
	}
	else
		set_property("adv_checked", "true"); //setting it so that the adventure check only happens once


	if (mapimage() <= 8) { //phase 1 collect 135 hobo parts
		int scobo_start = 135;
		if (roles contains get_property("parts_collection") && !($strings[scarehobo, cagebot] contains get_property("parts_collection"))) {
			prep();
			int parts_left = scobo_start - richard(get_property("parts_collection"));
			while (richard(get_property("parts_collection")) < scobo_start) {
				adventure(1, $location[Hobopolis Town Square]);
				post_adv();
				if (!LastAdvTxt().contains_text(rich_takes[get_property("parts_collection")]) && last_monster() == $monster[normal hobo])
					abort(rich_takes[get_property("parts_collection")].replace_string("takes", "failed to take"));
				parts_left = scobo_start - richard(get_property("parts_collection"));
				print(get_property("parts_collection") + " left to collect: " + parts_left);
			}
		}

		set_property("battleAction", "custom combat script");
		set_property("currentMood", "apathetic");
		while ((richard("boots") < scobo_start || richard("eyes") < scobo_start || richard("guts") < scobo_start || richard("skulls") < scobo_start || richard("crotches") < scobo_start || richard("skins") < scobo_start) && mapimage() <= 8) {
			foreach thing in $strings[skins, boots, skulls, eyes, crotches, guts]
			if (richard(thing) < scobo_start)
				print(`Looks we are short {scobo_start - richard(thing)} {thing}{thing == "crotch"?"e":""}`);
			print("Not all parts have been collected, waiting. If you'd like to change roles type hamster roles");
			waitq(5);
			if (richard("boots") >= scobo_start && richard("eyes") >= scobo_start && richard("guts") >= scobo_start && richard("skulls") >= scobo_start && richard("crotches") >= scobo_start && richard("skins") >= scobo_start && mapimage() <= 8)
				break;
		}
	}
}

// scobomaker opens the first tent
void first_tent() {
	if (get_property("parts_collection") != "scarehobo") {
		while (!tent_open() && mapimage() <= 12) {
			print("Tent not opened yet, waiting for designated person to open it");
			waitq(5);
		}
		return;
	}

	int scobo_used = 0;
	int manual_hobos_killed = 0;
	if (mapimage() < 9) {
		print("Letting other people's script catch up");
		wait(15);
		rlogs = visit_url("clan_raidlogs.php");
		matcher manual_hobos = create_matcher("\\bdefeated\\s+Normal hobo x\\s+(\\d+)", rlogs);
		while (manual_hobos.find()) {
			manual_hobos_killed += (manual_hobos.group(1)).to_int();
		}
		scobo_used = ceil(1375-manual_hobos_killed)/10;
		print("Making scobos until image 12, may take a few seconds", "blue");
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
						if (!contains_text(LastAdvTxt(), rich_takes[part]) && last_monster() == $monster[normal hobo])
							abort(`Richard failed to take {part}`);
						post_adv();
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
	if (mapimage() == 12 && get_property("tent_stage") != "step1") {
		set_property("tent_stage", "started");
		waitq(3);
		int scobo_to_use = 0;
		if (get_property("scobo_needed") == "")
			foreach n, needed in int[int]{13:78, 12:72, 10:49, 9:19, 8:4, 7:0} {
				int total = 0;
				foreach part in roles
					if (!($strings[scarehobo, cagebot] contains part)){
						total += min(n, richard(part));
						if (total >= needed) {
							scobo_to_use = n;
							set_property("scobo_needed", `{n}`);
							break;
						}
					}
			}
		else
			scobo_to_use = to_int(get_property("scobo_needed"));
		foreach part in roles if (!($strings[scarehobo, cagebot] contains part))
			while (richard(part) < scobo_to_use) {
				prep(part);
				adventure(1, $location[Hobopolis Town Square]);
				if (!contains_text(LastAdvTxt(), rich_takes[part]) && last_monster() == $monster[normal hobo]) 
					abort(`Richard failed to take {part}`);
				post_adv();
			}
		if (to_int(get_property("scobo_needed")) < 9){
			set_property("scobo_needed", "");
			abort("Looks like the script skipped some lines please rerun the script as scobos needed is definitely too low"); //debugging lines
		}
		set_property("scobo_needed", "");
		visit_url("clan_hobopolis.php?preaction=simulacrum&place=3&qty="+scobo_to_use);
		waitq(3);
		set_property("tent_stage", "step1");
		waitq(3);
	}

	if (mapimage() == 12 && get_property("tent_stage") == "step1") {
		while (!tent_open()) {
			foreach part in roles if (!($strings[scarehobo, cagebot] contains part))
				if (richard(part) == min(richard("boots"), richard("eyes"), richard("guts"), richard("skulls"), richard("crotches"), richard("skins"))) {
					prep(part);
					adventure(1, $location[Hobopolis Town Square]);
					if (!contains_text(LastAdvTxt(), rich_takes[part]) && last_monster() == $monster[normal hobo])
						abort(`Richard failed to take {part}`);
					post_adv();
					if (tent_open())
						break;
				}
		}
		set_property ("tent_stage", "finished");
	}
}

// everyone alternates between working and reopening the tent
void until_hodge() {
	familiar famrem = my_familiar();
	foreach f in $familiars[peace turkey, disgeist, left-hand man, disembodied hand]
		if (f.have_familiar()) {
			f.use_familiar();
			break;
		}
	repeat {
		cli_execute("/switch hobopolis");
		if (tent_open()) {
			if (settings.get_bool("tent"))
				exit;
			foreach cl, it in instruments
				if (my_class() == cl && get_property("is_mosher") != "true" && !maximize(`-combat, equip {it}`, false))
					abort("failed to equip a hobo instrument...");
				if (settings.get_bool("MTR"))
					equip($item[Mafia Thumb Ring], $slot[acc3]);
			set_auto_attack(0015);
			set_ccs ("cleesh free runaway");
			set_property("moshed", "false");
			int TS_noncom = 0;
			string town_square = visit_url("adventure.php?snarfblat=167");
			matcher matcher_TS_noncom = create_matcher("whichchoice value=(\\d+)", town_square); 
			if (matcher_TS_noncom.find()){
				TS_noncom += matcher_TS_noncom.group(1).to_int();
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
						chat_clan("offstage" , "hobopolis" );
						waitq(3);
					}
					if (get_property("is_mosher") == "true") {
						while (to_int(get_property("people_staged")) < 6) {
							print("At tent, waiting until everyone is staged before moshing", "blue");
							waitq(5);
						}
						run_choice(2);
						run_choice(2);
						waitq(5);
						while (get_property("moshed") != "true") {
							print("Waiting until KoL recognizes the mosh", "blue");
							waitq(5);
						}
					}
					print(num_mosh() + " moshes executed", "blue");
				} else {
					print("The script thinks this is a wandering NC... let's hope it is", "blue");
					run_choice(-1);
				}
			} else {
				run_combat();
			}
		}
		if (!tent_open() && mapimage() != 25) {
			use_familiar(famrem);
			if (get_property("parts_collection") == "scarehobo" || settings.get_bool("tent")) {
				if (get_property("moshed") == "true") {
					while (to_int(get_property("people_unstaged")) < 6 && get_property("moshed") == "true") {
						print("waiting for everyone to get off stage");
						waitq(5);
					}
					set_property("people_staged", "0");
					set_property("people_unstaged", "0");
					set_property("moshed", "false");
					waitq(5);
				}
				if (num_mosh() == 8 || settings.get_bool("tent")){
					set_property("tent_stage", "step1");
				}
				if (get_property("tent_stage") != "step1") {
					set_property("tent_stage", "started");
					wait(3);
					int scobo_to_use = 0;
					if (get_property("scobo_needed") == "")
						foreach n, needed in int[int]{11:65, 10:50, 9:35, 8:20, 7:5, 6:0} { // keys 1 less than last time
							int total = 0;
							foreach part in roles
								if (!($strings[scarehobo, cagebot] contains part)){
									total += min(n, richard(part));
									if (total >= needed) {
										scobo_to_use = n;
										set_property("scobo_needed", `{n}`);
										break;
									}
								}
						}
					else
						scobo_to_use = to_int(get_property("scobo_needed"));
					foreach part in roles if (!($strings[scarehobo, cagebot] contains part))
						while (richard(part) < scobo_to_use) {
							prep(part);
							adventure(1, $location[Hobopolis Town Square]);
							if (!contains_text(LastAdvTxt(), rich_takes[part]) && last_monster() == $monster[normal hobo])
								abort(`Richard failed to take {part}`);
							post_adv();
						}
					set_property("scobo_needed","");
					visit_url("clan_hobopolis.php?preaction=simulacrum&place=3&qty="+scobo_to_use);
					wait(3);
					print(scobo_to_use + " scobos just used", "blue");
					set_property("tent_stage", "step1");
					wait(3);
				}
				if (get_property("tent_stage") == "step1") {
					while (!tent_open()) {
						foreach part in roles if (!($strings[scarehobo, cagebot] contains part))
							if (richard(part) == min(richard("boots"), richard("eyes"), richard("guts"), richard("skulls"), richard("crotches"), richard("skins"))) {
								prep(part);
								adventure(1, $location[Hobopolis Town Square]);
								if (!contains_text(LastAdvTxt(), rich_takes[part])  && last_monster() == $monster[normal hobo])
									abort(`Richard failed to take {part}`);
								post_adv();
								if ((num_mosh() >= 7 || settings.get_bool("tent")) && min(richard("boots"), richard("eyes"), richard("guts"), richard("skulls"), richard("crotches"), richard("skins")) >= 1) {
									print("Making 1 Scobo...", "orange");
									visit_url("clan_hobopolis.php?preaction=simulacrum&place=3&qty="+ min(richard("boots"), richard("eyes"), richard("guts"), richard("skulls"), richard("crotches"), richard("skins")));
									waitq(3);
								}
								if (tent_open())
									break;
							}
						set_property("battleAction", "custom combat script");
						post_adv();
					}
					set_property ("tent_stage", "finished");
				}
			} else {
				while (!tent_open() && (mapimage() < 25 || mapimage() == 125)) {
					print("Waiting for tent to open");
					set_property("people_staged", "0");
					if (to_int(get_property("people_unstaged")) >= 6)
						set_property("people_unstaged", "0");
					set_property("moshed", "false");
					cli_execute("/switch hobopolis");
					waitq(10);
				}
			}
			cli_execute("chat");
			maximize("-combat", false);
			if (settings.get_bool("MTR"))
				equip($item[Mafia Thumb Ring], $slot[acc3]);
		}
	} until ((mapimage() >= 25 && mapimage() != 125) || num_mosh() >= 8);
}

void finishing(int argument) {
	if (get_auto_attack() != 0)
		set_auto_attack(0);
	set_property("battleAction", "custom combat script");
	set_property("currentMood", "apathetic");
	set_property("chatbotScript", chatbotScriptStorage);
	set_property("autoSatisfyWithCloset", autoSatisfyWithClosetStorage);
	if (mapimage() == 25 || mapimage() == 26) {
		set_property("initialized" ,"1");
		foreach eli in $items[double-ice box, enchanted fire extinguisher, Gazpacho's Glacial Grimoire, witch's bra, Codex of Capsaicin Conjuration, Ol' Scratch's ash can, Ol' Scratch's manacles, Snapdragon pistil, Chester's Aquarius medallion, Engorged Sausages and You, Sinful Desires, slime-covered staff, Necrotelicomnicon, The Necbromancer's Stein, Cookbook of the Damned, Wand of Oscus]
			if ( closet_amount( eli ) > 0)
				take_closet(  closet_amount( eli ), eli);
		print ("It apprears the uberhodge is up, good luck", "green");
	} else if (argument == 0){
		abort("Uh oh, there was a (hopefully) one time bug, please rerun hamster");
	}
}

void main(string... args) {
	settings = tokenize(args, settings);
	try{
		setup();
		sewer();
		if (settings.get_bool("sewers"))
			exit;
		if (settings.get_bool("tent") == false){
			partial_parts();
			collections();
			first_tent();
		}
		until_hodge();
	} finally{
		finishing(count(args));
	}
}
