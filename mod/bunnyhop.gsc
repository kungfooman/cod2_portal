
addVelocity(direction, velocity)
{
	player = self;
	oldhealth = player.health;

	
	damage = velocity;
	player.maxhealth = 10000000;
	player.health = 10000000;

	eAttacker = player;
	eInflictor = player;
	eAttacker = player;
	iDamage = damage;
	iDFlags = 0;
	sMeansOfDeath = "MOD_PROJECTILE";
	sWeapon = "bla_mp"; // rename to velocity_mp (weaponfile have edited viewkicks=0)
	vPoint = undefined;
	vDir = direction;
	sHitLoc = "none";
	psOffsetTime = 0;
	eAttacker finishPlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime);
}

bounce( pos, power )
{
	oldhp = self.health;
	self.health = self.health + power;
	/*self finishPlayerDamage( self, self, power, 0, "MOD_PROJECTILE", "bh_mp", undefined, pos, "none", 0 );*/
	self addVelocity(pos, power);
	self.health = oldhp;
}

run()
{
	while (isDefined(self))
	{
		oldAngles = self.angles;
		wait 0.1;

		/*stance = self getStance();*/
		stance = "bullshit";
		useButton = self useButtonPressed();
		onGround = self isOnGround();
		fraction = bulletTrace( self getEye(), self getEye() + utils\math::vectorScale(anglesToForward(self.angles), 32 ), true, self )["fraction"];
		
		// Begin
		if( !self.doingBH && useButton && !onGround && fraction == 1 ) 
		{
			/*self setClientCvar("bg_viewKickMax", 0);
			self setClientCvar("bg_viewKickMin", 0);
			self setClientCvar("bg_viewKickRandom", 0);
			self setClientCvar("bg_viewKickScale", 0);*/
			self.doingBH = true;
		}

		// Accelerate
		if( self.doingBH && useButton && onGround && stance != "prone" && fraction == 1 )
		{
			if( self.bh < 120 )
				self.bh += 30;
		}

		// Finish
		if( self.doingBH && !useButton || self.doingBH && stance == "prone" || self.doingBH && fraction < 1 )
		{
			/*self setClientCvar("bg_viewKickMax", 90);
			self setClientCvar("bg_viewKickMin", 5);
			self setClientCvar("bg_viewKickRandom", 0.4);
			self setClientCvar("bg_viewKickScale", 0.2);*/
			
			self.doingBH = false;
			self.bh = 0;
			continue;
		}

		// Bounce
		if( self.bh && self.doingBH && onGround && fraction == 1 )
		{
			bounceFrom = (self.origin - utils\math::vectorScale( anglesToForward( self.angles ), 50 )) - (0,0,42);
			bounceFrom = vectorNormalize( self.origin - bounceFrom );
			self bounce( bounceFrom, self.bh );
			self bounce( bounceFrom, self.bh );
			wait 0.1;
		}
	}
}
