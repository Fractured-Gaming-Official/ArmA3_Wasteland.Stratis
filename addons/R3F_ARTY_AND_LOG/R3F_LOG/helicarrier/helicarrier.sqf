/**
 * Héliporte un objet avec un héliporteur
 *
 * @param 0 l'héliporteur
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

	private ["_hasNoProhibitedCargo", "_helicarrier", "_object"];

	_hasNoProhibitedCargo =
	{
		private _ammoCargo = getAmmoCargo _this;
		private _repairCargo = getRepairCargo _this;

		if (isNil "_ammoCargo" || {!finite _ammoCargo}) then { _ammoCargo = 0 };
		if (isNil "_repairCargo" || {!finite _repairCargo}) then { _repairCargo = 0 };

		(_ammoCargo <= 0 && _repairCargo <= 0)
	};

	_helicarrier = _this select 0;
	_object = (nearestObjects [_helicarrier, R3F_LOG_CFG_heliportableObjects, 20]) select {_obj = _x; _x call _hasNoProhibitedCargo && (_helicarrier getVariable ["R3F_LOG_helicarrierHvy",false] || {{_obj isKindOf _x} count R3F_LOG_CFG_objectHeliportableHvy == 0})};
	// Parce que l'héliporteur peut être un objet héliportable
	_object = (_object select {VEHICLE_UNLOCKED(_x) && !(_x getVariable "R3F_LOG_disabled")}) - [_helicarrier];

	if (count _object > 0) then
	{
		_object = _object select 0;

		if !(_object getVariable "R3F_LOG_disabled") then
		{
			if (unitIsUAV _object && {!(_object getVariable ["ownerUID","0"] isEqualTo getPlayerUID player) && !(group (uavControl _object select 0) in [grpNull, group player])}) exitWith
 			{
 				player globalChat STR_R3F_LOG_actionHeliUAVGrp;
 			};

			if (isNull (_object getVariable "R3F_LOG_isTransportedBy")) then
			{
				if ({isPlayer _x} count crew _object == 0) then
				{
					// Si l'objet n'est pas en train d'être déplacé par un joueur
					if (isNull (_object getVariable "R3F_LOG_isMovedBy") || (!alive (_object getVariable "R3F_LOG_isMovedBy"))) then
					{
						private ["_doNotTow", "_towing"];
						// Ne pas héliporter quelque chose qui remorque autre chose
						_doNotTow = true;
						_towing = _object getVariable "R3F_LOG_towing";
						if !(isNil "_towing") then
						{
							if !(isNull _towing) then
							{
								_doNotTow = false;
							};
						};

						if (_doNotTow) then
						{
							// On mémorise sur le réseau que l'héliporteur remorque quelque chose
							_helicarrier setVariable ["R3F_LOG_helicopter", _object, true];
							// On mémorise aussi sur le réseau que l'objet est attaché à un véhicule
							_object setVariable ["R3F_LOG_isTransportedBy", _helicarrier, true];

							_heliBB = _helicarrier call fn_boundingBoxReal;
							_heliMinBB = _heliBB select 0;
							_heliMaxBB = _heliBB select 1;

							_objectBB = _object call fn_boundingBoxReal;
							_objectMinBB = _objectBB select 0;
							_objectMaxBB = _objectBB select 1;

							_objectCenterX = (_objectMinBB select 0) + (((_objectMaxBB select 0) - (_objectMinBB select 0)) / 2);
							_objectCenterY = (_objectMinBB select 1) + (((_objectMaxBB select 1) - (_objectMinBB select 1)) / 2);

							_heliPos = _helicarrier modelToWorld [0,0,0];
							_objectPos = _object modelToWorld [0,0,0];

							_minZ = (_heliMinBB select 2) - (_objectMaxBB select 2) - 0.5;

							// Attacher sous l'héliporteur au ras du sol
							[_object, true] call fn_enableSimulationGlobal;
							_object attachTo [_helicarrier,
							[
								0 - _objectCenterX,
								0 - _objectCenterY,
								/*((_objectPos select 2) - (_heliPos select 2) + 2) min*/ _minZ
							]];

							player globalChat format [STR_R3F_LOG_actionHeliLiftDone, getText (configFile >> "CfgVehicles" >> (typeOf _object) >> "displayName")];
						}
						else
						{
							player globalChat format [STR_R3F_LOG_actionObjectTowingCantLift, getText (configFile >> "CfgVehicles" >> (typeOf _object) >> "displayName")];
						};
					}
					else
					{
						player globalChat format [STR_R3F_LOG_actionHeliObjectMovedByPlayer, getText (configFile >> "CfgVehicles" >> (typeOf _object) >> "displayName")];
					};
				}
				else
				{
					player globalChat format [STR_R3F_LOG_actionHeliPlayerInObject, getText (configFile >> "CfgVehicles" >> (typeOf _object) >> "displayName")];
				};
			}
			else
			{
				player globalChat format [STR_R3F_LOG_actionHeliAlreadyTransported, getText (configFile >> "CfgVehicles" >> (typeOf _object) >> "displayName")];
			};
		};
	};

	R3F_LOG_mutexLocalLock = false;
};
