// ******************************************************************************************
// * This project is licensed under the GNU Affero GPL v3. Copyright © 2014 A3Wasteland.com *
// ******************************************************************************************
//	@file Name: mission_HostileHeliFormation.sqf
//	@file Author: JoSchaap, AgentRev
//	@file Modified: [FRAC] Mokey
//	@file missionSuccessHandler Author: soulkobk

if (!isServer) exitwith {};
#include "mainMissionDefines.sqf"

private ["_lastVehiclePos","_heliChoices", "_convoyVeh", "_veh1Class", "_veh2Class", "_veh3Class", "_createVehicle", "_vehicles", "_leader", "_speedMode", "_waypoint", "_vehiclePrimary", "_vehicleSupport", "_numWaypoints", "_box1", "_box2", "_box3", "_smoke"];

private ["_veh1Object","_veh2Object","_veh3Object"];

_setupVars =
{
	_missionType = "Hostile Helicopters";
	_locationsArray = nil;
};

_setupObjects =
{
	_createVehicle =
	{
		private ["_type", "_position", "_direction", "_variant", "_vehicle", "_soldier"];
		_type = _this select 0;
		_position = _this select 1;
		_direction = _this select 2;
		_variant = _type param [1,"",[""]];
		if (_type isEqualType []) then
		{
			_type = _type select 0;
		};
		_vehicle = createVehicle [_type,_position,[],0,"FLY"];
		_vehicle setVariable ["R3F_LOG_disabled",true,true];
		if (_variant != "") then
		{
			_vehicle setVariable ["A3W_vehicleVariant",_variant,true];
		};
		[_vehicle] call vehicleSetup;
		_vehicle setDir _direction;
		_aiGroup addVehicle _vehicle;
		_soldier = [_aiGroup, _position] call createRandomSoldierC;
		_soldier moveInDriver _vehicle;
		switch (true) do
		{
			case (_type isKindOf "Heli_Transport_01_base_F"):
			{
				_soldier = [_aiGroup, _position] call createRandomSoldierC;
				_soldier moveInTurret [_vehicle, [1]];

				_soldier = [_aiGroup, _position] call createRandomSoldierC;
				_soldier moveInTurret [_vehicle, [2]];
			};

			case (_type isKindOf "Heli_Attack_01_base_F" || _type isKindOf "Heli_Attack_02_base_F"):
			{
				_soldier = [_aiGroup, _position] call createRandomSoldierC;
				_soldier moveInGunner _vehicle;
			};
		};
		if (_type isKindOf "Air") then
		{
			{
				if (["CMFlare", _x] call fn_findString != -1) then
				{
					_vehicle removeMagazinesTurret [_x, [-1]];
				};
			} forEach getArray (configFile >> "CfgVehicles" >> _type >> "magazines");
		};
		[_vehicle, _aiGroup] spawn checkMissionVehicleLock;
		_vehicle
	};
	_missionPos = markerPos (((call cityList) call BIS_fnc_selectRandom) select 0);
	_heliChoices =
	[
		["B_Heli_Transport_01_F", ["B_Heli_Light_01_dynamicLoadout_F", "pawneeNormal"]],
		["B_Heli_Transport_01_camo_F", ["O_Heli_Light_02_dynamicLoadout_F", "orcaDAGR"]],
		["B_Heli_Transport_01_F", "I_Heli_light_03_dynamicLoadout_F"]
	];
	if (missionDifficultyHard) then
	{
		(_heliChoices select 0) set [0, "B_Heli_Attack_01_dynamicLoadout_F"];
		(_heliChoices select 1) set [0, "O_Heli_Attack_02_dynamicLoadout_F"];
		(_heliChoices select 2) set [0, "O_Heli_Attack_02_dynamicLoadout_F"];
	};
	_convoyVeh = selectRandom _heliChoices;
	_veh1Class = _convoyVeh select 0;
	_veh2Class = _convoyVeh select 1;
	_veh3Class = _convoyVeh select 1;
	_aiGroup = createGroup CIVILIAN;
	_directionToFly = random 360; // fly direction.
	_veh1Object = [_veh1Class,([_missionPos,100,0] call BIS_fnc_relPos),_directionToFly] call _createVehicle;
	_veh2Object = [_veh2Class,([_missionPos,100,120] call BIS_fnc_relPos),_directionToFly] call _createVehicle;
	_veh3Object = [_veh3Class,([_missionPos,100,240] call BIS_fnc_relPos),_directionToFly] call _createVehicle;
	_vehicles = [_veh1Object,_veh2Object,_veh3Object];
	_leader = effectiveCommander (_vehicles select 0);
	_aiGroup selectLeader _leader;
	_aiGroup setCombatMode "YELLOW";
	_aiGroup setBehaviour "SAFE";
	_aiGroup setFormation "VEE";
	_speedMode = if (missionDifficultyHard) then { "NORMAL" } else { "LIMITED" };
	_aiGroup setSpeedMode _speedMode;
	{
		_waypoint = _aiGroup addWaypoint [markerPos (_x select 0), 0];
		_waypoint setWaypointType "MOVE";
		_waypoint setWaypointCompletionRadius 50;
		_waypoint setWaypointCombatMode "YELLOW";
		_waypoint setWaypointBehaviour "SAFE";
		_waypoint setWaypointFormation "VEE";
		_waypoint setWaypointSpeed _speedMode;
	} forEach ((call cityList) call BIS_fnc_arrayShuffle);
	_missionPicture = getText (configFile >> "CfgVehicles" >> (_veh1Class param [0,""]) >> "picture");
	_vehiclePrimary = getText (configFile >> "CfgVehicles" >> (_veh1Class param [0,""]) >> "displayName");
	_vehicleSupport = getText (configFile >> "CfgVehicles" >> (_veh2Class param [0,""]) >> "displayName");
	_missionHintText = format ["A formation of armed helicopters containing a <t color='%3'>%1</t> and two <t color='%3'>%2</t> are patrolling the island. Destroy them and recover their cargo!", _vehiclePrimary, _vehicleSupport, mainMissionColor];
	_numWaypoints = count (wayPoints _aiGroup);
};
_waitUntilMarkerPos = {getPosATL _leader};
_waitUntilSuccessCondition = {(!(alive _veh1Object) && !(alive _veh2Object) && !(alive _veh3Object) && !(alive _leader))};
_waitUntilCondition = {currentWaypoint _aiGroup >= _numWaypoints};
_failedExec = nil;

#include "..\missionSuccessHandler.sqf"

_missionCratesSpawn = true;
_missionCrateAmount = 4;
_missionCrateSmoke = true;
_missionCrateSmokeDuration = 120;
_missionCrateChemlight = true;
_missionCrateChemlightDuration = 120;

_missionMoneySpawn = false;
_missionMoneyAmount = 100000;
_missionMoneyBundles = 10;
_missionMoneySmoke = true;
_missionMoneySmokeDuration = 120;
_missionMoneyChemlight = true;
_missionMoneyChemlightDuration = 120;

_missionSuccessMessage = "The sky is clear again, the enemy patrol was taken out! Ammo crates have fallen out their chopper.";

_this call mainMissionProcessor;
