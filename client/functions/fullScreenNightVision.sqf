// ************************************************************************************************
// * This project is licensed under the GNU Affero GPL v3. Copyright © 2018 soulkobk.blogspot.com *
// ************************************************************************************************
// * written by soulkobk (soulkobk.blogspot.com) @ 01/05/2018 for full screen night vision *hack*
// *
// * unequip your nvgoggles and equip yourself with the combat goggles (green) as a replacement
// * which will make your night vision full screen.
// *
// * equipped nvgoggles = black border night vision.
// * equipped combat goggles (green) = full screen night vision.
// *
// * load this file as...
// * [] execVM "fullScreenNightVision.sqf";
// *
// * enjoy a mod-free version of full screen night vision without any ppEffect.
// ************************************************************************************************

if (!hasInterface) exitWith {};

SL_var_fullScreenNightVision =
[
	"G_Combat_Goggles_tna_F"
];

SL_fn_fullScreenNightVision = {
	params ["_displayCode","_keyCode","_isShift","_isCtrl","_isAlt"];
	_handled = false;
	if (_keyCode in actionKeys "NightVision") then
	{
		switch SL_var_fullScreenNightVisionMode do
		{
			case 0: {
				9876 cutText ["", "PLAIN", 0.001, false];
				if (cameraView != "GUNNER") then
				{
					if (goggles player in SL_var_fullScreenNightVision) then
					{
						player action ["nvGoggles", player];
						SL_var_fullScreenNightVisionMode = currentVisionMode player;
						_handled = true;
					};
				};
			};
			case 1: {
				9876 cutText ["", "PLAIN", 0.001, false];
				if (cameraView != "GUNNER") then
				{
					player action ["nvGogglesOff", player];
					SL_var_fullScreenNightVisionMode = currentVisionMode player;
					_handled = true;
				};
			};
			case 2: {
				9876 cutText ["", "PLAIN", 0.001, false];
				_handled = false;
			};
		};
	};
	_handled
};

player addEventHandler ["GetOutMan", {
	params ["_player", "_role", "_vehicle", "_turret"];
	switch SL_var_fullScreenNightVisionMode do
	{
		case 1: {
			9876 cutText ["", "PLAIN", 0.001, false];
			if (cameraView != "GUNNER") then
			{
				if (goggles player in SL_var_fullScreenNightVision) then
				{
					player action ["nvGoggles", player];
					SL_var_fullScreenNightVisionMode = currentVisionMode player;
					_handled = true;
				};
			};
		};
		case 0: {
			9876 cutText ["", "PLAIN", 0.001, false];
			if (cameraView != "GUNNER") then
			{
				player action ["nvGogglesOff", player];
				SL_var_fullScreenNightVisionMode = currentVisionMode player;
				_handled = true;
			};
		};
		case 2: {
			9876 cutText ["", "PLAIN", 0.001, false];
			_handled = false;
		};
	};
}];

SL_var_fullScreenNightVisionMode = currentVisionMode player;

waitUntil {!(isNull (findDisplay 46))};
(findDisplay 46) displayAddEventHandler ["KeyDown", "_this call SL_fn_fullScreenNightVision;"];
