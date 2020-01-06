#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <geoip.inc>
#include <string.inc>
#include "sdkhooks"

#include "zombiemod/zm_base.inc"

new UserMsg:g_FadeUserMsgId;

//#define MotherZombieModel "models/player/mapeadores/kaem/zh/zh2.mdl"
#define Download_Skin_SS 3
new String:Mother_Zombie_Skin[3][256] = {
	{"models/player/mapeadores/morell/zh/zh3fix.mdl"},
	{"models/player/tm_phoenix.mdl"},
	{"models/player/tm_pirate.mdl"}
}

public OnMapStart()
{
	for(new i = 0; i < Download_Skin_SS; i++)
	{
		PrecacheModel(Mother_Zombie_Skin[i], true);
	}
	//PrecacheModel("models/player/tm_pirate.mdl", true);
	
	AddFolderToDownloadsTable("models/player/mapeadores/kaem/zh", true);
	AddFolderToDownloadsTable("models/player/mapeadores/morell/zh", true);
	AddFolderToDownloadsTable("materials/models/player/mapeadores/morell/zh", true);
	AddFolderToDownloadsTable("materials/models/player/mapeadores/kaem/zh", true);
	
	new String:cmap[32];
	GetCurrentMap(cmap, 32);
	if(StrContains(cmap, "ze_",false) == 0)
	{
		Teleport_Mother = 1;
	}
	else
	{
		Teleport_Mother = 0;
	}
}

public Action:Ready_Timer(Handle:timer)
{
	PrintHintTextToAll("유저가 들어오길 기다리는 중입니다.");
	//return Plugin_Continue;
}

public Plugin:myinfo =
{
	name = "ZombieMod For Lisa",
	author = "타이가",
	description = "ZM",
	version = "0.5",
	url = "http://cafe.naver.com/taigarpg"
};

new ztele_count[MAXPLAYERS+1];
new Float:ztele_origin[MAXPLAYERS+1][3];

public OnPluginStart()
{
	RegConsoleCmd("kill", Command_Suicide, "자살방지");
	RegConsoleCmd("spectate", Command_Suicide, "자살방지");
	RegConsoleCmd("jointeam", Command_Suicide, "자살방지");
	RegConsoleCmd("joinclass", Command_Suicide, "자살방지");
	RegConsoleCmd("explode", Command_Suicide, "자살방지");
	
	
	HookEvent("round_start", Round_Start);
	HookEvent("round_end", Round_End);
	HookEvent("player_spawn", Player_Spawn);
	HookEvent("round_freeze_end", roundfreezeend_event);
	RegConsoleCmd("sm_ztele", command_ztele, "ztele");
	RegConsoleCmd("sm_zspawn", command_zspawn, "zspawn");
	RegConsoleCmd("sm_zmenu", command_zmenu, "zmenu");
	//RegConsoleCmd("jointeam", Command_JoinTeam);
	
	AdminListMode	= CreateConVar("adminlist_mode", "2", "방법");
	RegConsoleCmd("say", SayHook);
	RegConsoleCmd("say_team", SayHook);
	
	g_FadeUserMsgId = GetUserMessageId("Fade");
}

#define Max_Sound 2 //감염 사운드 최대 갯수
 new String:infect_sound[Max_Sound][128] = { 
"npc/fast_zombie/fz_scream1.wav", 
"npc/fast_zombie/fz_scream1.wav"
};

public Action:command_zmenu(Client, Arguments)
{
	zmenu_command(Client);
	return Plugin_Handled;
}

public zmenu_command(Client)
{
	new Handle:Panel = CreatePanel();
	SetPanelTitle(Panel, "LiSA 좀비모드");
	DrawPanelText(Panel, "===================");
	DrawPanelItem(Panel, "어드민 메뉴 - 관리자만 사용 가능");
	DrawPanelText(Panel, "===================");
	DrawPanelItem(Panel, "ZCLASS - 클래스를 선택합니다");
	DrawPanelItem(Panel, "ZSPAWN - 게임에 난입합니다");
	DrawPanelItem(Panel, "ZTELE - 끼었을경우 텔레포트합니다");
	DrawPanelText(Panel, "==================");
	DrawPanelItem(Panel, "나가기");
	DrawPanelText(Panel, "==================");
 
	SendPanelToClient(Panel, Client, command_zmenu_choice, 30);

	CloseHandle(Panel);
}

public command_zmenu_choice(Handle:Menu, MenuAction:Click, Parameter1, Parameter2)
{
	new Handle:Panel = CreatePanel();
	new Client = Parameter1;

	if(Click == MenuAction_Select)
	{
		if(Parameter2 == 1)
		{
			if(ZSPAWN_USE[Client] != 1)
			{
				CS_RespawnPlayer(Client);
			}
			else
			{
				PrintToChat(Client, "사용할 수 없습니다.");
			}
		}
		if(Parameter2 == 2)
		{
			if(ZSPAWN_USE[Client] != 1)
			{
				CS_RespawnPlayer(Client);
			}
			else
			{
				PrintToChat(Client, "사용할 수 없습니다.");
			}
		}

		if(Parameter2 == 3)
		{
			if(ZSPAWN_USE[Client] != 1)
			{
				CS_RespawnPlayer(Client);
			}
			else
			{
				PrintToChat(Client, "사용할 수 없습니다.");
			}
		}

		if(Parameter2 == 4)
		{
			if(AliveCheck(Client) == true)
			{
				if (ztele_count[Client] > 0)
				{
					ztele_count[Client] -= 1;
					TeleportEntity(Client, ztele_origin[Client], NULL_VECTOR, NULL_VECTOR);
					PrintToChat(Client, "\x04 [타이가서버]\x01 %d 개 남음" ,ztele_count[Client]);
				}
				else PrintToChat(Client, "\x04 [타이가서버]\x01 텔레포트 다 씀.");
			}
		}
	}
	CloseHandle(Panel);
}

public OnClientPutInServer(Client)
{
	SDKHook(Client, SDKHook_OnTakeDamage, OnTakeDamageHook);
	ZSPAWN_USE[Client] = 0;
}

public OnClientDisconnect(Client)
{
	SDKUnhook(Client, SDKHook_OnTakeDamage, OnTakeDamageHook);
}

public OnMapEnd()
{
	if(Zombie_Count_Timer != INVALID_HANDLE)		
	{
	//타이머를킬하고
	KillTimer(Zombie_Count_Timer);
	//핸들걸어버린다.
	Zombie_Count_Timer = INVALID_HANDLE;
	}
	
	if(Ready_Timer_end != INVALID_HANDLE)		
	{
	//타이머를킬하고
	KillTimer(Ready_Timer_end);
	//핸들걸어버린다.
	Ready_Timer_end = INVALID_HANDLE;
	}
	
	for(new i = 1; i <= MaxClients; i++)
	{
		ZSPAWN_USE[i] = 0;
		Mother_Zombie_Player[i] = 0;
	}
}

public Action:command_ztele(Client, Arguments)
{
	if(AliveCheck(Client) == true)
	{
		if (ztele_count[Client] > 0)
		{
			ztele_count[Client] -= 1;
			TeleportEntity(Client, ztele_origin[Client], NULL_VECTOR, NULL_VECTOR);
			PrintToChat(Client, "\x04 [타이가서버]\x01 %d 개 남음" ,ztele_count[Client]);
		}
		else PrintToChat(Client, "\x04 [타이가서버]\x01 텔레포트 다 씀.");
	}
}

public Action:command_zspawn(Client, Arguments)
{
	if(DeadCheck(Client) == true)
	{
		if(GetClientTeam(Client) != 1)
		{
			if(ZSPAWN_USE[Client] != 1)
			{
				CS_RespawnPlayer(Client);
			}
			else
			{
				PrintToChat(Client, "사용할 수 없습니다.");
			}
		}
		else
		{
			PrintToChat(Client, "관전은 사용 불가능합니다.");
		}
	}
	else
	{
		PrintToChat(Client, "당신은 이미 살아있습니다!");
	}
}

public Action:Round_Start(Handle:Event, const String:Name[], bool:Broadcast)
{
	if(Zombie_Count_Timer == INVALID_HANDLE)		
	{
		if(Ready_Timer_end != INVALID_HANDLE)		
		{
		//타이머를킬하고
		KillTimer(Ready_Timer_end);
		//핸들걸어버린다.
		Ready_Timer_end = INVALID_HANDLE;
		}
		Zombie_Select_Time = 30;
		zombie_appear = 0;
		RemoveEntity();
	}
}

public Action:Zombie_Countdown_Timer(Handle:timer)
{
	Zombie_Select_Time -= 1;
	PrintHintTextToAll("%d 초 후에 감염이 시작됩니다!", Zombie_Select_Time);
	if (Zombie_Select_Time == 0)
	{
		new ClientGame = GetClientCount(true);
		if (ClientGame < 30)
		{
			Zombie_Select_Number = 6;
		}
		
		GetRandomZombie_Normal();

		for(new i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && (GetClientTeam(i) == 2))
			{
				if (Mother_Zombie_Player[i] != 1)
				{
					CS_SwitchTeam(i, CS_TEAM_CT)
				}
			}
		}
		
		if(Zombie_Count_Timer != INVALID_HANDLE)		
		{
		//타이머를킬하고
		KillTimer(Zombie_Count_Timer);
		//핸들걸어버린다.
		Zombie_Count_Timer = INVALID_HANDLE;
		}
		return Plugin_Stop;
	}
	else if(Zombie_Select_Time < 0)
	{
		if(Zombie_Count_Timer != INVALID_HANDLE)		
		{
		//타이머를킬하고
		KillTimer(Zombie_Count_Timer);
		//핸들걸어버린다.
		Zombie_Count_Timer = INVALID_HANDLE;
		}
		Ready_Timer_end = CreateTimer(1.0, Ready_Timer, _, TIMER_REPEAT);
	}
	return Plugin_Continue;
}

public Action:Round_End(Handle:Event, const String:Name[], bool:Broadcast)
{
	new h_winner = GetEventInt(Event, "winner");
	
	for(new i = 1; i <= MaxClients; i++)
	{
		new T = GetTeamClientCount(2);
		new CT = GetTeamClientCount(3);
		if(T+1 < CT)
		{
			CS_SwitchTeam(GetRandomPlayer(3), 2);
		}
		else
		{
			if(CT+1 < T)
			{
				CS_SwitchTeam(GetRandomPlayer(2), 3);
			}
		}
		SDKUnhook(i, SDKHook_WeaponSwitch, OnWeaponSwitch);
		Mother_Zombie_Player[i] = 0;
	}
	if(h_winner == 3)
	{
		PrintToChatAll("\x06 [인간팀 승리] - \x04인간\x03들이 살아남으셨습니다.");
	}
	else if(h_winner == 2)
	{
		PrintToChatAll("\x06 [좀비팀 승리] - \x02좀비\x05들이 \x04모든 인간\x05들을 감염시켰습니다");
	}
	if(Zombie_Count_Timer != INVALID_HANDLE)		
	{
	//타이머를킬하고
	KillTimer(Zombie_Count_Timer);
	//핸들걸어버린다.
	Zombie_Count_Timer = INVALID_HANDLE;
	}
	zombie_appear = 0;
	TeamManager_BalanceTeams();
}

public Action:Player_Spawn(Handle:event, const String:Name[], bool:Broadcast)
{
	new Client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(zombie_appear == 0)
	{
		ztele_count[Client] = 1;
		GetClientAbsOrigin(Client, ztele_origin[Client]);
	}
	if(IsPlayerAlive(Client) && Client > 0)
	{
		ZSPAWN_USE[Client] = 1;
	}
	
	new Money = GetEntProp(Client, Prop_Send, "m_iAccount")
	Money = 16000;
	SetEntProp(Client, Prop_Send, "m_iAccount", Money);
}

public Action:roundfreezeend_event(Handle:Event, const String:Name[], bool:Broadcast)
{
	if(Zombie_Count_Timer != INVALID_HANDLE)		
	{
	//타이머를킬하고
	KillTimer(Zombie_Count_Timer);
	//핸들걸어버린다.
	Zombie_Count_Timer = INVALID_HANDLE;
	}
	Zombie_Count_Timer = CreateTimer(1.0, Zombie_Countdown_Timer, _, TIMER_REPEAT);
}

public GetRandomZombie_Normal()
{
	if (Zombie_Select_Number > 0)
	{
		new mother_zombie_team = GetRandomInt(2, 3);
		new mother_zombie_select = GetRandomPlayer(mother_zombie_team);
		
		Zombie_Select_Number -= 1;
		Mother_zombie(mother_zombie_select);
		GetRandomZombie_Normal();
		zombie_appear = 1;
	}
}

stock Mother_zombie(Client)
{
	if(Client > 0 && Client <= MaxClients)
	{
		if (GetClientTeam(Client) != 2) CS_SwitchTeam(Client, CS_TEAM_T);
		WeaponRemove(Client);
		GivePlayerItem(Client, "weapon_knife");
		new Health_Offset = FindSendPropOffs("CCSPlayer", "m_iHealth");
		SetEntData(Client, Health_Offset, 12000, 4);
		SetEntityModel(Client, Mother_Zombie_Skin[GetRandomInt(0, 2)]);
		PrintToChat(Client, "[타이가]\x02 숙주좀비로 감염 \x01되셨습니다!");
		SDKHook(Client, SDKHook_WeaponSwitch, OnWeaponSwitch);
		Mother_Zombie_Player[Client] = 1;
		
		if(Teleport_Mother == 1)
		{
			TeleportEntity(Client, ztele_origin[Client], NULL_VECTOR, NULL_VECTOR);
		}
	}
	
	if (ztele_count[Client] == 0) ztele_count[Client] = 2;
	if (ztele_count[Client] == 1) ztele_count[Client] = 3;
}

stock Normal_zombie(Client)
{
	if (GetClientTeam(Client) != 2) CS_SwitchTeam(Client, CS_TEAM_T);
	WeaponRemove(Client);
	GivePlayerItem(Client, "weapon_knife");
	new Health_Offset = FindSendPropOffs("CCSPlayer", "m_iHealth");
	SetEntData(Client, Health_Offset, 7000, 4);
	SetEntityModel(Client, Mother_Zombie_Skin[GetRandomInt(0, 2)]);
	//SetEntityModel(Client, "models/player/mapeadores/kaem/zh/zh2fix.mdl");
	PrintToChat(Client, "[타이가]\x02 감염 \x01되셨습니다.");
	SDKHook(Client, SDKHook_WeaponSwitch, OnWeaponSwitch);
	
	if (ztele_count[Client] == 0) ztele_count[Client] = 2;
	if (ztele_count[Client] == 1) ztele_count[Client] = 3;
}

public WeaponRemove(client)
{
	new wepIdx;
	for( new i = 0; i < 6; i++ )
	{
		while( ( wepIdx = GetPlayerWeaponSlot( client, i ) ) != -1 )
		{
			RemovePlayerItem( client, wepIdx );
		}
	}
}

public Action:OnTakeDamageHook(Client, &attacker, &inflictor, &Float:damage, &damagetype)
{
	if(zombie_appear == 0)
	{
		return Plugin_Handled;
	}
	if(damagetype & DMG_FALL)
	{
		return Plugin_Handled;
	}
	
	if(zombie_appear == 1)
	{
		if(GetClientTeam(attacker) == 2)
		{
			if(GetClientTeam(Client) == 3)
			{
				GetClientAbsOrigin(Client, zombie_abs[Client]);
				damage += 100.1;
				CS_RespawnPlayer(Client);
				TeleportEntity(Client, zombie_abs[Client], NULL_VECTOR, NULL_VECTOR);
				Normal_zombie(Client);
				// 사망이벤트를 허위로 발동시킨다.
				new Handle:event = CreateEvent("player_death");
				if (event != INVALID_HANDLE)
				{
					SetEventInt(event, "userid", GetClientUserId(Client));
					SetEventInt(event, "attacker", GetClientUserId(attacker));
					SetEventString(event, "weapon", "zombies_claws_of_death");
					FireEvent(event, false);
				}
				
				new score = Tools_ClientScore(attacker, true, false);
				Tools_ClientScore(attacker, true, true, ++score);
				
				// 피해자에게 사망횟수 증가.
				new deaths = Tools_ClientScore(Client, false, false);
				Tools_ClientScore(Client, false, true, ++deaths);
			}
		}
	}
	
	decl Random_Shake,Random_Blood;
	Random_Shake = GetRandomInt(1,300);
	Random_Blood = GetRandomInt(1,150);
					
	if(Random_Shake <= 10)
	{
		if(GetClientTeam(attacker) == 3 && GetClientTeam(Client) == 2)
		{
			VEffectsShakeClientScreen(Client, 15.0, 1.0, 5.0);
		}
	}
	
	if(Random_Blood <= 15)
	{
		if(GetClientTeam(attacker) == 3 && GetClientTeam(Client) == 2)
		{
			Blood_Effect(Client);
		}
	}
	
	if(GetClientTeam(attacker) == 2 && GetClientTeam(Client) == 3)
	{
		VEffectsShakeClientScreen(Client, 15.0, 1.0, 5.0);
	}
	
	if(GetClientTeam(attacker) == 2 && GetClientTeam(Client) == 3)
	{
		Blood_Effect(Client);
	}
	
	AliveCT = 0;
	for(new i = 1; i <= MaxClients; i++)
	{
		if(IsClientConnectedIngameAlive(i))
		{
			if(GetClientTeam(i) == 3)
			{
				AliveCT += 1;		
			}
		}
	}
	if(AliveCT == 0)
	{
		CS_TerminateRound(7.0, CSRoundEnd_TerroristWin);
	}
	return Plugin_Continue;
}

//무승부 방지
public Action:CS_OnTerminateRound(&Float:delay, &CSRoundEndReason:reason)
{
	/*
	if(reason == CSRoundEnd_Draw)
	{	
		return Plugin_Handled;
	}
	*/
	return Plugin_Continue;
}

public Action:CS_OnBuyCommand(Client, const String:weapon[])
{
	if (StrEqual(weapon, "negev", false))   
	{  
		PrintToChat(Client, "\x05 네게브를 구입할 수 없습니다.");
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public Action:OnWeaponSwitch(Client, weapon)
{
	decl String:sWeapon[32];
	GetEdictClassname(weapon, sWeapon, sizeof(sWeapon));
	if(!StrEqual(sWeapon, "weapon_knife"))
	{
		if(GetPlayerWeaponSlot(Client, 0) != -1) RemovePlayerItem(Client, GetPlayerWeaponSlot(Client, 0));
		if(GetPlayerWeaponSlot(Client, 1) != -1) RemovePlayerItem(Client, GetPlayerWeaponSlot(Client, 1));
		if(GetPlayerWeaponSlot(Client, 3) != -1) RemovePlayerItem(Client, GetPlayerWeaponSlot(Client, 3));
		if(GetPlayerWeaponSlot(Client, 4) != -1) RemovePlayerItem(Client, GetPlayerWeaponSlot(Client, 4));
		return Plugin_Handled;
	}
	return Plugin_Continue;
}


// VEffectsShakeClientScreen(client, 15.0, 1.0, 5.0);
stock VEffectsShakeClientScreen(client, Float:amplitude, Float:frequency, Float:duration)
{
    new Handle:hShake = StartMessageOne("Shake", client);
    if (hShake == INVALID_HANDLE)
    {
        return;
    }
	
    if (GetUserMessageType() == UM_Protobuf)
    {
        PbSetInt(hShake, "command", 0);
        PbSetFloat(hShake, "local_amplitude", amplitude);
        PbSetFloat(hShake, "frequency", frequency);
        PbSetFloat(hShake, "duration", duration);
    }
    else
    {
        BfWriteByte(hShake, 0);
        BfWriteFloat(hShake, amplitude);
        BfWriteFloat(hShake, frequency);
        BfWriteFloat(hShake, duration);
    }
    EndMessage();
}

stock Blood_Effect(client)
{
	new clients[2];
	clients[0] = client;	
	
	new duration = 255;
	new holdtime = 255;
	new flags = 0x0002;
	new color[4] = { 0, 0, 0, 128 };
	color[0] = GetRandomInt(0,220);
	color[1] = GetRandomInt(0,1);
	color[2] = GetRandomInt(0,1);

	new Handle:message = StartMessageEx(g_FadeUserMsgId, clients, 1);
	
	if (GetUserMessageType() == UM_Protobuf)
	{
		PbSetInt(message, "duration", duration);
		PbSetInt(message, "hold_time", holdtime);
		PbSetInt(message, "flags", flags);
		PbSetColor(message, "clr", color);
	}
	else
	{
		BfWriteShort(message, duration);
		BfWriteShort(message, holdtime);
		BfWriteShort(message, flags);
		BfWriteByte(message, color[0]);
		BfWriteByte(message, color[1]);
		BfWriteByte(message, color[2]);
		BfWriteByte(message, color[3]);
	}
	EndMessage();
}

stock bool:IsClientConnectedIngameAlive(client){
	if(client > 0 && client <= MaxClients){
		if(IsClientConnected(client) == true){
			if(IsClientInGame(client) == true){
				if(IsPlayerAlive(client) == true && IsClientObserver(client) == false){
					return true;
				}else{
					return false;
				}
			}else{
				return false;
			}
		}else{
			return false;
		}
	}else{
		return false;
	}
}

public bool:AliveCheck(Client)
{
	if(Client > 0 && Client <= MaxClients)
	{
		if(IsClientConnected(Client) == true)
		{
			if(IsClientInGame(Client) == true)
			{
				if(IsPlayerAlive(Client) == true) return true;
				else return false;
			}
			else return false;
		}
		else return false;
	}
	else return false;
}

public bool:DeadCheck(Client)
{
	if(Client > 0 && Client <= MaxClients)
	{
		if(IsClientConnected(Client) == true)
		{
			if(IsClientInGame(Client) == true)
			{
				if(IsPlayerAlive(Client) == false) return true;
				else return false;
			}
			else return false;
		}
		else return false;
	}
	else return false;
}

stock bool:Check(client){
	
	if(client > 0 && client <= MaxClients){
	
		if(IsClientConnected(client) == true){
			
			if(IsClientInGame(client) == true){
			
				return true;
				
			}else{
				
				return false;
				
			}
			
		}else{
					
			return false;
					
		}
		
	}else{
	
		return false;
	
	}
	
}

stock Tools_ClientScore(client, bool:score = true, bool:apply = true, value = 0)
{
	if (!apply)
	{
		if (score)
		{
			// score가 true면 클라이언트 사살점수를 반영.
			return GetEntProp(client, Prop_Data, "m_iFrags");
		}
		
		else
		{
			// 클라이언트의 죽은 횟수를 반영.
			return GetEntProp(client, Prop_Data, "m_iDeaths");
		}
		
	}
	
	// score가 true면 클라이언트의 사살점수를 설정.
	if (score)
	{
		SetEntProp(client, Prop_Data, "m_iFrags", value);
	}
	
	// 클라이언트 사망 수를 설정.
	else
	{
		SetEntProp(client, Prop_Data, "m_iDeaths", value);
	}
	
	// 우리는 클라이언트의 점수 또는 사망수를 설정합니다.
	return -1;
}

stock AddFolderToDownloadsTable(const String:sDirectory[], bool:bRecursive = false)
{
	decl String:sFile[64], String:sPath[512];
	new FileType:iType, Handle:hDir = OpenDirectory(sDirectory);
	while(ReadDirEntry(hDir, sFile, sizeof(sFile), iType)) 
	{
		if(iType == FileType_Directory && bRecursive) 
		AddFolderToDownloadsTable(sFile);
		else if(iType == FileType_File)
		{
		Format(sPath, sizeof(sPath), "%s/%s", sDirectory, sFile);
		AddFileToDownloadsTable(sPath);
		}
	}
}
