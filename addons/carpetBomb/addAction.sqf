player addAction ["Carpet Bomb",
{
if (currentWeapon player == "Laserdesignator_02" && isLaserOn player) then
{
  _pos = screenToWorld [0.5,0.5];
  _bomb = ["", _pos,270,20,100] spawn GOM_fnc_carpetbombing;
  player removeWeapon "Laserdesignator_02";
} else {
systemChat "Your not designating anything";
};
