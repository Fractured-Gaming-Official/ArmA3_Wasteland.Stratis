/**
 * Initialise un véhicule carrier
 *
 * @param 0 le carrier
 */

private ["_carrier", "_isDisabled", "_loadedObjects"];

_carrier = _this select 0;

_isDisabled = _carrier getVariable "R3F_LOG_disabled";
if (isNil "_isDisabled") then
{
	_carrier setVariable ["R3F_LOG_disabled", false];
};

// Définition locale de la variable si elle n'est pas définie sur le réseau
_loadedObjects = _carrier getVariable "R3F_LOG_loadedObjects";
if (isNil "_loadedObjects") then
{
	_carrier setVariable ["R3F_LOG_loadedObjects", [], false];
};

_carrier addAction [("<img image='client\icons\r3f_loadin.paa' color='#06ef00'/> <t color='#06ef00'>" + STR_R3F_LOG_actionLoad + "</t>"), "addons\R3F_ARTY_AND_LOG\R3F_LOG\carrier\loadUp.sqf", nil, 6, true, true, "", "R3F_LOG_addActionObject == _target && R3F_LOG_validLoadAction"];

_carrier addAction [("<img image='client\icons\r3f_loadin.paa' color='#06ef00'/> <t color='#06ef00'>" + STR_R3F_LOG_actionLoadSelection + "</t>"), "addons\R3F_ARTY_AND_LOG\R3F_LOG\carrier\loadSelection.sqf", nil, 6, true, true, "", "R3F_LOG_addActionObject == _target && R3F_LOG_validLoadSelectionAction"];

_carrier addAction [("<img image='client\icons\r3f_contents.paa' color='#ffff00'/> <t color='#ffff00'>" + STR_R3F_LOG_vehicleContentsAction + "</t>"), "addons\R3F_ARTY_AND_LOG\R3F_LOG\carrier\checkVehicleContent.sqf", nil, 5, false, true, "", "R3F_LOG_addActionObject == _target && R3F_LOG_validVehicleContentsAction"];
