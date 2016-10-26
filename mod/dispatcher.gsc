onPlayerConnect()
{
	player = self;
	
	// this approuch depends on getGuid(),
	// cracked servers would need an account-system

	guid = player getGuid();
	//if (!player std\persistence::loginUser(guid, "secretLulz")) // try to login
	//{
	//	std\persistence::createUser(guid, "secretLulz"); // hmk, than create the user first
	//	player std\persistence::loginUser(guid, "secretLulz"); // and then login
	//}


	//player std\hud_money::onPlayerConnect();
	//player std\hud_rank::onPlayerConnect();
	
	//player thread std\stats::giveDebugStats(); // behind the init-huds

	//std\stats::add("xp", 0); // update hud for first time
	//std\stats::add("money", 0); // update hud for first time
	
	// hard threading test (it works, it adds exactly 1000 money, im happy)
	//for (i=0; i<1000; i++)
	//	player thread std\stats::add("money", 1);
	
	player thread mod\bunnyhop::run();
	player setClientCvar("jump_height", "80");
	player setClientCvar("jump_slowdownEnable", "0");
	player thread mod\player::onMenuResponse();
	player thread mod\portal::onPlayerConnect();
}

trigger_portal_teleporter()
{
	trigger = getEnt("portal", "targetname");
	
	if (!isDefined(trigger))
		return;
	
	while (1)
	{
		trigger waittill("trigger", player);
		player setOrigin((256,-192,16));
		player setPlayerAngles((0,0,0));
	}
}

just_once()
{
	player = self;
	if (isDefined(player.isStillRespawning))
		return;
	player.isStillRespawning = true;
	/* that doesnt worked
	// else it will be touching like 10 times
	while (trigger isTouching(player))
		wait 0.05;
	*/
	
	//player mod\bank::addIngameCoins(10);
	//player iprintln("you got now: " + player mod\bank::getIngameCoins() + " coins!");
	player std\stats::add("money", 10);
	player [[level.respawn]]();
	
	wait 1.00; // wait one second (should be enough)
	
	player.isStillRespawning = undefined;
}
trigger_portal_finish()
{
	trigger = getEnt("portal_finish", "targetname");
	
	if (!isDefined(trigger))
		return;
	
	while (1)
	{
		trigger waittill("trigger", player);
		player thread just_once();
	}
}


waittillPlayerConnect()
{
	while (1)
	{
		level waittill("connected", player);
		player thread onPlayerConnect();
	}
}


onStartGameType()
{
	mod\precache::precache();
	
	if (0)
	{
		host = "127.0.0.1";
		user = "kung";
		pass = "zetatest";
		db = "kung_zeta";
		port = 3306;
		std\mysql::make_global_mysql(host, user, pass, db, port);
	}
	
	thread waittillPlayerConnect();
	thread std\debugging::watchCloserCvar();
	thread std\debugging::watchScriptCvar();
	
	//thread std\test::test();
	
	// order is important
	//std\stats::statsEventAdd("money", std\persistence::eventAddGetMoney);
	//std\stats::statsEventAddEver("money", std\hud_money::eventUpdate);
	//std\stats::statsEventAdd("xp", std\persistence::eventAddGetXP);
	//std\stats::statsEventAddEver("xp", std\hud_rank::eventUpdate);
	
	setCvar("scr_spectatefree", "1");
	setCvar("jump_height", "80");
	setCvar("jump_slowdownEnable", "0");
	setCvar("g_deadChat", "1");
	setCvar("scr_spectateEnemy", "1");
	setCvar("scr_spectateFree", "1");
	
	thread trigger_portal_teleporter();
	thread trigger_portal_finish();
	
	
	while (!isDefined(level.startRound))
		wait 0.05;
	
	iprintlnbold("^1######");
	wait 1;
	iprintlnbold("^1#####");
	wait 1;
	iprintlnbold("^1####");
	wait 1;
	iprintlnbold("^1###");
	wait 1;
	iprintlnbold("^1##");
	wait 1;
	iprintlnbold("^1#");
	wait 1;
	iprintlnbold("^1G^7LaDOS ^1S^7tarted!");
	
	/* players will be linked to this entity! */
	level.blocker = spawn("script_origin", (0,0,0));
	
	numberOfRounds = 20;
	for (i=0; i<numberOfRounds; i++)
	{
		players = utils\utils::getPlayers();
		
		/* spawn and block players! */
		for (i=0; i<players.size; i++)
		{
			player = players[i];
			player [[level.spawnplayer]]();
			//if (!isDefined(player.blocker))
			//	player.blocker = spawn("script_model");
			//player freezeControls(true);
			player linkTo(level.blocker);
		}
		
		/* tell some round info! */
		iprintlnbold(players.size + " ^1P^7layers ^1S^7pawned! ^1R^7ound ^1" + (i+1) + "^7/^1" + numberOfRounds);
		iprintlnbold("^1###");
		wait 1;
		iprintlnbold("^1##");
		wait 1;
		iprintlnbold("^1#");
		wait 1;
		
		/* unblock players! */
		for (i=0; i<players.size; i++)
		{
			player = players[i];
			//player freezeControls(false);
			if (isDefined(player))
				player unlink();
		}
		
		
		level.kingOfTime = undefined;
		
		while (!isDefined(level.kingOfTime))
			wait 0.05;
			
		iprintlnbold(level.kingOfTime.name + " ^1W^7on ^1T^7he ^1R^7ound!!");
		level.kingOfTime.score += 10;
		wait 5;
	}
}