//GOM_CB V1.1 by Grumpy Old Man
//
//Changelog V1.1
//-MP and dedicated Server compatible
//added air raid sirens to various vanilla buildings (fully autonomous) and bomb falling sounds

//first parameter gives the bomb type, empty string will make the script use a random bomb, mod bombs will also be used
//second parameter holds the position that should be bombed
//third parameter holds the direction
//fourth parameter defines the amount of bombs to be dropped
//fifth parameter defines the average distance for the bombs to spread

//example:
// _bomb = ["",screenToWorld [0.5,0.5],270,20,100] spawn GOM_fnc_carpetbombing;
//this will drop a carpet of 20 bombs of a random type, beginning at the screen center position, moving ~100m from east to west

//value limits are 48 bombs, 250 meters to prevent the script from bombing the entire map


GOM_fnc_airRaidSirens = {

    params ["_bomblocation"];

    _airraidsirens = nearestobjects [_bomblocation,["Land_BellTower_01_V1_F","Land_BellTower_01_V2_F","Land_BellTower_02_V1_F","Land_BellTower_02_V2_F","Land_Cargo_HQ_V1_F","Land_Cargo_HQ_V2_F","Land_Cargo_HQ_V3_F","Land_Chapel_Small_V1_F","Land_Chapel_Small_V2_F","Land_Chapel_V1_F","Land_Chapel_V2_F","Land_Church_01_V1_F","Land_Loudspeakers_F"],1500];

    for "_i" from 0 to 4 do {

        {[_x,["air_raid",500,1]] remoteExec ["say3D",[0,-2] select isDedicated]} foreach _airraidsirens;
        sleep 8.6;

    };

};

GOM_fnc_carpetBombing = {
	params [["_bombType",""],["_bomblocation",[0,0,0]],["_direction",random 360],["_amount",20],["_distance",50]];

	if (_bomblocation isEqualTo [0,0,0]) exitWith {systemchat "GOM_carpetbombing: Error, no bomb location given!"};


	if (_bombType isEqualTo "") then {_bombType = selectRandom ["Bo_GBU12_LGB","Bo_Mk82_MI08","Bomb_03_F","Bomb_04_F"]};

	if (!isClass (configFile >> "CfgAmmo" >> _bombType)) exitWith {systemchat "GOM_carpetbombing: Error, bombtype is not a valid class!"};
	//if !(missionNamespace getVariable ["GOM_fnc_carpetBombingAvailable",true]) exitWith {systemchat "GOM_carpetbombing: Already running!"};
	missionNamespace setVariable ["GOM_fnc_carpetBombingAvailable",false,true];

	_amount = _amount min 48;
	_distance = _distance min 250;
	_debug = false;

	_firstImpactPos = (_bomblocation getPos [(_distance / 2),_direction + 180]) vectorAdd [0,0,200];
	_posincrement = _distance / _amount;

	_sirens = [_firstImpactPos] spawn GOM_fnc_airRaidSirens;

	sleep random [5,10,15];
	_randomsound = selectRandom ["BattlefieldJet1_3D","BattlefieldJet2_3D","BattlefieldJet3_3D"];
	_closePlayers = allPlayers select {_x distance2D _firstImpactPos < 1500};
	[_randomsound] remoteExec ["playSound",_closePlayers];

	sleep 20;

	_relpos = _firstImpactPos;
	_bomb = objNull;
	for "_i" from 1 to _amount do {

		sleep 0.1;
		_tempPos = _relpos vectorAdd [random [-20,0,20],random [-20,0,20],random [-5,0,5]];


		_bomb = _bombType createvehicle _tempPos;
		_bomb setposasl _tempPos;
		_relpos = _firstImpactPos getPos [(_posincrement * _i),_direction] vectorAdd [0,0,200];

		if (_debug) then {

			_helper = "Sign_Arrow_Large_F" createvehicle [getposATL _bomb select 0, getposATL _bomb select 1,0];

		};

		_bomb setVectorDirAndUp [[0,0,-1],[0,0.8,0]];
		_bomb setVelocityModelSpace [0,50,-50];
		_bomb setFeatureType 2;

		_nul = [_bomb] spawn {

			params ["_bomb"];
			waituntil {getposATL _bomb select 2 <= 700};
			_soundarray = ["Shell1","Shell2","Shell3","Shell4"];
			_soundpos = [getposATL _bomb select 0, getposATL _bomb select 1,0];
			_helper = "Land_Battery_F" createvehicle _soundpos;
			_helper hideobjectGlobal true;
			_rndSound = selectRandom _soundarray;

			[_helper,[_rndSound,1,200]] remoteExec ["say3D",[0,-2] select isDedicated];
			waituntil {!alive _bomb};
			deletevehicle _helper;

		};

	};


	sleep 30;
	missionNamespace setVariable ["GOM_fnc_carpetBombingAvailable",true,true];
true
};
