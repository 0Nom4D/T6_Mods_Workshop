#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes_zm\_hud_util;
#include maps\mp\gametypes_zm\_hud_message;
#include maps\mp\zombies\_zm;
#include maps\mp\zombies\_zm_utility;

init()
{
    level.start_weapon = "m1911_upgraded_zm";
    level.perk_purchase_limit = 9;
    level thread onPlayerConnect();
}

onPlayerConnect()
{
    for(;;) {
        level waittill ("connecting", player);
        player thread onplayerspawned();
        player thread healthPlayer();
    }
}

onplayerspawned()
{
    self endon("disconnect");
	level endon("end_game");

	map = getDvar("ui_zm_mapstartlocation");
    for (;;) {
        self waittill("spawned_player");
        switch (map) {
            case "transit":
                self giveWeapon("gl_tar21_zm+gl+mms");
                break;
            case "town":
                self giveWeapon("hamr_upgraded_zm+grip+acog");
                break;
            case "prison":
                self giveWeapon("blundergat_upgraded_zm");
                break;
            case "tomb":
                self giveWeapon("c96_upgraded_zm");
                self giveWeapon("mg08_upgraded_zm");
                break;
            case "farm":
                self giveWeapon("galil_upgraded_zm+reflex");
                break;
            case "processing":
                self giveWeapon("an94_upgraded_zm+mms+grip");
                break;
            case "rooftop":
                self giveWeapon("slipgun_upgraded_zm");
                break;
            case "nuked":
                self giveWeapon("xm8_upgraded_zm+reflex+gl");
                break;
        }
        self givemaxammo(self getCurrentWeapon());
        self IPrintLnBold("Hello world player!");
        self thread giveAllPerks(map);
        level thread drawZombiesCounter();
    }
}

giveAllPerks(map)
{
    // Make the thread end if the player dies, disconnect or the game ends
    self endon("perk_abort_drinking");

    switch (map) {
        // Give perks depending on the map
        // Be careful, some maps can crash if you give your player every perk
    }
}

healthPlayer()
{
	self endon("disconnect");
	self.healthText = createFontString("Objective" , 1.7);
    self.healthText setPoint("CENTER", "TOP", 300, "CENTER");
    while(true) {
        self.healthText setText( "^2HEALTH: ^7"+ self.health);
        wait 0.5;
    }
}

doGivePerk(perk)
{
    // Make the thread end if the player dies, disconnect or the game ends
    if (!(self hasperk(perk) || (self maps/mp/zombies/_zm_perks::has_perk_paused(perk))))
    {
        // Give the player the perk
        self notify("burp");
    }
}

drawZombiesCounter()
{
    level.zombiesCounter = createServerFontString("hudsmall", 1.9);
    level.zombiesCounter setPoint("CENTER", "CENTER", "CENTER", 190);

    while (true) {
        enemies = get_round_enemy_array().size + level.zombie_total;
        if (enemies != 0)
            level.zombiesCounter.label = &"Zombies: ^1";
        else
            level.zombiesCounter.label = &"Zombies: ^6";
        level.zombiesCounter setValue(enemies);
        wait 0.05;
    }
}