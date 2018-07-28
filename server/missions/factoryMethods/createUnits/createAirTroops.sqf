// ******************************************************************************************
// * This project is licensed under the GNU Affero GPL v3. Copyright © 2018 A3Wasteland.com *
// ******************************************************************************************
//	@file Name: airTroopGroup.sqf
//	@file Author: [FRAC] Mokey , soulkobk
//	@file Updated: 1:23 PM 22/05/2018 rewritten by soulkobk

if (!isServer) exitWith {};

private ["_unitClasses","_unitGroup","_missionPosition","_unit","_unitAmount"];

_unitClasses =
[
	"C_man_polo_1_F",
	"C_man_polo_2_F",
	"C_man_polo_3_F",
	"C_man_polo_4_F",
	"C_man_polo_5_F",
	"C_man_polo_6_F"
];

_unitGroup = _this select 0;
_missionPosition = _this select 1;
_unitAmount = param [2, 12, [0]];
_missionRadius = param [3, 100, [0]];
_missionPosition set [2,2000]; // update mission altitude to 2000m.

for "_i" from 1 to _unitAmount do
{
	_unitPosition = [0,0,0];
	_overland = false;
	while {!_overLand} do // force a land position, don't spawn over water.
	{
		_unitPosition = _missionPosition vectorAdd ([[(random _missionRadius) + 10, 0, 0], random 360] call BIS_fnc_rotateVector2D);
		if !(surfaceIsWater _unitPosition) then
		{
			_overLand = true;
		};
	};
	if !(_unitPosition isEqualTo [0,0,0]) then
	{
		// create the unit
		_unit = _unitGroup createUnit [(selectRandom _unitClasses),_unitPosition,[],0,"FORM"];
		waitUntil {alive _unit};
		_unit setPos _unitPosition;
		[_unit,_unitGroup,_missionPosition] spawn // units will spawn high, free fall to a random height, then pull chute (min 100m).
		{
			params ["_unit","_unitGroup","_missionPosition"];
			_missionSpawnHeight = _missionPosition select 2;
			_pullChuteAltitude = round(random 500) max 100 min 400; // 100m minimum height, 400 maximum height.
			_timer = time + 90; // max 1m30s free fall.
			waitUntil {sleep 0.1; (((getPos _unit select 2) <= _pullChuteAltitude) || (time > _timer))};
			_parachute = createVehicle ["Steerable_Parachute_F",(getPos _unit),[],0,"CAN_COLLIDE"];
			_parachute allowDamage false;
			//_smoke = createVehicle ["SmokeShellRed_infinite",(getPos _unit),[],0,"CAN_COLLIDE"]; //disabled smoke due to server FPS impact
			//_smoke attachTo [_parachute,[0,0,0]]; //disabled smoke due to server FPS impact
			_unit assignAsDriver _parachute;
			_unit moveInDriver _parachute;
			_timer = time + 180; // max 3m00s until on ground.
			waitUntil {sleep 0.1; ((isTouchingGround _unit) || (time > _timer))};
			//deleteVehicle _smoke; //disabled smoke due to server FPS impact
			_leader = leader _unitGroup;
			if (_unit isEqualTo _leader) then
			{
				_missionPosition set [2,0];
				_unit move _missionPosition;
				_unit doMove _missionPosition;
			}
			else
			{
				_unit doFollow leader _unitGroup;
			};
		};
		// update the solider
		[_unit] call randomSoldierLoadout;
		_unit spawn refillPrimaryAmmo;
		_unit call setMissionSkill;
		_unit addEventHandler ["Killed", server_playerDied];
	};
	sleep 0.5;
};

_soldiers = units _unitGroup;
_soldiers
