/*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*///*//*//*/

//	@file Version: 2.0
//	@file Name gearLevel15.sqf
//	@file Author: Mokey
//	@file Created: 4/21/2018 09:48

/*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published
by the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.
/*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*/

private ["_player"];

_player = _this;

_player setVariable ["gmoney",1000];

#include "gearWhiteList.sqf"

["Open",false] call BIS_fnc_arsenal;

[missionNameSpace,(_availableBackPacks),false,false] call BIS_fnc_addVirtualBackpackCargo;
[missionNameSpace,(_availableHeadGear + _availableHeadGearAccessories + _availableUniforms + _availableVests + _availableAttachments + _availableAccessories + _availableAttachments),false,false] call BIS_fnc_addVirtualItemCargo;
[missionNameSpace,(_availableRifleMagazines + _availableSniperMagazines + _availableLmgMagazines + _availableSmgMagazines + _availableHandGunMagazines + _availableRockets + _availableHandGrenades + _availableGLRounds + _available3GLRounds + _availableExplosives),false,false] call BIS_fnc_addVirtualMagazineCargo;
[missionNameSpace,(_availableRifles + _availableSnipers + _availableLmgs + _availableSmgs + _availableHandGuns + _availableLaunchers),false,false] call BIS_fnc_addVirtualWeaponCargo;

systemChat format["Welcome %1, Enjoy your Virtual Arsenal!", name player];
