/**
 * Larguer un objet en train d'être héliporté
 *
 * @param 0 l'héliporteur
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

	private ["_helicarrier", "_object", "_airdrop"];

	_helicarrier = _this select 0;
	_object = _helicarrier getVariable "R3F_LOG_helicopter";
	_parachute = param [3, false, [false]];

	// On mémorise sur le réseau que le véhicule n'héliporte plus rien
	_helicarrier setVariable ["R3F_LOG_helicopter", objNull, true];
	// On mémorise aussi sur le réseau que l'objet n'est plus attaché
	_object setVariable ["R3F_LOG_isTransportedBy", objNull, true];

	if (_parachute) then
	{
		pvar_parachuteLiftedVehicle = netId _object;
		publicVariableServer "pvar_parachuteLiftedVehicle";
	}
	else
	{
		_airdrop = (vectorMagnitude velocity _helicarrier > 15 || (getPos _helicarrier) select 2 > 40);

		if (local _object) then
		{
			[_object, _airdrop] call detachTowedObject;
		}
		else
		{
			pvar_detachTowedObject = [netId _object, _airdrop];
			publicVariable "pvar_detachTowedObject";
		};
	};

	player globalChat format [STR_R3F_LOG_actionHeliDropDone, getText (configFile >> "CfgVehicles" >> (typeOf _object) >> "displayName")];

	R3F_LOG_mutexLocalLock = false;
};
