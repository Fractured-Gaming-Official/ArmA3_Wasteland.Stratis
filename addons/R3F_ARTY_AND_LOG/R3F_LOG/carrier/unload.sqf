/**
 * Décharger un objet d'un carrier - appelé deuis l'interface listant le contenu du carrier
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

	#include "dlg_constants.h"
	private ["_carrier", "_loadedObjects", "_objectTypeToUnload", "_objectToUnload", "_i"];

	_carrier = uiNamespace getVariable "R3F_LOG_dlg_CV_carrier";
	_loadedObjects = _carrier getVariable "R3F_LOG_loadedObjects";

	_objectTypeToUnload = lbData [R3F_LOG_IDC_dlg_CV_contentsList, lbCurSel R3F_LOG_IDC_dlg_CV_contentsList];

	closeDialog 0;

	// Recherche d'un objet du type demandé
	_objectToUnload = objNull;
	for [{_i = 0}, {_i < count _loadedObjects}, {_i = _i + 1}] do
	{
		if (typeOf (_loadedObjects select _i) == _objectTypeToUnload) exitWith
		{
			_objectToUnload = _loadedObjects select _i;
		};
	};

	if !(isNull _objectToUnload) then
	{
		// On mémorise sur le réseau le nouveau contenu du carrier (càd avec cet objet en moins)
		_loadedObjects = _loadedObjects - [_objectToUnload];
		_carrier setVariable ["R3F_LOG_loadedObjects", _loadedObjects, true];
		_objectToUnload setVariable ["R3F_LOG_isTransportedBy", objNull, true];
		[_objectToUnload, true] call fn_enableSimulationGlobal;
		[R3F_LOG_PUBVAR_attachmentPoint, true] call fn_enableSimulationGlobal;

		detach _objectToUnload;

		if (unitIsUAV _objectToUnload) then
		{
			[_objectToUnload, 1] call A3W_fnc_setLockState; // unlock
			["enableDriving", _objectToUnload] call A3W_fnc_towingHelper;
		};

		if ({_objectToUnload isKindOf _x} count R3F_LOG_CFG_movableObjects > 0) then
		{
			[_objectToUnload] execVM "addons\R3F_ARTY_AND_LOG\R3F_LOG\movableObject\move.sqf";
		}
		else
		{
			private ["_maxDimension"];
			_maxDimension = (((boundingBox _objectToUnload select 1 select 1) max (-(boundingBox _objectToUnload select 0 select 1))) max ((boundingBox _objectToUnload select 1 select 0) max (-(boundingBox _objectToUnload select 0 select 0))));

			player globalChat STR_R3F_LOG_actionUnloadInProgress;

			sleep 2;

			// On pose l'objet au hasard vers l'arrière du carrier
			_objectToUnload setPos [
				(getPos _carrier select 0) - ((_maxDimension+5+(random 10)-(boundingBox _carrier select 0 select 1))*sin (getDir _carrier - 90+random 180)),
				(getPos _carrier select 1) - ((_maxDimension+5+(random 10)-(boundingBox _carrier select 0 select 1))*cos (getDir _carrier - 90+random 180)),
				0
			];
			_objectToUnload setVelocity [0,0,0];

			player globalChat STR_R3F_LOG_actionUnloadDone;
		};
	}
	else
	{
		player globalChat STR_R3F_LOG_actionAlreadyUnloaded;
	};

	R3F_LOG_mutexLocalLock = false;
};
