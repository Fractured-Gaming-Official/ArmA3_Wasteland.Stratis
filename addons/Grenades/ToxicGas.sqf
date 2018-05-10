/*
@file Name: ToxicGas.sqf
@file Version: 1.2
@file Author: Mokey
@file Description: Toxic Gas addon for A3W
@web: https://fractured-gaming.com
@Special Thanks to Pitoucc, CREAMPIE, and Izzer
-----------------------------------------------------------------------
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
For more for see <http://www.gnu.org/licenses/>.
-----------------------------------------------------------------------
*/

//Expects a String NOT an array
thrownSmokeShell = "SmokeShellYellow";
launcherSmokeShell = "G_40mm_SmokeYellow";
effectDistance = 7;



gasMask =
        [
                "H_CrewHelmetHeli_B",
                "H_CrewHelmetHeli_O",
                "H_CrewHelmetHeli_I",
                "H_HelmetO_ViperSP_ghex_F",
                "H_HelmetO_ViperSP_hex_F"
        ];

exemptVehicles =
        [
                "B_MRAP_01_F",
                "B_MRAP_01_hmg_F",
                "B_MRAP_01_gmg_F",
                "O_MRAP_02_F",
                "O_MRAP_02_hmg_F",
                "O_MRAP_02_gmg_F",
                "I_MRAP_03_F",
                "I_MRAP_03_hmg_F",
                "I_MRAP_03_gmg_F",
                "O_APC_Wheeled_02_rcws_v2_F",
                "B_APC_Wheeled_01_cannon_F",
                "I_APC_Wheeled_03_cannon_F",
                "B_AFV_Wheeled_01_cannon_F",
                "B_AFV_Wheeled_01_up_cannon_F",
                "I_LT_01_scout_F",
                "I_LT_01_cannon_F",
                "I_LT_01_AT_F",
                "I_LT_01_AA_F",
                "B_APC_Tracked_01_CRV_F",
                "B_APC_Tracked_01_rcws_F",
                "I_APC_tracked_03_cannon_F",
                "O_APC_Tracked_02_cannon_F",
                "B_APC_Tracked_01_AA_F",
                "O_APC_Tracked_02_AA_F",
                "B_MBT_01_cannon_F",
                "B_MBT_01_TUSK_F",
                "O_MBT_02_cannon_F",
                "I_MBT_03_cannon_F",
                "O_T_MBT_04_cannon_F",
                "O_T_MBT_04_command_F"
        ];

setNoGasStatus =
        {
                "dynamicBlur" ppEffectEnable true;              // enables ppeffect
                "dynamicBlur" ppEffectAdjust [0];               // enables normal vision
                "dynamicBlur" ppEffectCommit 10;                // time it takes to go back to normal vision
                resetCamShake;                                  // resets the shake
                20 fadeSound 1;                                 // fades the sound back to normal
        };

setGasStatus =
        {
                "dynamicBlur" ppEffectEnable true;                 // enables ppeffect
                "dynamicBlur" ppEffectAdjust [8];                 // intensity of blur
                "dynamicBlur" ppEffectCommit 10;                 // time till vision is fully blurred
                enableCamShake true;                            // enables camera shake
                addCamShake [5, 20, 5];                        // sets shakevalues [power, duration, frequency]
                //player setFatigue 1;                        // sets the fatigue to 100%
                5 fadeSound 0.1;                             // fades the sound to 10% in 5 seconds
        };

gasDamage =
        {
                player setDamage (damage player + 0.10);      //damage per tick
                call BIS_fnc_indicateBleeding;
                sleep 2;                                      // Timer damage is assigned "seconds"

        };

[]spawn{
        While{true} do
                {
                        call setNoGasStatus;
                        waituntil
                        {
                                _smokeShell = nearestObject [getPosATL player, thrownSmokeShell];
                                _curPlayerInvulnState = player getVariable ["isAdminInvulnerable", false];
                                _smokeShell distance player < effectDistance
                                &&
                                velocity _smokeShell isEqualTo [ 0, 0, 0 ]
                                &&
                                !_curPlayerInvulnState
                        };
                        if ((headgear player in gasMask) || ((typeOf vehicle player) in exemptVehicles)) then
                        {
                                call setNoGasStatus;
                        }
                        else
                        {
                                call setGasStatus;
                                call gasDamage;
                        };
                };
        };
[]spawn{
        While{true} do
                {
                        call setNoGasStatus;
                        waituntil
                        {
                                _smokeShell = nearestObject [getPosATL player, launcherSmokeShell];
                                _curPlayerInvulnState = player getVariable ["isAdminInvulnerable", false];
                                _smokeShell distance player < effectDistance
                                &&
                                velocity _smokeShell isEqualTo [ 0, 0, 0 ]
                                &&
                                !_curPlayerInvulnState
                        };
                        if ((headgear player in gasMask) || ((typeOf vehicle player) in exemptVehicles)) then
                        {
                                call setNoGasStatus;
                        }
                        else
                        {
                                call setGasStatus;
                                call gasDamage;
                        };
                };
        };
