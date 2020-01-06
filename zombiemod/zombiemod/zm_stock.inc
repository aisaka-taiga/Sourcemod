stock GetRandomPlayer(team)
{
	new clients[MaxClients+1], clientCount;
	for (new i = 1; i <= MaxClients; i++)
	if(IsClientInGame(i) && (GetClientTeam(i) == team) && (AliveCheck(i) == true))
	clients[clientCount++] = i;
	return (clientCount == 0) ? -1 : clients[GetRandomInt(0, clientCount-1)];
}

TeamManager_BalanceTeams()
{
	new maxplayers = GetMaxClients();
  
	// 테러로 모두 옮긴뒤
	for (new x = 1; x <= maxplayers; x++)
	{	
		if (IsClientInGame(x))
		{
			if (GetClientTeam(x) > 1)
			{
				CS_SwitchTeam(x, CS_TEAM_T);
			}
		}
	}
  
	//절반은 CT로!
	for (new x = 1; x <= maxplayers; x++)
	{
		if (IsClientInGame(x))
		{
			if (GetClientTeam(x) > 1)
			{
				CS_SwitchTeam(x, CS_TEAM_CT);
				x++;
			}
		}
	}
}

RemoveEntity()
{
	// 클래스 네임 버퍼 선언.
	decl String:classname[64];
	
	// 유효한 모든 엔티티 인덱스를 반복(for)하여 찾는다.
	new maxentities = GetMaxEntities();
	for (new e = 1; e <= maxentities; e++)
	{
		// 유효한 엔티티가 아니라면 정지(패스).
		if (!IsValidEntity(e))
		{
			continue;
		}
		
		// Edict Classname을 획득
		GetEdictClassname(e, classname, sizeof(classname));
		
		// Edict Classname에 위에 선언한 TO_REMOVE_OBJECTIVES의 엔티티들과 일치하는 것이 있다면 제거.
		if (StrContains("func_bomb_target|func_hostage_rescue|hostage_entity|c4", classname) > -1)
		{
			// 제거.
			RemoveEdict(e);
		}
	}
}