#include <sourcemod>
#include <cstrike>

public Plugin:myinfo =
{
	name = "money reset",
	author = "타이가",
	description = "스폰시 달러 16000원으로 설정",
	version = "0.1",
	url = "https://github.com/aisaka-taiga/"
};

public OnPluginStart()
{
	HookEvent("player_spawn", EventSpawn);
}

public Action:EventSpawn(Handle:event, String:Name[], bool:dontBroadcast)
{
	new Client = GetClientOfUserId(GetEventInt(event, "userid"));
	new Money = GetEntProp(Client, Prop_Send, "m_iAccount")
	Money = 16000;
	SetEntProp(Client, Prop_Send, "m_iAccount", Money);
}
