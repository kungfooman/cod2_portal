/*
	Ich wollte es eigentlich noch ein wenig schöner programmieren, aber nja, funzt auch so soweit. ^^

	Zum Installieren:
		mod\afk::precacheAndRun();
	Schreiben nach:
		zom.gsc in Funktion Callback_StartGameType()
	Irgendwo oben in der Funktion.

	VON HIER ANPASSEN -->
	VON HIER ANPASSEN -->
	VON HIER ANPASSEN -->
*/
msgStartClock()
{
	player = self;
	iprintln(player.name + " seems to be afk. some meteor will land on him soon.");
}
msgEndClock()
{
	player = self;
	iprintln("the meteor is landing on " + player.name);
}
msgBackToKeyboard()
{
	player = self;
	iprintln(player.name + " just went back to keyboard.");
}
timeWithoutClock()
{
	return 15*1000; // 15 Sekunden
}
timeWithClock()
{
	return 15*1000;
}

/*
	<-- BIS HIER ANPASSEN
	<-- BIS HIER ANPASSEN
	<-- BIS HIER ANPASSEN
*/

precache()
{
	precacheShader("hudStopwatch");
	precacheShader("hudstopwatchneedle");
	level.fxFire = loadfx("fx/explosions/flak_puff.efx");
}

// forceSpec ist incht mehr gebraucht!
forceSpec()
{
	player = self;
	//player maps\mp\gametypes\zom::menuSpectator();
	//player maps\mp\gametypes\sd::menuSpectator();
	//player maps\mp\gametypes\dm::menuSpectator();
}

isAFK(time)
{
	player = self;

	// init the first call
	if (!isDefined(player.afkLastChange))
	{
		player.afkLastChange = getTime();
		player.afkLastAngles = player getPlayerAngles();
		player.afkLastOrigin = player.origin;
		return false;
	}

	if (player.sessionstate != "playing")
		return false;

	if (player getPlayerAngles() != player.afkLastAngles)
		player.afkLastChange = getTime();

	if (player getPlayerAngles() != player.afkLastAngles)
		player.afkLastChange = getTime();


	player.afkLastAngles = player getPlayerAngles();
	player.afkLastOrigin = player.origin;

	if (getTime() - player.afkLastChange > time)
		return true;
	return false;
}

isSamePosition()
{
	player = self;

	if (!isDefined(player.afkLastAngles))
	{
		player.afkLastAngles = player getPlayerAngles();
		player.afkLastOrigin = player.origin;
	}

	if (player getPlayerAngles() != player.afkLastAngles)
		return false;

	if (player.origin != player.afkLastOrigin)
		return false;

	// set values to compare in the next 0.05 sec
	player.afkLastAngles = player getPlayerAngles();
	player.afkLastOrigin = player.origin;

	return true;
}

handleAFK()
{
	player = self;

	player msgStartClock();

	clock = newClientHudElem(player);
	clock.x = 6;
	clock.y = 76;
	clock.horzAlign = "left";
	clock.vertAlign = "top";
	clock setClock(timeWithClock()/1000, timeWithClock()/1000, "hudStopwatch", 48, 48); // wait2

	soundhelper = spawn("script_model", player.origin);
	soundhelper playLoopSound("bomb_tick");

	end = getTime() + timeWithClock();
	while (1)
	{
		
		if (player isSamePosition() == false)
		{
			clock destroy();
			player msgBackToKeyboard();
			soundhelper stopLoopSound();
			soundhelper delete();
			player.afkInThread = undefined;
			player.afkLastChange = getTime(); // reset counter
			return;
		}
		if (getTime() > end)
		{
			clock destroy();
			player msgEndClock();
			soundhelper stopLoopSound();
			break;
		}
		wait 0.05;
	}

	//player iprintln("[INFO] LAUNCHING BOMB!");

	for(j=10; j>0; j--)
	{
		pos = player.origin+(0,0,j*200);

		playfx(level.fxFire, pos);
		soundhelper.origin = pos;
		soundhelper playsound("elm_distant_explod2");

		wait 0.50;
	}

	//player iprintln("suicide and spec.");

	soundhelper playsound("explo_metal_rand");
	player suicide();

	//wait 2;
	//player forceSpec();

	soundhelper delete();
	player.afkInThread = undefined;
	return;
}

checkAFK()
{
	player = self;

	if (isDefined(player.afkInThread))
	{
		//iprintln("noch in thread");
		return;
	}

	//player iprintln("check afk");
	if (player isAFK(timeWithoutClock()))
	{
		//player iprintln("afk for 10 secs...");
		player.afkInThread = true;
		player thread handleAFK();
	}
}


checkPlayers()
{
	while (1)
	{
		players = getentarray("player", "classname");
		for (i=0; i<players.size; i++)
		{
			player = players[i];
			player checkAFK();
		}
		wait 0.05;
	}
}

precacheandrun()
{
	precache();
	thread checkPlayers();
}