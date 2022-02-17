#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes_zm\_hud_util;
#include maps\mp\gametypes_zm\_hud_message;
#include maps\mp\zombies\_zm;
#include maps\mp\zombies\_zm_utility;

init()
{
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
        self IPrintLnBold("Hello world player!");
        level thread drawZombiesCounter();
    }
}

healthPlayer()
{
	self endon("disconnect");
	self.healthText = createFontString("Objective" , 1.7);
    // Draws the player on top center with left offset of 300px
    while(true) {
        // Draws the player's health
    }
}

drawZombiesCounter()
{
    level.zombiesCounter = createServerFontString("hudsmall", 1.9);
    // Set point font at Bottom Center

    while (true) {
        // Draws the number of zombies on current wave
    }
}