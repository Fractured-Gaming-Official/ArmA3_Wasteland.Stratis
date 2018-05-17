/*
    ----------------------------------------------------------------------------------------------

    Copyright © 2016 soulkobk (soulkobk.blogspot.com)

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as
    published by the Free Software Foundation, either version 3 of the
    License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program. If not, see <http://www.gnu.org/licenses/>.

    ----------------------------------------------------------------------------------------------

    Name: overRideLauncherOptics.sqf
    Version: 1.0.0
    Author: soulkobk (soulkobk.blogspot.com)
    Creation Date: 9:33 PM 04/07/2016
    Modification Date: 8:11 PM 21/07/2017

    Description:

    Parameter(s): none

    Example: none

    Change Log:
    1.0.0 -    original base script.

    ----------------------------------------------------------------------------------------------
*/

if (!hasInterface) exitWith {};

SL_overRideLauncher =
	[
		"launch_B_Titan_F",
		"launch_B_Titan_short_F",
		"launch_B_Titan_short_tna_F",
		"launch_B_Titan_tna_F",
		"launch_I_Titan_F",
		"launch_I_Titan_short_F",
		"launch_MRAWS_green_F",
		"launch_MRAWS_green_rail_F",
		"launch_MRAWS_olive_F",
		"launch_MRAWS_olive_rail_F",
		"launch_MRAWS_sand_F",
		"launch_MRAWS_sand_rail_F",
		"launch_NLAW_F",
		"launch_O_Titan_F",
		"launch_O_Titan_ghex_F",
		"launch_O_Titan_short_F",
		"launch_O_Titan_short_ghex_F",
		"launch_O_Vorona_brown_F",
		"launch_O_Vorona_green_F",
		"launch_RPG32_F",
		"launch_RPG32_ghex_F",
		"launch_RPG7_F",
		"launch_Titan_F",
		"launch_Titan_short_F"
	];

SL_fn_nightVisionLauncher = {
	params ["_displayCode","_keyCode","_isShift","_isCtrl","_isAlt"];
	_handled = false;
	if (_keyCode in actionKeys "NightVision") then
	{
		SL_visionModeLauncher = currentVisionMode player;
		switch SL_visionModeLauncher do
		{
			case 0: {
				9875 cutText ["", "PLAIN", 0.001, false];
				if (cameraView == "GUNNER") then
				{
					_launcherParents = [(configFile >> "CfgWeapons" >> (currentWeapon player)),true] call BIS_fnc_returnParents;
					_isLauncher = "Launcher" in _launcherParents; // make sure what the player is holding is an actual launcher.
					_isLauncherAllowed = ((currentWeapon player) in SL_overRideLauncher); // check if the launcher is in the allowed array
					if (_isLauncher && _isLauncherAllowed) then // if is launcher and in the allowed array...
					{
						SL_currentLauncher = (currentWeapon player);
						SL_modeLauncher = uiNameSpace getVariable ["SL_fn_launcherState",0];
						switch SL_modeLauncher do
						{
							case 0: {
								setApertureNew [2, 8, 14, .9];
								SL_colorCorrectionLauncher = ppEffectCreate ["ColorCorrections",1500];
								SL_colorCorrectionLauncher ppEffectEnable true;
								SL_colorCorrectionLauncher ppEffectAdjust [1,1,0,[0,0.8,2,0.3],[1,5,5,0.5],[2,-1.5,0.8,-0.62],[0,0,0,0,0,0,4]];
								SL_colorCorrectionLauncher ppEffectCommit 0;
								SL_filmGrainLauncher = ppEffectCreate ["FilmGrain",2050];
								SL_filmGrainLauncher ppEffectEnable true;
								SL_filmGrainLauncher ppEffectAdjust [0.15,0.5,0.25,0.5,0.5,true];
								SL_filmGrainLauncher ppEffectCommit 0;
								uiNameSpace setVariable ["SL_fn_launcherState",1];
								[] spawn
								{
									waitUntil {(uiNameSpace getVariable "SL_fn_launcherState" isEqualTo 0) || (cameraView != "GUNNER") || !(SL_currentLauncher isEqualTo (currentWeapon player))};
									if (SL_modeLauncher isEqualTo 0) then
									{
										setAperture -1;
										ppEffectDestroy SL_colorCorrectionLauncher;
										ppEffectDestroy SL_filmGrainLauncher;
										uiNameSpace setVariable ["SL_fn_launcherState",0];
									};
								};
							};
							case 1: {
								setAperture -1;
								ppEffectDestroy SL_colorCorrectionLauncher;
								ppEffectDestroy SL_filmGrainLauncher;
								uiNameSpace setVariable ["SL_fn_launcherState",0];
							};
						};
					_handled = true;
					};
				};
			};
		};
	};
	_handled
};

waitUntil {!(isNull (findDisplay 46))};
(findDisplay 46) displayAddEventHandler ["KeyDown", "_this call SL_fn_nightVisionLauncher;"];
