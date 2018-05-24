/**
 * Initialise un véhicule towing
 *
 * @param 0 le towing
 */

private ["_tug", "_isDisabled", "_towing"];

_tug = _this select 0;

_isDisabled = _tug getVariable "R3F_LOG_disabled";
if (isNil "_isDisabled") then
{
	_tug setVariable ["R3F_LOG_disabled", false];
};

// Définition locale de la variable si elle n'est pas définie sur le réseau
_towing = _tug getVariable "R3F_LOG_towing";
if (isNil "_towing") then
{
	_tug setVariable ["R3F_LOG_towing", objNull, false];
};

if ({_tug isKindOf _x} count R3F_LOG_CFG_tugsHvy > 0) then
{
	_tug setVariable ["R3F_LOG_tugHvy", true, false];
};

_tug addAction [("<img image='client\icons\r3f_tow.paa' color='#ffff00'/> <t color='#ffff00'>" + STR_R3F_LOG_actionTowObject + "</t>"), "addons\R3F_ARTY_AND_LOG\R3F_LOG\towing\doTow.sqf", nil, 6, true, true, "", "R3F_LOG_addActionObject == _target && R3F_LOG_actionTowValid"];

_tug addAction [("<img image='client\icons\r3f_tow.paa' color='#ffff00'/> <t color='#ffff00'>" + STR_R3F_LOG_actionTowSelection + "</t>"), "addons\R3F_ARTY_AND_LOG\R3F_LOG\towing\towSelection.sqf", nil, 6, true, true, "", "R3F_LOG_addActionObject == _target && R3F_LOG_actionTowSeletionValid"];

_tug addAction [("<img image='client\icons\r3f_tow.paa' color='#ffff00'/> <t color='#ffff00'>" + STR_R3F_LOG_actionCancelTow + "</t>"), "addons\R3F_ARTY_AND_LOG\R3F_LOG\towing\cancelTow.sqf", nil, 6, true, true, "", "R3F_LOG_addActionObject == _target && R3F_LOG_actionTowSeletionValid"];
