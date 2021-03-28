The goal of this mod is to adjust the screen location of the weapon pawn in the Weapon Upgrade UI

It succeeds. It also restores the 'spinning tilting' weapon on selection of upgrades function

Included various options in the base config that -might- be standard. Feel free to expirement yourself

+ModClassOverrides=(BaseGameClass="UIArmory_WeaponUpgrade", ModClass="WOTC_RustyWeaponUpgradeUI.UIArmory_WeaponUpgrade_Offset")

ADDS WeaponPanelImage = "_ConventionalCannon" AND UIArmoryCameraPointTag = 'UIPawnLocation_WeaponUpgrade_Cannon' to weapons that have nothing in these fields

===================
STEAM DESC	https://steamcommunity.com/sharedfiles/filedetails/?id=2042829719
===================
[h1] What is this for? [/h1]
The goal of this mod is to adjust the screen location of the weapon model in the Weapon Upgrade UI for better positioning and ease of readability.

[h1] What does it do?[/h1]
The first thing this mod does is adds [i]WeaponPanelImage = "_ConventionalCannon"[/i] and [i]UIArmoryCameraPointTag = 'UIPawnLocation_WeaponUpgrade_Cannon'[/i] to any weapon template in the game that might be missing them. The Weapon Upgrade UI needs these to be able to place a model on the screen .... NO it does not seem to affect anything else to my knowledge and does not require it to actually match the weapon type.

Secondly the config file XComUI has options [b]per weapon template[/b] to adjust the position of the displayed weapon.

And thirdly it restores the weapon movement display when selecting upgrades, if the weapon has them set. This function may cause the weapon preview to 'flicker' as it readjusts between upgrade options.

[h1] Config [/h1]
Included in the default config are some common offenders like the Cannons, Bolt Caster and SPARK Rifles. Some modded weapon types like SPARK Flamethrowers and Chemthrowers.

There are however literally [i]hundreds[/i] of modded weapons on the workshop and I'm just not prepared to go through checking each and every one. Please feel free to add your own config entries to the discussion below.

[h1] Compatibility and Issues [/h1]
[b]The mod overrides UIArmory_WeaponUpgrade[/b] and will likely conflict with other mods that do the same. I had no issue using it with Musashi's Tactical Armory UI.. and that mod was indeed my inspiration for this one.

Conflicts with [url=https://steamcommunity.com/sharedfiles/filedetails/?id=1142377029] Grimy's Loot Mod [/url]
Both mods can work together, however your GeoScape will slow to a crawl... ...
The changes here have been submitted for approval into the base Community Highlander, when this happens the MCO conflict will dissolve.

[h1] Credits and Thanks [/h1]
Many thanks to Musashi whose code I studied for making this and Team CX for ever helpful support.

I'd also like to thank the XCOM2 Modders discord for always being supportive of all my dumb questions.

~ Enjoy [b]!![/b] and please [url=https://www.buymeacoffee.com/RustyDios] buy me a Cuppa Tea[/url]
