/**
 * Recherche périodiquement les nouveaux objets pour leur ajouter les fonctionnalités d'artillerie et de logistique si besoin
 * Script à faire tourner dans un fil d'exécution dédié
 * Version allégée pour un serveur dédié uniquement
 *
 * Copyright (C) 2010 madbull ~R3F~
 *
 * This program is free software under the terms of the GNU General Public License version 3.
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

// A l'heure actuelle ce fil d'exécution n'est utile que si l'artillerie est activée
#ifdef R3F_ARTY_enable

// Attente fin briefing
sleep 0.1;

private ["_vehList", "_countVehList", "_i", "_object"];

// Contiendra la liste des véhicules (et objets) déjà initialisés
_knownVehList = [];

while {true} do
{
	// Récupération des tout les nouveaux véhicules de la carte SAUF les objets dérivant de "Static" non récupérable par "vehicles"
	_vehList = vehicles;
	_countVehList = count _vehList;

	if (_countVehList > 0) then
	{
		// On parcoure tout les véhicules présents dans le jeu en 18 secondes
		{
			if !(_object getVariable ["R3F_LOG_initDediDone", false]) then
			{
				_object = _x;
				_object setVariable ["R3F_LOG_initDediDone", true];
			}

			sleep (18/_countVehList);
		} forEach _vehList;
	}
	else
	{
		sleep 18;
	};
};

#endif
