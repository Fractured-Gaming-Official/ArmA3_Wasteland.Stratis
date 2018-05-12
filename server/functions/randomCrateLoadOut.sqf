/*
	----------------------------------------------------------------------------------------------

	Copyright © 2018 soulkobk (soulkobk.blogspot.com)

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU Affero General Public License as
	published by the Free Software Foundation, either version 3 of the
	License, or (at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
	GNU Affero General Public License for more details.

	You should have received a copy of the GNU Affero General Public License
	along with this program. If not, see <http://www.gnu.org/licenses/>.

	----------------------------------------------------------------------------------------------

	Name: randomCrateLoadOut.sqf
	Version: 1.0.A3WL
	Author: soulkobk (soulkobk.blogspot.com)
	Creation Date: 3:10 PM 11/05/2018
	Modification Date: 3:10 PM 11/05/2018

	Description:
	For use with A3Wasteland 1.3x mission (A3Wasteland.com). This script is a replacement mission
	crate load-out script that will randomly select and place items in to mission crates.

	Edit storeConfig.sqf and add line...
	RCLO_ARRAY = compileFinal str (call pistolArray + call smgArray + call rifleArray + call lmgArray + call launcherArray + call throwputArray + call ammoArray + call accessoriesArray + call headArray + call uniformArray + call vestArray + call backpackArray + call genItemArray);

	Before the line (last line)...
	storeConfigDone = compileFinal "true";

	Also edit each existing array in storeConfig.sqf to allow specific objects to be added to RCLO crates with any of the following strings...
	"RCLO_WEAPONPRIMARY"
	"RCLO_WEAPONSECONDARY"
	"RCLO_WEAPONLAUNCHER"
	"RCLO_WEAPONACCESSORY"
	"RCLO_BACKPACK"
	"RCLO_BINOCULAR"
	"RCLO_BIPOD"
	"RCLO_HEADGEAR"
	"RCLO_ITEM"
	"RCLO_MAGAZINE"
	"RCLO_THROWABLE"
	"RCLO_MUZZLE"
	"RCLO_OPTIC"
	"RCLO_UNIFORM"
	"RCLO_VEST"
	"RCLO_MINE"
	"RCLO_GOGGLE"

	!!! Be sure to place each item in the correct category, else the script will not function properly !!!
	Examples...
	["Combat Goggles (Green)", "G_Combat_Goggles_tna_F", 25, "gogg", "noDLC","RCLO_GOGGLE"], // will allow add as goggle to RCLO crate.
	["Laser Designator (Olive)", "Laserdesignator_03", 250, "binoc", "noDLC","RCLO_BINOCULAR"], // will allow add as binocular to RCLO crate.
	["Kitbag (Coyote)", "B_Kitbag_cbr", 350, "backpack","RCLO_BACKPACK"], // will allow add as goggle to backpack crate.
	["Carrier Rig (Black)", "V_PlateCarrier2_blk", -1, "vest","RCLO_VEST"], // will allow add as vest to RCLO crate.
	["Full Ghillie (Arid)", "U_O_FullGhillie_ard", 2000, "uni","RCLO_UNIFORM"], // will allow add as uniform to RCLO crate.

	Place this script in the mission file, in path \server\functions\randomCrateLoadOut.sqf
	and edit \server\functions\serverCompile.sqf and place...
	randomCrateLoadOut = [_path, "randomCrateLoadOut.sqf"] call mf_compile;
	underneath the line...
	_path = "server\functions";

	It will totally replace the A3Wasteland function 'fn_refillbox'. You will need to search and
	replace the text/function in all your mission scripts in order to get this script to function.
	See Example: below.

	The custom function will disable damage to the crate, lock the crate until mission is completed,
	and randomly fill the crate with loot.

	**This will also add artillery strikes to the crate randomly (see bottom of script, A3W_artilleryStrike).

	Parameter(s): <object> call randomCrateLoadOut;

	Example: (missions)
	_box1 = createVehicle ["Box_NATO_WpsSpecial_F", _missionPos, [], 5, "None"];
	_box1 setDir random 360;
	// [_box1, "mission_USSpecial"] call fn_refillbox; // <- this line is now null
	_box1 call randomCrateLoadOut; // new randomCrateLoadOut function call

	Example: (outposts)
	["Box_FIA_Wps_F",[-5,4.801,0],90,{_this call randomCrateLoadOut;}]

	Change Log:
	1.0.A3W - adapted script for use of storeConfig.sqf arrays of A3Wasteland (specific A3Wasteland edit).

	----------------------------------------------------------------------------------------------
*/

if !(isServer) exitWith {}; // DO NOT DELETE THIS LINE!


waitUntil {!(isNil "RCLO_ARRAY")};

// #define __DEBUG__

_backPacks = call RCLO_ARRAY select {"RCLO_BACKPACK" in (_x select [3,999])}; // compiles array from storeConfig.sqf (A3Wasteland).
_binoculars = call RCLO_ARRAY select {"RCLO_BINOCULAR" in (_x select [3,999])};
_bipods = call RCLO_ARRAY select {"RCLO_BIPOD" in (_x select [3,999])};
_headGear = call RCLO_ARRAY select {"RCLO_HEADGEAR" in (_x select [3,999])};
_items = call RCLO_ARRAY select {"RCLO_ITEM" in (_x select [3,999])};
_launcherWeapons = call RCLO_ARRAY select {"RCLO_WEAPONLAUNCHER" in (_x select [3,999])};
_magazines = call RCLO_ARRAY select {"RCLO_MAGAZINE" in (_x select [3,999])};
_throwables = call RCLO_ARRAY select {"RCLO_THROWABLE" in (_x select [3,999])};
_muzzles = call RCLO_ARRAY select {"RCLO_MUZZLE" in (_x select [3,999])};
_optics = call RCLO_ARRAY select {"RCLO_OPTIC" in (_x select [3,999])};
_primaryWeapons = call RCLO_ARRAY select {"RCLO_WEAPONPRIMARY" in (_x select [3,999])};
_secondaryWeapons = call RCLO_ARRAY select {"RCLO_WEAPONSECONDARY" in (_x select [3,999])};
_uniforms = call RCLO_ARRAY select {"RCLO_UNIFORM" in (_x select [3,999])};
_vests = call RCLO_ARRAY select {"RCLO_VEST" in (_x select [3,999])};
_weaponAccessories = call RCLO_ARRAY select {"RCLO_WEAPONACCESSORY" in (_x select [3,999])};
_mines = call RCLO_ARRAY select {"RCLO_MINE" in (_x select [3,999])};
_goggles = call RCLO_ARRAY select {"RCLO_GOGGLE" in (_x select [3,999])};

_overallLoopAmount = 0;
_fillTheCrate = selectRandom [true,false];
if (_fillTheCrate) then
{
	_overallLoopAmount = 999;
}
else
{
	_overallLoopAmount = floor (round (random 8) + 2); // minimum 2, maximum 10
};

_backPackAmount = floor (round (random 3) + 3); // minimum 3, maximum 6
_binocularAmount = floor (round (random 5) + 2); // minimum 3, maximum 7
_bipodAmount = floor (round (random 3) + 2); // minimum 2, maximum 5
_headGearAmount = floor (round (random 3) + 5); // minimum 5, maximum 8
_itemAmount = floor (round (random 3) + 5); // minimum 5, maximum 8
_launcherAmount = floor (round (random 3) + 2); // minimum 2, maximum 5
_magazineAmount = floor (round (random 5) + 5); // minimum 5, maximum 10
_throwableAmount = floor (round (random 3) + 3); // minimum 3, maximum 6
_muzzleAmount = floor (round (random 2) + 2); // minimum 2, maximum 4
_opticAmount = floor (round (random 4) + 5); // minimum 5, maximum 9
_primaryWeaponAmount = floor (round (random 5) + 5); // minimum 5, maximum 10
_secondaryWeaponAmount = floor (round (random 3) + 2); // minimum 2, maximum 5
_uniformAmount = floor (round (random 4) + 3); // minimum 3, maximum 7
_vestAmount = floor (round (random 4) + 3); // minimum 3, maximum 7
_weaponAccessoryAmount = floor (round (random 3) + 2); // minimum 2, maximum 5
_minesAmount = floor (round (random 2) + 2); // minimum 2, maximum 4
_goggleAmount = floor (round (random 2) + 2); // minimum 2, maximum 4

_loadCrateWithWhatArray =
[
	"_backPacks",
	"_binoculars",
	"_bipods",
	"_headGear",
	"_items",
	"_launcherWeapons",
	"_magazines",
	"_throwables",
	"_muzzles",
	"_optics",
	"_primaryWeapons",
	"_secondaryWeapons",
	"_uniforms",
	"_vests",
	"_weaponAccessories",
	"_mines",
	"_goggles"
];

/*	------------------------------------------------------------------------------------------
	DO NOT EDIT BELOW HERE!
	------------------------------------------------------------------------------------------	*/

params ["_crate"];

clearBackpackCargoGlobal _crate;
clearMagazineCargoGlobal _crate;
clearWeaponCargoGlobal _crate;
clearItemCargoGlobal _crate;

_loadCrateItem = "";
_loadCrateAmount = 0;
_loadCrateWithWhat = "";

#ifdef __DEBUG__
	diag_log "----------------------------------------------------";
#endif

_ableToAddToCrate = false;
_canAddToCrate = {
	params ["_crate","_item","_num"];
	_ableToAddToCrate = _crate canAdd [_item,_num];
	_ableToAddToCrate
};

for [{_i = 0},{_i < _overallLoopAmount},{_i = _i + 1}] do
{
	if !(alive _crate) exitWith {};

	_typeOfCrate = typeOf _crate;

	_hasBackpackContainer = getNumber (configfile >> "CfgVehicles" >> _typeOfCrate >> "transportMaxBackpacks");
	_hasMagazineContainer = getNumber (configfile >> "CfgVehicles" >> _typeOfCrate >> "transportMaxMagazines");
	_hasWeaponContainer = getNumber (configfile >> "CfgVehicles" >> _typeOfCrate >> "transportMaxWeapons");
	_hasContainer = (_hasBackpackContainer + _hasMagazineContainer + _hasMagazineContainer);
	if (_hasContainer isEqualTo 0) exitWith {};

	_loadCrateWithWhat = selectRandom _loadCrateWithWhatArray;

	#ifdef __DEBUG__
		diag_log format ["%1 -> %2",(_i + 1),_loadCrateWithWhat];
	#endif

	switch (_loadCrateWithWhat) do
	{
		case "_backPacks": {
			_loadCrateAmount = _backPackAmount;
			for [{_lootCount = 0 },{_lootCount < _loadCrateAmount},{_lootCount = _lootCount + 1}] do
			{
				_loadCrateItem = (selectRandom _backPacks) select 1;
				_addToCrate = [_crate,_loadCrateItem,1] call _canAddToCrate;
				if (_addToCrate) then
				{
					_crate addBackpackCargoGlobal [_loadCrateItem,1];
					#ifdef __DEBUG__
						diag_log format [" + %1 added -> 1x %2",_loadCrateWithWhat,_loadCrateItem];
					#endif
				};
			};
		};
		case "_binoculars": {
			_loadCrateAmount = _binocularAmount;
			for [{_lootCount = 0},{_lootCount < _loadCrateAmount},{_lootCount = _lootCount + 1}] do
			{
				_loadCrateItem = (selectRandom _binoculars) select 1;
				_addToCrate = [_crate,_loadCrateItem,1] call _canAddToCrate;
				if (_addToCrate) then
				{
					_crate addItemCargoGlobal [_loadCrateItem,1];
					#ifdef __DEBUG__
						diag_log format [" + %1 added -> 1x %2",_loadCrateWithWhat,_loadCrateItem];
					#endif
				};
			};
		};
		case "_bipods": {
			_loadCrateAmount = _bipodAmount;
			for [{_lootCount = 0},{_lootCount < _loadCrateAmount},{_lootCount = _lootCount + 1}] do
			{
				_loadCrateItem = (selectRandom _bipods) select 1;
				_addToCrate = [_crate,_loadCrateItem,1] call _canAddToCrate;
				if (_addToCrate) then
				{
					_crate addItemCargoGlobal [_loadCrateItem,1];
					#ifdef __DEBUG__
						diag_log format [" + %1 added -> 1x %2",_loadCrateWithWhat,_loadCrateItem];
					#endif
				};
			};
		};
		case "_headGear": {
			_loadCrateAmount = _headGearAmount;
			for [{_lootCount = 0},{_lootCount < _loadCrateAmount},{_lootCount = _lootCount + 1}] do
			{
				_loadCrateItem = (selectRandom _headGear) select 1;
				_addToCrate = [_crate,_loadCrateItem,1] call _canAddToCrate;
				if (_addToCrate) then
				{
					_crate addItemCargoGlobal [_loadCrateItem,1];
					#ifdef __DEBUG__
						diag_log format [" + %1 added -> 1x %2",_loadCrateWithWhat,_loadCrateItem];
					#endif
				};
			};
		};
		case "_items": {
			_loadCrateAmount = _itemAmount;
			for [{_lootCount = 0},{_lootCount < _loadCrateAmount},{_lootCount = _lootCount + 1}] do
			{
				_loadCrateItem = (selectRandom _items) select 1;
				_addToCrate = [_crate,_loadCrateItem,1] call _canAddToCrate;
				if (_addToCrate) then
				{
					_crate addItemCargoGlobal [_loadCrateItem,1];
					#ifdef __DEBUG__
						diag_log format [" + %1 added -> 1x %2",_loadCrateWithWhat,_loadCrateItem];
					#endif
				};
			};
		};
		case "_launcherWeapons": {
			_loadCrateAmount = _launcherAmount;
			for [{_lootCount = 0},{_lootCount < _loadCrateAmount},{_lootCount = _lootCount + 1}] do
			{
				_loadCrateItem = (selectRandom _launcherWeapons) select 1;
				_loadCrateLootMagazine = getArray (configFile / "CfgWeapons" / _loadCrateItem / "magazines");
				_loadCrateLootMagazineClass = selectRandom _loadCrateLootMagazine;
				_loadCrateLootMagazineNum = floor (round (random 4) + 2); // minimum 2, maximum 6
				_addToCrate = [_crate,_loadCrateItem,1] call _canAddToCrate;
				if (_addToCrate) then
				{
					_crate addWeaponCargoGlobal [_loadCrateItem,1];
					#ifdef __DEBUG__
						diag_log format [" + %1 added -> 1x %2",_loadCrateWithWhat,_loadCrateItem];
					#endif
				};
				_addToCrate = [_crate,_loadCrateLootMagazineClass,_loadCrateLootMagazineNum] call _canAddToCrate;
				if (_addToCrate) then
				{
					_crate addMagazineCargoGlobal [_loadCrateLootMagazineClass,_loadCrateLootMagazineNum];
					#ifdef __DEBUG__
						diag_log format [" + %1 added -> 1x %2 with %3x %4 rockets",_loadCrateWithWhat,_loadCrateItem,_loadCrateLootMagazineNum,_loadCrateLootMagazineClass];
					#endif
				};
			};
		};
		case "_magazines": {
			_loadCrateAmount = _magazineAmount;
			for [{_lootCount = 0},{_lootCount < _loadCrateAmount},{_lootCount = _lootCount + 1}] do
			{
				_loadCrateItem = (selectRandom _magazines) select 1;
				_loadCrateLootMagazineNum = floor (round (random 4) + 2); // minimum 2, maximum 6
				_addToCrate = [_crate,_loadCrateItem,_loadCrateLootMagazineNum] call _canAddToCrate;
				if (_addToCrate) then
				{
					_crate addMagazineCargoGlobal [_loadCrateItem,_loadCrateLootMagazineNum];
					#ifdef __DEBUG__
						diag_log format [" + %1 added -> %2x %3 magazines",_loadCrateWithWhat,_loadCrateLootMagazineNum,_loadCrateItem];
					#endif
				};
			};
		};
		case "_throwables": {
			_loadCrateAmount = _throwableAmount;
			for [{_lootCount = 0},{_lootCount < _loadCrateAmount},{_lootCount = _lootCount + 1}] do
			{
				_loadCrateItem = (selectRandom _throwables) select 1;
				_loadCrateLootMagazineNum = floor (round (random 8) + 2); // minimum 2, maximum 10
				_addToCrate = [_crate,_loadCrateItem,_loadCrateLootMagazineNum] call _canAddToCrate;
				if (_addToCrate) then
				{
					_crate addMagazineCargoGlobal [_loadCrateItem,_loadCrateLootMagazineNum];
					#ifdef __DEBUG__
						diag_log format [" + %1 added -> %2x %3",_loadCrateWithWhat,_loadCrateLootMagazineNum,_loadCrateItem];
					#endif
				};
			};
		};
		case "_muzzles": {
			_loadCrateAmount = _muzzleAmount;
			for [{_lootCount = 0},{_lootCount < _loadCrateAmount},{_lootCount = _lootCount + 1}] do
			{
				_loadCrateItem = (selectRandom _muzzles) select 1;
				_addToCrate = [_crate,_loadCrateItem,1] call _canAddToCrate;
				if (_addToCrate) then
				{
					_crate addItemCargoGlobal [_loadCrateItem, 1];
					#ifdef __DEBUG__
						diag_log format [" + %1 added -> 1x %2",_loadCrateWithWhat,_loadCrateItem];
					#endif
				};
			};
		};
		case "_optics": {
			_loadCrateAmount = _opticAmount;
			for [{_lootCount = 0},{_lootCount < _loadCrateAmount},{_lootCount = _lootCount + 1}] do
			{
				_loadCrateItem = (selectRandom _optics) select 1;
				_addToCrate = [_crate,_loadCrateItem,1] call _canAddToCrate;
				if (_addToCrate) then
				{
					_crate addItemCargoGlobal [_loadCrateItem, 1];
					#ifdef __DEBUG__
						diag_log format [" + %1 added -> 1x %2",_loadCrateWithWhat,_loadCrateItem];
					#endif
				};
			};
		};
		case "_primaryWeapons": {
			_loadCrateAmount = _primaryWeaponAmount;
			for [{_lootCount = 0},{_lootCount < _loadCrateAmount},{_lootCount = _lootCount + 1}] do
			{
				_loadCrateItem = (selectRandom _primaryWeapons) select 1;
				_loadCrateLootMagazine = getArray (configFile / "CfgWeapons" / _loadCrateItem / "magazines");
				_loadCrateLootMagazineClass = selectRandom _loadCrateLootMagazine;
				_loadCrateLootMagazineNum = floor (round (random 6) + 4); // minimum 4, maximum 10
				_addToCrate = [_crate,_loadCrateItem,1] call _canAddToCrate;
				if (_addToCrate) then
				{
					_crate addWeaponCargoGlobal [_loadCrateItem,1];
					#ifdef __DEBUG__
						diag_log format [" + %1 added -> 1x %2",_loadCrateWithWhat,_loadCrateItem];
					#endif
				};
				_addToCrate = [_crate,_loadCrateLootMagazineClass,_loadCrateLootMagazineNum] call _canAddToCrate;
				if (_addToCrate) then
				{
					_crate addMagazineCargoGlobal [_loadCrateLootMagazineClass,_loadCrateLootMagazineNum];
					#ifdef __DEBUG__
						diag_log format [" + %1 added -> 1x %2 with %3x %4 magazines",_loadCrateWithWhat,_loadCrateItem,_loadCrateLootMagazineNum,_loadCrateLootMagazineClass];
					#endif
				};
			};
		};
		case "_secondaryWeapons": {
			_loadCrateAmount = _secondaryWeaponAmount;
			for [{_lootCount = 0},{_lootCount < _loadCrateAmount},{_lootCount = _lootCount + 1}] do
			{
				_loadCrateItem = (selectRandom _secondaryWeapons) select 1;
				_loadCrateLootMagazine = getArray (configFile / "CfgWeapons" / _loadCrateItem / "magazines");
				_loadCrateLootMagazineClass = selectRandom _loadCrateLootMagazine;
				_loadCrateLootMagazineNum = floor (round (random 4) + 2); // minimum 2, maximum 6
				_addToCrate = [_crate,_loadCrateItem,1] call _canAddToCrate;
				if (_addToCrate) then
				{
					_crate addWeaponCargoGlobal [_loadCrateItem,1];
					#ifdef __DEBUG__
						diag_log format [" + %1 added -> 1x %2",_loadCrateWithWhat,_loadCrateItem];
					#endif
				};
				_addToCrate = [_crate,_loadCrateLootMagazineClass,_loadCrateLootMagazineNum] call _canAddToCrate;
				if (_addToCrate) then
				{
					_crate addMagazineCargoGlobal [_loadCrateLootMagazineClass,_loadCrateLootMagazineNum];
					#ifdef __DEBUG__
						diag_log format [" + %1 added -> 1x %2 with %3x %4 magazines",_loadCrateWithWhat,_loadCrateItem,_loadCrateLootMagazineNum,_loadCrateLootMagazineClass];
					#endif
				};
			};
		};
		case "_uniforms": {
			_loadCrateAmount = _uniformAmount;
			for [{_lootCount = 0},{_lootCount < _loadCrateAmount},{_lootCount = _lootCount + 1}] do
			{
				_loadCrateItem = (selectRandom _uniforms) select 1;
				_addToCrate = [_crate,_loadCrateItem,1] call _canAddToCrate;
				if (_addToCrate) then
				{
					_crate addItemCargoGlobal [_loadCrateItem,1];
					#ifdef __DEBUG__
						diag_log format [" + %1 added -> 1x %2",_loadCrateWithWhat,_loadCrateItem];
					#endif
				};
			};
		};
		case "_vests": {
			_loadCrateAmount = _vestAmount;
			for [{_lootCount = 0},{_lootCount < _loadCrateAmount},{_lootCount = _lootCount + 1}] do
			{
				_loadCrateItem = (selectRandom _vests) select 1;
				_addToCrate = [_crate,_loadCrateItem,1] call _canAddToCrate;
				if (_addToCrate) then
				{
					_crate addItemCargoGlobal [_loadCrateItem,1];
					#ifdef __DEBUG__
						diag_log format [" + %1 added -> 1x %2",_loadCrateWithWhat,_loadCrateItem];
					#endif
				};
			};
		};
		case "_weaponAccessories": {
			_loadCrateAmount = _weaponAccessoryAmount;
			for [{_lootCount = 0},{_lootCount < _loadCrateAmount},{_lootCount = _lootCount + 1}] do
			{
				_loadCrateItem = (selectRandom _weaponAccessories) select 1;
				_addToCrate = [_crate,_loadCrateItem,1] call _canAddToCrate;
				if (_addToCrate) then
				{
					_crate addItemCargoGlobal [_loadCrateItem,1];
					#ifdef __DEBUG__
						diag_log format [" + %1 added -> 1x %2",_loadCrateWithWhat,_loadCrateItem];
					#endif
				};
			};
		};
		case "_mines": {
			_loadCrateAmount = _minesAmount;
			for [{_lootCount = 0},{_lootCount < _loadCrateAmount},{_lootCount = _lootCount + 1}] do
			{
				_loadCrateItem = (selectRandom _mines) select 1;
				_loadCrateLootMagazineNum = floor (round (random 2) + 2); // minimum 2, maximum 4
				_addToCrate = [_crate,_loadCrateItem,_loadCrateLootMagazineNum] call _canAddToCrate;
				if (_addToCrate) then
				{
					_crate addItemCargoGlobal [_loadCrateItem,_loadCrateLootMagazineNum];
					#ifdef __DEBUG__
						diag_log format [" + %1 added -> %2x %3",_loadCrateWithWhat,_loadCrateLootMagazineNum,_loadCrateItem];
					#endif
				};
			};
		};
		case "_goggles": {
			_loadCrateAmount = _goggleAmount;
			for [{_lootCount = 0},{_lootCount < _loadCrateAmount},{_lootCount = _lootCount + 1}] do
			{
				_loadCrateItem = (selectRandom _goggles) select 1;
				_loadCrateLootMagazineNum = floor (round (random 2) + 2); // minimum 2, maximum 4
				_addToCrate = [_crate,_loadCrateItem,_loadCrateLootMagazineNum] call _canAddToCrate;
				if (_addToCrate) then
				{
					_crate addItemCargoGlobal [_loadCrateItem,_loadCrateLootMagazineNum];
					#ifdef __DEBUG__
						diag_log format [" + %1 added -> %2x %3",_loadCrateWithWhat,_loadCrateLootMagazineNum,_loadCrateItem];
					#endif
				};
			};
		};
	};
};

if (["A3W_artilleryStrike"] call isConfigOn) then
{
	if (random 1.0 < ["A3W_artilleryCrateOdds", 1/10] call getPublicVar) then
	{
		_box setVariable ["artillery", 1, true];
	};
};

#ifdef __DEBUG__
	diag_log "----------------------------------------------------";
#endif
