/**
 * Sélectionne un objet à remorquer
 *
 * @param 0 l'objet à sélectionner
 */

if (R3F_LOG_mutexLocalLock) exitWith
{
	player globalChat STR_R3F_LOG_mutexActionOngoing;
};

private _object = _this select 0;

if (unitIsUAV _object && {!(_object getVariable ["ownerUID","0"] isEqualTo getPlayerUID player) && !(group (uavControl _object select 0) in [grpNull, group player])}) then
{
 	player globalChat STR_R3F_LOG_actionObjectSelectionUAVGrp;
}
else
{
	R3F_LOG_selectedObject = _object;

	R3F_LOG_selectedObject = _this select 0;
	player globalChat format [STR_R3F_LOG_actionSelectVehToTow, getText (configFile >> "CfgVehicles" >> (typeOf R3F_LOG_selectedObject) >> "displayName")];

	R3F_LOG_mutexLocalLock = false;
};
