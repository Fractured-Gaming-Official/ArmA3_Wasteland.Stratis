/**
 * Charger l'objet sélectionné (R3F_LOG_selectedObject) dans un carrier
 *
 * @param 0 le carrier
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

	private ["_object", "_carrierClasses", "_carrier", "_i"];

	_object = R3F_LOG_selectedObject;
	_carrier = _this select 0;

	if (!(isNull _object) && VEHICLE_UNLOCKED(_object) && !(_object getVariable "R3F_LOG_disabled")) then
	{
		if (isNull (_object getVariable "R3F_LOG_isTransportedBy") && (isNull (_object getVariable "R3F_LOG_isMovedBy") || (!alive (_object getVariable "R3F_LOG_isMovedBy")))) then
		{
			private ["_loadedObjects", "_currentLoad", "_objectCapacityCost", "_maxLoad"];

			_loadedObjects = _carrier getVariable "R3F_LOG_loadedObjects";

			// Calcul du chargement actuel
			_currentLoad = 0;
			{
				for [{_i = 0}, {_i < count R3F_LOG_CFG_transportableObjects}, {_i = _i + 1}] do
				{
					if (_x isKindOf (R3F_LOG_CFG_transportableObjects select _i select 0)) exitWith
					{
						_currentLoad = _currentLoad + (R3F_LOG_CFG_transportableObjects select _i select 1);
					};
				};
			} forEach _loadedObjects;

			// Recherche de la capacité de l'objet
			_objectCapacityCost = 99999;
			for [{_i = 0}, {_i < count R3F_LOG_CFG_transportableObjects}, {_i = _i + 1}] do
			{
				if (_object isKindOf (R3F_LOG_CFG_transportableObjects select _i select 0)) exitWith
				{
					_objectCapacityCost = (R3F_LOG_CFG_transportableObjects select _i select 1);
				};
			};

			// Recherche de la capacité maximale du carrier
			_maxLoad = 0;
			for [{_i = 0}, {_i < count R3F_LOG_CFG_carriers}, {_i = _i + 1}] do
			{
				if (_carrier isKindOf (R3F_LOG_CFG_carriers select _i select 0)) exitWith
				{
					_maxLoad = (R3F_LOG_CFG_carriers select _i select 1);
				};
			};

			// Si l'objet loge dans le véhicule
			if (_currentLoad + _objectCapacityCost <= _maxLoad) then
			{
				if (_object distance _carrier <= 30) then
				{
					// On mémorise sur le réseau le nouveau contenu du véhicule
					_loadedObjects = _loadedObjects + [_object];
					_carrier setVariable ["R3F_LOG_loadedObjects", _loadedObjects, true];
					_object setVariable ["R3F_LOG_isTransportedBy", _carrier, true];

					player globalChat STR_R3F_LOG_loadSelectionInProgressAction;

					sleep 2;

					// Choisir une position dégagée (sphère de 50m de rayon) dans le ciel dans un cube de 9km^3
					private ["_nbDrawPos", "_attachmentPosition"];
					_attachmentPosition = [random 3000, random 3000, (10000 + (random 3000))];
					_nbDrawPos = 1;
					while {(!isNull (nearestObject _attachmentPosition)) && (_nbDrawPos < 25)} do
					{
						_attachmentPosition = [random 3000, random 3000, (10000 + (random 3000))];
						_nbDrawPos = _nbDrawPos + 1;
					};

					[R3F_LOG_PUBVAR_attachmentPoint, true] call fn_enableSimulationGlobal;
					[_object, true] call fn_enableSimulationGlobal;

					if (unitIsUAV _object) then
					{
						[_object, 2] call A3W_fnc_setLockState; // lock
						["disableDriving", _object] call A3W_fnc_towingHelper;
					};

					_object attachTo [R3F_LOG_PUBVAR_attachmentPoint, _attachmentPosition];

					R3F_LOG_selectedObject = objNull;

					player globalChat format [STR_R3F_LOG_actionLoadSelectionDone, getText (configFile >> "CfgVehicles" >> (typeOf _object) >> "displayName")];
				}
				else
				{
					player globalChat format [STR_R3F_LOG_actionLoadSelectionTooFar, getText (configFile >> "CfgVehicles" >> (typeOf _object) >> "displayName")];
				};
			}
			else
			{
				player globalChat format [STR_R3F_LOG_actionLoadSelectionNotEnoughRoom, (_maxLoad - _currentLoad), _objectCapacityCost];
			};
		}
		else
		{
			player globalChat format [STR_R3F_LOG_actionLoadSelectionObjectInMotion, getText (configFile >> "CfgVehicles" >> (typeOf _object) >> "displayName")];
		};
	};

	R3F_LOG_mutexLocalLock = false;
};
