/*
	----------------------------------------------------------------------------------------------

	Copyright © 2018 soulkobk (soulkobk.blogspot.com)

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU Affero General Public License as
	published by the Free Software Foundation, either version 3 of the
	License, or (at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
	GNU Affero General Public License for more details.

	You should have received a copy of the GNU Affero General Public License
	along with this program. If not, see <http://www.gnu.org/licenses/>.

	----------------------------------------------------------------------------------------------

	Name: missionSuccessHandler.sqf
	Version: 1.0.A3WL1
	Author: soulkobk (soulkobk.blogspot.com) in conjunction with Mokey [FRAC]
	Creation Date: 5:00 PM 16/05/2018
	Modification Date: 2:30 PM 18/05/2018

	Description:
	For use with A3Wasteland 1.3x mission (A3Wasteland.com).

	Parameter(s):

	Example:

	Change Log:
	1.0.A3WL0 - new missionSuccessHandler for all A3Wasteland missions.
	1.0.A3WL1 - added conditional timers to all waitUntil statements, moved smoke and chem lights to
	            inside the crates so they don't glitch through. added alive check to sack.

	----------------------------------------------------------------------------------------------
*/

_missionCratesSpawn = true; // upon mission success, spawn crates?
_missionCrateAmount = 2; // the total number of crates to spawn.
_missionCrateSmoke = true; // spawn crate smoke (red) to show location of dropped crates?
_missionCrateSmokeDuration = 120; // how long will the smoke last for once the crate reaches the ground?
_missionCrateChemlight = true; // spawn crate chemlight (red) to show location of dropped crates?
_missionCrateChemlightDuration = 120; // how long will the chemlight last for once the crate reaches the ground?

_missionMoneySpawn = true; // upon mission success, spawn money?
_missionMoneyAmount = 100000; // the total amount of money to spawn.
_missionMoneyBundles = 10; // how many bundles of money to spawn? (_missionMoneyAmount / _missionMoneyBundles).
_missionMoneySmoke = true; // spawn money smoke (red) to show location of dropped money?
_missionMoneySmokeDuration = 120; // how long will the smoke last for once the money reaches the ground?
_missionMoneyChemlight = true; // spawn money chemlight (red) to show location of dropped money?
_missionMoneyChemlightDuration = 120; // how long will the chemlight last for once the money reaches the ground?

_missionSuccessMessage = "The hostile helicopters have been eradicated, go collect the dropped supplies!"; // mission success hint description

/*/ ------------------------------------------------------------------------------------------- /*/
_missionFinishPos = [0,0,0];
_waitUntilExec =
{
	_leader = leader _aiGroup;
	if !(isNull _leader) then
	{
		_missionFinishPos = getPosATL _leader;
	};
};
_successExec =
{
	if !(_missionFinishPos isEqualTo [0,0,0]) then
	{
		if (_missionCratesSpawn) then
		{
			_i = 0;
			while {_i < _missionCrateAmount} do
			{
				[_missionFinishPos,_missionCrateSmoke,_missionCrateSmokeDuration,_missionCrateChemlight,_missionCrateChemlightDuration] spawn
				{
					params ["_missionFinishPos","_missionCrateSmoke","_missionCrateSmokeDuration","_missionCrateChemlight","_missionCrateChemlightDuration"];
					_crateObject = selectRandom ["Box_NATO_Wps_F","Box_East_Wps_F","Box_IND_Wps_F","Box_NATO_WpsSpecial_F","Box_East_WpsSpecial_F","Box_IND_WpsSpecial_F"];
					_crate = createVehicle [_crateObject,_missionFinishPos,[],5,"CAN_COLLIDE"];
					_crate allowDamage false;
					_timer = time + 10;
					waitUntil {sleep 0.1; (!isNull _crate) || (time > _timer)};
					_crate call randomCrateLoadOut;
					if ((_missionFinishPos select 2) > 5) then
					{
						_crateParachute = createVehicle ["O_Parachute_02_F",(getPosATL _crate),[],0,"CAN_COLLIDE"];
						_crateParachute allowDamage false;
						_crate attachTo [_crateParachute, [0,0,0]];
						_timer = time + 120;
						waitUntil {(getPosATL _crate select 2 < 5) || (time > _timer)};
						detach _crate;
						deleteVehicle _crateParachute;
					};
					_timer = time + 10;
					waitUntil {sleep 0.1; (getPos _crate select 2 < 0.1) || (time > _timer)};
					_cratePos = getPosATL _crate;
					_cratePos set [2, (_cratePos select 2) max 0 + 0.01];
					_crate setPosATL _cratePos;
					_crate allowDamage true;
					if (_missionCrateSmoke) then
					{
						[_crate,_cratePos,_missionCrateSmokeDuration] spawn
						{
							params ["_crate","_cratePos","_missionCrateSmokeDuration"];
							_smokeSignalCrate = createVehicle ["SmokeShellRed_infinite",_cratePos,[],0,"CAN_COLLIDE"];
							_smokeSignalCrate attachTo [_crate, [0,0,0]];
							_timer = time + _missionCrateSmokeDuration;
							waitUntil {sleep 0.1; time > _timer};
							deleteVehicle _smokeSignalCrate;
						};
					};
					if (_missionCrateChemlight) then
					{
						[_crate,_cratePos,_missionCrateChemlightDuration] spawn
						{
							params ["_crate","_cratePos","_missionCrateChemlightDuration"];
							_lightSignalCrate = createVehicle ["Chemlight_red",_cratePos,[],0,"CAN_COLLIDE"];
							_lightSignalCrate attachTo [_crate, [0,0,0]];
							_timer = time + _missionCrateChemlightDuration;
							waitUntil {sleep 0.1; time > _timer};
							deleteVehicle _lightSignalCrate;
						};
					};
				};
				_i = _i + 1;
			};
		};
		if (_missionMoneySpawn) then
		{
			[_missionFinishPos,_missionMoneySmoke,_missionMoneySmokeDuration,_missionMoneyChemlight,_missionMoneyChemlightDuration,_missionMoneyAmount,_missionMoneyBundles] spawn
			{
				params ["_missionFinishPos","_missionMoneySmoke","_missionMoneySmokeDuration","_missionMoneyChemlight","_missionMoneyChemlightDuration","_missionMoneyAmount","_missionMoneyBundles"];
				_sack = createVehicle ["Land_Sack_F",_missionFinishPos,[],5,"CAN_COLLIDE"];
				_sack allowDamage false;
				_timer = time + 10;
				waitUntil {sleep 0.1; (!isNull _sack) || (time > _timer)};
				if ((_missionFinishPos select 2) > 5) then
				{
					_crateParachute = createVehicle ["O_Parachute_02_F",(getPosATL _sack),[],0,"CAN_COLLIDE"];
					_crateParachute allowDamage false;
					_sack attachTo [_crateParachute, [0,0,0]];
					_timer = time + 120;
					waitUntil {sleep 0.1; (getPosATL _sack select 2 < 5) || (time > _timer)};
					detach _sack;
					deleteVehicle _crateParachute;
				};
				_log = createVehicle ["Land_WoodenLog_F",(getPosATL _sack),[],0,"CAN_COLLIDE"];
				_sack attachTo [_log, [0,0,0]];
				_timer = time + 10;
				waitUntil {sleep 0.1; (getPos _sack select 2 < 0.1) || (time > _timer)};
				detach _sack;
				deleteVehicle _log;
				_sackPos = getPosATL _sack;
				_sackPos set [2, (getPosATL _sack select 2) max 0 + 0.01];
				_sack setPosATL _sackPos;
				_i = 0;
				while {_i < _missionMoneyBundles} do
				{
					_cash = createVehicle ["Land_Money_F",_sackPos,[],5,"CAN_COLLIDE"];
					_cash setPos ([_sackPos, [[2 + random 3,0,0], random 360] call BIS_fnc_rotateVector2D] call BIS_fnc_vectorAdd);
					_cash setDir random 360;
					_cash setVariable ["cmoney", (_missionMoneyAmount / _missionMoneyBundles), true];
					_cash setVariable ["owner", "world", true];
					_cash call A3W_fnc_setItemCleanup;
					_i = _i + 1;
				};
				_missionSackDeleteDuration = 0;
				if (_missionMoneySmoke) then
				{
					_missionSackDeleteDuration = _missionSackDeleteDuration + _missionMoneySmokeDuration;
					[_sack,_sackPos,_missionMoneySmokeDuration] spawn
					{
						params ["_sack","_sackPos","_missionMoneySmokeDuration"];
						_smokeSignalMoney = createVehicle ["SmokeShellRed_infinite",_sackPos,[],0,"CAN_COLLIDE"];
						_smokeSignalMoney attachTo [_sack, [0,0,0]];
						_timer = time + _missionMoneySmokeDuration;
						waitUntil {sleep 0.1; !(alive _sack) || time > _timer};
						deleteVehicle _smokeSignalMoney;
					};
				};
				if (_missionMoneyChemlight) then
				{
					_missionSackDeleteDuration = _missionSackDeleteDuration + _missionMoneyChemlightDuration;
					[_sack,_sackPos,_missionMoneyChemlightDuration] spawn
					{
						params ["_sack","_sackPos","_missionMoneyChemlightDuration"];
						_lightSignalMoney = createVehicle ["Chemlight_red",_sackPos,[],0,"CAN_COLLIDE"];
						_lightSignalMoney attachTo [_sack, [0,0,0]];
						_timer = time + _missionMoneyChemlightDuration;
						waitUntil {sleep 0.1; !(alive _sack) || time > _timer};
						deleteVehicle _lightSignalMoney;
					};
				};
				if (_missionSackDeleteDuration isEqualTo 0) then
				{
					_sack allowDamage true;
					deleteVehicle _sack;
				}
				else
				{
					[_sack,_missionSackDeleteDuration] spawn
					{
						params ["_sack","_missionSackDeleteDuration"];
						_timer = time + 10;
						waitUntil {sleep 0.1; time > _timer};
						_sack allowDamage true;
						_timer = time + _missionSackDeleteDuration;
						waitUntil {sleep 0.1; !(alive _sack) || time > _timer};
						sleep 2;
						deleteVehicle _sack;
					};
				};
			};
		};
	};
	_successHintMessage = _missionSuccessMessage;
};
/*/ ------------------------------------------------------------------------------------------- /*/
