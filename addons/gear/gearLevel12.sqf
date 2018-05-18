/*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*///*//*//*/

//	@file Version: 2.0
//	@file Name gearLevel12.sqf
//	@file Author: Mokey
//	@file Modified: Shinedwarf
//	@file Created: 4/21/2018 09:48

/*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published
by the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.
/*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*/

private ["_player"];

_player = _this;

_player setVariable ["gmoney",1000];

{_player removeWeapon _x} forEach weapons _player;
{_player removeMagazine _x} forEach magazines _player;

removeallitems _player;
removeVest _player;
removeBackpack _player;
removeGoggles _player;
removeHeadgear _player;

_player addBackpack "G_Bergen";
_player addMagazines ["9Rnd_45ACP_Mag", 1];
_player addWeapon "hgun_ACPC2_F";

_player selectWeapon "hgun_ACPC2_F";
switch (true) do
	{
		case (["_medic_", typeOf _player] call fn_findString != -1):
		{
			_player addItem "MediKit";
			_player removeItem "";
		};
		case (["_engineer_", typeOf _player] call fn_findString != -1):
		{
			_player addItem "ToolKit";
			_Player addItem "MineDetector";
			_player removeItem "";
		};
		case (["_sniper_", typeOf _player] call fn_findString != -1):
		{
			_player addWeapon "Rangefinder";
			_player removeItem "";
		};
			case (["_diver_", typeOf _player] call fn_findString != -1):
		{
			_player addVest "V_RebreatherIA";
			_player addGoggles "G_Diving";
			_player removeItem "";

		};
	};
