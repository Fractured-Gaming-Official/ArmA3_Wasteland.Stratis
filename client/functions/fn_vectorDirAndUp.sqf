params["_objGrabbed", "_valid"];

if (isNil {_objGrabbed}) exitWith {};

if (isNil {_valid}) then {
	_valid = false;
};

if !(_objGrabbed isEqualTo R3F_LOG_playerMovesObject) exitWith {};

R3F_LOG_playerMovesObject attachTo [R3F_objectAttachedTo, [bldPosX, bldPosY, bldPosZ]];

private _dirAndUp =
[
[sin bldYawVector * cos bldPitchVector,
cos bldYawVector * cos bldPitchVector,
sin bldPitchVector],
[[sin bldRollVector,
-sin bldPitchVector,
cos bldRollVector * cos bldPitchVector],
-bldYawVector]
call BIS_fnc_rotateVector2D];

R3F_LOG_playerMovesObject setVectorDirAndUp _dirAndUp;

if( _valid ) then
{
	R3F_LOG_setDirAndUp = [R3F_LOG_playerMovesObject, R3F_objectAttachedTo, _dirAndUp, bldPosX, bldPosY, bldPosZ];
	publicVariable "R3F_LOG_setDirAndUp";
};
