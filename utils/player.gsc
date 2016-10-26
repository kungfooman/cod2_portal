lookAt(toIgnore)
{
	player = self;

	originStart = player getEye() + (0,0,25);
	angles = player getPlayerAngles();
	forward = anglesToForward(angles);

	originEnd = originStart + utils\math::vectorScale(forward, 1000000);

	trace = bullettrace(originStart, originEnd, false, toIgnore);

	if (trace["fraction"] == 1)
		return undefined;

	return trace;
}

/*
	functions:
	0 == setVelocity
	1 == getVelocity
	2 == aimButtonPressed
	3 == forwardButtonPressed
	4 == backButtonPressed
	5 == moveleftButtonPressed
	6 == moverightButtonPressed
*/

setVelocity(velocity)
{
	player = self;
	
	functionid = 0;
	playerid = player getEntityNumber();
	x = velocity[0];
	y = velocity[1];
	z = velocity[2];
	ret = closer(functionid, playerid, x, y, z);
}
getVelocity()
{
	player = self;
	
	functionid = 1;
	playerid = player getEntityNumber();
	ret = closer(functionid, playerid);
	//iprintln("ret=", ret);
	return ret;
}

aimButtonPressed()
{
	player = self;
	
	functionid = 2;
	playerid = player getEntityNumber();

	ret = closer(functionid, playerid);
	return ret;
}