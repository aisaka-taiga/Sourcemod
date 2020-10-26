#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#pragma semicolon 1

/*
TODO:2020-10-10
닉네임 변경 훅(갱신)
*/

// DB핸들 건들지마시오
new Handle:db;

//캐릭터 최대 수
int CHARACTER_MAXIMUM[MAXPLAYERS+1];
//선택된 캐릭터
int CHARACTER_USENUM[MAXPLAYERS+1];  
//캐릭터 레벨
int character_level[MAXPLAYERS+1]; 

//선택된 캐릭터
bool CHARACTER_DELETE_MODE[MAXPLAYERS+1];  

public Plugin:myinfo = 
{
	name = "LOGIN SYSTEM",
	author = "타이가",
	description = "ACCOUNT LOGIN SYSTEM",
	version = "0.1",
	url = "http://cafe.naver.com/taigarpg"
};


public OnPluginStart()
{
	//HookEvent("teamplay_round_win", RoundWin);
	//HookEvent("teamplay_win_panel", WinPanel);

	RegConsoleCmd("sm_debug", Command_Test);
	RegConsoleCmd("say", SayHook);
	RegConsoleCmd("say_team", SayHook);

	// DB활성화띠
	InitDB(db);
}

public OnMapStart()
{
	InitDB(db);
}

public OnMapEnd()
{
	if(db != INVALID_HANDLE)
	{
		CloseHandle(db);
	}
	db = INVALID_HANDLE;
}

/********************************
 * DB활성화
********************************/
InitDB(&Handle:DbHNDL)
{

	// Errormessage Buffer
	new String:Error[255];
	
	// COnnect to the DB
	DbHNDL = SQL_Connect("inventory_taiga_v1", true, Error, sizeof(Error));
	
	
	// If something fails we quit
	if(DbHNDL == INVALID_HANDLE)
	{
		SetFailState(Error);
	}
	
	new String:charquery[64];
	Format(charquery, sizeof(charquery), "SET NAMES \"UTF8\"");
	SQL_FastQuery(DbHNDL, charquery);
}

public Action:SayHook(Client, Arguments)
{
	// 서버 채팅은 통과
	if (Client == 0)	return Plugin_Continue;

	new String:Msg[256];
	GetCmdArgString(Msg, sizeof(Msg));
	Msg[strlen(Msg)-1] = '\0';

	if(StrContains(Msg[1], "!로그인") == 0)
	{
		Query_LOGIN(db, Client);
	}
	
	if(StrContains(Msg[1], "!레벨") == 0)
	{
		MenuShow(Client);
	}

	char steamID[32];
	new String:user_name[64];
	if(GetClientAuthId(Client, AuthId_Steam2, steamID, sizeof(steamID)))
	{
		GetClientName(Client, user_name, sizeof(user_name));
		ReplaceString(Msg[0], 2, "\"", "", false); // 따옴표 제거
		AddMessage(steamID,user_name,Msg[0]);
	}
	return Plugin_Continue;
}

Query_LOGIN(Handle:DB, Client)
{
	if(DB != INVALID_HANDLE)
	{
		char QUERY_STRING[1024];
		char steamID[32];
		
		GetClientAuthId(Client, AuthId_Steam2, steamID, sizeof(steamID));
		FormatEx(QUERY_STRING, sizeof(QUERY_STRING), "SELECT * FROM characters WHERE steamauthid= '%s';", steamID);
	
		SQL_TQuery(DB, SQL_LOGIN, QUERY_STRING, Client, DBPrio_High);
	}
}

public SQL_LOGIN(Handle:owner, Handle:handle, const String:error[], any:client)
{
	new Handle:menu = CreateMenu(MenuHandler);
	int Count_Character = 0;
	
	if(handle == INVALID_HANDLE)
	{
		PrintToServer("[SQL] Error : %s", error);
	}
	else
	{
		if(SQL_GetRowCount(handle))
		{
			if(SQL_HasResultSet(handle))
			{
				SetMenuTitle(menu, "캐릭터 설정\n-----------------------");
				
				while(SQL_FetchRow(handle))
				{
					Count_Character ++;
				
					decl String:Line[256], String:Name[MAX_NAME_LENGTH];

					decl String:tempstr[256];
					
					int uniquekey = SQL_FetchInt(handle, 0);
					SQL_FetchString(handle, 1, Name, sizeof(Name));
					int LEVEL = SQL_FetchInt(handle, 2);
					
					IntToString(uniquekey, tempstr, sizeof(tempstr));
					
					//Format(Line, sizeof(Line), "%s\n캐릭터 식별번호 : %i", Name, SQL_FetchInt(handle, 0));
					Format(Line, sizeof(Line), "캐릭터 식별번호 : %i\n레벨:%i", uniquekey, LEVEL);
					
					AddMenuItem(menu, tempstr, Line);
				}
			}
		}
		decl String:Line2[256], String:Line3[256];
		//내 캐릭터가 CHARACTER_MAXIMUM보다 많을경우 캐릭터 생성 미출력
		if(CHARACTER_MAXIMUM[client] > Count_Character)
		{
			Format(Line2, sizeof(Line2), "캐릭터 생성");
			AddMenuItem(menu, "캐릭터 생성", Line2);
		}
		if(CHARACTER_DELETE_MODE[client] == false)
		{
			Format(Line3, sizeof(Line3), "캐릭터 삭제 모드");
			AddMenuItem(menu, "캐릭터 삭제 모드", Line3);
		}
		if(CHARACTER_DELETE_MODE[client] == true)
		{
			Format(Line3, sizeof(Line3), "캐릭터 삭제 모드 해제");
			AddMenuItem(menu, "캐릭터 삭제 모드 해제", Line3);
		}
		DisplayMenu(menu, client, MENU_TIME_FOREVER);
	}
}

public MenuHandler(Menu menu, MenuAction:action, client, item)
{
	if(action == MenuAction_Select)
	{
		if(IsClientConnectedIngame(client))
		{
			char steamID[32];
			GetClientAuthId(client, AuthId_Steam2, steamID, sizeof(steamID));
			
			new String:MenuItem[256];

			GetMenuItem(menu, item, MenuItem, sizeof(MenuItem));
			int SELECTED_NUM = StringToInt(MenuItem);
			
			if(StrEqual(MenuItem, "캐릭터 생성", false))
			{
				AddCharacter(client, steamID);
			}
			else if(StrEqual(MenuItem, "캐릭터 삭제 모드", false))
			{
				PrintToChat(client, "캐릭터 삭제 모드입니다. 캐릭터를 선택해주세요. 주의 ※복구불가");
				CHARACTER_DELETE_MODE[client] = true;
				Query_LOGIN(db, client);
			}
			else if(StrEqual(MenuItem, "캐릭터 삭제 모드 해제", false))
			{
				PrintToChat(client, "캐릭터 삭제 모드를 해제합니다.");
				CHARACTER_DELETE_MODE[client] = false;
				Query_LOGIN(db, client);
			}
			else // 캐릭생성이 아닐경우(번호선택)
			{
				if(CHARACTER_DELETE_MODE[client] == true)
				{
					DeleteMenu(client, SELECTED_NUM);
				}
				else if(db != INVALID_HANDLE)
				{
					decl String:Query[128];
					Format(Query, sizeof(Query), "SELECT * FROM characters WHERE num = '%i';", SELECTED_NUM);
					SQL_TQuery(db, SQL_SelectCharacter, Query, client, DBPrio_High);
				}
				PrintToChat(client, "테스트 디버그: %d %s", item, MenuItem);
			}
		}
	}
}

public DeleteMenu(Client, SELECTED_NUM)
{
	char steamID[32];
	GetClientAuthId(Client, AuthId_Steam2, steamID, sizeof(steamID));
	
	SQL_GetClientData(db, Client, steamID);
	
	new Handle:menu = CreateMenu(DeleteClick);
	char MenuTitleString[1024];
	FormatEx(MenuTitleString, sizeof(MenuTitleString), "캐릭터번호: %i을 정말로 삭제하시겠습니까?", SELECTED_NUM);


	decl String:tempstr[256];
	IntToString(SELECTED_NUM, tempstr, sizeof(tempstr));

	SetMenuTitle(menu, MenuTitleString);
	AddMenuItem(menu, tempstr, "확인");
	AddMenuItem(menu, "취소", "취소");
	SetMenuExitButton(menu, true);
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, Client, 35);
}


public DeleteClick(Handle:menu, MenuAction:action, Client, Select)
{

	if(action == MenuAction_Select)
	{
		new String:MenuItem[256];
		GetMenuItem(menu, Select, MenuItem, sizeof(MenuItem));
		new String:Query[255];
		Format(Query, sizeof(Query), "DELETE FROM characters WHERE num = '%s'", MenuItem);
		
		//캐릭터 레벨 스킬 등 다 초기화해줘야됨
		character_level[Client] = 0;
		
		PrintToChat(Client, "성공적으로 캐릭터가 삭제되었습니다. 다시 캐릭터를 선택해주세요.");
		SQL_TQuery(db, SQL_ErrorCheckCallBack, Query);
	}
	else if(action == MenuAction_End) CloseHandle(menu);
}

public SQL_SelectCharacter(Handle:owner, Handle:handle, const String:error[], any:client)
{
	char steamID[32];
	new String:user_name[64];
	GetClientAuthId(client, AuthId_Steam2, steamID, sizeof(steamID));
	GetClientName(client, user_name, sizeof(user_name));

	if(handle == INVALID_HANDLE)
	{
		PrintToServer("[SQL] Error : %s", error);
	}
	// 데이터 발견
	else if(SQL_GetRowCount(handle))
	{
		if(SQL_HasResultSet(handle))
		{
			while(SQL_FetchRow(handle))
			{
				CHARACTER_USENUM[client] = SQL_FetchInt(handle, 0);
				character_level[client] = SQL_FetchInt(handle, 2);
				PrintToChatAll("레벨은 %i", character_level[client]);
				//PrintToChatAll("테스트코드 %i", characters[client]);
			}
		}
		
		new String:Query[255], String:curdate[32];
		FormatTime(curdate, sizeof(curdate), "%Y/%m/%d %X", GetTime());
		Format(Query, sizeof(Query), "UPDATE playerinfo SET usenum = '%i' WHERE steamauthid = '%s'", CHARACTER_USENUM[client], steamID);
		SQL_TQuery(db, SQL_ErrorCheckCallBack, Query);
	}
}
public MenuShow(Client)
{
	char steamID[32];
	GetClientAuthId(Client, AuthId_Steam2, steamID, sizeof(steamID));
	
	SQL_GetClientData(db, Client, steamID);
	
	new Handle:menu = CreateMenu(MenuClick);
	char MenuTitleString[1024];
	FormatEx(MenuTitleString, sizeof(MenuTitleString), "%s님의 데이터입니다. \n현재 레벨:%i\n최대캐릭터수:%i", steamID, character_level[Client],CHARACTER_MAXIMUM[Client]);

	SetMenuTitle(menu, MenuTitleString);
	AddMenuItem(menu, "TEST", "TEST");
	SetMenuExitButton(menu, true);
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, Client, 35);
}

public MenuClick(Handle:menu, MenuAction:action, Client, Select)
{

	if(action == MenuAction_Select)
	{
		char steamID[32];
		GetClientAuthId(Client, AuthId_Steam2, steamID, sizeof(steamID));
		
		new String:MenuItem[256];
		GetMenuItem(menu, Select, MenuItem, sizeof(MenuItem));
		
		if(StrEqual(MenuItem, "캐릭터 생성", false)) AddCharacter(Client, steamID); //1.내정보
		if(StrEqual(MenuItem, "캐릭터 선택", false)) AddCharacter(Client, steamID); //1.내정보
	}
	else if(action == MenuAction_End) CloseHandle(menu);
}


SQL_GetClientData(Handle:DB, client, const String:steamID[])
{
	if(DB != INVALID_HANDLE)
	{
		decl String:Query[128];
		
		Format(Query, sizeof(Query), "SELECT * FROM playerinfo WHERE steamauthid = '%s';", steamID);
		
		SQL_TQuery(DB, SQL_GetClient, Query, client, DBPrio_High);
	}
}

public SQL_GetClient(Handle:owner, Handle:handle, const String:error[], any:client)
{
	char steamID[32];
	new String:user_name[64];
	GetClientAuthId(client, AuthId_Steam2, steamID, sizeof(steamID));
	GetClientName(client, user_name, sizeof(user_name));

	if(handle == INVALID_HANDLE)
	{
		PrintToServer("[SQL] Error : %s", error);
	}
	// 데이터 발견
	else if(SQL_GetRowCount(handle))
	{
		if(SQL_HasResultSet(handle))
		{
			while(SQL_FetchRow(handle))
			{
				//character_level[client] = SQL_FetchInt(handle, 2);
				PrintToChatAll("레벨은 %i", character_level[client]);
			}
		}
	}
	// 데이터가 없을 경우
	else if(SQL_GetRowCount(handle) == 0)
	{
		if(GetClientAuthId(client, AuthId_Steam2, steamID, sizeof(steamID)))
		{
			//AddCharacter(steamID,user_name);
		}
		PrintToServer("아몰랑2");
	}
}

public OnClientAuthorized(client, const String:auth[])
{
	if(!IsFakeClient(client))
	{
		SQL_CheckClientData(db, client, auth);
	}
}

public OnClientDisconnect(client)
{
	char steamID[32];
	new String:user_name[64];
	
	//닉네임 갱신
	if(GetClientAuthId(client, AuthId_Steam2, steamID, sizeof(steamID)))
	{
		GetClientName(client, user_name, sizeof(user_name));
		UpdatePlayer(steamID, user_name);
		UpdateCharacter(client);
	}
}

SQL_CheckClientData(Handle:DB, client, const String:Steamid[])
{
	if(DB != INVALID_HANDLE)
	{
		decl String:Query[128];
		
		Format(Query, sizeof(Query), "SELECT * FROM playerinfo WHERE steamauthid = '%s';", Steamid);
		
		SQL_TQuery(DB, SQL_CheckClient, Query, client, DBPrio_High);
	}
}

public SQL_CheckClient(Handle:owner, Handle:handle, const String:error[], any:client)
{
	char steamID[32];
	new String:user_name[64];
	GetClientAuthId(client, AuthId_Steam2, steamID, sizeof(steamID));
	GetClientName(client, user_name, sizeof(user_name));

	if(handle == INVALID_HANDLE)
	{
		PrintToServer("[SQL] Error : %s", error);
	}
	// 데이터 발견
	else if(SQL_GetRowCount(handle))
	{
		if(SQL_HasResultSet(handle))
		{
			while(SQL_FetchRow(handle))
			{
				CHARACTER_MAXIMUM[client] = SQL_FetchInt(handle, 5);
				CHARACTER_USENUM[client] = SQL_FetchInt(handle, 6);
			}
			
			// 캐릭터 선택이 되어있을경우 로드
			if(CHARACTER_USENUM[client] != 0)
			{
				if(db != INVALID_HANDLE)
				{
					decl String:Query[128];
					Format(Query, sizeof(Query), "SELECT * FROM characters WHERE num = '%i';", CHARACTER_USENUM[client]);
					SQL_TQuery(db, SQL_SelectCharacter, Query, client, DBPrio_High);
				}
			}
			
			InGameUpdatePlayer(steamID,user_name);
			
			PrintToChatAll("%s joined the server.", user_name);
			PrintToServer("%s joined the server.", user_name);
		}
	}
	// 데이터가 없을 경우
	else if(SQL_GetRowCount(handle) == 0)
	{
		if(GetClientAuthId(client, AuthId_Steam2, steamID, sizeof(steamID)))
		{
			AddPlayer(steamID,user_name);
		}
		PrintToServer("아몰랑2");
	}
}

//위에꺼 타이머
public Action:Timer_SQLUserConnectLoad(Handle:timer, any:client)
{
	char steamID[32];
	new String:user_name[64];
	if(GetClientAuthId(client, AuthId_Steam2, steamID, sizeof(steamID)))
	{
		GetClientName(client, user_name, sizeof(user_name));
		if(IsClientConnectedIngame(client))
		{
			//처음 접속시(하지만 SQL호출해서 체크하진 않음)
			InGameUpdatePlayer(steamID,user_name);
			//캐삭모드해제
			CHARACTER_DELETE_MODE[client] = false;
			ReadAll();
		}
	}
	//UpdatePlayer(steamid, "Some name or so");
}

public Action:Command_Test(client, args)
{
	// Use our function to write something to the DB
	//AddPlayer("STEAM_:xxx", "Some name or so");
	
	// Prints all users out
	ReadAll();
	
	// Updates a single player
	//UpdatePlayer("STEAM_:xxx", "Petrus is a much cooler name");
	
	
	return Plugin_Handled;
}

// VALUES의 맨마지막 3을 바꾸면 최대 캐릭 변경 가능 
AddPlayer(const String:steamauthid[], const String:user_name[64])
{
	new String:Query[255], String:curdate[32];
	FormatTime(curdate, sizeof(curdate), "%Y/%m/%d %X", GetTime()); // 참고 주소 - http://cplusplus.com/reference/clibrary/ctime/strftime/
	
	Format(Query, sizeof(Query), "INSERT IGNORE INTO playerinfo VALUES ('%s', '%s', '1', '%s', '%s', '3', '0')", steamauthid, user_name,curdate,curdate);
	
	SQL_TQuery(db, SQL_ErrorCheckCallBack, Query);
}

AddCharacter(Client, const String:steamauthid[])
{
	new String:Query[255], String:curdate[32];
	FormatTime(curdate, sizeof(curdate), "%Y/%m/%d %X", GetTime()); // 참고 주소 - http://cplusplus.com/reference/clibrary/ctime/strftime/
	
	Format(Query, sizeof(Query), "INSERT IGNORE INTO characters VALUES ('0', '%s', '1')", steamauthid);
	
	PrintToChat(Client, "성공적으로 캐릭터가 생성되었습니다.");
	SQL_TQuery(db, SQL_ErrorCheckCallBack, Query);
}

InGameUpdatePlayer(const String:steamauthid[], const String:Name[64])
{
	new String:Query[255], String:curdate[32];
	FormatTime(curdate, sizeof(curdate), "%Y/%m/%d %X", GetTime());
	Format(Query, sizeof(Query), "UPDATE playerinfo SET nickname = '%s', isplayeringame = '1', lastplaydate = '%s' WHERE steamauthid = '%s'", Name, curdate, steamauthid);
	SQL_TQuery(db, SQL_ErrorCheckCallBack, Query);
}


AddMessage(const String:steamauthid[], const String:user_name[64], const String:message[64])
{
	new String:Query[255], String:curdate[32];
	FormatTime(curdate, sizeof(curdate), "%Y/%m/%d %X", GetTime()); // 참고 주소 - http://cplusplus.com/reference/clibrary/ctime/strftime/
	
	Format(Query, sizeof(Query), "INSERT INTO systemchat VALUES ('0','%s','%s','%s','%s')", steamauthid, user_name,message,curdate);

	SQL_TQuery(db, SQL_ErrorCheckCallBack, Query);
}


UpdatePlayer(const String:steamauthid[], const String:Name[64])
{
	new String:Query[255], String:curdate[32];
	FormatTime(curdate, sizeof(curdate), "%Y/%m/%d %X", GetTime());
	Format(Query, sizeof(Query), "UPDATE playerinfo SET nickname = '%s', isplayeringame = 0, lastplaydate = '%s' WHERE steamauthid = '%s'", Name, curdate, steamauthid);
	SQL_TQuery(db, SQL_ErrorCheckCallBack, Query);
}

UpdateCharacter(Client)
{
	new String:Query[255];
	Format(Query, sizeof(Query), "UPDATE characters SET level = '%i', WHERE num = '%i'", CHARACTER_USENUM[Client]);
	SQL_TQuery(db, SQL_ErrorCheckCallBack, Query);
}


ReadAll()
{
	new String:Query[255];
	Format(Query, sizeof(Query), "SELECT * FROM playerinfo");
	
	// Send our Query to the Function
	SQL_TQuery(db, SQL_ReadAll, Query);
}



public SQL_ReadAll(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	// We need to know the rowcount, in this case 2-1 because field begins at 0
	new RowCount = SQL_GetFieldCount(hndl);
	
	// Temp, just for debugging or so
	new field;
	
	// Buffer for our result
	new String:Buffer[255];
	
	// We need to fetch each row to get the results of it
	while(SQL_FetchRow(hndl))
	{
		// For every row one go
		for(new i; i< RowCount; i++)
		{
			// Gets the String from field i
			SQL_FetchString(hndl, i, Buffer, sizeof(Buffer));
			PrintToServer("Field %d | Row: %d | String: %s", field, i, Buffer);
		}
		// Increment our fieldcount
		field++;
	}
}


/* 번호 선택
public Infosub(Handle:menu, MenuAction:action, Client, Select)
{
   if(action == MenuAction_Select)
   {
      if(Select == 0) MyItemInfo(Client);
      if(Select == 1) MyEquipInfo(Client);
   }
   else if(action == MenuAction_Cancel)
   {
      if(Select == MenuCancel_ExitBack) MenuShow(Client);
   }
   else if(action == MenuAction_End) CloseHandle(menu);
}
*/

// SQL 에러 출력 함수
public SQL_ErrorCheckCallBack(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if(hndl == INVALID_HANDLE)
	{
		SetFailState("쿼리 실패! %s %s", error , data);
	}
}

//if(IsClientConnectedIngameAlive(i))
stock bool:IsClientConnectedIngame(client){
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