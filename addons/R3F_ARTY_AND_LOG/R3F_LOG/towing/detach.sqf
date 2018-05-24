/**
 * Détacher un objet d'un véhicule
 *
 * @param 0 l'objet à détacher
 *
 * Copyright (C) 2010 madbull ~R3F~
 *
 * This program is free software under the terms of the GNU General Public License version 3.
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

if (R3F_LOG_mutexLocalLock) then
{
	player globalChat STR_R3F_LOG_mutexActionOngoing;
}
else
{
	R3F_LOG_mutexLocalLock = true;

	private ["_tug", "_object"];

	_object = _this select 0;
	_tug = _object getVariable "R3F_LOG_isTransportedBy";

	// Ne pas permettre de décrocher un objet s'il est porté héliporté
	if ({_tug isKindOf _x} count R3F_LOG_CFG_tugs > 0) then
	{
		[player, "AinvPknlMstpSlayWrflDnon_medic"] call switchMoveGlobal;

		/*player addEventHandler ["AnimDone",
		{
			if (_this select 1 == "AinvPknlMstpSlayWrflDnon_medic") then
			{
				player switchMove "";
				player removeAllEventHandlers "AnimDone";
			};
		}];*/

		_towerBB = _tug call fn_boundingBoxReal;
		_towerMinBB = _towerBB select 0;
		_towerMaxBB = _towerBB select 1;

		if ((getPosASL player) select 2 > 0) then
		{
			player attachTo [_tug,
			[
				(_towerMinBB select 0) - 0.25,
				(_towerMinBB select 1) - 0.25,
				_towerMinBB select 2
			]];

			player setDir 90;
			player setPos (getPos player);
			sleep 0.05;
			detach player;
		};

		sleep 2;

		// On mémorise sur le réseau que le véhicule remorque quelque chose
		_tug setVariable ["R3F_LOG_towing", objNull, true];
		// On mémorise aussi sur le réseau que le objet est attaché en remorque
		_object setVariable ["R3F_LOG_isTransportedBy", objNull, true];

		if (local _object) then
		{
			[_object] call detachTowedObject;
		}
		else
		{
			pvar_detachTowedObject = [netId _object];
			publicVariable "pvar_detachTowedObject";
		};

		sleep 4;

		if (isNull objectParent player) then
		{
			[player, ""] call switchMoveGlobal;
		};

		if ({_object isKindOf _x} count R3F_LOG_CFG_movableObjects > 0) then
		{
			// Si personne n'a re-remorquer l'objet pendant le sleep 6
			if (isNull (_tug getVariable "R3F_LOG_towing") &&
				(isNull (_object getVariable "R3F_LOG_isTransportedBy")) &&
				(isNull (_object getVariable "R3F_LOG_isMovedBy"))
			) then
			{
				[_object] execVM "addons\R3F_ARTY_AND_LOG\R3F_LOG\movableObject\move.sqf";
			};
		}
		else
		{
			player globalChat STR_R3F_LOG_actionObjectUntowed;
		};
	}
	else
	{
		player globalChat STR_R3F_LOG_actionOnlyPilotDetach;
	};

	R3F_LOG_mutexLocalLock = false;
};
