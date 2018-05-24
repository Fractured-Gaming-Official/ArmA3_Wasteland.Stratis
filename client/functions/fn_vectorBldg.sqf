params["_objGrabbed"];

if ( isNil { _objGrabbed } ) exitWith {};
if !( _objGrabbed isEqualTo R3F_LOG_playerMovesObject ) exitWith {};

R3F_objectAttachedTo = player;
closeDialog 0;

objReset = {
	bldPosX = 0;
	bldPosY = 5;
	bldPosZ = 2;
	bldYawVector = 0;
	bldPitchVector = 0;
	bldRollVector = 0;
};

keyDownEHId = (findDisplay 46) displayAddEventHandler ["KeyDown", {
	params ["_dikCode", "_ctrl", "_shift"];
	_dikCode = _this select 1;
    	_shift =_this select 2;
    	_ctrl = _this select 3;
	private _handled = false;

		switch ( _dikCode ) do {
			//Add (+) & Page UP Ascend (+Z)
			case 78;
			case 201: {
				_increment = 1;
				if ( _shift ) then { _increment = 2; };
				if ( _ctrl ) then { _increment = 0.1; };

				bldPosZ = (((bldPosZ + _increment) min 12) max 0);
				[R3F_LOG_playerMovesObject, false] call fn_vectorDirAndUp;

				_handled = true;
			};
			//Subtract (-) & Page DOWN Descend (-Z)
			case 74;
			case 209: {
				_increment = 1;
				if ( _shift ) then { _increment = 2; };
				if ( _ctrl ) then { _increment = 0.1; };

				bldPosZ = (((bldPosZ - _increment) min 12) max 0);
				[R3F_LOG_playerMovesObject, false] call fn_vectorDirAndUp;

				_handled = true;
			};
			//Num8 Move forward (+Y)
			case 72: {
				_increment = 1;
				if ( _shift ) then { _increment = 2; };
				if ( _ctrl ) then { _increment = 0.1; };

				bldPosY = (((bldPosY + _increment) min 12) max 1);
				[R3F_LOG_playerMovesObject, false] call fn_vectorDirAndUp;

				_handled = true;
			};
			//Num2 Move backwards (-Y)
			case 80: {
				_increment = 1;
				if ( _shift ) then { _increment = 2; };
				if ( _ctrl ) then { _increment = 0.1; };

				bldPosY = (((bldPosY - _increment) min 12) max 1);
				[R3F_LOG_playerMovesObject, false] call fn_vectorDirAndUp;

				_handled = true;
			};
			//Num4 Move left (-X)
			case 75: {
				_increment = 1;
				if ( _shift ) then { _increment = 2; };
				if ( _ctrl ) then { _increment = 0.1; };

				bldPosX = (((bldPosX - _increment) min 7) max -7);
				[R3F_LOG_playerMovesObject, false] call fn_vectorDirAndUp;

				_handled = true;
			};
			//Num6 Move right (+X)
			case 77: {
				_increment = 1;
				if ( _shift ) then { _increment = 2; };
				if ( _ctrl ) then { _increment = 0.1; };

				bldPosX = (((bldPosX + _increment) min 7) max -7);
				[R3F_LOG_playerMovesObject, false] call fn_vectorDirAndUp;

				_handled = true;
			};
			//keypad DOWN Rotate down (+PITCH)
			case 208: {
				_increment = 1;
				if ( _shift ) then { _increment = 2; };
				if ( _ctrl ) then { _increment = 0.1; };

				bldPitchVector = (((bldPitchVector + _increment) min 360) max -360);
				[R3F_LOG_playerMovesObject, false] call fn_vectorDirAndUp;

				_handled = true;
			};
			//Keypad UP Rotate up (-PITCH)
			case 200: {
				_increment = 1;
				if ( _shift ) then { _increment = 2; };
				if ( _ctrl ) then { _increment = 0.1; };

				bldPitchVector = (((bldPitchVector - _increment) min 360) max -360);
				[R3F_LOG_playerMovesObject, false] call fn_vectorDirAndUp;

				_handled = true;
			};
			//Num7 Rotate left (-YAW)
			case 71: {
				_increment = 1;
				if ( _shift ) then { _increment = 5; };
				if ( _ctrl ) then { _increment = 0.5; };

				bldYawVector = ((( bldYawVector - _increment ) min 360) max -360);
				[R3F_LOG_playerMovesObject, false] call fn_vectorDirAndUp;

				_handled = true;
			};
			//Num9 Rotate right (+YAW)
			case 73: {
				_increment = 1;
				if ( _shift ) then { _increment = 5; };
				if ( _ctrl ) then { _increment = 0.5; };

				bldYawVector = ((( bldYawVector + _increment ) min 360) max -360);
				[R3F_LOG_playerMovesObject, false] call fn_vectorDirAndUp;

				_handled = true;
			};
			//Keypad Left Roll left (-ROLL)
			case 203: {
				_increment = 1;
				if ( _shift ) then { _increment = 2; };
				if ( _ctrl ) then { _increment = 0.1; };

				bldRollVector = (((bldRollVector - _increment) min 360) max -360);
				[R3F_LOG_playerMovesObject, false] call fn_vectorDirAndUp;

				_handled = true;
			};
			//Keypad Right Roll right (+ROLL)
			case 205: {
				_increment = 1;
				if ( _shift ) then { _increment = 2; };
				if ( _ctrl ) then { _increment = 0.1; };

				bldRollVector = (((bldRollVector + _increment) min 360) max -360);
				[R3F_LOG_playerMovesObject, false] call fn_vectorDirAndUp;

				_handled = true;
			};
		};
	_handled;
}];

keyUpEHId = (findDisplay 46) displayAddEventHandler ["KeyUp", {
	params ["_dikCode", "_ctrl", "_shift"];
	_dikCode = _this select 1;
    	_shift =_this select 2;
    	_ctrl = _this select 3;
	private _handled = false;

		switch (_dikCode) do {
			//Add (+) Ascend (+Z)
			case 78;
			//Page UP Ascend (+Z)
			case 201;
			//Subtract (-) Descend (-Z)
			case 74;
			//Page DOWN Descend (-Z)
			case 209;
			//Num8 Move forward (+Y)
			case 72;
			//Num2 Move backwards (-Y)
			case 80;
			//Num4 Move left (-X)
			case 75;
			//Num6 Move right (+X)
			case 77;
			//keypad DOWN Rotate down (+PITCH)
			case 208;
			//Keypad UP Rotate up (-PITCH)
			case 200;
			//Num7 Rotate left (-YAW)
			case 71;
			//Num9 Rotate right (+YAW)
			case 73;
			//Keypad Left Roll left (-ROLL)
			case 203;
			//Keypad Right Roll right (+ROLL)
			case 205: {
				[R3F_LOG_playerMovesObject, true] call fn_vectorDirAndUp;
				_handled = true;
			};
			//Del Reset
			case 211;
			//BackSpace Reset
			case 14: {
				[] call objReset;
				[R3F_LOG_playerMovesObject, true] call fn_vectorDirAndUp;
				_handled = true;
			};
			//Num 5 Snap
			/*
			case 76: {
				if ( (typeOf cursorObject) in R3F_LOG_CFG_movableObjects ) then
				{
					if ( R3F_objectAttachedTo isEqualTo player ) then
					{
						[]spawn
						{
							_offsetDir = "";

							disableSerialization;
							_result = ["Snap to this object?", "", "Snap", "Cancel"] call BIS_fnc_guiMessage;
							waitUntil {sleep 0.5; !isNil "_result"};

							if ( _result ) then
							{
								_bbr = boundingBoxReal cursorObject;
								_offsetX = ((abs ((_bbr select 1 select 0) - (_bbr select 0 select 0))) / 2);
								_offsetY = ((abs ((_bbr select 1 select 1) - (_bbr select 0 select 1))) / 2);
								_offsetZ = ((abs ((_bbr select 1 select 2) - (_bbr select 0 select 2))) / 2);

								switch (_offsetDir) do {
									case "X": {
										bldPosX = _offsetX;
										bldPosY = 0;
										bldPosZ = 0;
									};
									case "-X": {
										bldPosX = -(_offsetX);
										bldPosY = 0;
										bldPosZ = 0;
									};
									case "Y": {
										bldPosX = 0;
										bldPosY = _offsetY;
										bldPosZ = 0;
									};
									case "-Y": {
										bldPosX = 0;
										bldPosY = -(_offsetY);
										bldPosZ = 0;
									};
									case "Z": {
										bldPosX = 0;
										bldPosY = 0;
										bldPosZ = _offsetZ;
									};
								};
								bldYawVector = 0;
								bldPitchVector = 0;
								bldRollVector = 0;

								R3F_objectAttachedTo = cursorObject;
								[R3F_LOG_playerMovesObject, true] call fn_vectorDirAndUp;
							};
						};
					} else {
						R3F_objectAttachedTo = player;
						[] call objReset;
						[R3F_LOG_playerMovesObject, true] call fn_vectorDirAndUp;
					};
				} else {
					["You can only snap to movable objects!", 5] call mf_notify_client;
				};
				_handled = true;
			};
			*/
			//Num 0 Release
			case 82: {
				["", "", "", false] execVM "addons\R3F_ARTY_AND_LOG\R3F_LOG\movableObject\release.sqf";

				[] call objReset;
				R3F_objectAttachedTo = objNull;
				(findDisplay 46) displayRemoveEventHandler ["KeyDown", keyDownEHId];
				(findDisplay 46) displayRemoveEventHandler ["KeyUp", keyUpEHId];
				_handled = true;
			};
		};
	_handled;
}];
