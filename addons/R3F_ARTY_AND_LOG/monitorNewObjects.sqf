/**
 * Recherche périodiquement les nouveaux objets pour leur ajouter les fonctionnalités d'artillerie et de logistique si besoin
 * Script à faire tourner dans un fil d'exécution dédié
 *
 * Copyright (C) 2010 madbull ~R3F~
 *
 * This program is free software under the terms of the GNU General Public License version 3.
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "R3F_ARTY_disableEnable.sqf"
#include "R3F_LOG_disableEnable.sqf"

// Attente fin briefing
sleep 0.1;

private ["_listObjectsDeplHeliTowTransp", "_knownVehList", "_vehList", "_countVehList", "_i", "_object"];

#ifdef R3F_LOG_enable
// Union des tableaux de types d'objets servant dans un isKindOf
_listObjectsDeplHeliTowTransp = R3F_LOG_CFG_movableObjects + R3F_LOG_CFG_heliportableObjects + R3F_LOG_CFG_towableObjects + R3F_LOG_transportableObjectClasses;
#endif

// Contiendra la liste des véhicules (et objets) déjà initialisés
//_knownVehList = [];

while {true} do
{
	if !(isNull player) then
	{
		// Récupération des tout les nouveaux véhicules de la carte et des nouveaux objets dérivant de "Static" (caisse de mun, drapeau, ...) proches du joueur
		_vehList = nearestObjects [player, ["LandVehicle", "Ship", "Air", "Thing", "Static"], 75];

		_countVehList = count _vehList;

		if (_countVehList > 0) then
		{
			_sleepDelay = 10 / _countVehList;

			// On parcoure tout les véhicules présents dans le jeu en 18 secondes
			{
				_object = _x;

				if !(_object getVariable ["R3F_LOG_initDone", false]) then
				{
					#ifdef R3F_LOG_enable
					// If object can be moved / airlifted / towed / loaded in
					if ({_object isKindOf _x} count _listObjectsDeplHeliTowTransp > 0) then
					{
						[_object] spawn R3F_LOG_FNC_objectInit;
					};

					// If vehicle can airlift
					if ({_object isKindOf _x} count R3F_LOG_CFG_helicarriers > 0) then
					{
						[_object] spawn R3F_LOG_FNC_helicarrierInit;
					};

					// If vehicle can transport contents
					if ({_object isKindOf _x} count R3F_LOG_carrierClasses > 0) then
					{
						[_object] spawn R3F_LOG_FNC_carrierInit;
					};

					// If vehicle can tow
					if ({_object isKindOf _x} count R3F_LOG_CFG_tugs > 0) then
					{
						[_object] spawn R3F_LOG_FNC_tugInit;
					};

					_object setVariable ["R3F_LOG_initDone", true];
					if (!local _object && !simulationEnabled _object) then { _object enableSimulation true };
					#endif
				};

				sleep _sleepDelay;

			} forEach _vehList;

			/*
			// Les objets ont été initialisés, on les mémorise pour ne plus les ré-initialiser
			{
				_knownVehList set [count _knownVehList, _x];
			} forEach _vehList;*/
		}
		else
		{
			sleep 10;
		};
	}
	else
	{
		sleep 2;
	};
};
