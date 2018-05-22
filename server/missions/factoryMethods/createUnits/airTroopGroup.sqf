if (!isServer) exitWith {};

private ["_soldierTypes", "_uniformTypes", "_vestTypes", "_weaponTypes", "_group", "_position", "_rank", "_soldier","_nbUnits"];

_soldierTypes = ["C_man_polo_1_F", "C_man_polo_2_F", "C_man_polo_3_F", "C_man_polo_4_F", "C_man_polo_5_F", "C_man_polo_6_F"];
_uniformTypes = ["U_B_CombatUniform_mcam_vest", "U_B_CombatUniform_mcam_tshirt" ,"U_B_CombatUniform_mcam"];
_vestTypes = ["V_PlateCarrier1_rgr","V_PlateCarrier2_rgr"];
_weaponTypes = ["arifle_TRG20_F","LMG_Mk200_F","arifle_MXM_F","arifle_MX_GL_F"];

_group = _this select 0;
_position = _this select 1;
_rank = param [2, "", [""]];
_nbUnits = param [2, 14, [0]];
_radius = param [3, 10, [0]];

for "_i" from 1 to _nbUnits do
{
	_uPos = _position vectorAdd ([[random _radius, 0, 0], random 360] call BIS_fnc_rotateVector2D);
	_soldier = _group createUnit[(selectRandom _soldierTypes), _uPos, [], 0, "Form"];
	_soldier setPos _uPos;

	//[_soldierTypes call BIS_fnc_selectRandom, _position, [], 0, "NONE"];
	_soldier addUniform (_uniformTypes call BIS_fnc_selectRandom);
	_soldier addVest (_vestTypes call BIS_fnc_selectRandom);
	[_soldier, _weaponTypes call BIS_fnc_selectRandom, 3] call BIS_fnc_addWeapon;
	if (_rank != "") then
	{
		_soldier setRank _rank;
	};

	_parachute = createVehicle ["Steerable_Parachute_F",(getPosATL _soldier),[],0,"CAN_COLLIDE"];
	_parachute allowDamage false;
	_soldier assignAsDriver _parachute;
	_soldier moveInDriver _parachute;
	_soldier spawn refillPrimaryAmmo;
	_soldier spawn addMilCap;
	_soldier call setMissionSkill;
	_soldier addEventHandler ["Killed", server_playerDied];
	[_soldier] call randomSoldierLoadout;
	sleep 0.5;
};
_leader = leader _group;


_soldier
