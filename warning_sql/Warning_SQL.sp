
#include <sourcemod>
#include <sdktools>

new Handle:DB = INVALID_HANDLE;
new Waring_Count[MAXPLAYERS+1]

#define MaxBanWarning 5 //경고 초과 횟수
new Ban_type = 1; // 1 = 소스밴 사용자 및 일반 밴 사용자는 0 = 소스모드 밴 사용자(내장)

/* 
 SQL 기반: ABCDE SQL
 경고 플러그인 기반: 니카 경고 누적 플러그인
 아이디어: 샌박
 제작; 타이가
*/

/*
	어드민 권한
	ADMFLAG_RESERVATION	
	ADMFLAG_GENERIC	
	ADMFLAG_KICK
	ADMFLAG_BAN
	ADMFLAG_UNBAN
	ADMFLAG_SLAY
	ADMFLAG_CHANGEMAP
	ADMFLAG_CONVARS
	ADMFLAG_CONFIG
	ADMFLAG_CHAT
	ADMFLAG_VOTE
	ADMFLAG_PASSWORD
	ADMFLAG_RCON
	ADMFLAG_CHEATS
	ADMFLAG_ROOT
*/

#define admin_authority ADMFLAG_BAN

public Plugin:myinfo =
{
	name = "경고 플러그인 For Taiga",
	author = "타이가",
	description = "SQL BAN",
	version = "0.8h",
	url = "http://cafe.naver.com/taigarpg"	
};

public OnPluginStart()
{
	RegAdminCmd("sm_warning", Command_Warning, admin_authority, "원하는 플레이어에게 경고량을 원하는 만큼 증가시킵니다.");
	//RegAdminCmd("sm_idwarning", Command_Warning, admin_authority, "원하는 플레이어에게 경고량을 원하는 만큼 증가시킵니다."); =>업데이트 예정
	//RegAdminCmd("sm_ban", Command_WBAN, admin_authority, "원하는 플레이어에게 경고량을 원하는 만큼 증가시킵니다.");
	//RegAdminCmd("sm_addban", Command_addban, admin_authority);
	
	HookEvent("player_changename", OnChangeName);
}

public OnMapStart()
{
	SQL_TConnect(SQL_Connection, "superban");
}

public OnMapEnd()
{
	if(DB != INVALID_HANDLE)
	{
		CloseHandle(DB);
		DB = INVALID_HANDLE;
	}
}

public OnClientPutInServer(Client)
{
	if(!IsFakeClient(Client))
	{
		decl String:SteamID[32], String:Query[128];
		GetClientAuthString(Client, SteamID, sizeof(SteamID));

		Format(Query, sizeof(Query), "SELECT * FROM SQL_WARNING WHERE SteamID = '%s'", SteamID);

		SQL_TQuery(DB, SQL_LoadData, Query, Client);
		CreateTimer(2.5, Warning_Load, Client);
	}
}

//워닝 카운트 불러오기
public Action:Warning_Load(Handle:Timer, any:Client)
{
	new String:Name[64];
	GetClientName(Client, Name, sizeof(Name));	
	
	if(Client > 0 && IsClientInGame(Client))
	{
		PrintToChatAll("\x04[SM] - \x03%s \x01님이 현재까지 받은 경고량 : \x03%d", Name, Waring_Count[Client]);
		PrintToChatAll("\x04[SM] - \x03%s \x01님은 앞으로 \x03%d\x01번더 경고를 받으면 영구밴처벌이 내려집니다.", Name, MaxBanWarning - Waring_Count[Client]);
	}	
	
	if(Waring_Count[Client] >= MaxBanWarning)
	{
		if(Ban_type == 1)
		{
			ServerCommand("sm_ban \"%s\" 0 \"경고 횟수 초과\"", Name);
		}
		else
		{
			KickClient(Client, "경고 횟수를 초과하셨습니다.");
		}
		PrintToChatAll("%s님이 경고 횟수를 초과하셔서 영구 밴당하셨습니다.", Name);
	}
}

//워닝 커맨드
public Action:Command_Warning(Client, Arguments)
{
	if(Arguments < 2)
	{
		PrintToChat(Client, "\x04[SM]\x01 - 사용법은 \x03!warning \"플레이어 닉네임\" \"경고량\"\x01 입니다.");
		return Plugin_Handled;
	}

	new String:Player_Name[32], String:Given_Warning[32], Converted_Warning, TargetCheck, Target = -1;
	GetCmdArg(1, Player_Name, sizeof(Player_Name));
	GetCmdArg(2, Given_Warning, sizeof(Given_Warning));

	for(new i=1; i <= MaxClients; i++)
	{
		if(!IsClientConnected(i))
			continue;

		new String:Other[128];
		GetClientName(i, Other, sizeof(Other));
		if(StrContains(Other, Player_Name, false) != -1)
		{
			Target = i;
			TargetCheck++;
		}
	}
	
	if(Target == -1)
	{
		PrintToChat(Client, "\x04[SM]\x01 - \x03%s\x01님을 찾을수 없습니다.", Player_Name);
		return Plugin_Handled;
	}
	
	if(TargetCheck > 1)
	{
		PrintToChat(Client, "\x04[SM]\x01 - 이름이 겹치는 플레이어가 존재합니다.");
		return Plugin_Handled;
	}
	
	StringToIntEx(Given_Warning, Converted_Warning);
	Waring_Count[Target] += Converted_Warning;
	
	CreateTimer(0.0, Warning_Load, Target);
	SQL_SaveClientData(DB, Target);
	return Plugin_Handled;
}

//W밴 커맨드
public Action:Command_WBAN(Client, Arguments)
{
	if(Arguments < 2)
	{
		PrintToChat(Client, "\x04[SM]\x01 - 사용법은 \x03!ban \"플레이어 닉네임\" \x01입니다.");
		return Plugin_Handled;
	}

	new String:Player_Name[32], TargetCheck, Target = -1;
	GetCmdArg(1, Player_Name, sizeof(Player_Name));

	for(new i=1; i <= MaxClients; i++)
	{
		if(!IsClientConnected(i))
			continue;

		new String:Other[128];
		GetClientName(i, Other, sizeof(Other));
		if(StrContains(Other, Player_Name, false) != -1)
		{
			Target = i;
			TargetCheck++;
		}
	}
	
	if(Target == -1)
	{
		PrintToChat(Client, "\x04[SM]\x01 - \x03%s\x01님을 찾을수 없습니다.", Player_Name);
		return Plugin_Handled;
	}
	
	if(TargetCheck > 1)
	{
		PrintToChat(Client, "\x04[SM]\x01 - 이름이 겹치는 플레이어가 존재합니다.");
		return Plugin_Handled;
	}
	
	Waring_Count[Target] = 5;
	
	CreateTimer(0.0, Warning_Load, Target);
	SQL_SaveClientData(DB, Target);
	return Plugin_Handled;
}

/*
public Action:Command_addban(Client, Arguments)
{
	new Target = -1;
	GetCmdArg(1, Player_Name, sizeof(Player_Name));

	for(new i=1; i <= MaxClients; i++)
	{
		if(!IsClientConnected(i))
			continue;

		new String:Other[128];
		GetClientName(i, Other, sizeof(Other));
		if(StrContains(Other, Player_Name, false) != -1)
		{
			Target = i;
		}
	}
	IsBanned[Target] = 1;
}
*/

SQL_SaveClientData(Handle:DATABASE, client)
{
	if(DATABASE != INVALID_HANDLE)
	{
		decl String:Query[512], String:Steamid[32];
		GetClientAuthString(client, Steamid, sizeof(Steamid));
		
		Format(Query, 256, "update SQL_WARNING set Warning_N = %d where steamid = '%s';", Waring_Count[client], Steamid);
		
		SQL_TQuery(DATABASE, SQL_CheckError, Query, client, DBPrio_High);
	}
}

public OnClientDisconnect(Client)
{
	SQL_SaveClientData(DB, Client);
	if(DB != INVALID_HANDLE)
	{
		decl String:Name[32], String:SteamID[32], String:Query[128];
		GetClientName(Client, Name, sizeof(Name));
		GetClientAuthString(Client, SteamID, sizeof(SteamID));
		
		Format(Query, sizeof(Query), "UPDATE SQL_WARNING SET Name = '%s' WHERE SteamID = '%s'", Name, SteamID);
		
		SQL_TQuery(DB, SQL_CheckError, Query, Client, DBPrio_High);
	}
}

public Action:OnChangeName(Handle:Event, const String:Name[], bool:dontBroadcast)
{
	new Client = GetClientOfUserId(GetEventInt(Event, "userid"));

	decl String:CName[32];
	GetEventString(Event, "newname", CName, sizeof(CName));
	
	if(DB != INVALID_HANDLE)
	{
		decl String:SteamID[32], String:Query[128];
		GetClientAuthString(Client, SteamID, sizeof(SteamID));
		
		Format(Query, sizeof(Query), "UPDATE SQL_WARNING SET Name = '%s' WHERE SteamID = '%s'", Name, SteamID);
		
		SQL_TQuery(DB, SQL_CheckError, Query, Client, DBPrio_High);
	}
}

// SQL 운지

public SQL_Connection(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if(hndl == INVALID_HANDLE)
	{
		PrintToServer("[TAIGASQL] Error : %s", error);
	}
	else
	{
		DB = hndl;

		SQL_TQuery(DB, SQL_CheckError, "SET NAMES UTF8;", 0, DBPrio_High);		
		SQL_TQuery(DB, SQL_CheckTable, "SHOW TABLES LIKE 'TAIGASQL'", 0, DBPrio_High);
	}
}

public SQL_CheckError(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if(hndl == INVALID_HANDLE)
	{
		PrintToServer("[TAIGASQL] Error : %s", error);
	}
}

public SQL_CheckTable(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if(hndl == INVALID_HANDLE)
	{
		PrintToServer("[TAIGASQL] Error : %s", error);
	}

	if(!SQL_GetRowCount(hndl))
	{
		if(DB != INVALID_HANDLE)
		{
			SQL_TQuery(DB, SQL_CheckError, "CREATE TABLE IF NOT EXISTS SQL_WARNING (SteamID VARCHAR(32) NOT NULL, Name VARCHAR(32) NOT NULL, Warning_N INT,, PRIMARY KEY (SteamID)) ENGINE=MyISAM DEFAULT CHARSET=UTF8;", 0, DBPrio_High);
		}
	}
}

public SQL_LoadData(Handle:owner, Handle:handle, const String:error[], any:client)
{
	if(handle == INVALID_HANDLE)
	{
		PrintToChat(client, "\x05[TAIGASQL]\x03 Cannot find your data!");
	}
	else
	{
		decl String:Name[32], String:SteamID[32], String:Query[128];
		GetClientName(client, Name, sizeof(Name));
		{
		if(SQL_GetRowCount(handle))
		{
			if(SQL_HasResultSet(handle))
			{
				decl String:Steamid[32], String:Check[32];
				GetClientAuthString(client, Steamid, sizeof(Steamid));
				
				while(SQL_FetchRow(handle))
				{
					SQL_FetchString(handle, 0, Check, sizeof(Check));
				
					if(StrEqual(Steamid, Check))
					{
						Waring_Count[client] = SQL_FetchInt(handle, 2);
					}
				}
			}
		}
		else if(!SQL_GetRowCount(handle))
		GetClientAuthString(client, SteamID, sizeof(SteamID));
			
		Format(Query, sizeof(Query), "INSERT INTO SQL_WARNING (SteamID, Name, Warning_N) VALUES ('%s', '%s', 0)", SteamID, Name);
			
		SQL_TQuery(DB, SQL_CheckError, Query, client, DBPrio_High);
		}
	}
}
