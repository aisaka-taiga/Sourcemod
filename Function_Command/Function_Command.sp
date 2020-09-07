new String:SN[18] = "SM"; // 프리픽스

#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include "sdkhooks"

public Plugin:myinfo =
{
	name = "Function command Plugin For Taig1a",
	author = "타이가",
	description = "Sex",
	version = "0.1",
	url = "http://cafe.naver.com/taigarpg"
};

public OnPluginStart()
{
	LoadTranslations("common.phrases");
	RegAdminCmd("sm_spec", Command_Move, ADMFLAG_GENERIC, "플레이어를 스펙팀으로 이동시킵니다");
	RegAdminCmd("sm_ter", Command_Move1, ADMFLAG_GENERIC, "플레이어를 테러팀으로 이동시킵니다");	
	RegAdminCmd("sm_cont", Command_Move2, ADMFLAG_GENERIC, "플레이어를 대테러팀으로 이동시킵니다");	
	RegAdminCmd("sm_respawn", Command_respawn, ADMFLAG_GENERIC, "플레이어를 부활 시킵니다");	
	RegAdminCmd("sm_hp", Command_hpup, ADMFLAG_GENERIC, "플레이어의 체력을 바꿉니다");	
}
//
public Action:Command_Move(client, args)
{
	if (args < 1)
	{
		PrintToChat(client, "\x03[%s] - \x01!sepc \"닉네임\"", SN);
		return Plugin_Handled;
	}
	
	
	decl String:arg1[65];
	GetCmdArg(1, arg1, sizeof(arg1));

	new target = FindTarget(client, arg1);
	if (target == -1)
	{
		return Plugin_Handled;
	}

	PrintToChatAll("\x04%N님이 %N님에 의해 관전으로 이동되었습니다.", target, client);
	ChangeClientTeam(target, 0);
	ClientCommand(target, "kill");
	return Plugin_Handled;
}

public Action:Command_Move1(client, args)
{
	if (args < 1)
	{
		PrintToChat(client, "\x03[%s] - \x01!ter \"닉네임\"", SN);
		return Plugin_Handled;
	}
	
	decl String:arg1[65];
	GetCmdArg(1, arg1, sizeof(arg1));

	new target = FindTarget(client, arg1);
	if (target == -1)
	{
		return Plugin_Handled;
	}
	
	PrintToChatAll("\x04%N님이 %N님에 의해 테러리스트로 이동되었습니다.", target, client);
	ChangeClientTeam(target, 2);
	ClientCommand(target, "kill");
	return Plugin_Handled;
}

public Action:Command_Move2(client, args)
{
	if (args < 1)
	{
		PrintToChat(client, "\x03[%s] - \x01!cont \"닉네임\"", SN);
		return Plugin_Handled;
	}
	
	decl String:arg1[65];
	GetCmdArg(1, arg1, sizeof(arg1));

	new target = FindTarget(client, arg1);
	if (target == -1)
	{
		return Plugin_Handled;
	}

	PrintToChatAll("\x04%N님이 %N님에 의해 대테러리스트로 이동되었습니다.", target, client);
	ChangeClientTeam(target, 3);
	ClientCommand(target, "kill");
	return Plugin_Handled;
}

public Action:Command_respawn(client, args)
{
	if (args < 1)
	{
		PrintToChat(client, "\x03[%s] - \x01!respawn \"닉네임\"", SN);
		return Plugin_Handled;
	}
	
	decl String:arg1[65];
	GetCmdArg(1, arg1, sizeof(arg1));

	new target = FindTarget(client, arg1);
	if (target == -1)
	{
		return Plugin_Handled;
	}
	if(!IsPlayerAlive(target))
	{
		PrintToChatAll("\x04%N님이 %N님에 의해 부활하였습니다.", target, client);
		CS_RespawnPlayer(target);
	}
	else
	{
		PrintToChat(client,"대상이 이미 살아있습니다.");
	}
	return Plugin_Handled;
}


public Action:Command_hpup(client, args)
{
	if (args < 1)
	{
		PrintToChat(client, "\x03[%s] - \x01!hp \"닉네임\" \"체력\"", SN);
		return Plugin_Handled;
	}
	
	decl String:arg1[65], String:arg2[32], HP;
	GetCmdArg(1, arg1, sizeof(arg1));
	GetCmdArg(2, arg2, sizeof(arg2));
	StringToIntEx(arg2, HP);

	new target = FindTarget(client, arg1);
	if (target == -1)
	{
		return Plugin_Handled;
	}
	if(IsPlayerAlive(target))
	{
		PrintToChatAll("\x04%N님이 %N님의 체력을 %d로 변경함", target, client, HP);
		SetEntityHealth(target, HP);
	}
	else
	{
		PrintToChat(client,"대상이 사망한 상태입니다.");
	}
	return Plugin_Handled;
}

