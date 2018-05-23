// ******************************************************************************************
// * This project is licensed under the GNU Affero GPL v3. Copyright © 2018 A3Wasteland.com *
// ******************************************************************************************
//	@file Name: createDivingGroup.sqf
//	@file Author: soulkobk
//	@file Updated: 5:33 PM 23/05/2018 by soulkobk

if (!isServer) exitWith {};

	private ["_unitClasses","_unitGroup","_missionPosition","_unit","_unitAmount"];

	_unitClasses =
	[
	"C_man_polo_1_F",
	"C_man_polo_2_F",
	"C_man_polo_3_F",
	"C_man_polo_4_F",
	"C_man_polo_5_F",
	"C_man_polo_6_F"
	];

	_unitGroup = _this select 0;
	_missionPosition = _this select 1;
	_unitAmount = param [2, 12, [0]];
	_missionRadius = param [3, 100, [0]];

	for "_i" from 1 to _unitAmount do
	{
		_unitPosition = [0,0,0];
		_overWater = false;
		while {!_overWater} do
		{
			_unitPosition = _missionPosition vectorAdd ([[(random _missionRadius) + 10, 0, 0], random 360] call BIS_fnc_rotateVector2D);
			if (surfaceIsWater _unitPosition) then
			{
				_overWater = true;
			};
		};
		if !(_unitPosition isEqualTo [0,0,0]) then
		{
			_unit = _unitGroup createUnit [(selectRandom _unitClasses),_unitPosition,[],0,"FORM"];
			waitUntil {alive _unit};
			_unit setPos _unitPosition;
			removeAllAssignedItems _unit;
			_unit addVest "V_RebreatherB";
			_unit addUniform "U_B_Wetsuit";
			_unit addGoggles "G_Diving";
			_unit addMagazine "20Rnd_556x45_UW_Mag";
			_unit addWeapon "arifle_SDAR_F";
			_unit addMagazine "20Rnd_556x45_UW_Mag";
			_unit addMagazine "20Rnd_556x45_UW_Mag";
			_unit spawn refillPrimaryAmmo;
			_unit call setMissionSkill;
			_unit addRating 9999999;
			_unit addEventHandler ["Killed", server_playerDied];
		};
		sleep 0.5;
	};

	_soldiers = units _unitGroup;
	_soldiers
