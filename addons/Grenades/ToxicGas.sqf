//	@file Name: ToxicGas.sqf
//  @file Author: Mokey
//	@file Description: Toxic Gas addon for A3W
//	@web: http://www.fractured-gaming.com
//	@Special Thanks to Pitoucc, CREAMPIE, and Izzer

#include "definitions.sqf"

setNoGasStatus = {
  "dynamicBlur" ppEffectEnable true;                  // enables ppeffect
  "dynamicBlur" ppEffectAdjust [0];                   // enables normal vision
  "dynamicBlur" ppEffectCommit 5;                    // time it takes to go back to normal vision
  resetCamShake;                                      // resets the shake
  7 fadeSound 1;                                     // fades the sound back to normal
  sleep 1;
};

burnEyes = {                                      // Settings for player with NO PROTECTION from gas
  "dynamicBlur" ppEffectEnable true;              	  // enables ppeffect
  "dynamicBlur" ppEffectAdjust [12];             	  	// intensity of blur
  "dynamicBlur" ppEffectCommit 5;               	    // time till vision is fully blurred
  enableCamShake true;                           	    // enables camera shake
  addCamShake [9, 60, 7];                           	// sets shakevalues
  5 fadeSound 0.1;                                    // fades the sound to 10% in 5 seconds
  sleep 1;
};

gasDamage = {
	player setDamage (damage player + 0.15);     	     	//damage per tick
	sleep 3;                                 		        // Timer damage is assigned "seconds"
//	player setFatigue 1;                               // sets the fatigue to 100%
};

While{true} do{

	call setNoGasStatus;

	waituntil{
        _smokeShell = nearestObject [getPosATL player, "SmokeShellYellow"];
	    _curPlayerInvulnState = player getVariable ["isAdminInvulnerable", false];
		_smokeShell distance player < 7
		&&
	    velocity _smokeShell isEqualTo [ 0, 0, 0 ]
	    &&
	    !_curPlayerInvulnState
	};

  if ((headgear player in _gasMaskFull) || (goggles player in _gasMaskFull) || (typeOf vehicle player in _exemptVehicles) ||
   (headgear player in _gasMaskMouth) || (goggles player in _gasMaskMouth) ||
   (headgear player in _gasMaskEyes) || (goggles player in _gasMaskEyes)) then
  {
    if ((headgear player in _gasMaskFull) || (goggles player in _gasMaskFull) || (typeOf vehicle player in _exemptVehicles)) then
    {
      call setNoGasStatus;
    }
    else
    {
      if ((headgear player in _gasMaskEyes) || (goggles player in _gasMaskEyes)) then
      {
        call gasDamage;
      };
      if ((headgear player in _gasMaskMouth) || (goggles player in _gasMaskMouth)) then
      {
        call burnEyes;
      };
    };
  }
  else
  {
    call burnEyes;
    call gasDamage;
  };
};
