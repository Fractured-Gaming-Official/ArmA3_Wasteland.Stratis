// ******************************************************************************************
// * This project is licensed under the GNU Affero GPL v3. Copyright © 2018 A3Wasteland.com *
// ******************************************************************************************
//	@file Name: mission_shipWrecked.sqf - high payout for high risk.
//	@file Author: soulkobk
//	@file Updated: 5:33 PM 23/05/2018 by soulkobk

if (!isServer) exitwith {};

	#include "moneyMissionDefines.sqf";

	private ["_pos","_radius","_leader","_speedMode","_waypoint","_numWaypoints","_groupAmount"];
	private ["_moneyAmount","_moneyBundles","_moneyText","_moneyArray"];
	private ["_crateAmount","_crateArray"];
	private ["_aiGroup"];
	private ["_patrolBoatClassArray","_patrolBoatAmount"];

	_setupVars =
	{
		_missionType = "Ship Wrecked";
		_locationsArray = nil;

		_moneyAmount = round(floor(random [100000,250000,400000]));
		_moneyBundles = 10;

		_moneyText = "$" + (_moneyAmount call fn_numbersText);

		_crateAmount = selectRandom [4,5,6];

		_patrolBoatClassArray =
		[
		"B_Boat_Armed_01_minigun_F",
		"B_Boat_Transport_01_F",
		"O_Boat_Armed_01_hmg_F",
		"O_Boat_Transport_01_F",
		"I_Boat_Armed_01_minigun_F",
		"I_Boat_Transport_01_F"
		];
		_patrolBoatAmount = selectRandom [2,3,4];
	};

	_setupObjects =
	{
		_speedMode = if (missionDifficultyHard) then {"NORMAL"} else {"LIMITED"};
		_shipWreck = ""; _missionPos = [0,0,0]; _radius = 0;
		_shipWreckOK = false;
		while {!_shipWreckOK} do
		{
			_shipWreck = selectRandom (nearestTerrainObjects [[0,0,0], ["ShipWreck"],9999]);
			_missionPos = getPosASL _shipWreck;
			_radius = 100;
			_anyPlayersAround = (nearestObjects [_missionPos,["MAN"],(_radius * 3)]) select {isPlayer _x};
			if ((count _anyPlayersAround) isEqualTo 0) exitWith
			{
				_shipWreckOK = true;
			};
			sleep 0.1;
		};
		_crateArray = [];
		for [{_i = 0},{_i < _crateAmount},{_i = _i + 1}] do
		{
			_crateObject = selectRandom ["Box_NATO_Wps_F","Box_East_Wps_F","Box_IND_Wps_F","Box_NATO_WpsSpecial_F","Box_East_WpsSpecial_F","Box_IND_WpsSpecial_F"];
			_crate = createVehicle [_crateObject,(ASLtoATL _missionPos),[],5,"CAN_COLLIDE"];
			_crate setPos ([(ASLtoATL _missionPos),[[5 + random 5,0,0],random 360] call BIS_fnc_rotateVector2D] call BIS_fnc_vectorAdd);
			_crate setDir random 360;
			_crate allowDamage false;
			_crate setVariable ["R3F_LOG_disabled",true,true]; // so can't access inventory.
			_crate setVariable ["A3W_storeSellBox",true,true]; // so can't access deposit money.
			clearBackpackCargoGlobal _crate;
			clearMagazineCargoGlobal _crate;
			clearWeaponCargoGlobal _crate;
			clearItemCargoGlobal _crate;
			_crateArray pushBackUnique _crate;
		};
		_moneyArray = [];
		for [{_i = 0},{_i < _moneyBundles},{_i = _i + 1}] do
		{
			_money = createVehicle ["Land_Money_F",(ASLtoATL _missionPos),[],5,"CAN_COLLIDE"];
			_money setPos ([(ASLtoATL _missionPos),[[5 + random 5,0,0],random 360] call BIS_fnc_rotateVector2D] call BIS_fnc_vectorAdd);
			_money setDir random 360;
			_money allowDamage false;
			_money setVariable ["owner","mission",true];
			_moneyArray pushBackUnique _money;
		};
		_aiGroup = createGroup CIVILIAN;
		_groupAmount = (round(random 6) + 6); // min 6, max 12
		_divers = [_aiGroup,_missionPos,_groupAmount,_radius] call createDivingGroup;
		_leader = leader _aiGroup;
		_leader setRank "LIEUTENANT";
		_aiGroup setCombatMode "RED"; // units will defend themselves
		_aiGroup setBehaviour "AWARE"; // units feel safe until they spot an enemy or get into contact
		_aiGroup setFormation "STAG COLUMN";
		_aiGroup setSpeedMode _speedMode;
		for [{_i = 0},{_i < _patrolBoatAmount},{_i = _i + 1}] do
		{
			_patrolBoat = createVehicle [(selectRandom _patrolBoatClassArray),((ASLtoATL _missionPos) vectorAdd ([[(random _radius) + 25, 0, 0], random 360] call BIS_fnc_rotateVector2D)),[],0,"CAN_COLLIDE"];
			[_patrolBoat] call vehicleSetup;
			createVehicleCrew _patrolBoat;
			{
				[_x] joinSilent _aiGroup;
				[_x] call randomSoldierLoadout;
				_x spawn refillPrimaryAmmo;
				_x call setMissionSkill;
				_x addRating 9999999;
				_x addEventHandler ["Killed", server_playerDied];
				} forEach (crew _patrolBoat);
				_aiGroup addVehicle _patrolBoat;
				[_patrolBoat, _aiGroup] spawn checkMissionVehicleLock;
				_patrolBoat setFuel ((random 0.2) + 0.5);
			};
			_wp1 = _aiGroup addWaypoint [([_missionPos,60,0] call BIS_fnc_relPos),0];
			_wp1 setWaypointType "MOVE";
			[_aiGroup, 1] setWaypointBehaviour "SAFE";
			[_aiGroup, 1] setWaypointCombatMode "RED";
			[_aiGroup, 1] setWaypointCompletionRadius 30;
			[_aiGroup, 1] setWaypointStatements ["true", "(group this) setCurrentWaypoint [group this, 2]"];
			_wp2 = _aiGroup addWaypoint [([_missionPos,60,120] call BIS_fnc_relPos),0];
			_wp2 setWaypointType "MOVE";
			[_aiGroup, 2] setWaypointBehaviour "SAFE";
			[_aiGroup, 2] setWaypointCombatMode "RED";
			[_aiGroup, 2] setWaypointCompletionRadius 30;
			[_aiGroup, 2] setWaypointStatements ["true", "(group this) setCurrentWaypoint [group this, 3]"];
			_wp3 = _aiGroup addWaypoint [([_missionPos,60,240] call BIS_fnc_relPos),0];
			_wp3 setWaypointType "MOVE";
			[_aiGroup, 3] setWaypointBehaviour "SAFE";
			[_aiGroup, 3] setWaypointCombatMode "RED";
			[_aiGroup, 3] setWaypointCompletionRadius 30;
			[_aiGroup, 3] setWaypointStatements ["true", "(group this) setCurrentWaypoint [group this, 1]"];
			_missionHintText = format ["Armed enemy are trying to retrieve<t size='1.25' color='%1'>Weapon Crates</t><br/> and <br/><t size='1.25' color='%1'>%2</t><br/> worth of money from a <br/><t size='1.25' color='%1'>Ship Wreck</t><br/><br/>Go fight over who gets it!",moneyMissionColor,_moneyText];
		};

		_waitUntilMarkerPos = nil;
		_waitUntilExec = nil;
		_waitUntilCondition = nil;
		_failedExec =
		{
			{
				_crate = _x;
				deleteVehicle _crate;
				} forEach _crateArray;
				{
					_money = _x;
					deleteVehicle _money;
					} forEach _moneyArray;
				};
				_successExec =
				{
					{
						_crate = _x;
						_crate call randomCrateLoadOut;
						_crate setVariable ["R3F_LOG_disabled",false,true];
						_crate setVariable ["A3W_storeSellBox",false,true];
						_crate allowDamage true;
						} forEach _crateArray;
						{
							_money = _x;
							_money setVariable ["cmoney",round(_moneyAmount / _moneyBundles),true];
							_money setVariable ["owner","world",true];
							_money allowDamage true;
							_money call A3W_fnc_setItemCleanup;
							} forEach _moneyArray;
							_successHintMessage = "Well done, you defeated the enemy at the ship wreck.<br/>Go retrieve it all from the bottom of the ocean, good luck!";
						};

						_this call sideMissionProcessor;
