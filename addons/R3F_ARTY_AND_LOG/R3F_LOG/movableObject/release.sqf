/*
	@file Author: [404] Costlyy (Original code part of R3F)
	@file Version: 1.0
	@file Date:	22/11/2012
	@file Description: Releases the object that the player has currently selected.
	@file Args: [ , , ,boolean(true = release horizontally)]
*/
if (R3F_LOG_mutexLocalLock) then
{
	player globalChat STR_R3F_LOG_mutexActionOngoing;
}
else
{
	_doReleaseHorizontally = _this select 3;

	R3F_LOG_mutexLocalLock = true;

	if (_doReleaseHorizontally) then {
		R3F_LOG_forceHorizontally = true; // Force the object horizontally according the the centre of said object.
	};

	R3F_LOG_playerMovesObject = objNull;
	sleep 0.1;

	R3F_LOG_mutexLocalLock = false;
};
