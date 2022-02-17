#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes_zm\_hud_util;
#include maps\mp\gametypes_zm\_hud_message;
#include maps\mp\zombies\_zm;
#include maps\mp\zombies\_zm_utility;

init()
{
    // Give your player the Packed M1911 aka Mustang and Sally
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

    for (;;) {
        self waittill("spawned_player");
        // Give your player the Packed DSR50 with Ironsights and Suppressor
        self IPrintLnBold("Hello world player!");
        level thread drawZombiesCounter();
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