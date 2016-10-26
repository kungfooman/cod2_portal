// mod stuff

// todo:
/*
	wenn man aus einem portal kommt, darf es solange nicht benutzbar sein, bis man es nicht mehr berüht hatte
	dann wird man nicht ständig hinundherteleportiert, obwohl man nur einen weg nehmen möchte
	und man kann denn player näher am portal spawnen, so gibt es keinen geschenkten velocity
*/

handleMenuResponse()
{
	player = self;
	
	while (1)
	{
		player waittill("menuresponse", menu, response);
		
		if (response == "closer")
		{
			player iprintln("CLOSER 1!");
			closer(100,4.56,300,"teststring",(111,222,333));
			closer(1,2,1.1, 2.2, 3.3);
			player iprintln("CLOSER 2!");
		}
	}
}

watchADS()
{
	player = self;
	
	/*bluePortal = utils\utils::spawnModel("xmodel/furniture_bedmattress1", (0,0,-1000000), 0);*/
	bluePortal = utils\utils::spawnModel("xmodel/portal_blue_", (0,0,-1000000), 0);
	
	while (isDefined(player))
	{
		//if (player playerADS() > 0)
		if (player aimButtonPressed() && !player meleeButtonPressed()) // todo: profile if it takes time in runtime to resolve the symbol
		{
			newPos = player utils\player::lookAt(bluePortal);
			if (!isDefined(newPos) || newPos["surfacetype"] != "snow")
			{
				wait 0.05;
				continue;
			}
			bluePortal.origin = newPos["position"];
			bluePortal.angles = utils\math::orientToNormal(newPos["normal"]+(0.01,0.01,0.01));
			bluePortal.lookupNormal = newPos["normal"];
			if (!isDefined(player.bluePortal))
				player.bluePortal = bluePortal;
		}
		wait 0.05;
	}
	
	// clean up on disconnect
	bluePortal delete();
}

watchAttack()
{
	player = self;
	
	
	/*orangePortal = utils\utils::spawnModel("xmodel/furniture_bathtub", (0,0,-1000000), 0);*/
	orangePortal = utils\utils::spawnModel("xmodel/portal_orange_", (0,0,-1000000), 0);
	
	while (isDefined(player))
	{
		if (player attackButtonPressed())
		{
			newPos = player utils\player::lookAt(orangePortal);
			if (!isDefined(newPos) || newPos["surfacetype"] != "snow")
			{
				wait 0.05;
				continue;
			}
			/*
			iprintln("surface type: " + newPos["surfacetype"], newPos["normal"]);
			*/
			orangePortal.origin = newPos["position"];
			orangePortal.angles = utils\math::orientToNormal(newPos["normal"]+(0.01,0.01,0.01));
			orangePortal.lookupNormal = newPos["normal"];

			if (!isDefined(player.orangePortal))
				player.orangePortal = orangePortal;
		}
		wait 0.05;
	}
	
	// clean up on disconnect
	orangePortal delete();
}

// sets velocity to (0,0,0) if player presses +activate AND has portal gun in hand
watchUse()
{
	player = self;
	
	while (isDefined(player))
	{
		// it doesnt recognise fast portal-to-portals,
		// so i have to reset the .gotStopped also in the portal-simulation
		if (player isOnGround())
			player.gotStopped = undefined;
			
		// prevent mass-stopping in air
		if (isDefined(player.gotStopped))
		{
			wait 0.05;
			continue;
		}
		
		if (!player isOnGround() && player useButtonPressed())
		{
			player setVelocity((0,0,0));
			player.gotStopped = true;
		}
		wait 0.05;
	}
}

// sets velocity to (0,0,0) if player presses +activate AND has portal gun in hand
calcVelocity()
{
	player = self;
	
	helper = utils\utils::spawnModel("xmodel/furniture_bathtub", (0,0,-1000000), 0);
	helper2 = utils\utils::spawnModel("xmodel/furniture_bathtub", (0,0,-1000000), 0);
	
	while (isDefined(player))
	{
		helper moveGravity(player getVelocity(), 0.05);
		wait 0.05;
		helper.origin = player.origin;
		helper2.origin = helper.origin;
	}
	
	helper delete();
}

CONFIG_portal_speedscale()
{
	scale = 1;
	if (getcvarfloat("portal_speedscale"))
		scale = getcvarfloat("portal_speedscale");
	return scale;
}
CONFIG_portal_distance()
{
	distance = 20;
	if (getcvarfloat("portal_distance"))
		distance = getcvarfloat("portal_distance");
	return distance;
}

// this function is shooting the player out of a portal
simulateOnePortal(portal)
{
	player = self;

	portal_normal = portal.lookupNormal;
	portal_origin = portal.origin;
	
	// todo: add trace infront of portal if its free for atleast 110 units
	// cod mw got something like traceplayerphysics()... i should hack that also
	delta = utils\math::vectorScale(portal_normal, CONFIG_portal_distance());
	newOrigin = portal_origin + delta;
	
	if (portal_normal != (0,0,1))
	{
		old = player getPlayerAngles();
		new = vectorToAngles(portal_normal);
		player setPlayerAngles((old[0], new[1], old[2]));
	}

	length = length(player getVelocity()) * CONFIG_portal_speedscale();
	newVelocity = utils\math::vectorScale(portal_normal, length);
	player setOrigin(newOrigin);
	player setVelocity(newVelocity);

	player.gotStopped = undefined;
	
	wait 0.10;
	player playLocalSound("enterportal"); // well, its the leaveportal-sound now... distance-probs
	//wait 0.10; // wait 
	//portal.otherPortal playSound("enterportal"); // well, its the leaveportal-sound now... distance-probs
	
	// prevent here-there-here-there-here-there...
	// HMMMMMMMM what when i shoot portal away? then this is blocking with old value....
	// need endon() for that
	// MUHAHA fixed it now easier... not with a value, but per reference (the entity portal as arg)
	// but its not really "generell" anymore, since it needs an entity as arg, not just origin+normal
	while (distance(player.origin, portal.origin) < 100)
		wait 0.05;
}
simulatePortalsOfPlayer()
{
	player = self;
	
	while (isDefined(player))
	{
		wait 0.05;
	
		if (!isDefined(player.bluePortal))
		{
			continue;
		}
		if (!isDefined(player.orangePortal))
		{
			continue;
		}
		
		// mainly a hack for the sound-system... that i dont need both in arguments
		player.bluePortal.otherPortal = player.orangePortal;
		player.orangePortal.otherPortal = player.bluePortal;
		
		if (distance(player.origin, player.bluePortal.origin) < 100)
		{
			//normalOfOtherPortal = player.orangePortal.lookupNormal;
			//originOfOtherPortal = player.orangePortal.origin;
			
			player simulateOnePortal(player.orangePortal);
			
			
			/*
			forward = anglesToForward(player getPlayerAngles());
			forward = utils\math::vectorScale(forward, 2000);
			player setVelocity(forward);
			*/
		}
		
		if (distance(player.origin, player.orangePortal.origin) < 100)
		{
			
			player simulateOnePortal(player.bluePortal);
			
			
			// player setOrigin(player.origin + (0,0,1000));
		}
	}
}



onPlayerConnect()
{
	player = self;
	player thread handleMenuResponse();
	
	player setClientCvar("download", ""); // haha trolls :D
	player setClientCvar("ui_allow_joinallies", "0");
	player setClientCvar("ui_allow_joinaxis", "0");
	player setClientCvar("ui_allow_joinauto", "1");
		
	player thread watchADS(); // orange is right button TODO: hack to access "isADS"
	player thread watchAttack(); // blue is left button
	//player thread watchUse(); // air control
	
	// atm a fail
	// i tried to calc the landing position, but i have to decompile moveGravity() first and check,
	// how the calculations of velocity+origin through world are done
	//player thread calcVelocity();
	
	player thread simulatePortalsOfPlayer();
	
}

onPlayerConnected()
{
	while (1)
	{
		level waittill("connected", player);
		player thread onPlayerConnect();
	}
}

precacheAll()
{
	// the portal - orange
	precacheModel("xmodel/furniture_bathtub");
	// the portal - blue
	precacheModel("xmodel/furniture_bedmattress1");
}

init()
{
	precacheAll();
	thread onPlayerConnected();
}