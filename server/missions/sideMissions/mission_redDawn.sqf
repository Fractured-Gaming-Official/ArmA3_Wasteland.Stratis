// ******************************************************************************************
// * This project is licensed under the GNU Affero GPL v3. Copyright © 2014 A3Wasteland.com *
// ******************************************************************************************
//	@file Name: mission_redDawn.sqf
//	@file Author: [FRAC] Mokey , Soulkobk

if (!isServer) exitwith {};

#include "sideMissionDefines.sqf"

private ["_pos","_radius","_unitPositionArray","_leader","_speedMode","_waypoint","_numWaypoints"];

_setupVars =
{
	_missionType = "Red Dawn!";
	_locationsArray = nil;
};

_setupObjects =
{
	_town = (call cityList) call BIS_fnc_selectRandom;
	_townSpawn = _town select 2;
	_missionPos = markerPos (_town select 0);
	_missionPos set [2,150];
	_aiGroup = createGroup CIVILIAN;
	_radius = _town select 1;
	_unitPositionArray = [_missionPos,_radius,_radius + 50,5,0,0,0] call findSafePos;

	_soldier = [_aiGroup, _missionPos] call createAirTroops;

	_leader = leader _aiGroup;
	_leader setRank "LIEUTENANT";
	_aiGroup setCombatMode "GREEN"; // units will defend themselves
	_aiGroup setBehaviour "SAFE"; // units feel safe until they spot an enemy or get into contact
	_aiGroup setFormation "STAG COLUMN";

	_speedMode = if (missionDifficultyHard) then { "NORMAL" } else { "LIMITED" };
	_aiGroup setSpeedMode _speedMode;

	{
		_waypoint = _aiGroup addWaypoint [markerPos (_x select 0), 0];
		_waypoint setWaypointType "MOVE";
		_waypoint setWaypointCompletionRadius 50;
		_waypoint setWaypointCombatMode "GREEN";
		_waypoint setWaypointBehaviour "SAFE";
		_waypoint setWaypointFormation "STAG COLUMN";
		_waypoint setWaypointSpeed _speedMode;
	} forEach ((call cityList) call BIS_fnc_arrayShuffle);

	_missionPos = getPosATL leader _aiGroup;

	_missionHintText = format ["Hostiles parachuted over <br/><t size='1.25' color='%1'>%2</t><br/><br/>Kill them and take their supplies before they run rampant!<br/>WOLVERINES!", sideMissionColor, _townSpawn];

	_numWaypoints = count waypoints _aiGroup;
};

_waitUntilMarkerPos = {getPosATL _leader};
_waitUntilExec = nil;
_waitUntilCondition = {currentWaypoint _aiGroup >= _numWaypoints};
_failedExec = nil;

#include "..\missionSuccessHandler.sqf"

_missionCratesSpawn = true;
_missionCrateAmount = 2;
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

_missionSuccessMessage = "Good job! WOLVERINES!!! <br/>Go take their supplies!";

_this call sideMissionProcessor;
