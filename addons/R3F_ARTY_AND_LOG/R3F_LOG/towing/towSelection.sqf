/**
 * Remorque l'objet sélectionné (R3F_LOG_selectedObject) à un véhicule
 *
 * @param 0 le towing
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

	_object = R3F_LOG_selectedObject;
	_tug = _this select 0;

	if (!(isNull _object) && (alive _object) && VEHICLE_UNLOCKED(_object) && !(_object getVariable "R3F_LOG_disabled")) then
	{
		if (unitIsUAV _object && {!(_object getVariable ["ownerUID","0"] isEqualTo getPlayerUID player) && !(group (uavControl _object select 0) in [grpNull, group player])}) exitWith
		{
			player globalChat STR_R3F_LOG_actionObjectSelectionUAVGrp;
		};

		if (isNull (_object getVariable "R3F_LOG_isTransportedBy") && (isNull (_object getVariable "R3F_LOG_isMovedBy") || (!alive (_object getVariable "R3F_LOG_isMovedBy")))) then
		{
			if (_object distance _tug <= 30) then
			{
				//The vehicle that is driving.
				_tempobj = _tug;		_countTransportedBy = 1;
				while{!isNull(_tempobj getVariable["R3F_LOG_isTransportedBy", objNull])} do {_countTransportedBy = _countTransportedBy + 1; _tempobj = _tempobj getVariable["R3F_LOG_isTransportedBy", objNull];};

				//The vehicle that is being towed.
				_tempobj = _object;		_countTowedVehicles = 1;
				while{!isNull(_tempobj getVariable["R3F_LOG_towing", objNull])} do {_countTowedVehicles = _countTowedVehicles + 1; _tempobj = _tempobj getVariable["R3F_LOG_towing", objNull];};

				if(_countTransportedBy + _countTowedVehicles <= 2) then
				{
					// On mémorise sur le réseau que le véhicule remorque quelque chose
					_tug setVariable ["R3F_LOG_towing", _object, true];
					// On mémorise aussi sur le réseau que le canon est attaché en remorque
					_object setVariable ["R3F_LOG_isTransportedBy", _tug, true];

					["disableDriving", _object] call A3W_fnc_towingHelper;

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

					sleep 2;

					// Attacher à l'arrière du véhicule au ras du sol
					[_tug, true] call fn_enableSimulationGlobal;
					[_object, true] call fn_enableSimulationGlobal;
					_object attachTo [_tug,
					[
						_towerCenterX - _objectCenterX,
						(_towerMinBB select 1) - (_objectMaxBB select 1) - 0.5,
						(_towerGroundPos select 2) - (_objectMinBB select 2) + 0.1
					]];

					R3F_LOG_selectedObject = objNull;

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
				}
				else {
					player globalChat "You can't tow more than one vehicle.";
				};
			}
			else
			{
				player globalChat format [STR_R3F_LOG_actionObjectTooFarTow, getText (configFile >> "CfgVehicles" >> (typeOf _object) >> "displayName")];
			};
		}
		else
		{
			player globalChat format [STR_R3F_LOG_actionObjectInTransit, getText (configFile >> "CfgVehicles" >> (typeOf _object) >> "displayName")];
		};
	};

	R3F_LOG_mutexLocalLock = false;
};
