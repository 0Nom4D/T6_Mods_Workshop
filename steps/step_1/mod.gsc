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
    }
}

onplayerspawned()
{
    self endon("disconnect");
	level endon("end_game");

    for (;;) {
        self waittill("spawned_player");
        // Prints a text on screen
    }
}