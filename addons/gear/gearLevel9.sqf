/*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*///*//*//*/

//	@file Version: 2.0
//	@file Name gearLevel9.sqf
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

_player setVariable ["gmoney",900];

{_player removeWeapon _x} forEach weapons _player;
{_player removeMagazine _x} forEach magazines _player;
removeVest _player;
removeBackpack _player;

_player addBackpack "B_Carryall_oli";
_player addVest "V_PlateCarrierIA1_dgtl";
_player linkItem "NVGoggles";
_player linkItem "ItemGPS";
_player addWeapon "Binocular";
_player addMagazines ["HandGrenade", 2];
_player addItem "FirstAidKit";
_player addHeadgear "H_HelmetB_light";
_player addMagazines ["9Rnd_45ACP_Mag", 2];
_player addWeapon "hgun_ACPC2_F";

switch (true) do
	{
		case (["_medic_", typeOf _player] call fn_findString != -1):
		{
			_player addItem "MediKit";
			_player addMagazines ["30Rnd_65x39_caseless_mag", 2];
			_player addMagazines ["3Rnd_Smoke_Grenade_shell", 1];
			_player addMagazines ["3Rnd_HE_Grenade_shell", 1];
			_player addWeapon "arifle_MX_GL_F";
			_player addPrimaryWeaponItem "optic_Hamr";
			_player addMagazines ["RPG32_F", 1];
			_player addWeapon "launch_RPG32_F";
			_player addMagazines ["SmokeShell", 2];
			_player selectWeapon "arifle_MX_GL_F";
		};
		case (["_engineer_", typeOf _player] call fn_findString != -1):
		{
			_player addItem "ToolKit";
			_Player addItem "MineDetector";
			_player unassignItem "Binocular";
			_player removeItem "Binocular";
			_player addWeapon "Laserdesignator";
			_player addItem "Laserbatteries";
			_player addMagazines ["30Rnd_65x39_caseless_mag", 3];
			_player addWeapon "arifle_MXC_F";
			_player addPrimaryWeaponItem "optic_Hamr";
			_player addPrimaryWeaponItem "muzzle_snds_H_MG_blk_F";
			_player addMagazines ["RPG32_F", 1];
			_player addWeapon "launch_RPG32_F";
			_player addMagazines ["MiniGrenade", 2];
			_player addMagazines ["SLAMDirectionalMine_Wire_Mag", 2];
			_player addMagazines ["ATMine_Range_Mag", 1];
			_player selectWeapon "arifle_MXC_F";
		};
		case (["_sniper_", typeOf _player] call fn_findString != -1):
		{
			_player addWeapon "Rangefinder";
			_player addMagazines ["20Rnd_762x51_Mag", 3];
			_player addWeapon "srifle_EBR_F";
			_player addPrimaryWeaponItem "optic_DMS";
			_player addPrimaryWeaponItem "muzzle_snds_B";
			_player addPrimaryWeaponItem "bipod_01_F_blk";
			_player addMagazines ["RPG32_F", 1];
			_player addWeapon "launch_RPG32_F";
			_player addMagazines ["APERSTripMine_Wire_Mag", 2];
			_player addMagazines ["ClaymoreDirectionalMine_Remote_Mag", 2];
			_player selectWeapon "srifle_EBR_F";
		};
		case (["_diver_", typeOf _player] call fn_findString != -1):
		{
			_player addVest "V_RebreatherIA";
			_player addGoggles "G_Diving";
			_player addMagazines ["30Rnd_556x45_Stanag_Tracer_Green", 3];
			_player addMagazines ["20Rnd_556x45_UW_mag", 4];
			_player addWeapon "arifle_SDAR_F";
			_player addMagazines ["MiniGrenade", 4];
			_player selectWeapon "arifle_SDAR_F";
		};
	};
