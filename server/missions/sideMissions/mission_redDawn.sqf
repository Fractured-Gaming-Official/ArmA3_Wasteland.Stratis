// ******************************************************************************************
// * This project is licensed under the GNU Affero GPL v3. Copyright © 2014 A3Wasteland.com *
// ******************************************************************************************
//	@file Name: mission_redDawn.sqf
//	@file Author: [FRAC] Mokey , Soulkobk

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

#include "..\missionSuccessHandler.sqf"

_missionCratesSpawn = true;
_missionCrateNumber = 2;
_missionCrateSmoke = true;
_missionCrateSmokeDuration = 120;
_missionCrateChemlight = true;
_missionCrateChemlightDuration = 120;

_missionMoneySpawn = false;
_missionMoneyTotal = 100000;
_missionMoneyBundles = 10;
_missionMoneySmoke = true;
_missionMoneySmokeDuration = 120;
_missionMoneyChemlight = true;
_missionMoneyChemlightDuration = 120;

_missionSuccessMessage = "Good job! WOLVERINES!!! <br/>Go take their supplies!";

_this call sideMissionProcessor;
