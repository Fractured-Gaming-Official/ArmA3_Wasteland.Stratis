// ******************************************************************************************
// * This project is licensed under the GNU Affero GPL v3. Copyright © 2014 A3Wasteland.com *
// ******************************************************************************************
//	@file Name: mission_redDawn.sqf
//	@file Author: [FRAC] Mokey , soulkobk
//	@file Updated: 5:44 PM 22/05/2018 updated by soulkobk

if (!isServer) exitwith {};

#include "sideMissionDefines.sqf"

private ["_pos","_radius","_leader","_speedMode","_waypoint","_numWaypoints","_groupAmount"];

_setupVars =
{
	_missionType = "Red Dawn";
	_locationsArray = nil;
};

_setupObjects =
{
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
        sleep 0.1;
    };

	_aiGroup = createGroup CIVILIAN;
	_groupAmount = (round(random 6) + 12); // min 12, max 18
	_soldiers = [_aiGroup,_missionPos,_groupAmount,_radius] call createAirTroops;
	{
		// skill level is "HIGH" for all (see setMissionSkill.sqf).
		_x setSkill ["aimingSpeed", 0.3];
		_x setSkill ["spotDistance", 0.3];
		_x setSkill ["aimingAccuracy", 0.3];
		_x setSkill ["aimingShake", 0.3];
		_x setSkill ["spotTime", 0.5];
		_x setSkill ["spotDistance", 0.8];
		_x setSkill ["commanding", 0.8];
		_x setSkill ["general", 0.9];
	} forEach _soldiers;

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
		_waypoint setWaypointCombatMode "RED";
		_waypoint setWaypointBehaviour "COMBAT";
		_waypoint setWaypointFormation "STAG COLUMN";
		_waypoint setWaypointSpeed _speedMode;
	} forEach ((call cityList) call BIS_fnc_arrayShuffle);

	_missionPos = getPosATL leader _aiGroup;
	_missionHintText = format ["Hostile forces have parachuted over <br/><t size='1.25' color='%1'>%2</t><br/><br/>Kill them and take their supplies before they run rampant!", sideMissionColor, (_town select 2)];
	_numWaypoints = count wayPoints _aiGroup;
};

_waitUntilMarkerPos = {getPosATL _leader};
_waitUntilExec = nil;
_waitUntilCondition = {currentWaypoint _aiGroup >= _numWaypoints};
_failedExec = nil;

#include "..\missionSuccessHandler.sqf"

_missionCratesSpawn = true;
_missionCrateAmount = selectRandom [3,4,5,6];
_missionCrateSmoke = true;
_missionCrateSmokeDuration = 120;
_missionCrateChemlight = true;
_missionCrateChemlightDuration = 120;

_missionMoneySpawn = false;
_missionMoneyAmount = round(floor(random [20000,40000,60000]));
_missionMoneyBundles = 10;
_missionMoneySmoke = true;
_missionMoneySmokeDuration = 120;
_missionMoneyChemlight = true;
_missionMoneyChemlightDuration = 120;

_missionSuccessMessage = "Good job, you successfully defeated Red Dawn,<br/>Now go and retrieve their supplies!";

_this call sideMissionProcessor;
