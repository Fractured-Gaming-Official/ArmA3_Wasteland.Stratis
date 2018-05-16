// ******************************************************************************************
// * This project is licensed under the GNU Affero GPL v3. Copyright © 2014 A3Wasteland.com *
// ******************************************************************************************
//	@file Name: mission_TownInvasion.sqf
//	@file Author: [404] Deadbeat, [404] Costlyy, JoSchaap, AgentRev, Zenophon
//  @file Information: JoSchaap's Lite version of 'Infantry Occupy House' Original was made by: Zenophon

if (!isServer) exitwith {};

#include "sideMissionDefines.sqf"

private ["_nbUnits", "_box1", "_box2", "_townName", "_missionPos", "_buildingRadius", "_putOnRoof", "_fillEvenly", "_tent1", "_chair1", "_chair2", "_cFire1"];

_setupVars =
{
	_missionType = "RED DAWN";
	_nbUnits = if (missionDifficultyHard) then { AI_GROUP_LARGE } else { AI_GROUP_MEDIUM };
	_locArray = ((call cityList) call BIS_fnc_selectRandom);
	_missionPos = markerPos (_locArray select 0);
	_missionPos set [2,200];
	_buildingRadius = _locArray select 1;
	_townName = _locArray select 2;
	_nbUnits = _nbUnits + round(random (_nbUnits*0.5));
	_buildingRadius = if (_buildingRadius > 201) then {(_buildingRadius*0.5)} else {_buildingRadius};

};

_setupObjects =
{
	_fillEvenly = true;
	_putOnRoof = true;
	_aiGroup = createGroup CIVILIAN;
	[_aiGroup, _missionPos, _nbUnits] call createAirTroops;
	{
 		_x move _missionPos;
		_x moveTo _missionPos;
	} forEach units _aiGroup;
	[_aiGroup, _missionPos, _buildingRadius, _fillEvenly, _putOnRoof] call moveIntoBuildings;

	_missionHintText = format ["Hostiles parachuted over <br/><t size='1.25' color='%1'>%2</t><br/><br/>There seem to be <t color='%1'>%3 enemies</t> dropping in! Get rid of them all, and take their supplies!<br/>WOLVERINES!", sideMissionColor, _townName, _nbUnits];
};

_waitUntilMarkerPos = nil;
_waitUntilExec = nil;
_waitUntilCondition = nil;
_failedExec = nil;

/*/ ------------------------------------------------------------------------------------------- /*/
/*/ scripted by soulkobk 5:00 PM 16/05/2018 for Arma 3 - A3Wasteland -------------------------- /*/
/*/ ------------------------------------------------------------------------------------------- /*/
#include "..\missionSuccessHandler.sqf"

_missionCratesSpawn = true; // upon mission success, spawn crates?
_missionCrateNumber = 2; // the total number of crates to spawn.
_missionCrateSmoke = true; // spawn crate smoke (red) to show location of dropped crates?
_missionCrateSmokeDuration = 120; // how long will the smoke last for once the crate reaches the ground?
_missionCrateChemlight = true; // spawn crate chemlight (red) to show location of dropped crates?
_missionCrateChemlightDuration = 120; // how long will the chemlight last for once the crate reaches the ground?

_missionMoneySpawn = false; // upon mission success, spawn money?
_missionMoneyTotal = 100000; // the total amount of money to spawn.
_missionMoneyBundles = 10; // edit this! how many bundles of money to spawn? (_missionMoneyTotal / _missionMoneyBundles).
_missionMoneySmoke = true; // spawn money smoke (red) to show location of dropped money?
_missionMoneySmokeDuration = 120; // how long will the smoke last for once the money reaches the ground?
_missionMoneyChemlight = true; // spawn money chemlight (red) to show location of dropped money?
_missionMoneyChemlightDuration = 120; // how long will the chemlight last for once the money reaches the ground?

_missionSuccessMessage = "Good job! WOLVERINES!!! <br/>Go take their supples!";

_this call sideMissionProcessor;
