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
	Version: 1.0.A3WL3
	Author: soulkobk (soulkobk.blogspot.com)
	Creation Date: 3:10 PM 11/05/2018
	Modification Date: 1:02 PM 22/05/2018

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

	"RCLO_RARE" was added in order to make the random choices based upon a percentage chance of being actually chosen.
	Want an item to be rare? add "RCLO_RARE" in to the store item array, example...
	["TWS MG", "optic_tws_mg", 150000, "item", "HIDDEN", "RCLO_OPTIC", "RCLO_RARE"],
	If this item is randomly chosen, there is a percentage chance it will actually be added to the crate.
	Probability is set via the _raresChance variable.

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
	1.0.A3WL0 - adapted script for use of storeConfig.sqf arrays of A3Wasteland (specific A3Wasteland edit).
	1.0.A3WL1 - adapted script for RCLO_RARE usage with a percentage probability of actually being added.
	1.0.A3WL2 - updated script to precisely fill crates to a certain (random) percentage from 25% to 100%.
	1.0.A3WL3 - added in error checking so if base class arrays are empty (due to missing storeConfig entries), then skip it.
	            code routine updates, increased rare chance to 75% (from 50%).

	----------------------------------------------------------------------------------------------
*/

if !(isServer) exitWith {}; // DO NOT DELETE THIS LINE!

waitUntil {!(isNil "RCLO_ARRAY")};

// #define __DEBUG__

_backPacks = call RCLO_ARRAY select {"RCLO_BACKPACK" in (_x select [3,999])}; _backPackAmount = round (floor (random 3) + 3);
_binoculars = call RCLO_ARRAY select {"RCLO_BINOCULAR" in (_x select [3,999])}; _binocularAmount = round (floor (random 5) + 2);
_bipods = call RCLO_ARRAY select {"RCLO_BIPOD" in (_x select [3,999])}; _bipodAmount = round (floor (random 3) + 2);
_goggles = call RCLO_ARRAY select {"RCLO_GOGGLE" in (_x select [3,999])}; _goggleAmount = round (floor (random 2) + 2);
_headGear = call RCLO_ARRAY select {"RCLO_HEADGEAR" in (_x select [3,999])}; _headGearAmount = round (floor (random 3) + 5);
_items = call RCLO_ARRAY select {"RCLO_ITEM" in (_x select [3,999])}; _itemAmount = round (floor (random 3) + 5);
_launcherWeapons = call RCLO_ARRAY select {"RCLO_WEAPONLAUNCHER" in (_x select [3,999])}; _launcherAmount = round (floor (random 3) + 2);
_magazines = call RCLO_ARRAY select {"RCLO_MAGAZINE" in (_x select [3,999])}; _magazineAmount = round (floor (random 5) + 5);
_mines = call RCLO_ARRAY select {"RCLO_MINE" in (_x select [3,999])}; _minesAmount = round (floor (random 2) + 2);
_muzzles = call RCLO_ARRAY select {"RCLO_MUZZLE" in (_x select [3,999])}; _muzzleAmount = round (floor (random 2) + 2);
_optics = call RCLO_ARRAY select {"RCLO_OPTIC" in (_x select [3,999])}; _opticAmount = round (floor (random 4) + 5);
_primaryWeapons = call RCLO_ARRAY select {"RCLO_WEAPONPRIMARY" in (_x select [3,999])}; _primaryWeaponAmount = round (floor (random 5) + 5);
_secondaryWeapons = call RCLO_ARRAY select {"RCLO_WEAPONSECONDARY" in (_x select [3,999])}; _secondaryWeaponAmount = round (floor (random 3) + 2);
_throwables = call RCLO_ARRAY select {"RCLO_THROWABLE" in (_x select [3,999])}; _throwableAmount = round (floor (random 3) + 3);
_uniforms = call RCLO_ARRAY select {"RCLO_UNIFORM" in (_x select [3,999])}; _uniformAmount = round (floor (random 4) + 3);
_vests = call RCLO_ARRAY select {"RCLO_VEST" in (_x select [3,999])}; _vestAmount = round (floor (random 4) + 3);
_weaponAccessories = call RCLO_ARRAY select {"RCLO_WEAPONACCESSORY" in (_x select [3,999])}; _weaponAccessoryAmount = round (floor (random 3) + 2);

_rares = call RCLO_ARRAY select {"RCLO_RARE" in (_x select [3,999])};
_raresChance = 75; // percentage chance of actually being added to crate after actually being chosen.

_loadCrateWithWhatArray =
[
	"_backPacks",
	"_binoculars",
	"_bipods",
	"_goggles",
	"_headGear",
	"_items",
	"_launcherWeapons",
	"_magazines",
	"_mines",
	"_muzzles",
	"_optics",
	"_primaryWeapons",
	"_secondaryWeapons",
	"_throwables",
	"_uniforms",
	"_vests",
	"_weaponAccessories"
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

_crateTypeOf = typeOf _crate;
_crateMaxLoad = getNumber (configFile >> "CfgVehicles" >> _crateTypeOf >> "maximumLoad");
_crateMassPercentage = (selectRandom [0.25,0.30,0.35,0.40,0.45,0.50,0.55,0.60,0.65,0.70,0.75,0.80,0.85,0.90,0.95,1]) max 0.25 min 1;
_crateMassLimit = _crateMaxLoad * _crateMassPercentage;

_crateMassCurrent = 0;
_ableToAddToCrateFailedTimes = 0;

_canAddToCrate =
{
	params ["_crate","_item","_amount"];
	_ableToAddToCrate = false;
	_mass = getNumber (configFile >> "CfgWeapons" >> _item >> "ItemInfo" >> "mass"); // items
	if (_mass isEqualTo 0) then { _mass = getNumber (configFile >> "CfgWeapons" >> _item >> "WeaponSlotsInfo" >> "mass")}; // weapons/uniforms/vests/optics/muzzles/headgear
	if (_mass isEqualTo 0) then { _mass = getNumber (configFile >> "CfgMagazines" >> _item >> "mass") }; // magazines
	if (_mass isEqualTo 0) then { _mass = getNumber (configFile >> "CfgVehicles" >> _item >> "mass") }; // backpacks
	if (_mass isEqualTo 0) then { _mass = getNumber (configFile >> "CfgGlasses" >> _item >> "mass")}; // goggles

	if (((_mass + _crateMassCurrent) < _crateMassLimit) && (_crate canAdd [_item,_amount])) then
	{
		_ableToAddToCrate = true;
		_isRare = !((_rares select {_item in _x}) isEqualTo []);
		if (_isRare) then
		{
			if ((1/_raresChance) > (random 1)) then
			{
				_ableToAddToCrate = true;
			}
			else
			{
				_ableToAddToCrate = false;
			};
		};
	};
	if (_ableToAddToCrate) then
	{
		_crateMassCurrent = _crateMassCurrent + _mass;
		_ableToAddToCrateFailedTimes = 0;
	}
	else
	{
		_ableToAddToCrateFailedTimes = _ableToAddToCrateFailedTimes + 1;
	};
	_ableToAddToCrate
};

_fillTheCrate = true;
while {_fillTheCrate} do
{
	_hasBackpackContainer = getNumber (configFile >> "CfgVehicles" >> _crateTypeOf >> "transportMaxBackpacks");
	_hasMagazineContainer = getNumber (configFile >> "CfgVehicles" >> _crateTypeOf >> "transportMaxMagazines");
	_hasWeaponContainer = getNumber (configFile >> "CfgVehicles" >> _crateTypeOf >> "transportMaxWeapons");
	_hasContainer = (_hasBackpackContainer + _hasMagazineContainer + _hasMagazineContainer);
	if (_hasContainer isEqualTo 0) exitWith {};

	_loadCrateWithWhat = selectRandom _loadCrateWithWhatArray;

	#ifdef __DEBUG__
		diag_log format ["%1 -> %2",_crateTypeOf,_loadCrateWithWhat];
	#endif

	switch (_loadCrateWithWhat) do
	{
		case "_backPacks": {
			if !(_backPacks isEqualTo []) then
			{
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
		};
		case "_binoculars": {
			if !(_binoculars isEqualTo []) then
			{
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
		};
		case "_bipods": {
			if !(_bipods isEqualTo []) then
			{
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
		};
		case "_headGear": {
			if !(_headGear isEqualTo []) then
			{
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
		};
		case "_items": {
			if !(_items isEqualTo []) then
			{
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
		};
		case "_launcherWeapons": {
			if !(_launcherWeapons isEqualTo []) then
			{
				_loadCrateAmount = _launcherAmount;
				for [{_lootCount = 0},{_lootCount < _loadCrateAmount},{_lootCount = _lootCount + 1}] do
				{
					_loadCrateItem = (selectRandom _launcherWeapons) select 1;
					_addToCrate = [_crate,_loadCrateItem,1] call _canAddToCrate;
					if (_addToCrate) then
					{
						_crate addWeaponCargoGlobal [_loadCrateItem,1];
						#ifdef __DEBUG__
							diag_log format [" + %1 added -> 1x %2",_loadCrateWithWhat,_loadCrateItem];
						#endif
					};
					_loadCrateLootMagazine = getArray (configFile / "CfgWeapons" / _loadCrateItem / "magazines");
					_loadCrateLootMagazineClass = selectRandom _loadCrateLootMagazine;
					_loadCrateLootMagazineNum = round (floor (random 4) + 2); // minimum 2, maximum 6
					for "_i" from 0 to _loadCrateLootMagazineNum do
					{
						_addToCrate = [_crate,_loadCrateLootMagazineClass,1] call _canAddToCrate;
						if (_addToCrate) then
						{
							_crate addMagazineCargoGlobal [_loadCrateLootMagazineClass,1];
							#ifdef __DEBUG__
								diag_log format [" + %1 added -> 1x %2",_loadCrateWithWhat,_loadCrateLootMagazineClass];
							#endif
						};
					};
				};
			};
		};
		case "_magazines": {
			if !(_magazines isEqualTo []) then
			{
				_loadCrateAmount = _magazineAmount;
				for [{_lootCount = 0},{_lootCount < _loadCrateAmount},{_lootCount = _lootCount + 1}] do
				{
					_loadCrateItem = (selectRandom _magazines) select 1;
					_loadCrateLootMagazineNum = round (floor (random 4) + 2); // minimum 2, maximum 6
					for "_i" from 0 to _loadCrateLootMagazineNum do
					{
						_addToCrate = [_crate,_loadCrateItem,1] call _canAddToCrate;
						if (_addToCrate) then
						{
							_crate addMagazineCargoGlobal [_loadCrateItem,1];
							#ifdef __DEBUG__
								diag_log format [" + %1 added -> %2x %3 magazines",_loadCrateWithWhat,1,_loadCrateItem];
							#endif
						};
					};
				};
			};
		};
		case "_throwables": {
			if !(_throwables isEqualTo []) then
			{
				_loadCrateAmount = _throwableAmount;
				for [{_lootCount = 0},{_lootCount < _loadCrateAmount},{_lootCount = _lootCount + 1}] do
				{
					_loadCrateItem = (selectRandom _throwables) select 1;
					_loadCrateLootMagazineNum = round (floor (random 8) + 2); // minimum 2, maximum 10
					for "_i" from 0 to _loadCrateLootMagazineNum do
					{
						_addToCrate = [_crate,_loadCrateItem,1] call _canAddToCrate;
						if (_addToCrate) then
						{
							_crate addMagazineCargoGlobal [_loadCrateItem,1];
							#ifdef __DEBUG__
								diag_log format [" + %1 added -> %2x %3",_loadCrateWithWhat,1,_loadCrateItem];
							#endif
						};
					};
				};
			};
		};
		case "_muzzles": {
			if !(_muzzles isEqualTo []) then
			{
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
		};
		case "_optics": {
			if !(_optics isEqualTo []) then
			{
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
		};
		case "_primaryWeapons": {
			if !(_primaryWeapons isEqualTo []) then
			{
				_loadCrateAmount = _primaryWeaponAmount;
				for [{_lootCount = 0},{_lootCount < _loadCrateAmount},{_lootCount = _lootCount + 1}] do
				{
					_loadCrateItem = (selectRandom _primaryWeapons) select 1;
					_addToCrate = [_crate,_loadCrateItem,1] call _canAddToCrate;
					if (_addToCrate) then
					{
						_crate addWeaponCargoGlobal [_loadCrateItem,1];
						#ifdef __DEBUG__
							diag_log format [" + %1 added -> 1x %2",_loadCrateWithWhat,_loadCrateItem];
						#endif
					};
					_loadCrateLootMagazine = getArray (configFile / "CfgWeapons" / _loadCrateItem / "magazines");
					_loadCrateLootMagazineClass = selectRandom _loadCrateLootMagazine;
					_loadCrateLootMagazineNum = round (floor (random 6) + 4); // minimum 4, maximum 10
					for "_i" from 0 to _loadCrateLootMagazineNum do
					{
						_addToCrate = [_crate,_loadCrateLootMagazineClass,1] call _canAddToCrate;
						if (_addToCrate) then
						{
							_crate addMagazineCargoGlobal [_loadCrateLootMagazineClass,1];
							#ifdef __DEBUG__
								diag_log format [" + %1 added -> 1x %2",_loadCrateWithWhat,_loadCrateLootMagazineClass];
							#endif
						};
					};
				};
			};
		};
		case "_secondaryWeapons": {
			if !(_secondaryWeapons isEqualTo []) then
			{
				_loadCrateAmount = _secondaryWeaponAmount;
				for [{_lootCount = 0},{_lootCount < _loadCrateAmount},{_lootCount = _lootCount + 1}] do
				{
					_loadCrateItem = (selectRandom _secondaryWeapons) select 1;
					_addToCrate = [_crate,_loadCrateItem,1] call _canAddToCrate;
					if (_addToCrate) then
					{
						_crate addWeaponCargoGlobal [_loadCrateItem,1];
						#ifdef __DEBUG__
							diag_log format [" + %1 added -> 1x %2",_loadCrateWithWhat,_loadCrateItem];
						#endif
					};
					_loadCrateLootMagazine = getArray (configFile / "CfgWeapons" / _loadCrateItem / "magazines");
					_loadCrateLootMagazineClass = selectRandom _loadCrateLootMagazine;
					_loadCrateLootMagazineNum = round (floor (random 4) + 2); // minimum 2, maximum 6
					for "_i" from 0 to _loadCrateLootMagazineNum do
					{
						_addToCrate = [_crate,_loadCrateLootMagazineClass,1] call _canAddToCrate;
						if (_addToCrate) then
						{
							_crate addMagazineCargoGlobal [_loadCrateLootMagazineClass,1];
							#ifdef __DEBUG__
								diag_log format [" + %1 added -> 1x %2",_loadCrateWithWhat,_loadCrateLootMagazineClass];
							#endif
						};
					};
				};
			};
		};
		case "_uniforms": {
			if !(_uniforms isEqualTo []) then
			{
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
		};
		case "_vests": {
			if !(_vests isEqualTo []) then
			{
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
		};
		case "_weaponAccessories": {
			if !(_weaponAccessories isEqualTo []) then
			{
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
		};
		case "_mines": {
			if !(_mines isEqualTo []) then
			{
				_loadCrateAmount = _minesAmount;
				for [{_lootCount = 0},{_lootCount < _loadCrateAmount},{_lootCount = _lootCount + 1}] do
				{
					_loadCrateItem = (selectRandom _mines) select 1;
					_loadCrateLootMagazineNum = round (floor (random 2) + 2); // minimum 2, maximum 4
					for "_i" from 0 to _loadCrateLootMagazineNum do
					{
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
			};
		};
		case "_goggles": {
			if !(_goggles isEqualTo []) then
			{
				_loadCrateAmount = _goggleAmount;
				for [{_lootCount = 0},{_lootCount < _loadCrateAmount},{_lootCount = _lootCount + 1}] do
				{
					_loadCrateItem = (selectRandom _goggles) select 1;
					_loadCrateLootMagazineNum = round (floor (random 2) + 2); // minimum 2, maximum 4
					for "_i" from 0 to _loadCrateLootMagazineNum do
					{
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
			};
		};
	};
	if ((_crateMassCurrent > _crateMassLimit) || (_ableToAddToCrateFailedTimes > 5)) exitWith
	{
		#ifdef __DEBUG__
			diag_log format ["CRATE FILLED TO %1%4 CAPACITY -> %2 (MAX LOAD %3)",(_crateMassPercentage * 100),_crateTypeOf,_crateMaxLoad,"%"];
		#endif
		_fillTheCrate = false;
	};
	if !(alive _crate) exitWith
	{
		#ifdef __DEBUG__
			diag_log format ["CRATE DAMAGED -> %1",_crateTypeOf];
		#endif
		_fillTheCrate = false;
	};
};

if (["A3W_artilleryStrike"] call isConfigOn) then
{
	if (random 1.0 < ["A3W_artilleryCrateOdds", 1/10] call getPublicVar) then
	{
		_crate setVariable ["artillery", 1, true];
	};
};

#ifdef __DEBUG__
	diag_log "----------------------------------------------------";
#endif
