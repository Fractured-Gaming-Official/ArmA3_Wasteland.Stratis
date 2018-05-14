// ******************************************************************************************
// * This project is licensed under the GNU Affero GPL v3. Copyright � 2014 A3Wasteland.com *
// ******************************************************************************************
//	@file Name: mission_Roadblock.sqf
//	@file Author: JoSchaap, AgentRev, LouD

if (!isServer) exitwith {};
#include "sideMissionDefines.sqf";

private [ "_box1", "_barGate", "_bunker1", "_bunker2", "_obj1", "_obj2", "_drop_item"];

_setupVars =
{
	_missionType = "Roadblock";
	_locationsArray = RoadblockMissionMarkers;
};

_setupObjects =
{
	_missionPos = markerPos _missionLocation;
	_markerDir = markerDir _missionLocation;

	//delete existing base parts and vehicles at location
	_baseToDelete = nearestObjects [_missionPos, ["All"], 25];
	{ deleteVehicle _x } forEach _baseToDelete;

	_bargate = createVehicle ["Land_BarGate_F", _missionPos, [], 0, "NONE"];
	_bargate setDir _markerDir;
	_bunker1 = createVehicle ["Land_BagBunker_Small_F", _bargate modelToWorld [6.5,-2,-4.1], [], 0, "NONE"];
	_obj1 = createVehicle ["I_GMG_01_high_F", _bargate modelToWorld [6.5,-2,-4.1], [], 0, "NONE"];
	_bunker1 setDir _markerDir;
	_bunker2 = createVehicle ["Land_BagBunker_Small_F", _bargate modelToWorld [-8,-2,-4.1], [], 0, "NONE"];
	_obj2 = createVehicle ["I_GMG_01_high_F", _bargate modelToWorld [-8,-2,-4.1], [], 0, "NONE"];
	_bunker2 setDir _markerDir;

	_aiGroup = createGroup CIVILIAN;
	[_aiGroup,_missionPos,12,15] spawn createCustomGroup3;

	_missionHintText = format ["Enemies have set up an illegal roadblock and are stopping all vehicles! They need to be stopped!", sideMissionColor];
};

_waitUntilMarkerPos = nil;
_waitUntilExec = nil;
_waitUntilCondition = nil;

_failedExec =
{
	// Mission failed

	{ deleteVehicle _x } forEach [_barGate, _bunker1, _bunker2, _obj1, _obj2];

};

_drop_item =
{
	private["_item", "_pos"];
	_item = _this select 0;
	_pos = _this select 1;

	if (isNil "_item" || {typeName _item != typeName [] || {count(_item) != 2}}) exitWith {};
	if (isNil "_pos" || {typeName _pos != typeName [] || {count(_pos) != 3}}) exitWith {};

	private["_id", "_class"];
	_id = _item select 0;
	_class = _item select 1;

	private["_obj"];
	_obj = createVehicle [_class, _pos, [], 5, "None"];
	_obj setPos ([_pos, [[2 + random 3,0,0], random 360] call BIS_fnc_rotateVector2D] call BIS_fnc_vectorAdd);
	_obj setVariable ["mf_item_id", _id, true];
};

_successExec =
{
	_numCratesToSpawn = 2; // edit this value to how many crates are to be spawned!
	_lastPos = _this;
	_i = 0;
	while {_i < _numCratesToSpawn} do
	{
		_lastPos spawn
		{
			_lastPos = _this;
	     		_crate = createVehicle ["Box_East_Wps_F", _lastPos, [], 5, "None"];
	     		_crate setDir random 360;
	     		_crate allowDamage false;
	     		waitUntil {!isNull _crate};
	     		if ((_lastPos select 2) > 5) then
			{
		 		_crateParachute = createVehicle ["O_Parachute_02_F", (getPosATL _crate), [], 0, "CAN_COLLIDE" ];
		 		_crateParachute allowDamage false;
		 		_crate attachTo [_crateParachute, [0,0,0]];
		 		_crate call randomCrateLoadOut;
		 		waitUntil {getPosATL _crate select 2 < 5};
		 		detach _crate;
		 		deleteVehicle _crateParachute;
			};
	     		_smokeSignalTop = createVehicle  ["SmokeShellRed_infinite", getPosATL _crate, [], 0, "CAN_COLLIDE" ];
	     		_lightSignalTop = createVehicle  ["Chemlight_red", getPosATL _crate, [], 0, "CAN_COLLIDE" ];
	     		_smokeSignalTop attachTo [_crate, [0,0,0.25]];
	     		_lightSignalTop attachTo [_crate, [0,0,0.25]];
	     		_smokeSignalBtm = createVehicle  ["SmokeShellRed_infinite", getPosATL _crate, [], 0, "CAN_COLLIDE" ];
	     		_lightSignalBtm = createVehicle  ["Chemlight_red", getPosATL _crate, [], 0, "CAN_COLLIDE" ];
	     		_smokeSignalBtm attachTo [_crate, [0,0,-0.2]];
	     		_lightSignalBtm attachTo [_crate, [0,0,-0.2]];
			_timer = time + 120;
			waitUntil {sleep 1; time > _timer};
			_crate allowDamage true;
			deleteVehicle _smokeSignalTop;
			deleteVehicle _lightSignalTop;
			deleteVehicle _smokeSignalBtm;
			deleteVehicle _lightSignalBtm;
	 	};
	        _i = _i + 1;
	};
};

_this call sideMissionProcessor;
