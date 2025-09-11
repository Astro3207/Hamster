# Hamster.ash

A Kingdom of Loathing script that is intended to be a low set up script for getting the Hamster from Hodgman. This is mostly original with some inspiration from Grotfang's Hands Free Hamster script, EZHobo, and a Forums of Loathing post from somewhere.

This script looks so different and greatly polished due to DamianDominoDavis, thanks! And the people in ASS greatly helped me bebug the script, god there weere so many bugs.

## Installation
To install this script in KolMafia, simply use the following command in the gCLI:

`git checkout Astro3207/Hamster`

## What will I need to run it?
I've tried to keep the requirements as minimal as possible. You have the option to have outfits, custom combat script (ccs), or moods. If you do name them they should be named: boots, eyes, guts, skulls, crotches, skins (sewers is only needed if you decide to run Lucky!). If you lack the outfits then the script runs a modifier maximum best for the situation. If you don't have a ccs for the respective body parts, the script will fall back on stuffed mortar shell. If you lack the skill stuffed mortar shell or flavour of magic or need to collect skins (stuffed mortar shell can't reliably collct skins) the script will then fall on 120mp hoboplis spells. So in a pinch where you have a participant who does not have stuffed mortar shell or flavour of magic, they can but the 120mp hobopolis skills to use. There will be no mood set if you didn't make one. You will also need sufficient stats to do all of this of course. So basically if you have nothing set up to your preference __you only need stuffed mortar shell and flavour of magic (or wassail if you're collecting skins), if your stats are not sufficient to collect the parts, I would reccommend creating your own outfit, ccs, and mood__.
In addition there's the basic hobopolis requirements including 20 hobo glyphs and hobopolis instruments if you are not the mosher.

## What will this script do?
- It will first ask you for your role: one of the six body part makers, scarehobo maker, cagebot, and/or mosher.  
> What is the scarehobo maker? They will making the scarehobos, but also be responsible for collecting the parts one at a time after the initial tent opening. While others will spend 135 adventure collecting parts before the first tent, the scarehobo maker can spend 0 to 269 turns in total collecting body parts, but likely will spend around 134 (with 90% certainty). If the scarehobo maker is spending more than 154 turns (about 4% chance) collecting parts, it is likely to be over 1100 adventures.  

- It will ask if you want to Lucky! Your way through the sewers, otherwise it will CLEESH and tunnel your way through the sewers. It will also give you the option to finish off with Lucky! when you have 10 or less explorations left. It will first wait for cagebot to get caged. Then it will prioritize opening 9 grates before going down any sewer tunnels. I (and one other person has validated) that 9 to 12 grates opened is optimal, although I could be wrong. Then it'll take the tunnels and switch to Lucky! for the last <10 explorations if desired.  
- Then the 6 parts collectors will collect 135 body parts.  
- Once 106 of each part is collected the scarehobo maker will try to get to town square image 12 (to determine how good your scarehobo RNG is) then move towards image 125. If they ever run out of parts the script will make more, but only 1 kill at a time until tent is open.  
- Once 6 people has staged, the mosher will mosh.  
- When 6 people say "off stage" in hobopolis chat the scarehobo maker will continue. This repeats for 6 more moshes. Before tent 8 is open, the scarehobo maker will instead use scarehobos as they are prepared (before this the -script will save scarehobos for the next mosh as necessary).
- Everyone's script will stop when image 25 is seen or mosh afer mosh 8 meaning that Hodgman is up allowing you to collect any banquets and fighting Uber-Hodge.  

## What are it's features?
  - It will abort if a combat is lost.
  - It will abort if a body part fails to collect.
  - It will check with you that you are in the right clan.
  - It is hands free after answering the initial questions.
  - It is 2-3 scripts for everyone.
  - It is tolerant to aborts, wether it's from you or the script.
  - Somewhat optimizes your setup to make sure you can get the parts
  - It is tolerant to others people who are not running the script or Mafia (my clan has people who doesn't run Mafia). For more info see people not running the script below. The only people who really should be running the script is the scarehobo maker (or they just have to be flawless).

## Things that it does not do:
  - Check that you are on track for a Hamster (considering adding it, but requires calculations on my part)
  - Does not use sneaks, free kills, and free runaways (well it does use some but not all the free runs)

## For people not running the script:
  Simple all you have to do is your given role. The only specifics are that you should only collect 135 body parts initially and I would not reccomend you being the scarehobo maker. Stage as you normally would but say "off stage" into hobopolis chat when you get off.
