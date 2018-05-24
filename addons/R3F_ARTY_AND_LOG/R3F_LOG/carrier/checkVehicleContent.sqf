/**
 * Ouvre la boîte de dialogue du contenu du véhicule et la prérempli en fonction de véhicule
 *
 * @param 0 le véhicule dont il faut afficher le contenu
 *
 * Copyright (C) 2010 madbull ~R3F~
 *
 * This program is free software under the terms of the GNU General Public License version 3.
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

disableSerialization; // A cause des displayCtrl

if (R3F_LOG_mutexLocalLock) then
{
	player globalChat STR_R3F_LOG_mutexActionOngoing;
}
else
{
	R3F_LOG_mutexLocalLock = true;

	private ["_carrier", "_currentLoad", "_maxLoad", "_contents", "_contentTabGroups"];
	private ["_objectsTab", "_amountTab", "_i", "_j", "_dlg_vehicleContents"];

	_carrier = _this select 0;

	uiNamespace setVariable ["R3F_LOG_dlg_CV_carrier", _carrier];

	createDialog "R3F_LOG_dlg_vehicleContents";

	_contents = _carrier getVariable "R3F_LOG_loadedObjects";

	/** Liste des noms de classe des objets contenu dans le véhicule, sans doublon */
	_objectsTab = [];
	/** Quantité associé (par l'index) aux noms de classe dans _objectsTab */
	_amountTab = [];

	_currentLoad = 0;

	// Préparation de la liste du contenu et des quantités associées aux objets
	for [{_i = 0}, {_i < count _contents}, {_i = _i + 1}] do
	{
		private ["_object"];
		_object = _contents select _i;

		if !((typeOf _object) in _objectsTab) then
		{
			_objectsTab = _objectsTab + [typeOf _object];
			_amountTab = _amountTab + [1];
		}
		else
		{
			private ["_idxObject"];
			_idxObject = _objectsTab find (typeOf _object);
			_amountTab set [_idxObject, ((_amountTab select _idxObject) + 1)];
		};

		// Ajout de l'objet de le chargement actuel
		for [{_j = 0}, {_j < count R3F_LOG_CFG_transportableObjects}, {_j = _j + 1}] do
		{
			if (_object isKindOf (R3F_LOG_CFG_transportableObjects select _j select 0)) exitWith
			{
				_currentLoad = _currentLoad + (R3F_LOG_CFG_transportableObjects select _j select 1);
			};
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


	// Affichage du contenu dans l'interface
	#include "dlg_constants.h"
	private ["_ctrlList"];

	_dlg_vehicleContents = findDisplay R3F_LOG_IDD_dlg_vehicleContents;

	/**** DEBUT des traductions des labels ****/
	(_dlg_vehicleContents displayCtrl R3F_LOG_IDC_dlg_CV_title) ctrlSetText STR_R3F_LOG_dlg_CV_title;
	(_dlg_vehicleContents displayCtrl R3F_LOG_IDC_dlg_CV_credits) ctrlSetText STR_R3F_ARTY_LOG_productName;
	(_dlg_vehicleContents displayCtrl R3F_LOG_IDC_dlg_CV_unloadBtn) ctrlSetText STR_R3F_LOG_dlg_CV_unloadBtn;
	(_dlg_vehicleContents displayCtrl R3F_LOG_IDC_dlg_CV_cancelBtn) ctrlSetText STR_R3F_LOG_dlg_CV_cancelBtn;
	/**** FIN des traductions des labels ****/

	(_dlg_vehicleContents displayCtrl R3F_LOG_IDC_dlg_CV_vehicleCapacity) ctrlSetText (format [R3F_LOG_IDC_dlg_CV_vehicleCapacity, _currentLoad, _maxLoad]);

	_ctrlList = _dlg_vehicleContents displayCtrl R3F_LOG_IDC_dlg_CV_contentsList;

	if (count _objectsTab == 0) then
	{
		(_dlg_vehicleContents displayCtrl R3F_LOG_IDC_dlg_CV_unloadBtn) ctrlEnable false;
	}
	else
	{
		// Insertion de chaque type d'objets dans la liste
		for [{_i = 0}, {_i < count _objectsTab}, {_i = _i + 1}] do
		{
			private ["_index", "_icon"];

			_icon = getText (configFile >> "CfgVehicles" >> (_objectsTab select _i) >> "icon");

			// Si l'icône est valide
			if (toString ([toArray _icon select 0]) == "\") then
			{
				_index = _ctrlList lbAdd (getText (configFile >> "CfgVehicles" >> (_objectsTab select _i) >> "displayName") + format [" (%1x)", _amountTab select _i]);
				_ctrlList lbSetPicture [_index, _icon];
			}
			else
			{
				// Si le téléphone satellite est utilisé pour un PC d'artillerie
				if (!(isNil "R3F_ARTY_active") && (_objectsTab select _i) == "SatPhone") then
				{
					_index = _ctrlList lbAdd ("     " + STR_R3F_LOG_artyPcName + format [" (%1x)", _amountTab select _i]);
				}
				else
				{
					_index = _ctrlList lbAdd ("     " + getText (configFile >> "CfgVehicles" >> (_objectsTab select _i) >> "displayName") + format [" (%1x)", _amountTab select _i]);
				};
			};

			_ctrlList lbSetData [_index, _objectsTab select _i];
		};
	};

	waitUntil (uiNamespace getVariable "R3F_LOG_dlg_vehicleContents");
	R3F_LOG_mutexLocalLock = false;
};
