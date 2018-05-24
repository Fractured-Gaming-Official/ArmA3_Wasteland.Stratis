/**
 * Script principal qui initialise le système de logistique
 *
 * Copyright (C) 2010 madbull ~R3F~
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "config.sqf"

if (isServer) then
{
	// On crée le point d'attache qui servira aux attachTo pour les objets à charger virtuellement dans les véhicules
	R3F_LOG_PUBVAR_attachmentPoint = "Land_HelipadEmpty_F" createVehicle [0,0,0];
	publicVariable "R3F_LOG_PUBVAR_attachmentPoint";
};

// Un serveur dédié n'en a pas besoin
if !(isServer && isDedicated) then
{
	// Le client attend que le serveur ai créé et publié la référence de l'objet servant de point d'attache
	waitUntil {!isNil "R3F_LOG_PUBVAR_attachmentPoint"};

	/** Indique quel objet le joueur est en train de déplacer, objNull si aucun */
	R3F_LOG_playerMovesObject = objNull;

	/** Pseudo-mutex permettant de n'exécuter qu'un script de manipulation d'objet à la fois (true : vérouillé) */
	R3F_LOG_mutexLocalLock = false;

	/** Objet actuellement sélectionner pour être chargé/remorqué */
	R3F_LOG_selectedObject = objNull;

	// On construit la liste des classes des transporteurs dans les quantités associés (pour les nearestObjects, count isKindOf, ...)
	R3F_LOG_carrierClasses = [];

	{
		R3F_LOG_carrierClasses = R3F_LOG_carrierClasses + [_x select 0];
	} forEach R3F_LOG_CFG_carriers;

	// On construit la liste des classes des transportables dans les quantités associés (pour les nearestObjects, count isKindOf, ...)
	R3F_LOG_transportableObjectClasses = [];

	{
		R3F_LOG_transportableObjectClasses = R3F_LOG_transportableObjectClasses + [_x select 0];
	} forEach R3F_LOG_CFG_transportableObjects;

	R3F_LOG_FNC_objectInit = compile preprocessFile "addons\R3F_ARTY_AND_LOG\R3F_LOG\objectInit.sqf";
	R3F_LOG_FNC_helicarrierInit = compile preprocessFile "addons\R3F_ARTY_AND_LOG\R3F_LOG\helicarrier\helicarrierInit.sqf";
	R3F_LOG_FNC_tugInit = compile preprocessFile "addons\R3F_ARTY_AND_LOG\R3F_LOG\towing\towInit.sqf";
	R3F_LOG_FNC_carrierInit = compile preprocessFile "addons\R3F_ARTY_AND_LOG\R3F_LOG\carrier\carrierInit.sqf";

	/** Indique quel est l'objet concerné par les variables d'actions des addAction */
	R3F_LOG_addActionObject = objNull;

	// Liste des variables activant ou non les actions de menu
	R3F_LOG_validLoadAction = false;
	R3F_LOG_validLoadSelectionAction = false;
	R3F_LOG_validVehicleContentsAction = false;

	R3F_LOG_actionTowValid = false;
	R3F_LOG_actionTowSeletionValid = false;

	R3F_LOG_actionHeliTransValid = false;
	R3F_LOG_actionHeliDropValid = false;

	R3F_LOG_actionMoveObjectValid = false;
	R3F_LOG_actionObjectSelectionTowValid = false;
	R3F_LOG_actionDetachValid = false;
	R3F_LOG_actionObjectSelectionLoadValid = false;

	/** Ce fil d'exécution permet de diminuer la fréquence des vérifications des conditions normalement faites dans les addAction (~60Hz) */
	execVM "addons\R3F_ARTY_AND_LOG\R3F_LOG\monitorConditionsActionsMenu.sqf";
};
