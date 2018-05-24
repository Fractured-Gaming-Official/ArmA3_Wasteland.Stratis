/**
 * Fait déplacer un objet par le joueur. Il garde l'objet tant qu'il ne le relâche pas ou ne meurt pas.
 * L'objet est relaché quand la variable R3F_LOG_playerMovesObject passe à objNull ce qui terminera le script
 *
 * @param 0 l'objet à déplacer
 *
 * Copyright (C) 2010 madbull ~R3F~
 *
 * This program is free software under the terms of the GNU General Public License version 3.
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

_currentAnim =	animationState player;
_config = configFile >> "CfgMovesMaleSdr" >> "States" >> _currentAnim;
_onLadder =	(getNumber (_config >> "onLadder"));
if(_onLadder == 1) exitWith{player globalChat "You can't move this object while on a ladder";};

if (R3F_LOG_mutexLocalLock) exitWith
{
	player globalChat STR_R3F_LOG_mutexActionOngoing;
};

private _object = _this select 0;

if (unitIsUAV _object && {!(_object getVariable ["ownerUID","0"] isEqualTo getPlayerUID player) && !(group (uavControl _object select 0) in [grpNull, group player])}) then
{
	player globalChat STR_R3F_LOG_actionMoveObjectUAVGrp;
}
else
{
	R3F_LOG_mutexLocalLock = true;

	R3F_LOG_selectedObject = objNull;

	private ["_isSwimming", "_isCalculator", "_mainWeapon", "_mainWeaponAccessories", "_mainWeaponMagazines", "_actionMenuReleaseRelative", "_actionMenuReleaseHorizontal" , "_actionMenuRelease45", "_actionMenuRelease90", "_actionMenuRelease180", "_cannonAzimuth", "_muzzles", "_magazine", "_ammo", "_adjustPOS"];

	_object = _this select 0;
	if(isNil {_object getVariable "R3F_Side"}) then {
		_object setVariable ["R3F_Side", (playerSide), true];
	};

	_isSwimming = { [["Aswm","Assw","Absw","Adve","Asdv","Abdv"], animationState _this] call fn_startsWith };

	_tempVar = false;
	if(!isNil {_object getVariable "R3F_Side"}) then {
		if(playerSide != (_object getVariable "R3F_Side")) then {
			{if(side _x ==  (_object getVariable "R3F_Side") && alive _x && _x distance _object < 150) exitwith {_tempVar = true;};} foreach AllUnits;
		};
	};
	if(_tempVar) exitwith {
		hint format["This object belongs to %1 and they're nearby you cannot take this.", _object getVariable "R3F_Side"]; R3F_LOG_mutexLocalLock = false;
	};
	_object setVariable ["R3F_Side", (playerSide), true];

	// Si l'objet est un calculateur d'artillerie, on laisse le script spécialisé gérer
	_isCalculator = _object getVariable "R3F_ARTY_isCalculator";
	if !(isNil "_isCalculator") then
	{
		R3F_LOG_mutexLocalLock = false;
		[_object] execVM "addons\R3F_ARTY_AND_LOG\R3F_ARTY\poste_commandement\deplacer_calculateur.sqf";
	}
	else
	{
		_object setVariable ["R3F_LOG_isMovedBy", player, true];

		R3F_LOG_playerMovesObject = _object;

		// Sauvegarde et retrait de l'arme primaire
		/*_mainWeapon = primaryWeapon player;
		_mainWeaponAccessories = [];
		_mainWeaponMagazines = [];*/

		_mainWeapon = currentMuzzle player;

		player forceWalk true;
		player action ["SwitchWeapon", player, player, 100];

		sleep 0.5;

		// Si le joueur est mort pendant le sleep, on remet tout comme avant
		if (!alive player) then
		{
			R3F_LOG_playerMovesObject = objNull;
			_object setVariable ["R3F_LOG_isMovedBy", objNull, true];
			// Car attachTo de "charger" positionne l'objet en altitude :
			_object setPos [getPos _object select 0, getPos _object select 1, 0];
			_object setVelocity [0,0,0];

			R3F_LOG_mutexLocalLock = false;
		}
		else
		{
			_objectBB = _object call fn_boundingBoxReal;
			_objectMinBB = _objectBB select 0;
			_objectMaxBB = _objectBB select 1;

			_corner1 = [_objectMinBB select 0, _objectMinBB select 1, 0] vectorDistance [0,0,0];
			_corner2 = [_objectMinBB select 0, _objectMaxBB select 1, 0] vectorDistance [0,0,0];
			_corner3 = [_objectMaxBB select 0, _objectMinBB select 1, 0] vectorDistance [0,0,0];
			_corner4 = [_objectMaxBB select 0, _objectMaxBB select 1, 0] vectorDistance [0,0,0];

			bldPosX = 0;
		  	bldPosY = 1 + (_corner1 max _corner2 max _corner3 max _corner4);
		  	bldPosZ = 0.1 - (_objectMinBB select 2);
			bldYawVector = 0;
			bldPitchVector = 0;
			bldRollVector = 0;

		  	_object attachTo [player, [bldPosX, bldPosY, bldPosZ]];
		  	[_object] call fn_vectorBldg;

			/*if (count (weapons _object) > 0) then
			{
				// Le canon doit pointer devant nous (sinon on a l'impression de se faire empaler)
				_cannonAzimuth = ((_object weaponDirection (weapons _object select 0)) select 0) atan2 ((_object weaponDirection (weapons _object select 0)) select 1);

				// On est obligé de demander au serveur de tourner le canon pour nous
				R3F_LOG_FRAC_PUBVAR_setDir = [_object, (getDir _object)-_cannonAzimuth];
				if (isServer) then
				{
					["R3F_LOG_FRAC_PUBVAR_setDir", R3F_LOG_FRAC_PUBVAR_setDir] spawn R3F_LOG_FRAC_FNC__PUBVAR_setDir;
				}
				else
				{
					publicVariable "R3F_LOG_FRAC_PUBVAR_setDir";
				};
			};*/

			R3F_LOG_mutexLocalLock = false;
			R3F_LOG_forceHorizontally = false;

			_actionMenuReleaseRelative = player addAction [("<img image='client\icons\r3f_release.paa' color='#06ef00'/> <t color='#06ef00'>" + STR_R3F_LOG_actionReleaseObject + "</t>"), "addons\R3F_ARTY_AND_LOG\R3F_LOG\movableObject\release.sqf", false, 5, true, true];
			_actionMenuReleaseHorizontal = player addAction [("<img image='client\icons\r3f_releaseh.paa' color='#06ef00'/> <t color='#06ef00'>" + STR_RELEASE_HORIZONTAL + "</t>"), "addons\R3F_ARTY_AND_LOG\R3F_LOG\movableObject\release.sqf", true, 5, true, true];
			_actionMenuRelease45 = player addAction [("<img image='client\icons\r3f_rotate.paa' color='#06ef00'/> <t color='#06ef00'>Rotate object 45°</t>"), "addons\R3F_ARTY_AND_LOG\R3F_LOG\movableObject\rotate.sqf", 45, 5, true, false];
			//_actionMenuRelease90 = player addAction [("<img image='client\ui\ui_arrow_combo_ca.paa'/> <t color='#dddd00'>Rotate object 90°</t>"), "addons\R3F_ARTY_AND_LOG\R3F_LOG\movableObject\rotate.sqf", 90, 5, true, false];
			//_actionMenuRelease180 = player addAction [("<img image='client\ui\ui_arrow_combo_ca.paa'/> <t color='#dddd00'>Rotate object 180°</t>"), "addons\R3F_ARTY_AND_LOG\R3F_LOG\movableObject\rotate.sqf", 180, 5, true, false];

			// On limite la vitesse de marche et on interdit de monter dans un véhicule tant que l'objet est porté
			while {attachedTo R3F_LOG_playerMovesObject == player && alive player} do
			{
				if (vehicle player != player) then
				{
					player globalChat STR_R3F_LOG_cantEnterVehicleCarryingObj;
					player action ["eject", vehicle player];
					moveOut player;
					sleep 1;
				}
				else
				{
					if (currentWeapon player != "" && {!(player call _isSwimming)}) then
					{
						player action ["SwitchWeapon", player, player, 100];
					};
				};

				if ([(velocity player) select 0,(velocity player) select 1,0] call BIS_fnc_magnitude > 3.5) then
				{
					player globalChat STR_R3F_LOG_movingTooFast;
					player playMove "AmovPpneMstpSnonWnonDnon";
					sleep 1;
				};

				sleep 0.25;
			};

			_object enableSimulation false;
			bldPosX = 0;
			bldPosY = 5;
			bldPosZ = 2;
			bldYawVector = 0;
			bldPitchVector = 0;
			bldRollVector = 0;
			R3F_objectAttachedTo = objNull;
			(findDisplay 46) displayRemoveEventHandler ["KeyDown", keyDownEHId];
			(findDisplay 46) displayRemoveEventHandler ["KeyUp", keyUpEHId];
			// L'objet n'est plus porté, on le repose
				detach _object;

			// this addition comes from Sa-Matra (fixes the heigt of some of the objects) - all credits for this fix go to him!

			_class = typeOf _object;

			_zOffset = switch (true) do
			{
				//case (_class == "Land_Scaffolding_F"):         { 3 };
				case (_class == "Land_Canal_WallSmall_10m_F"): { 2 };
				case (_class == "Land_Canal_Wall_Stairs_F"):   { 2 };
				case (_class == "Land_PierLadder_F"):          { 2 };
				default { 0 };
			};

			if (R3F_LOG_forceHorizontally) then
			{
				R3F_LOG_forceHorizontally = false;

				_objectATL = getPosATL _object;

				if ((_objectATL select 2) - _zOffset < 0) then
				{
					_objectATL set [2, 0 + _zOffset];
					_object setPosATL _objectATL;
				} else {
					_objectASL = getPosASL _object;
					_objectASL set [2, ((getPosASL player) select 2) + _zOffset];
					_object setPosASL _objectASL;
				};

				_object setVectorUp [0,0,1];
			}
			else
			{
				_objectPos = _object call fn_getPos3D;
				_dirAndUp = [
				[ sin bldYawVector * cos bldPitchVector, cos bldYawVector * cos bldPitchVector, sin bldPitchVector],
				[[ sin bldRollVector, -sin bldPitchVector, cos bldRollVector * cos bldPitchVector], -bldYawVector]
				call BIS_fnc_rotateVector2D];
				R3F_LOG_playerMovesObject setVectorDirAndUp _dirAndUp;
			};

			_object setVelocity [0,0,0];

			player removeAction _actionMenuReleaseRelative;
			player removeAction _actionMenuReleaseHorizontal;
			player removeAction _actionMenuRelease45;
			//player removeAction _actionMenuRelease90;
			//player removeAction _actionMenuRelease180;
			R3F_LOG_playerMovesObject = objNull;
			R3F_objectAttachedTo = objNull;

			bldPosX = 0;
			bldPosY = 5;
			bldPosZ = 0;
			bldYawVector = 0;
			bldPitchVector = 0;
			bldRollVector = 0;

			_object setVariable ["R3F_LOG_isMovedBy", objNull, true];

			if (_object getVariable ["R3F_LOG_isMovedBy", objNull] == player) then
			{
				_object setVariable ["R3F_LOG_isMovedBy", objNull, true];
			};

			player forceWalk false;
			player selectWeapon _mainWeapon;

			// Restauration de l'arme primaire
			/*if (alive player && _mainWeapon != "") then
			{
				if(primaryWeapon player != "") then {
					_o = createVehicle ["WeaponHolder", player modelToWorld [0,0,0], [], 0, "NONE"];
					_o addWeaponCargoGlobal [_mainWeapon, 1];
				}
				else {
					{
						_magazine = _x select 0;
						_ammo = _x select 1;

						if(_magazine != "" && _ammo > 0) then {
							player addMagazine _x;
						};
					} forEach _mainWeaponMagazines; // add all default primery weapon magazines

					player addWeapon _mainWeapon;

					{ if(_x!="") then { player addPrimaryWeaponItem _x; }; } foreach (_mainWeaponAccessories);

					player selectWeapon _mainWeapon;
					//player selectWeapon (getArray (configFile >> "cfgWeapons" >> _mainWeapon >> "muzzles") select 0);
				};
			};*/
		};
	};
};
