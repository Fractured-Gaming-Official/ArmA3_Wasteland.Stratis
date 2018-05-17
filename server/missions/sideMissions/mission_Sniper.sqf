// ******************************************************************************************
// * This project is licensed under the GNU Affero GPL v3. Copyright © 2014 A3Wasteland.com *
// ******************************************************************************************
//	@file Version: 1.0
//	@file Name: mission_Sniper.sqf
//	@file Author: [404] Deadbeat, [404] Costlyy, AgentRev
//	@file Created: 08/12/2012 15:19
//	@file Modified: [FRAC] Mokey
//	@file missionSuccessHandler Author: soulkobk

if (!isServer) exitwith {};
#include "sideMissionDefines.sqf"

private ["_box1", "_box2"];

_setupVars =
{
	_missionType = "Sniper Nest";
	_locationsArray = ForestMissionMarkers;
};

_setupObjects =
{
	_missionPos = markerPos _missionLocation;

	_box1 = createVehicle ["Box_NATO_Wps_F", _missionPos, [], 5, "None"];
	_box1 setDir random 360;
//	[_box1, "mission_USSpecial"] call fn_refillbox;
	_box1 call randomCrateLoadOut; // new randomCrateLoadOut function call

	_box2 = createVehicle ["Box_East_Wps_F", _missionPos, [], 5, "None"];
	_box2 setDir random 360;
//	[_box2, "mission_USLaunchers"] call randomCrateLoadOut;
	_box2 call randomCrateLoadOut; // new randomCrateLoadOut function call

	{ _x setVariable ["R3F_LOG_disabled", true, true] } forEach [_box1, _box2];

	_aiGroup = createGroup CIVILIAN;
	[_aiGroup,_missionPos] spawn createsniperGroup;

	_aiGroup setCombatMode "YELLOW";
	_aiGroup setBehaviour "COMBAT";

	_missionHintText = "A weapon cache has been spotted near the marker.";
};

_waitUntilMarkerPos = nil;
_waitUntilExec = nil;
_waitUntilCondition = nil;

_failedExec = nil;
_successExec =
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

_missionSuccessMessage = "Good Job! Those Snipers won't be an issue anymore. Their Crates are yours for the taking.";

_this call sideMissionProcessor;
