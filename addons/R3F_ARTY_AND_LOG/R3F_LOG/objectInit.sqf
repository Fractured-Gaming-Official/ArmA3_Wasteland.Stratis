/**
 * Initialise un objet déplaçable/héliportable/remorquable/transportable
 *
 * @param 0 l'objet
 *
 * Copyright (C) 2010 madbull ~R3F~
 *
 * This program is free software under the terms of the GNU General Public License version 3.
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

private ["_object", "_isDisabled", "_isCarriedBy", "_isMovedBy", "_objectState", "_doLock", "_doUnlock","_currentAnim","_config","_onLadder"];

_object = _this select 0;

_doLock = 0;
_doUnlock = 1;

_isDisabled = _object getVariable "R3F_LOG_disabled";
if (isNil "_isDisabled") then
{
	_object setVariable ["R3F_LOG_disabled", false];  //on altis its smarter to only enable deplacement on objects we WANT players to move so if it doesnt find an r3f tag, it disables r3f on the object
};

// Définition locale de la variable si elle n'est pas définie sur le réseau
_isCarriedBy = _object getVariable "R3F_LOG_isTransportedBy";
if (isNil "_isCarriedBy") then
{
	_object setVariable ["R3F_LOG_isTransportedBy", objNull, false];
};

// Définition locale de la variable si elle n'est pas définie sur le réseau
_isMovedBy = _object getVariable "R3F_LOG_isMovedBy";
if (isNil "_isMovedBy") then
{
	_object setVariable ["R3F_LOG_isMovedBy", objNull, false];
};

// Ne pas monter dans un véhicule qui est en cours de transport
_object addEventHandler ["GetIn",
{
	_veh = _this select 0;
	_seat = _this select 1;
	_unit = _this select 2;

	_movedBy = _veh getVariable ["R3F_LOG_isMovedBy", objNull];
	_towedBy = _veh getVariable ["R3F_LOG_isTransportedBy", objNull];

	if (_unit == player && _seat == "DRIVER" && (!isNull _towedBy || alive _movedBy)) then
	{
		player action ["Eject", _veh];
		moveOut player;
		player globalChat STR_R3F_LOG_transport_en_cours;
	};
}];

if ({_object isKindOf _x} count R3F_LOG_CFG_movableObjects > 0) then
{
	_object addAction [("<img image='client\icons\r3f_lift.paa' color='#ffff00'/> <t color='#ffff00'>" + STR_R3F_LOG_actionMoveObject + "</t>"), "addons\R3F_ARTY_AND_LOG\R3F_LOG\movableObject\move.sqf", nil, 5, false, true, "", "R3F_LOG_addActionObject == _target && R3F_LOG_actionMoveObjectValid && !(_target getVariable ['objectLocked', false])"];
	_object addAction [("<img image='client\icons\r3f_lock.paa' color='#ff0000'/> <t color='#ff0000'>" + STR_LOCK_OBJECT + "</t>"), "addons\R3F_ARTY_AND_LOG\R3F_LOG\movableObject\objectLockStateMachine.sqf", _doLock, -5, false, true, "", "R3F_LOG_addActionObject == _target && R3F_LOG_actionMoveObjectValid && Object_canLock && (!(_target isKindOf 'AllVehicles') || {_target isKindOf 'StaticWeapon'})"];
	_object addAction [("<img image='client\icons\r3f_unlock.paa' color='#06ef00'/> <t color='#06ef00'>" + STR_UNLOCK_OBJECT + "</t>"), "addons\R3F_ARTY_AND_LOG\R3F_LOG\movableObject\objectLockStateMachine.sqf", _doUnlock, -5, false, true, "", "R3F_LOG_addActionObject == _target && R3F_LOG_actionMoveObjectValid && !Object_canLock"];
};

if ({_object isKindOf _x} count R3F_LOG_CFG_towableObjects > 0) then
{
	if ({_object isKindOf _x} count R3F_LOG_CFG_movableObjects > 0) then
	{
		_object addAction [("<img image='client\icons\r3f_tow.paa' color='#ffff00'/> <t color='#ffff00'>" + STR_R3F_LOG_actionTowObject + "</t>"), "addons\R3F_ARTY_AND_LOG\R3F_LOG\towing\doTow.sqf", nil, 6, true, true, "", "R3F_LOG_addActionObject == _target && R3F_LOG_actionTowValid"];
	};

	_object addAction [("<img image='client\icons\r3f_tow.paa' color='#ffff00'/> <t color='#ffff00'>" + STR_R3F_LOG_actionTowSelectedVeh + "</t>"), "addons\R3F_ARTY_AND_LOG\R3F_LOG\towing\selectObject.sqf", nil, 5, false, true, "", "R3F_LOG_addActionObject == _target && R3F_LOG_actionObjectSelectionTowValid && Object_canLock"];

	_object addAction [("<img image='client\icons\r3f_untow.paa' color='#06ef00'/> <t color='#06ef00'>" + STR_R3F_LOG_actionDetachVeh + "</t>"), "addons\R3F_ARTY_AND_LOG\R3F_LOG\towing\detach.sqf", nil, 6, true, true, "", "R3F_LOG_addActionObject == _target && R3F_LOG_actionDetachValid"];
};

if ({_object isKindOf _x} count R3F_LOG_transportableObjectClasses > 0) then
{
	if ({_object isKindOf _x} count R3F_LOG_CFG_movableObjects > 0) then
	{
		_object addAction [("<img image='client\icons\r3f_loadin.paa' color='#06ef00'/> <t color='#06ef00'>" + STR_R3F_LOG_actionLoad + "</t>"), "addons\R3F_ARTY_AND_LOG\R3F_LOG\carrier\loadUp.sqf", nil, 6, true, true, "", "R3F_LOG_addActionObject == _target && R3F_LOG_validLoadAction"];
	};

	_object addAction [("<img image='client\icons\r3f_loadin.paa' color='#06ef00'/> <t color='#06ef00'>" + STR_R3F_LOG_actionObjectLoadSelection + "</t>"), "addons\R3F_ARTY_AND_LOG\R3F_LOG\carrier\selectObject.sqf", nil, 5, false, true, "", "R3F_LOG_addActionObject == _target && R3F_LOG_actionObjectSelectionLoadValid && Object_canLock"];
};
