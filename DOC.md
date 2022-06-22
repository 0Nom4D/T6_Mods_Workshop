# GSC Scripting References

***Note: Please note that function having 'x' can have multiple syntax. Ask the workshop creator for any questions.***

## Visual content functions

|Function|Parameters|Description|
|:------:|:--------:|:---------:|
|createServerFontString|string, float|Create a String using the font and the size passed as parameter|
|x setPoint|string, string, string, int|Set a visual variable on screen at position given as parameters|
|get_round_enemy_array|None|Get size of the enemy array describing the number of zombies in current round|
|x setValue|size_t|Set a visual variable to a value|
|x setText|string|Sets a string to a visual variable|
|self IPrintLnBold|string|Displays text given as parameter on screen|

## Threading functions

|Function|Parameters|Description|
|:------:|:--------:|:---------:|
|self waittill|string, {object}|Stops the script until an action is done. Example: `waittill("connecting", player)` waits until player is connected to activate further steps|
|self waittill_any_return|string[]|Stops the script until one of the actions given as parameter is done.|
|x thread|None|Creates a new thread|
|x endon|string|Stops a script's thread when event given as parameter is triggered. Example: `endon("death")` let the function thread alive until the player is alive|

## Game Properties functions

|Function|Parameters|Description|
|:------:|:--------:|:---------:|
|getDvar|string|Gets the content of a global game engine variable|
|self giveWeapon|string|Give player the weapon corresponding to weapon id given as parameter|
