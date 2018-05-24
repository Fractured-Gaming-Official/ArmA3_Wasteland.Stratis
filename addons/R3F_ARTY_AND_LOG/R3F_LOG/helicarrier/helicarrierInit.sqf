/**
 * Initialise un véhicule héliporteur
 *
 * @param 0 l'héliporteur
 */

private ["_helicarrier", "_isDisabled", "_helicopter"];

_helicarrier = _this select 0;

_isDisabled = _helicarrier getVariable "R3F_LOG_disabled";
if (isNil "_isDisabled") then
{
	_helicarrier setVariable ["R3F_LOG_disabled", false];
};

// Définition locale de la variable si elle n'est pas définie sur le réseau
_helicopter = _helicarrier getVariable "R3F_LOG_helicopter";
if (isNil "_helicopter") then
{
	_helicarrier setVariable ["R3F_LOG_helicopter", objNull, false];
};

if ({_helicarrier isKindOf _x} count R3F_LOG_CFG_helicarrierHvy > 0) then
{
	_helicarrier setVariable ["R3F_LOG_helicarrierHvy", true, false];
};

_helicarrier addAction [("<img image='client\icons\r3f_tow.paa' color='#ffff00'/> <t color='#ffff00'>" + STR_R3F_LOG_actionHeliLift + "</t>"), "addons\R3F_ARTY_AND_LOG\R3F_LOG\helicarrier\helicarrier.sqf", nil, 6, true, true, "", "R3F_LOG_addActionObject == _target && R3F_LOG_actionHeliTransValid"];

_helicarrier addAction [("<img image='client\icons\r3f_release.paa' color='#06ef00'/> <t color='#06ef00'>" + STR_R3F_LOG_actionHeliDrop + "</t>"), "addons\R3F_ARTY_AND_LOG\R3F_LOG\helicarrier\drop.sqf", nil, 6, true, true, "", "R3F_LOG_addActionObject == _target && R3F_LOG_actionHeliDropValid"];

_helicarrier addAction [("<img image='client\icons\r3f_release.paa' color='#06ef00'/> <t color='#06ef00'>" + STR_R3F_LOG_actionHeliParaDrop + "</t>"), "addons\R3F_ARTY_AND_LOG\R3F_LOG\helicarrier\drop.sqf", true, 6, true, true, "", "R3F_LOG_addActionObject == _target && R3F_LOG_actionHeliDropValid && {(getPos vehicle player) select 2 >= 40}"];
