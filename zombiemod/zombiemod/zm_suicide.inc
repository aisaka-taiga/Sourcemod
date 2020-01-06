public Action:Command_Suicide(Client, args)
{
	if(Mother_Zombie_Player[Client] == 1)
	{
		new String:SteamId[32];
		decl String:name[128];
		GetClientName(Client, name, sizeof(name));
		GetClientAuthString(Client, SteamId, 32);
			
		PrintToChatAll("\x03 [타이가]\x02숙주좀비 \x04%s\x01(\x04%s\x01)님이 \x07자살 \x01시도를 하였습니다!!", name, SteamId);
		
		return Plugin_Handled;
	}
	return Plugin_Continue;
}
