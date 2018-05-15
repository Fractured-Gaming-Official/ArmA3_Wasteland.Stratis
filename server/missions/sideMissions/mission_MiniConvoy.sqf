// ******************************************************************************************
// * This project is licensed under the GNU Affero GPL v3. Copyright © 2014 A3Wasteland.com *
// ******************************************************************************************
//	@file Version: 2.1
//	@file Name: mission_MiniConvoy.sqf
//	@file Author: JoSchaap / routes by Del1te - (original idea by Sanjo), AgentRev
//	@file Created: 31/08/2013 18:19

if (!isServer) exitwith {};
#include "sideMissionDefines.sqf";

private ["_convoyVeh", "_veh1", "_veh2", "_veh3", "_createVehicle", "_vehicles", "_leader", "_speedMode", "_waypoint", "_vehicleName", "_numWaypoints", "_box1", "_box2"];

_setupVars =
{
	_missionType = "Truck Convoy";
	_locationsArray = LandConvoyPaths;
};

_setupObjects =
{
	private ["_starts", "_startDirs", "_waypoints"];
	call compile preprocessFileLineNumbers format ["mapConfig\convoys\%1.sqf", _missionLocation];

	// pick the vehicles for the convoy
	_convoyVeh = if (missionDifficultyHard) then
	{
		["I_G_Offroad_01_armed_F", "I_Truck_02_transport_F", "I_G_Offroad_01_F"]
	}
	else
	{
		[
			["B_Quadbike_01_F", "C_Van_01_box_F", "B_Quadbike_01_F"],
			["I_G_Offroad_01_F", "I_Truck_02_transport_F", "I_G_Offroad_01_F"]
		] call BIS_fnc_selectRandom;
	};

	_veh1 = _convoyVeh select 0;
	_veh2 = _convoyVeh select 1;
	_veh3 = _convoyVeh select 2;

	_createVehicle =
	{
		private ["_type", "_position", "_direction", "_vehicle", "_soldier"];

		_type = _this select 0;
		_position = _this select 1;
		_direction = _this select 2;

		_vehicle = createVehicle [_type, _position, [], 0, "None"];
		_vehicle setVariable ["R3F_LOG_disabled", true, true];
		_vehicle setVariable ["A3W_skipAutoSave", true, true];
		[_vehicle] call vehicleSetup;

		_vehicle setDir _direction;
		_aiGroup addVehicle _vehicle;

		_soldier = [_aiGroup, _position] call createRandomSoldier;
		_soldier moveInDriver _vehicle;

		_soldier = [_aiGroup, _position] call createRandomSoldier;
		_soldier moveInCargo [_vehicle, 0];

		switch (true) do
		{
			case (_type isKindOf "Offroad_01_armed_base_F"):
			{
				_soldier = [_aiGroup, _position] call createRandomSoldier;
				_soldier moveInGunner _vehicle;
			};
			case (_type isKindOf "C_Van_01_box_F"):
			{
				[_vehicle, "\A3\Soft_F_Bootcamp\Van_01\Data\Van_01_ext_IG_01_CO.paa", [0]] call applyVehicleTexture; // Apply camo instead of civilian color
			};
		};

		[_vehicle, _aiGroup] spawn checkMissionVehicleLock;

		_vehicle
	};

	_aiGroup = createGroup CIVILIAN;

	_vehicles =
	[
		[_veh1, _starts select 0, _startDirs select 0] call _createVehicle,
		[_veh2, _starts select 1, _startDirs select 1] call _createVehicle,
		[_veh3, _starts select 2, _startDirs select 2] call _createVehicle
	];

	_leader = effectiveCommander (_vehicles select 0);
	_aiGroup selectLeader _leader;

	_aiGroup setCombatMode "YELLOW"; // units will defend themselves
	_aiGroup setBehaviour "SAFE"; // units feel safe until they spot an enemy or get into contact
	_aiGroup setFormation "STAG COLUMN";

	_speedMode = if (missionDifficultyHard) then { "NORMAL" } else { "LIMITED" };

	_aiGroup setSpeedMode _speedMode;

	{
		_waypoint = _aiGroup addWaypoint [_x, 0];
		_waypoint setWaypointType "MOVE";
		_waypoint setWaypointCompletionRadius 25;
		_waypoint setWaypointCombatMode "YELLOW";
		_waypoint setWaypointBehaviour "SAFE"; // safe is the best behaviour to make AI follow roads, as soon as they spot an enemy or go into combat they WILL leave the road for cover though!
		_waypoint setWaypointFormation "STAG COLUMN";
		_waypoint setWaypointSpeed _speedMode;
	} forEach _waypoints;

	_missionPos = getPosATL leader _aiGroup;

	_missionPicture = getText (configFile >> "CfgVehicles" >> _veh2 >> "picture");
	_vehicleName = getText (configFile >> "CfgVehicles" >> _veh2 >> "displayName");

	_missionHintText = format ["A <t color='%2'>%1</t> transporting 2 weapon crates is being escorted. Stop the convoy!", _vehicleName, sideMissionColor];

	_numWaypoints = count waypoints _aiGroup;
};

_waitUntilMarkerPos = {getPosATL _leader};
_waitUntilExec = nil;
_waitUntilCondition = {currentWaypoint _aiGroup >= _numWaypoints};

_failedExec = nil;

// _vehicles are automatically deleted or unlocked in missionProcessor depending on the outcome

_successExec =
{
	_numCratesToSpawn = 2; // edit this value to how many crates are to be spawned!
	_lastPos = _this;
	_i = 0;
	while {_i < _numCratesToSpawn} do
	{
		_lastPos spawn
		{
			_lastPos = _this;
	     		_crate = createVehicle ["Box_East_Wps_F", _lastPos, [], 5, "None"];
	     		_crate setDir random 360;
	     		_crate allowDamage false;
	     		waitUntil {!isNull _crate};
	     		if ((_lastPos select 2) > 5) then
			{
		 		_crateParachute = createVehicle ["O_Parachute_02_F", (getPosATL _crate), [], 0, "CAN_COLLIDE" ];
		 		_crateParachute allowDamage false;
		 		_crate attachTo [_crateParachute, [0,0,0]];
		 		_crate call randomCrateLoadOut;
		 		waitUntil {getPosATL _crate select 2 < 5};
		 		detach _crate;
		 		deleteVehicle _crateParachute;
			};
	     		_smokeSignalTop = createVehicle  ["SmokeShellRed_infinite", getPosATL _crate, [], 0, "CAN_COLLIDE" ];
	     		_lightSignalTop = createVehicle  ["Chemlight_red", getPosATL _crate, [], 0, "CAN_COLLIDE" ];
	     		_smokeSignalTop attachTo [_crate, [0,0,0.5]];
	     		_lightSignalTop attachTo [_crate, [0,0,0.25]];
			_timer = time + 120;
			waitUntil {sleep 1; time > _timer};
			_crate allowDamage true;
			deleteVehicle _smokeSignalTop;
			deleteVehicle _lightSignalTop;
	 	};
	        _i = _i + 1;
	};
	_successHintMessage = "The convoy has been stopped, the weapon crates and vehicles are now yours to take.";
};

_this call sideMissionProcessor;
