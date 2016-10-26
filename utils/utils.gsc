spawnModel(name, position, dir)
{
	model = spawn("script_model", position);
	model.angles = (0, dir, 0);
	model setModel(name);

	return model;
}

getPlayers()
{
	return getentarray("player", "classname");
}

getAlivePlayers()
{
	players = getentarray("player", "classname");
	tmp = [];
	for (i=0; i<players.size; i++)
	{
		if (players[i].sessionstate == "playing")
			tmp[tmp.size] = players[i];
	}
	return tmp;
}

getDeadPlayers()
{
	players = getentarray("player", "classname");
	tmp = [];
	for (i=0; i<players.size; i++)
	{
		if (players[i].sessionstate != "playing")
			tmp[tmp.size] = players[i];
	}
	return tmp;
}