#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <geoip.inc>
#include <string.inc>
#include "sdkhooks"
#include <zombiereloaded>

//M249 추가데미지(발당)
#define DAMAGE_DEFINE 3 


public Plugin:myinfo = 
{
	name = "Zombie Shop",
	author = "타이가",
	description = "Made for Lisa Zombie Server",
	version = "1.0.1",
	url = "http://cafe.naver.com/taiga800"
};

#pragma semicolon 1

new bool:KeyBuffer[MAXPLAYERS+1];
new PastKey[MAXPLAYERS+1];
new PastKey2[MAXPLAYERS+1];

new VIP_TYPE[MAXPLAYERS+1] = 0;
new String:Path2[MAXPLAYERS+1];

public OnPluginStart()
{
	RegAdminCmd("sm_addvip", Command_AddVip, ADMFLAG_KICK, "VIP를 추가합니다");
	RegAdminCmd("sm_test", Command_POINT3, ADMFLAG_KICK, "");
	CmdHook();
}

public OnClientPutInServer(Client)
{
	RegConsoleCmd("sm_shop", Command_shop, "상점을 엽니다.");
	RegConsoleCmd("sm_f", Command_shop2, "연막 구입.");
	SDKHook(Client, SDKHook_OnTakeDamage, OnTakeDamageHook);	
	CreateTimer(0.0, SLoad, Client);
}

public Action:Command_shop(Client, Arguments)
{
	Command_ShopMainMenu(Client);
}

public Action:OnTakeDamageHook(client, &attacker, &inflictor, &Float:damage, &damagetype)
{
	// 클라이언트 접속확인 (엔터티 데미지 x)
	if(IsClientConnectedIngame(client) && IsClientConnectedIngame(attacker))
	{
		decl String:s_Weapon[32];
		GetEdictClassname(inflictor, s_Weapon, 32);
			
		// 플레이어가 아닌가?
		if(!StrEqual(s_Weapon, "player"))
		{		
			return Plugin_Continue;
	
		}
			
		// 플레이어가 맞다면
		else
		{
			// 팀킬 방지
			if(GetClientTeam(client) == GetClientTeam(attacker))
			{	
				return Plugin_Continue;

			}
					
			// 공격자의 무기
			GetClientWeapon(attacker, s_Weapon, 32);	
				
			// 공격자의 무기가 칼 이라면
			if(ZR_IsClientHuman(client))
			{
				if(StrEqual(s_Weapon, "weapon_m249"))
				{
					damage += DAMAGE_DEFINE;
				}
			}
		}
	}
	return Plugin_Continue;
}

public Action:CS_OnBuyCommand(Client, const String:weapon[])
{
	if (StrEqual(weapon, "m249", false))   
	{  
		PrintToChat(Client, "\x05 해당 무기는 VIP상점에서만 구입 가능합니다.");
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public Action:Command_shop2(Client, Arguments)
{
	if(AllCheck(Client) == true)
	{
		if(ZR_IsClientHuman(Client))
		{
			if(GetEntProp(Client, Prop_Send, "m_iAccount") >= 6000)
			{
				SetEntProp(Client, Prop_Send, "m_iAccount", GetEntProp(Client, Prop_Send, "m_iAccount") - 6000);
				GiveSmokegrenade(Client, 1);
			}
		}
		else
		{
			PrintToChat(Client, "인간만 구입 가능합니다.");
		}
	}
}

public OnClientDisconnect(Client)
{
	SSave(Client);
}

//cmd훅 설정
public Action:CmdHook()
{

	if(AddCommandListener(cmdlistenernightvision, "nightvision"))
	{
		PrintToServer("Nightvision cmd hook succes");
	}
	else
	{
		PrintToServer("Nightvision cmd hook fail");
	}

	if(AddCommandListener(cmdlistenerautobuy, "autobuy"))
	{
		PrintToServer("Autobuy cmd hook succes");
	}
	else
	{
		PrintToServer("Autobuy cmd hook fail");
	}
	
	BuildPath(Path_SM, Path2, MAXPLAYERS+1, "data/Settings.txt");
}

public Action:SLoad(Handle:Timer, any:Client)
{
	if(Client > 0 && Client <= MaxClients)
	{
		new String:SteamID[32];
		GetClientAuthString(Client, SteamID, 32);

		decl Handle:Vault;
	
		Vault = CreateKeyValues("Vault");

		FileToKeyValues(Vault, Path2);
		
		KvJumpToKey(Vault, "PastKey", false);
		PastKey[Client] = KvGetNum(Vault, SteamID);
		KvRewind(Vault);

		KvJumpToKey(Vault, "PastKey2", false);
		PastKey2[Client] = KvGetNum(Vault, SteamID);
		KvRewind(Vault);
		
		KvJumpToKey(Vault, "VIP_TYPE", false);
		VIP_TYPE[Client] = KvGetNum(Vault, SteamID);
		KvRewind(Vault);
		
		CloseHandle(Vault);
	}
}

//온오프 세이브
public SSave(Client)
{
	if(Client > 0 && IsClientInGame(Client))
	{
		new String:SteamID[32];
		GetClientAuthString(Client, SteamID, 32);

		decl Handle:Vault;

		Vault = CreateKeyValues("Vault");

		if(FileExists(Path2))
			FileToKeyValues(Vault, Path2);
			
		if(PastKey[Client] > 0)
		{
			KvJumpToKey(Vault, "PastKey", true);
			KvSetNum(Vault, SteamID, PastKey[Client]);
			KvRewind(Vault);
		}
		else
		{
			KvJumpToKey(Vault, "PastKey", false);
			KvDeleteKey(Vault, SteamID);
			KvRewind(Vault);
		}

		if(PastKey2[Client] > 0)
		{
			KvJumpToKey(Vault, "PastKey2", true);
			KvSetNum(Vault, SteamID, PastKey2[Client]);
			KvRewind(Vault);
		}
		else
		{
			KvJumpToKey(Vault, "PastKey2", false);
			KvDeleteKey(Vault, SteamID);
			KvRewind(Vault);
		}
		
		if(VIP_TYPE[Client] > 0)
		{
			KvJumpToKey(Vault, "VIP_TYPE", true);
			KvSetNum(Vault, SteamID, VIP_TYPE[Client]);
			KvRewind(Vault);
		}
		else
		{
			KvJumpToKey(Vault, "VIP_TYPE", false);
			KvDeleteKey(Vault, SteamID);
			KvRewind(Vault);
		}

		KvRewind(Vault);

		KeyValuesToFile(Vault, Path2);

		CloseHandle(Vault);
	}
}

public Action:Command_AddVip(Client, Arguments)
{
	if(Arguments < 1)
	{
		PrintToChat(Client, "\x04사용법 : !addvip \"닉네임\" \"타입\"");
		return Plugin_Handled;
	}
	new String:Player_Name[32], Target = -1, String:VipType[32], Converted_LEVEL, Max;
	GetCmdArg(1, Player_Name, sizeof(Player_Name));
	GetCmdArg(2, VipType, sizeof(VipType));
		
	Max = GetMaxClients();
	for(new i=1; i <= Max; i++)
	{
		if(!IsClientConnected(i))
			continue;
		new String:Other[32];
		GetClientName(i, Other, sizeof(Other));
		if(StrContains(Other, Player_Name, false) != -1)
			Target = i;
	}
	if(Target == -1)
	{
		PrintToChat(Client, "유저가 존재하지 않습니다.");
		return Plugin_Handled;
	}
	
	StringToIntEx(VipType, Converted_LEVEL);
	VIP_TYPE[Target] += Converted_LEVEL;
	PrintToChat(Client, "[VIP] 권한을 설정하였습니다.");
	PrintToChat(Target, "[VIP] 권한을 획득하셨습니다.");
	return Plugin_Handled;
}

public Action:Command_POINT3(Client, Arguments)
{
	new String:Player_Name[32], String:Given_POINT[32], Converted_POINT, Max, Target = -1;
	GetCmdArg(1, Player_Name, sizeof(Player_Name));
	GetCmdArg(2, Given_POINT, sizeof(Given_POINT));
	Max = GetMaxClients();
	for(new i=1; i <= Max; i++)
	{
		if(!IsClientConnected(i))
			continue;

		new String:Other[32];
		GetClientName(i, Other, sizeof(Other));
		if(StrContains(Other, Player_Name, false) != -1)
			Target = i;
	}
	if(Target == -1)
	{
		PrintToChat(Client, "\x04%s님을 찾을수 없습니다.", Player_Name);
		return Plugin_Handled;
	}
	StringToIntEx(Given_POINT, Converted_POINT);
	VIP_TYPE[Target] += Converted_POINT;
	PrintToChat(Client, "\x05[%N]\x01님의 포인트의\x05[%d]\x01만큼 포인트가 더했습니다", Target, Converted_POINT);
	PrintToChat(Target, "\x01당신은 \x05[%d]\x01만큼 어드민이 포인트를 더했습니다.", Converted_POINT);
	return Plugin_Handled;
}

public Action:OnPlayerRunCmd(Client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon)
{	
	if(buttons & IN_SPEED)
	{
		if(KeyBuffer[Client] == false)
		{
			KeyBuffer[Client] = true;
			if(AllCheck(Client) == true)
			{
				if(ZR_IsClientHuman(Client))
				{
					if(PastKey[Client] == 2)
					{
					Command_ShopMainMenu(Client);
					return Plugin_Handled;
					}
				}
				else
				{
					return Plugin_Handled;
				}
			}
		}
	}
	else
	{
		KeyBuffer[Client] = false;
	}
	return Plugin_Continue;
}

Command_ShopMainMenu(Client)
{
	new Handle:menu = CreateMenu(Menu_ShopMainMenu);
	
	SetMenuTitle(menu, "---=== 상점 ===---");
		
	AddMenuItem(menu, "얼음탄구입(6000$)", "얼음탄구입(6000$)");	
	AddMenuItem(menu, "수류탄", "수류탄");
	AddMenuItem(menu, "VIP상점", "VIP상점");
	AddMenuItem(menu, "단축키", "단축키");
	
	SetMenuExitButton(menu, true);
	
	DisplayMenu(menu, Client, MENU_TIME_FOREVER);
}

public Menu_ShopMainMenu(Handle:menu, MenuAction:action, Client, select)
{
	if(action == MenuAction_Select)
	{
		if(AllCheck(Client) == true)
		{
			if(select == 0)
			{
				if(ZR_IsClientHuman(Client))
				{
					if(GetEntProp(Client, Prop_Send, "m_iAccount") >= 6000)
					{
						SetEntProp(Client, Prop_Send, "m_iAccount", GetEntProp(Client, Prop_Send, "m_iAccount") - 6000);
						GiveSmokegrenade(Client, 1);
					}
				}
			}
		
			if(select == 1)
			{
				if(ZR_IsClientHuman(Client))
				{
					Command_GrenadeShop(Client);
				}
				else
				{
					PrintToChat(Client, "\x04[ZE] \x03인간\x01만 이용할 수 있습니다.");
				}
			}
			
			if(select == 2)
			{
				if(ZR_IsClientHuman(Client))
				{
					if(VIP_TYPE[Client] != 0)
					{
						Command_VIP(Client);
					}
					else
					{
						PrintToChat(Client, "\x04[ZE] \x03VIP\x01만 이용할 수 있습니다.");
					}
				}
				else
				{
					PrintToChat(Client, "\x04[ZE] \x03인간\x01만 이용할수 있습니다.");
				}
			}
			else if(select == 3)
			{
				Command_PastOption(Client);
			}
		}
	}
	else if(action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

Command_VIP(Client)
{
	new Handle:menu = CreateMenu(Menu_VIP);
	
	SetMenuTitle(menu, "---=== VIP상점 ===---");
		
	AddMenuItem(menu, "M249구입(6000$)", "M249구입(6000$)");	
	AddMenuItem(menu, "뒤로 이동", "뒤로 이동");	
	
	SetMenuExitButton(menu, true);
	
	DisplayMenu(menu, Client, MENU_TIME_FOREVER);
}

public Menu_VIP(Handle:menu, MenuAction:action, Client, select)
{
	if(action == MenuAction_Select)
	{
		if(AllCheck(Client) == true)
		{
			if(select == 0)
			{
				if(ZR_IsClientHuman(Client))
				{
					if(GetEntProp(Client, Prop_Send, "m_iAccount") >= 6000)
					{
						SetEntProp(Client, Prop_Send, "m_iAccount", GetEntProp(Client, Prop_Send, "m_iAccount") - 6000);
						GivePlayerItem(Client, "weapon_m249");
					}
				}
			}
			
			if(select == 1)
			{
				Command_ShopMainMenu(Client);
			}
		}
	}
	else if(action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}


public Command_GrenadeShop(Client)
{
	new Handle:shop = CreateMenu(Menu_GrenadeShop);
	SetMenuTitle(shop, "-- 수류탄 상점 --");
	AddMenuItem(shop, "4000", "수류탄 : 1개(4000$)");
	AddMenuItem(shop, "6000", "얼음탄 : 1개(6000$)");
	AddMenuItem(shop, "6000", "화염병 : 1개(6000$)");
	AddMenuItem(shop, "3000", "신호탄 : 1개(3000$)");
	SetMenuExitButton(shop, true);
	SetMenuExitBackButton(shop, true);
	DisplayMenu(shop, Client, 15);
}

public Menu_GrenadeShop(Handle:menu, MenuAction:action, Client, Select)
{
	if(action == MenuAction_Select)
	{
 		new String:info[256];
		GetMenuItem(menu, Select, info, sizeof(info));
		new Cash = StringToInt(info);
		if(GetEntProp(Client, Prop_Send, "m_iAccount") >= Cash)
		{
			SetEntProp(Client, Prop_Send, "m_iAccount", GetEntProp(Client, Prop_Send, "m_iAccount") - Cash);
			if(Select == 0) GiveHegrenade(Client, 1);
			if(Select == 1) GiveSmokegrenade(Client, 1);
			if(Select == 2) GiveFire(Client, 1);
			if(Select == 3) GiveFlashBang(Client, 1);
		}
		else PrintToChat(Client, "돈이 부족합니다");
	}
	if(action == MenuAction_Cancel)
		if(Select == MenuCancel_ExitBack)
		Command_ShopMainMenu(Client);
}

stock GiveHegrenade(Client, value)
{
	GivePlayerItem(Client, "weapon_hegrenade");
}

stock GiveSmokegrenade(Client, value)
{
	GivePlayerItem(Client, "weapon_smokegrenade");
}

stock GiveFlashBang(Client, value)
{
	GivePlayerItem(Client, "weapon_flashbang");
}

stock GiveFire(Client, value)
{
	GivePlayerItem(Client, "weapon_molotov");
}

//패스트 키 옵션
public Command_PastOption(Client)
{
	new Handle:menu = CreateMenu(Menu_PastOption);

	SetMenuTitle(menu, "--== 단축키 설정 ==--");
	
	AddMenuItem(menu, "1", "쉬프트 단축키 온/오프");
	AddMenuItem(menu, "1", "단축키 F1 온/오프");

	SetMenuExitBackButton(menu, true);
	SetMenuExitButton(menu, true);

	DisplayMenu(menu, Client, MENU_TIME_FOREVER);
}

public Menu_PastOption(Handle:menu, MenuAction:action, Client, select)
{
	if(action == MenuAction_Select)
	{
		if(select == 0){
			if(PastKey[Client] == 2){
				PastKey[Client] = 1;
				PrintToChat(Client, "\x04[ZE] \x01- \x03쉬프트 단축키\x01가 \x04비활성화\x01 되었습니다.");
				SSave(Client);
				Command_PastOption(Client);
			}else{
				PastKey[Client] = 2;
				PrintToChat(Client, "\x04[ZE] \x01- \x03쉬프트 단축키\x01가 \x04활성화\x01 되었습니다.");
				SSave(Client);
				Command_PastOption(Client);
			}
		}
		if(select == 1){
			if(PastKey2[Client] == 2){
				PastKey2[Client] = 1;
				PrintToChat(Client, "\x04[ZE] \x01- \x03F1단축키\x01가 \x04비활성화\x01 되었습니다.");
				SSave(Client);
				Command_PastOption(Client);
			}else{
				PastKey2[Client] = 2;
				PrintToChat(Client, "\x04[ZE] \x01- \x03F1단축키\x01가 \x04활성화\x01 되었습니다.");
				SSave(Client);
				Command_PastOption(Client);
			}
		}
	}
	if(action == MenuAction_Cancel){
		if(select == MenuCancel_ExitBack){
			Command_ShopMainMenu(Client);
		}
	}
	if(action == MenuAction_End){
		CloseHandle(menu);
	}
}

public Action:cmdlistenernightvision(Client, const String:command[], arg)
{
	if(IsClientInGame(Client) == true)
	{
		if(PastKey[Client] == 2)
		{
			Command_ShopMainMenu(Client);
			return Plugin_Handled;
		}
		else
		{
			return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}

public Action:cmdlistenerautobuy(Client, const String:command[], arg)
{
	if(IsClientInGame(Client) == true)
	{
		if(PastKey2[Client] == 2)
		{
			Command_ShopMainMenu(Client);
			return Plugin_Handled;
		}
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

//접속 및 살아있는지 확인
stock bool:AllCheck(Client)
{
	if(Client > 0 && Client <= MaxClients)
	{
		if(IsClientConnected(Client) == true)
		{
			if(IsClientInGame(Client) == true)
			{
				if(IsPlayerAlive(Client) == true)
				{
					return true;
				}
				else
				{
					return false;
				}
			}
			else
			{	
				return false;	
			}
		}
		else
		{		
			return false;		
		}
	}
	else
	{		
		return false;		
	}
}

//접속 확인
stock bool:InCheck(Client)
{
	if(Client > 0 && Client <= MaxClients)
	{
		if(IsClientInGame(Client) == true)
		{
			return true;	
		}
		else
		{	
			return false;	
		}
		
	}
	else
	{
		return false;
	}
}

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
