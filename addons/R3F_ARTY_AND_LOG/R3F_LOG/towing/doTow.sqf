/**
 * Remorque l'objet déplacé par le joueur avec un towing
 *
 * Copyright (C) 2010 madbull ~R3F~
 *
 * This program is free software under the terms of the GNU General Public License version 3.
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#define VEHICLE_UNLOCKED(VEH) (locked (VEH) < 2 || (VEH) getVariable ["ownerUID","0"] isEqualTo getPlayerUID player)

if (R3F_LOG_mutexLocalLock) then
{
	player globalChat STR_R3F_LOG_mutexActionOngoing;
}
else
{
	R3F_LOG_mutexLocalLock = true;

	private ["_object", "_tug"];

	_object = R3F_LOG_playerMovesObject;

	_tug = nearestObjects [_object, R3F_LOG_CFG_tugs, 22];
	// Parce que le towing peut être un objet remorquable
	_tug = _tug - [_object];

	if (count _tug > 0) then
	{
		_tug = _tug select 0;

		if (alive _tug && isNull (_tug getVariable "R3F_LOG_towing") && (vectorMagnitude velocity _tug < 6) && (getPos _tug select 2 < 2) && VEHICLE_UNLOCKED(_tug) && !(_tug getVariable "R3F_LOG_disabled")) then
		{
			// On mémorise sur le réseau que le véhicule remorque quelque chose
			_tug setVariable ["R3F_LOG_towing", _object, true];
			// On mémorise aussi sur le réseau que le canon est attaché en remorque
			_object setVariable ["R3F_LOG_isTransportedBy", _tug, true];

			["disableDriving", _object] call A3W_fnc_towingHelper;

			_towerBB = _tug call fn_boundingBoxReal;
			_towerMinBB = _towerBB select 0;
			_towerMaxBB = _towerBB select 1;

			_objectBB = _object call fn_boundingBoxReal;
			_objectMinBB = _objectBB select 0;
			_objectMaxBB = _objectBB select 1;

			_towerCenterX = (_towerMinBB select 0) + (((_towerMaxBB select 0) - (_towerMinBB select 0)) / 2);
			_objectCenterX = (_objectMinBB select 0) + (((_objectMaxBB select 0) - (_objectMinBB select 0)) / 2);

			_towerGroundPos = _tug worldToModel (_tug call fn_getPos3D);

			if ((getPosASL player) select 2 > 0) then
			{
				// On place le joueur sur le côté du véhicule, ce qui permet d'éviter les blessure et rend l'animation plus réaliste
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

			[player, "AinvPknlMstpSlayWrflDnon_medic"] call switchMoveGlobal;
			sleep 2;

			// Attacher à l'arrière du véhicule au ras du sol
			// Attach to the rear of vehicle at ground level
			[_tug, true] call fn_enableSimulationGlobal;
			[_object, true] call fn_enableSimulationGlobal;
			_object attachTo [_tug,
			[
				_towerCenterX - _objectCenterX,
				(_towerMinBB select 1) - (_objectMaxBB select 1) - 0.5,
				(_towerGroundPos select 2) - (_objectMinBB select 2) + 0.1
			]];

			// Faire relacher l'objet au joueur (si il l'a dans "les mains")
			R3F_LOG_playerMovesObject = objNull;
			detach player;

			// Si l'objet est une arme statique, on corrige l'orientation en fonction de la direction du canon
			/*if (_object isKindOf "StaticWeapon") then
			{
				private ["_cannonAzimuth"];

				_cannonAzimuth = ((_object weaponDirection (weapons _object select 0)) select 0) atan2 ((_object weaponDirection (weapons _object select 0)) select 1);

				// Seul le D30 a le canon pointant vers le véhicule
				if !(_object isKindOf "D30_Base") then
				{
					_cannonAzimuth = _cannonAzimuth + 180;
				};

				// On est obligé de demander au serveur de tourner l'objet pour nous
				R3F_LOG_FRAC_PUBVAR_setDir = [_object, (getDir _object)-_cannonAzimuth];
				if (isServer) then
				{
					["R3F_LOG_FRAC_PUBVAR_setDir", R3F_LOG_FRAC_PUBVAR_setDir] spawn R3F_LOG_FRAC_FNC__PUBVAR_setDir;
				}
				else
				{
					publicVariable "R3F_LOG_FRAC_PUBVAR_setDir";
				};
			};*/

			sleep 5;

			if (isNull objectParent player) then
			{
				[player, ""] call switchMoveGlobal;
			};
		};
	};

	R3F_LOG_mutexLocalLock = false;
};
