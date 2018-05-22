// ******************************************************************************************
// * This project is licensed under the GNU Affero GPL v3. Copyright © 2014 A3Wasteland.com *
// ******************************************************************************************
//	@file Version: 2.1
//	@file Name: mission_MoneyShipment.sqf
//	@file Author: JoSchaap / routes by Del1te - (original idea by Sanjo), AgentRev
//	@file Created: 31/08/2013 18:19
//	@file Modified: [FRAC] Mokey
//	@file missionSuccessHandler Author: soulkobk

if (!isServer) exitwith {};
#include "moneyMissionDefines.sqf";

private ["_MoneyShipment", "_convoys", "_vehChoices", "_moneyText", "_vehClasses", "_createVehicle", "_vehicles", "_veh2", "_leader", "_speedMode", "_waypoint", "_vehicleName", "_numWaypoints", "_cash"];

private ["_moneyAmount"];
_setupVars =
{
	_MoneyShipment = selectRandom
	[
		// Easy
		[
			"Solo Smugglers", // Marker text
			  10000, 30000, 50000, // Money
			[
				[ // NATO convoy
					["B_MRAP_01_hmg_F", "B_MRAP_01_gmg_F", "B_T_LSV_01_armed_F", "B_T_LSV_01_AT_F"], // Veh 1
					["B_MRAP_01_hmg_F", "B_MRAP_01_gmg_F", "B_T_LSV_01_armed_F", "B_T_LSV_01_AT_F"] // Veh 2
				],
				[ // CSAT convoy
					["O_MRAP_02_hmg_F", "O_MRAP_02_gmg_F", "B_T_LSV_01_armed_F", "O_T_LSV_02_AT_F"], // Veh 1
					["O_MRAP_02_hmg_F", "O_MRAP_02_gmg_F", "B_T_LSV_01_armed_F", "O_T_LSV_02_AT_F"] // Veh 2
				],
				[ // AAF convoy
					["I_MRAP_03_hmg_F", "I_MRAP_03_gmg_F", "I_LT_01_cannon_F", "O_T_LSV_02_AT_F"], // Veh 1
					["I_MRAP_03_hmg_F", "I_MRAP_03_gmg_F", "I_LT_01_AT_F", "B_T_LSV_01_AT_F"] // Veh 2
				]
			]
		],
		// Medium
		[
			"Solo Smugglers+", // Marker text
			30000, 50000, 70000, // Money
			[
				[ // NATO convoy
					["I_LT_01_cannon_F", "I_LT_01_AT_F", "I_LT_01_AA_F"], // Veh 1
					["O_T_LSV_02_AT_F", "B_T_LSV_01_AT_F", "I_LT_01_cannon_F"], // Veh 2
					["I_LT_01_cannon_F", "I_LT_01_AT_F", "I_LT_01_AA_F"] // Veh 3
				],
				[ // AAF convoy
					["O_T_LSV_02_AT_F", "B_T_LSV_01_AT_F", "I_LT_01_cannon_F"], // Veh 1
					["I_LT_01_cannon_F", "I_LT_01_AT_F", "I_LT_01_AA_F"], // Veh 2
					["O_T_LSV_02_AT_F", "B_T_LSV_01_AT_F", "I_LT_01_cannon_F"] // Veh 3
				]
			]
		]
	];

	_missionType = _moneyShipment select 0;
	_moneyAmount = round (floor (random [_moneyShipment select 1, _moneyShipment select 2,  _moneyShipment select 3]));
	_moneyText = "$" + (_moneyAmount call fn_numbersText);
	_missionMoneyAmount = _moneyAmount; // for the successExec handler (missionSuccessHandler).
	_vehClasses = [];
	_vehChoices = selectRandom (_moneyShipment select 4);
	{ _vehClasses pushBack selectRandom _x } forEach _vehChoices;
};

_setupObjects =
{
	private ["_starts", "_startDirs", "_waypoints"];
	_createVehicle =
	{
		private ["_type", "_position", "_direction", "_vehicle", "_soldier"];
		_type = _this select 0;
		_position = _this select 1;
		_direction = _this select 2;
		_vehicle = createVehicle [_type, _position, [], 0, "None"];
		_vehicle setVariable ["R3F_LOG_disabled", true, true];
		[_vehicle] call vehicleSetup;

		if (worldName == "Tanoa" && _type select [1,3] != "_T_") then
		{
			switch (toUpper (_type select [0,2])) do
			{
				case "B_": { [_vehicle, ["Olive"]] call applyVehicleTexture };
				case "O_": { [_vehicle, ["GreenHex"]] call applyVehicleTexture };
			};
		};

		_vehicle setDir _direction;
		_aiGroup addVehicle _vehicle;
		_soldier = [_aiGroup, _position] call createRandomSoldier;
		_soldier moveInDriver _vehicle;

		if !(_type isKindOf "LT_01_base_F") then
		{
			_soldier = [_aiGroup, _position] call createRandomSoldier;
			_soldier moveInCargo [_vehicle, 0];
		};
		if !(_type isKindOf "Truck_F") then
		{
			_soldier = [_aiGroup, _position] call createRandomSoldier;
			_soldier moveInGunner _vehicle;
			if (_type isKindOf "LT_01_base_F") exitWith {};

			_soldier = [_aiGroup, _position] call createRandomSoldier;

			if (_vehicle emptyPositions "commander" > 0) then
			{
				_soldier moveInCommander _vehicle;
			}
			else
			{
				_soldier moveInCargo [_vehicle, 1];
			};
		};

		[_vehicle, _aiGroup] spawn checkMissionVehicleLock;
		_vehicle
	};


    // SKIP TOWN AND PLAYER PROXIMITY CHECK

    	_skippedTowns = // get the list from -> \mapConfig\towns.sqf
    	[
        	"Town_14" // Pythos Island Marker Name
    	];

    	_town = ""; _missionPos = [0,0,0]; _radius = 0;
    	_townOK = false;
    	while {!_townOK} do
	{
	        _town = selectRandom (call cityList); // initially select a random town for the mission.
	        _missionPos = markerPos (_town select 0); // the town position.
	        _radius = (_town select 1); // the town radius.
	        _anyPlayersAround = (nearestObjects [_missionPos,["MAN"],_radius]) select {isPlayer _x}; // search the area for players only.
	        if (((count _anyPlayersAround) isEqualTo 0) && !((_town select 0) in _skippedTowns)) exitWith // if there are no players around and the town marker is not in the skip list, set _townOK to true (exit loop).
	        {
	            _townOK = true;
	        };
	        sleep 0.1; // sleep between loops.
    	};
	_aiGroup = createGroup CIVILIAN;
	/*/ soulkobk ------------------------------------------------------------------------------ /*/
	_vehicles = [];
	_vehiclePosArray = nil;
	_nearRoads = (_missionPos nearRoads _radius); // check if any roads are near.
	if !(_nearRoads isEqualTo []) then
	{
    		{
			_vehiclePosArray = getPos (_nearRoads select _forEachIndex);
			_vehicles pushBack ([_x, _vehiclePosArray, 0, _aiGroup] call _createVehicle);
    		} forEach _vehClasses;
	}
	else
	{
    		{
			_vehiclePosArray = [_missionPos,(_radius / 2),_radius,5,0,0,0] call findSafePos;
			_vehicles pushBack ([_x, _vehiclePosArray, 0, _aiGroup] call _createVehicle);
    		} forEach _vehClasses;
	};
	/*/ --------------------------------------------------------------------------------------- /*/

	_veh2 = _vehClasses select (1 min (count _vehClasses - 1));
	_leader = effectiveCommander (_vehicles select 0);
	_aiGroup selectLeader _leader;
	_aiGroup setCombatMode "GREEN"; // units will defend themselves
	_aiGroup setBehaviour "SAFE"; // units feel safe until they spot an enemy or get into contact
	_aiGroup setFormation "COLUMN";
	_speedMode = if (missionDifficultyHard) then { "NORMAL" } else { "LIMITED" };
	_aiGroup setSpeedMode _speedMode;
	{
		_waypoint = _aiGroup addWaypoint [markerPos (_x select 0), 0];
		_waypoint setWaypointType "MOVE";
		_waypoint setWaypointCompletionRadius 100;
		_waypoint setWaypointCombatMode "GREEN";
		_waypoint setWaypointBehaviour "SAFE"; // safe is the best behaviour to make AI follow roads, as soon as they spot an enemy or go into combat they WILL leave the road for cover though!
		_waypoint setWaypointFormation "COLUMN";
		_waypoint setWaypointSpeed _speedMode;
	} forEach ((call cityList) call BIS_fnc_arrayShuffle);
	_missionPos = getPosATL leader _aiGroup;
	_missionPicture = getText (configFile >> "CfgVehicles" >> _veh2 >> "picture");
	_vehicleName = getText (configFile >> "cfgVehicles" >> _veh2 >> "displayName");
	_missionHintText = format ["Money Runners transporting <t color='%1'>%2</t> escorted by a <t color='%1'>%3</t> is en route to an unknown location.<br/>Stop them!", moneyMissionColor, _moneyText, _vehicleName];
	_numWaypoints = count waypoints _aiGroup;
};

_waitUntilMarkerPos = {getPosATL _leader};
_waitUntilExec = nil;
_waitUntilCondition = {currentWaypoint _aiGroup >= _numWaypoints};
_failedExec = nil;

#include "..\missionSuccessHandler.sqf"

_missionCratesSpawn = true;
_missionCrateAmount = selectRandom [1,2,3];
_missionCrateSmoke = false;
_missionCrateSmokeDuration = 120;
_missionCrateChemlight = true;
_missionCrateChemlightDuration = 120;

_missionMoneySpawn = true;
_missionParseSetupVars = call _setupVars;
//_missionMoneyAmount = _moneyAmount; // declared within the _setupVars (needed there, not here!).
_missionMoneyBundles = 10;
_missionMoneySmoke = true;
_missionMoneySmokeDuration = 120;
_missionMoneyChemlight = true;
_missionMoneyChemlightDuration = 120;

_missionSuccessMessage = "The runners have been stopped, the money and vehicles are now yours to take.";

_this call moneyMissionProcessor;
