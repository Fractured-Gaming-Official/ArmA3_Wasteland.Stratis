// ******************************************************************************************
// * This project is licensed under the GNU Affero GPL v3. Copyright © 2014 A3Wasteland.com *
// ******************************************************************************************
//	@file Version: 1.0
//	@file Name: onKilled.sqf
//	@file Author: [404] Deadbeat, MercyfulFate, AgentRev
//	@file Created: 20/11/2012 05:19

params ["_player", "_presumedKiller", "_instigator"];

_presumedKiller = effectiveCommander _presumedKiller;
_killer = _player getVariable "FAR_killerUnit";

if (isNil "_killer" && !isNil "FAR_findKiller") then
{
	_killer = _player call FAR_findKiller;
};

if (isNil "_killer" || {isNull _killer}) then
{
	_killer = [_instigator, _presumedKiller] select isNull _instigator;
};

_killer = effectiveCommander _killer;
_deathCause = _player getVariable ["A3W_deathCause_local", []];

if (_player getVariable ["FAR_isUnconscious", 0] == 1 && _deathCause isEqualTo []) then
{
	_deathCause = [["kill","bleedout"] select (_player getVariable ["FAR_injuryBroadcast", false])];
	_player setVariable ["A3W_deathCause_local", _deathCause];
};

private _killerTemp = _killer;

if (_killer == _player) then
{
	if (_deathCause isEqualTo []) then
	{
		_deathCause = switch (true) do
		{
			case (_player == player && ([missionNamespace getVariable "thirstLevel"] param [0,1,[0]] <= 0 || [missionNamespace getVariable "hungerLevel"] param [0,1,[0]] <= 0)): { "survival" };
			case (getOxygenRemaining _player <= 0 && getPosASLW _player select 2 < -0.1): { "drown" };
			default { "suicide" };
		};

		_deathCause = [_deathCause, serverTime];
		_player setVariable ["A3W_deathCause_local", _deathCause];
	};

	_killerTemp = objNull;
};

[_player, _killerTemp, _presumedKiller, _deathCause] remoteExecCall ["A3W_fnc_serverPlayerDied", 2];
[_player, true] call A3W_fnc_killBroadcast;

if (_player == player) then
{
	(findDisplay 2001) closeDisplay 0; // Close Gunstore
	(findDisplay 2009) closeDisplay 0; // Close Genstore
	(findDisplay 5285) closeDisplay 0; // Close Vehstore
	(findDisplay 63211) closeDisplay 0; // Close ATM
	uiNamespace setVariable ["BIS_fnc_guiMessage_status", false]; // close message boxes
	closeDialog 0;

	// Load scoreboard in render scope
	["A3W_scoreboard", "onEachFrame",
	{
		call loadScoreboard;
		["A3W_scoreboard", "onEachFrame"] call BIS_fnc_removeStackedEventHandler;
	}] call BIS_fnc_addStackedEventHandler;

	if (!isNil "savePlayerHandle" && {typeName savePlayerHandle == "SCRIPT" && {!scriptDone savePlayerHandle}}) then
	{
		terminate savePlayerHandle;
	};

	playerData_infoPairs = nil;
	playerData_savePairs = nil;
	combatTimestamp = -1; // Reset abort timer
};

diag_log format ["KILLED by %1", if (isPlayer _killer) then { "player " + str [name _killer, getPlayerUID _killer] } else { _killer }];

// reset var in case Killed event triggers twice (happens on rare occasions)
_player setVariable ["FAR_killerUnit", nil];

_player spawn
{
	_player = _this;

	_money = _player getVariable ["cmoney", 0];
	//_player setVariable ["cmoney", 0, true];
	[player, 0, true] call A3W_fnc_setCMoney;

	_items = if (_player == player) then { true call mf_inventory_list } else { [] };

	pvar_dropPlayerItems = [_player, _money, _items];
	publicVariableServer "pvar_dropPlayerItems";

	if (_player == player) then
	{
		{ _x call mf_inventory_remove } forEach _items;
	};
};

_player spawn fn_removeAllManagedActions;
removeAllActions _player;

// Handle teamkills
if (_player == player && playerSide in [BLUFOR,OPFOR] && player != _killer && vehicle player != vehicle _killer) then
{
	private _killerName = [_player getVariable "FAR_killerName"] param [0,"",[""]];
	private _killerUID = [_player getVariable "FAR_killerUID"] param [0,"",[""]];
	private _killerSide = [_player getVariable "FAR_killerSide"] param [0,sideUnknown,[sideUnknown]];

	if (playerSide == _killerSide) then
	{
		if (_killerUID in ["", "0", getPlayerUID player]) then
		{
			pvar_PlayerTeamKiller = []; // not a valid player
		}
		else
		{
			pvar_PlayerTeamKiller = [_killer, _killerUID, _killerName];
		};
	};
};

// soulkobk - hacky work-around for buggy goggles/balaclava due to profile bug (face wearable).
_unitGoggles = (goggles _player);
_unitHeadGear = (headGear _player);
_unitHMD = (hmd _player);

waitUntil {(((vectorMagnitude velocity _player * 3.6) isEqualTo 0) && (isTouchingGround _player))};

_headGearHolder = createVehicle ["weaponHolderSimulated", (getPosATL vehicle _player), [], 2, "CAN_COLLIDE"];
_headGearHolder setDir random 360;
_headGearHolder setVariable ["processedDeath", diag_tickTime];

if (_unitGoggles != "") then
{
	removeGoggles _player;
	_headGearHolder addItemCargoGlobal [_unitGoggles,1];
};

if (_unitHeadGear != "") then
{
	removeHeadgear _player;
	_headGearHolder addItemCargoGlobal [_unitHeadGear,1];
};

if (_unitHMD != "") then
{
	_player unassignItem _unitHMD;
	_player removeItem _unitHMD;
	_headGearHolder addItemCargoGlobal [_unitHMD,1];
};
