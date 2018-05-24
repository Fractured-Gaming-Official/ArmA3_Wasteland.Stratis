/**
 * Vérifie régulièrement des conditions portant sur l'objet pointé par l'arme du joueur
 * Permet de diminuer la fréquence des vérifications des conditions normalement faites dans les addAction (~60Hz)
 * La justification de ce système est que les conditions sont très complexes (count, nearestObjects)
 *
 * Copyright (C) 2010 madbull ~R3F~
 *
 * This program is free software under the terms of the GNU General Public License version 3.
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
private ["_pointObject", "_resetConditions", "_hasNoProhibitedCargo"];

_resetConditions =
{
	R3F_LOG_actionMoveObjectValid = false;
	R3F_LOG_actionDetachValid = false;
	R3F_LOG_validLoadAction = false;
	R3F_LOG_validLoadSelectionAction = false;
	R3F_LOG_validVehicleContentsAction = false;
	R3F_LOG_actionTowValid = false;
	R3F_LOG_actionTowSeletionValid = false;
	R3F_LOG_actionObjectSelectionTowValid = false;
	R3F_LOG_actionObjectSelectionLoadValid = false;
	R3F_LOG_actionHeliTransValid = false;
	R3F_LOG_actionHeliDropValid = false;
};

_hasNoProhibitedCargo =
{
	private _ammoCargo = getAmmoCargo _this;
	private _repairCargo = getRepairCargo _this;

	if (isNil "_ammoCargo" || {!finite _ammoCargo}) then { _ammoCargo = 0 };
	if (isNil "_repairCargo" || {!finite _repairCargo}) then { _repairCargo = 0 };

	(_ammoCargo <= 0 && _repairCargo <= 0)
};

#define VEHICLE_UNLOCKED(VEH) (locked (VEH) < 2 || (VEH) getVariable ["ownerUID","0"] isEqualTo getPlayerUID player)

while {true} do
{
	R3F_LOG_addActionObject = objNull;

	_pointObject = cursorTarget;

	if (vehicle player == player && !isNull _pointObject && {player distance _pointObject < 14 && getObjectType _pointObject == 8}) then
	{
		R3F_LOG_addActionObject = _pointObject;

		// Note : les expressions de conditions ne sont pas factorisées pour garder de la clarté (déjà que c'est pas vraiment ça) (et le gain serait minime)

		Object_canLock = !(_pointObject getVariable ['objectLocked', false]);

		// Si l'objet est un objet déplaçable
		if ({_pointObject isKindOf _x} count R3F_LOG_CFG_movableObjects > 0) then
		{
			// Condition action deplacer_objet
			R3F_LOG_actionMoveObjectValid =
				{getText (configFile >> "CfgVehicles" >> typeOf _x >> "simulation") != "UAVPilot"} count crew _pointObject == 0 &&
				isNull R3F_LOG_playerMovesObject &&
				{!alive (_pointObject getVariable "R3F_LOG_isMovedBy")} &&
				{isNull (_pointObject getVariable "R3F_LOG_isTransportedBy")} &&
				VEHICLE_UNLOCKED(_pointObject) &&
				{!(_pointObject getVariable "R3F_LOG_disabled")};
		};

		// Si l'objet est un objet remorquable
		if ({_pointObject isKindOf _x} count R3F_LOG_CFG_towableObjects > 0) then
		{
			// Condition action selectionner_objet_remorque
			R3F_LOG_actionObjectSelectionTowValid =
				alive _pointObject &&
				isNull R3F_LOG_playerMovesObject &&
				{isNull driver _pointObject || unitIsUAV _pointObject} && // allow UAV towing
				{isNull (_pointObject getVariable "R3F_LOG_isTransportedBy")} &&
				{!alive (_pointObject getVariable "R3F_LOG_isMovedBy")} &&
				VEHICLE_UNLOCKED(_pointObject) &&
				{!(_pointObject getVariable "R3F_LOG_disabled")} &&
				{_pointObject call _hasNoProhibitedCargo};

			// Condition action detacher
			R3F_LOG_actionDetachValid =
				isNull R3F_LOG_playerMovesObject &&
				{!isNull (_pointObject getVariable "R3F_LOG_isTransportedBy") && {VEHICLE_UNLOCKED(_pointObject getVariable "R3F_LOG_isTransportedBy")}} &&
				{!(_pointObject getVariable "R3F_LOG_disabled")};

			// S'il est déplaçable
			if ({_pointObject isKindOf _x} count R3F_LOG_CFG_movableObjects > 0) then
			{
				// Condition action remorquer_deplace
				R3F_LOG_actionTowValid =
					alive R3F_LOG_playerMovesObject &&
					{R3F_LOG_playerMovesObject == _pointObject} &&
					{{
						alive _x &&
						_x != _pointObject &&
						{isNull (_x getVariable "R3F_LOG_towing")} &&
						{vectorMagnitude velocity _x < 6} &&
						{(getPos _x) select 2 < 2} &&
						VEHICLE_UNLOCKED(_x) &&
						{!(_x getVariable "R3F_LOG_disabled")}
					} count nearestObjects [_pointObject, R3F_LOG_CFG_tugs, 18] > 0} &&
					VEHICLE_UNLOCKED(_pointObject) &&
					{!(_pointObject getVariable "R3F_LOG_disabled")};

				if ({_pointObject isKindOf (_x select 0)} count R3F_LOG_CFG_transportableObjects > 0) then
				{
					// Disable towing on loadable objects
					R3F_LOG_actionObjectSelectionTowValid = false;
				};
			};
		};

		// Si l'objet est un objet transportable
		if ({_pointObject isKindOf _x} count R3F_LOG_transportableObjectClasses > 0) then
		{
			// Et qu'il est déplaçable
			if ({_pointObject isKindOf _x} count R3F_LOG_CFG_movableObjects > 0) then
			{
				// Condition action charger_deplace
				R3F_LOG_validLoadAction =
					{getText (configFile >> "CfgVehicles" >> typeOf _x >> "simulation") != "UAVPilot"} count crew _pointObject == 0 &&
					R3F_LOG_playerMovesObject == _pointObject &&
					{{
						alive _x &&
						_x != _pointObject &&
						{vectorMagnitude velocity _x < 6} &&
						{(getPos _x) select 2 < 2} &&
						VEHICLE_UNLOCKED(_x) &&
						{!(_x getVariable "R3F_LOG_disabled")}
					} count nearestObjects [_pointObject, R3F_LOG_carrierClasses, 18] > 0} &&
					VEHICLE_UNLOCKED(_pointObject) &&
					{!(_pointObject getVariable "R3F_LOG_disabled")};
			};

			// Condition action selectionner_objet_charge
			R3F_LOG_actionObjectSelectionLoadValid =
				{getText (configFile >> "CfgVehicles" >> typeOf _x >> "simulation") != "UAVPilot"} count crew _pointObject == 0 &&
				isNull R3F_LOG_playerMovesObject &&
				{isNull (_pointObject getVariable "R3F_LOG_isTransportedBy")} &&
				{!alive (_pointObject getVariable "R3F_LOG_isMovedBy")} &&
				VEHICLE_UNLOCKED(_pointObject) &&
				{!(_pointObject getVariable "R3F_LOG_disabled")};
		};

		// Si l'objet est un véhicule towing
		if ({_pointObject isKindOf _x} count R3F_LOG_CFG_tugs > 0) then
		{
			// Condition action remorquer_deplace
			R3F_LOG_actionTowValid =
				alive _pointObject &&
				alive R3F_LOG_playerMovesObject &&
				VEHICLE_UNLOCKED(R3F_LOG_playerMovesObject) &&
				{!(R3F_LOG_playerMovesObject getVariable "R3F_LOG_disabled")} &&
				{{R3F_LOG_playerMovesObject isKindOf _x} count R3F_LOG_CFG_towableObjects > 0 &&
					(_pointObject getVariable ["R3F_LOG_tugHvy",false] || {{R3F_LOG_playerMovesObject isKindOf _x} count R3F_LOG_CFG_towableObjectsHvy == 0})} &&
				{isNull (_pointObject getVariable "R3F_LOG_towing")} &&
				{vectorMagnitude velocity _pointObject < 6} &&
				{(getPos _pointObject) select 2 < 2} &&
				VEHICLE_UNLOCKED(_pointObject) &&
				{!(_pointObject getVariable "R3F_LOG_disabled")} &&
				{{_pointObject isKindOf (_x select 0)} count R3F_LOG_CFG_transportableObjects == 0} &&
				{R3F_LOG_playerMovesObject call _hasNoProhibitedCargo && _pointObject call _hasNoProhibitedCargo};

			// Condition action remorquer_selection
			R3F_LOG_actionTowSeletionValid =
				alive _pointObject &&
				isNull R3F_LOG_playerMovesObject &&
				!isNull R3F_LOG_selectedObject &&
				{R3F_LOG_selectedObject != _pointObject} &&
				VEHICLE_UNLOCKED(R3F_LOG_selectedObject) &&
				{!(R3F_LOG_selectedObject getVariable "R3F_LOG_disabled")} &&
				{{R3F_LOG_selectedObject isKindOf _x} count R3F_LOG_CFG_towableObjects > 0 &&
					(_pointObject getVariable ["R3F_LOG_tugHvy",false] || {{R3F_LOG_selectedObject isKindOf _x} count R3F_LOG_CFG_towableObjectsHvy == 0})} &&
				{isNull (_pointObject getVariable "R3F_LOG_towing")} &&
				{vectorMagnitude velocity _pointObject < 6} &&
				{(getPos _pointObject) select 2 < 2} &&
				VEHICLE_UNLOCKED(_pointObject) &&
				{!(_pointObject getVariable "R3F_LOG_disabled")} &&
				{_pointObject call _hasNoProhibitedCargo};
		};

		// Si l'objet est un véhicule carrier
		if ({_pointObject isKindOf _x} count R3F_LOG_carrierClasses > 0) then
		{
			// Condition action charger_deplace
			R3F_LOG_validLoadAction =
				alive _pointObject &&
				!isNull R3F_LOG_playerMovesObject &&
				{R3F_LOG_playerMovesObject != _pointObject} &&
				VEHICLE_UNLOCKED(R3F_LOG_playerMovesObject) &&
				{!(R3F_LOG_playerMovesObject getVariable "R3F_LOG_disabled")} &&
				{{R3F_LOG_playerMovesObject isKindOf _x} count R3F_LOG_transportableObjectClasses > 0} &&
				{vectorMagnitude velocity _pointObject < 6} &&
				{(getPos _pointObject) select 2 < 2} &&
				VEHICLE_UNLOCKED(_pointObject) &&
				{!(_pointObject getVariable "R3F_LOG_disabled")};

			// Condition action charger_selection
			R3F_LOG_validLoadSelectionAction =
				alive _pointObject &&
				isNull R3F_LOG_playerMovesObject &&
				!isNull R3F_LOG_selectedObject &&
				{R3F_LOG_selectedObject != _pointObject} &&
				VEHICLE_UNLOCKED(R3F_LOG_selectedObject) &&
				{!(R3F_LOG_selectedObject getVariable "R3F_LOG_disabled")} &&
				{{R3F_LOG_selectedObject isKindOf _x} count R3F_LOG_transportableObjectClasses > 0} &&
				{vectorMagnitude velocity _pointObject < 6} &&
				{(getPos _pointObject) select 2 < 2} &&
				VEHICLE_UNLOCKED(_pointObject) &&
				{!(_pointObject getVariable "R3F_LOG_disabled")};

			// Condition action contenu_vehicule
			R3F_LOG_validVehicleContentsAction =
				alive _pointObject &&
				isNull R3F_LOG_playerMovesObject &&
				{vectorMagnitude velocity _pointObject < 6} &&
				{(getPos _pointObject) select 2 < 2} &&
				VEHICLE_UNLOCKED(_pointObject) &&
				{!(_pointObject getVariable "R3F_LOG_disabled")};
		};
	}
	else
	{
		call _resetConditions;
	};

	// Pour l'héliportation, l'objet n'est plus pointé, mais on est dedans
	// Si le joueur est dans un héliporteur
	if ({(vehicle player) isKindOf _x} count R3F_LOG_CFG_helicarriers > 0) then
	{
		R3F_LOG_addActionObject = vehicle player;

		// On est dans le véhicule, on affiche pas les options de carrier et towing
		call _resetConditions;

		// Condition action heliporter
		R3F_LOG_actionHeliTransValid =
			driver R3F_LOG_addActionObject == player &&
			{{_x != R3F_LOG_addActionObject && VEHICLE_UNLOCKED(_x) && !(_x getVariable "R3F_LOG_disabled")} count ((nearestObjects [R3F_LOG_addActionObject, R3F_LOG_CFG_heliportableObjects, 15]) select {_obj = _x; _x call _hasNoProhibitedCargo && (R3F_LOG_addActionObject getVariable ["R3F_LOG_helicarrierHvy",false] || {{_obj isKindOf _x} count R3F_LOG_CFG_objectHeliportableHvy == 0})}) > 0} &&
			{isNull (R3F_LOG_addActionObject getVariable "R3F_LOG_helicopter")} &&
			{vectorMagnitude velocity R3F_LOG_addActionObject < 6} &&
			{(getPos R3F_LOG_addActionObject) select 2 > 1} &&
			VEHICLE_UNLOCKED(R3F_LOG_addActionObject) &&
			{!(R3F_LOG_addActionObject getVariable "R3F_LOG_disabled")} &&
			{R3F_LOG_addActionObject call _hasNoProhibitedCargo};

		// Condition action heliport_larguer
		R3F_LOG_actionHeliDropValid =
			driver R3F_LOG_addActionObject == player &&
			{!isNull (R3F_LOG_addActionObject getVariable "R3F_LOG_helicopter")} &&
			//{vectorMagnitude velocity R3F_LOG_addActionObject < 15} &&
			//{(getPos R3F_LOG_addActionObject) select 2 < 40} &&
			{!(R3F_LOG_addActionObject getVariable "R3F_LOG_disabled")} &&
			{(getPosATL (R3F_LOG_addActionObject getVariable "R3F_LOG_helicopter") select 2) >= 0};
	};

	sleep 0.3;
};
