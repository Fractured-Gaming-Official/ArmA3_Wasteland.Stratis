// ******************************************************************************************
// * This project is licensed under the GNU Affero GPL v3. Copyright © 2014 A3Wasteland.com *
// ******************************************************************************************
//	@file Name: mission_HostileHeliFormation.sqf
//	@file Author: JoSchaap, AgentRev

if (!isServer) exitwith {};
#include "mainMissionDefines.sqf"

private ["_heliChoices", "_convoyVeh", "_veh1", "_veh2", "_veh3", "_createVehicle", "_vehicles", "_leader", "_speedMode", "_waypoint", "_vehicleName", "_vehicleName2", "_numWaypoints", "_box1", "_box2", "_box3", "_smoke"];

_setupVars =
{
	_missionType = "Hostile Helicopters";
	_locationsArray = nil;
};

_setupObjects =
{
	_missionPos = markerPos (((call cityList) call BIS_fnc_selectRandom) select 0);

	_heliChoices =
	[
		[["B_Heli_Attack_01_dynamicLoadout_F", "BlackfootAG"], ["B_Heli_Light_01_dynamicLoadout_F", "pawneeSkyhunter"]],
 		[["O_Heli_Attack_02_dynamicLoadout_F", "KajmanAG"], ["O_Heli_Light_02_dynamicLoadout_F", "orcaDAGR"]],
 		[["B_Heli_Attack_01_dynamicLoadout_F", "BlackfootAA"], ["I_Heli_light_03_dynamicLoadout_F", "HellAT"]]
	];


	_convoyVeh = _heliChoices call BIS_fnc_selectRandom;

	_veh1 = _convoyVeh select 0;
	_veh2 = _convoyVeh select 1;
	_veh3 = _convoyVeh select 1;

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

		_vehicle = createVehicle [_type, _position, [], 0, "FLY"];
		_vehicle setVariable ["R3F_LOG_disabled", true, true];

 		if (_variant != "") then
 		{
 			_vehicle setVariable ["A3W_vehicleVariant", _variant, true];
 		};

		[_vehicle] call vehicleSetup;
		_vehicle setDir _direction;
		_aiGroup addVehicle _vehicle;
		_soldier moveInDriver _vehicle;

		switch (true) do
		{
			case (_type isKindOf "Heli_Transport_01_base_F"):
			{
				// these choppers have 2 turrets so we need 2 gunners
				_soldier = [_aiGroup, _position] call createRandomSoldierC;
				_soldier moveInTurret [_vehicle, [1]];

				_soldier = [_aiGroup, _position] call createRandomSoldierC;
				_soldier moveInTurret [_vehicle, [2]];
			};

			case (_type isKindOf "Heli_Attack_01_base_F" || _type isKindOf "Heli_Attack_02_base_F"):
			{
				// these choppers need 1 gunner
				_soldier = [_aiGroup, _position] call createRandomSoldierC;
				_soldier moveInGunner _vehicle;
			};
		};

		[_vehicle, _aiGroup] spawn checkMissionVehicleLock;
		_vehicle
	};

	_aiGroup = createGroup CIVILIAN;
	_vehicles =
	[
		[_veh1, _missionPos vectorAdd ([[random 50, 0, 0], random 360] call BIS_fnc_rotateVector2D), 0] call _createVehicle,
		[_veh2, _missionPos vectorAdd ([[random 50, 0, 0], random 360] call BIS_fnc_rotateVector2D), 0] call _createVehicle,
		[_veh3, _missionPos vectorAdd ([[random 50, 0, 0], random 360] call BIS_fnc_rotateVector2D), 0] call _createVehicle
	];

	_leader = effectiveCommander (_vehicles select 0);
	_aiGroup selectLeader _leader;
	_aiGroup setCombatMode "YELLOW"; // units will defend themselves
	_aiGroup setBehaviour "SAFE"; // units feel safe until they spot an enemy or get into contact
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

	_missionPos = getPosATL leader _aiGroup;
	_missionPicture = getText (configFile >> "CfgVehicles" >> (_veh1 param [0,""]) >> "picture");
 	_vehicleName = getText (configFile >> "CfgVehicles" >> (_veh1 param [0,""]) >> "displayName");
 	_vehicleName2 = getText (configFile >> "CfgVehicles" >> (_veh2 param [0,""]) >> "displayName");
	_missionHintText = format ["A formation of Experimental Helicopters containing a <t color='%3'>%1</t> and two <t color='%3'>%2</t> are patrolling the island. Destroy them and recover their cargo!", _vehicleName, _vehicleName2, mainMissionColor];
	_numWaypoints = count waypoints _aiGroup;
};

_waitUntilMarkerPos = {getPosATL _leader};
_waitUntilExec = nil;
_waitUntilCondition = {currentWaypoint _aiGroup >= _numWaypoints};
_failedExec = nil;

_successExec =
{
	_vehicle spawn // spawn crate 1 - soulkobk
	{
		params ["_vehicle"];
		_crate = createVehicle ["Box_East_Wps_F", (getPosATL _vehicle) vectorAdd ([[_vehicle call fn_vehSafeDistance, 0, 0], random 360] call BIS_fnc_rotateVector2D), [], 5, "None"];
		_crate setDir random 360;
		_crate allowDamage false;
		waitUntil {!isNull _crate};
		_crateParachute = createVehicle ["O_Parachute_02_F", (getPosATL _crate), [], 0, "CAN_COLLIDE" ];
		_crateParachute allowDamage false;
		_crate attachTo [_crateParachute, [0,0,0]];
		_crate call randomCrateLoadOut;
		waitUntil {getPosATL _crate select 2 < 5};
		detach _crate;
		deleteVehicle _crateParachute;
		_smokeSignal = createVehicle  ["SmokeShellRed", getPosATL _crate, [], 0, "CAN_COLLIDE" ];
		_lightSignal = createVehicle  ["Chemlight_red", getPosATL _crate, [], 0, "CAN_COLLIDE" ];
		_smokeSignal attachTo [_crate, [0,0,0.2]];
		_lightSignal attachTo [_crate, [0,1,0]];
		_crate allowDamage true;
	};
	_vehicle spawn // spawn crate 2 - soulkobk
	{
		params ["_vehicle"];
		_crate = createVehicle ["Box_East_Wps_F", (getPosATL _vehicle) vectorAdd ([[_vehicle call fn_vehSafeDistance, 0, 0], random 360] call BIS_fnc_rotateVector2D), [], 5, "None"];
		_crate setDir random 360;
		_crate allowDamage false;
		waitUntil {!isNull _crate};
		_crateParachute = createVehicle ["O_Parachute_02_F", (getPosATL _crate), [], 0, "CAN_COLLIDE" ];
		_crateParachute allowDamage false;
		_crate attachTo [_crateParachute, [0,0,0]];
		_crate call randomCrateLoadOut;
		waitUntil {getPosATL _crate select 2 < 5};
		detach _crate;
		deleteVehicle _crateParachute;
		_smokeSignal = createVehicle  ["SmokeShellRed", getPosATL _crate, [], 0, "CAN_COLLIDE" ];
		_lightSignal = createVehicle  ["Chemlight_red", getPosATL _crate, [], 0, "CAN_COLLIDE" ];
		_smokeSignal attachTo [_crate, [0,0,0.2]];
		_lightSignal attachTo [_crate, [0,1,0]];
		_crate allowDamage true;
	};
	_vehicle spawn // spawn crate 2 - soulkobk
	{
		params ["_vehicle"];
		_crate = createVehicle ["Box_East_Wps_F", (getPosATL _vehicle) vectorAdd ([[_vehicle call fn_vehSafeDistance, 0, 0], random 360] call BIS_fnc_rotateVector2D), [], 5, "None"];
		_crate setDir random 360;
		_crate allowDamage false;
		waitUntil {!isNull _crate};
		_crateParachute = createVehicle ["O_Parachute_02_F", (getPosATL _crate), [], 0, "CAN_COLLIDE" ];
		_crateParachute allowDamage false;
		_crate attachTo [_crateParachute, [0,0,0]];
		_crate call randomCrateLoadOut;
		waitUntil {getPosATL _crate select 2 < 5};
		detach _crate;
		deleteVehicle _crateParachute;
		_smokeSignal = createVehicle  ["SmokeShellRed", getPosATL _crate, [], 0, "CAN_COLLIDE" ];
		_lightSignal = createVehicle  ["Chemlight_red", getPosATL _crate, [], 0, "CAN_COLLIDE" ];
		_smokeSignal attachTo [_crate, [0,0,0.2]];
		_lightSignal attachTo [_crate, [0,1,0]];
		_crate allowDamage true;
	};
	_successHintMessage = "The sky is clear again, the enemy patrol was taken out! Ammo crates have fallen out their chopper.";
};

_this call mainMissionProcessor;
