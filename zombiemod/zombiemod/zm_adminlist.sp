#include <sourcemod>

new Handle:AdminListMode = INVALID_HANDLE;
new Handle:AdminListMenu = INVALID_HANDLE;

public Plugin:myinfo = 
{
	name = "어둠人 리스트",
	author = "타이가",
	description = "어드민 리스트",
	version = "0.1",
	url = "None"
}

public Action:SayHook(client, args)
{
	new String:text[192];
	GetCmdArgString(text, sizeof(text));
		
	new startidx = 0;
	if (text[0] == '"')
	{
		startidx = 1;
			
		new len = strlen(text);
		if (text[len-1] == '"')
		{
			text[len-1] = '\0';
		}
	}
		
	if(StrEqual(text[startidx], "!어드민목록") || StrEqual(text[startidx], "/어드민리스트"))
	{
		switch(GetConVarInt(AdminListMode))
		{
			case 1:
			{
				decl String:AdminNames[MAXPLAYERS+1][MAX_NAME_LENGTH+1];
				new count = 0;
				for(new i = 1 ; i <= GetMaxClients();i++)
				{
					if(IsClientInGame(i))
					{
						new AdminId:AdminID = GetUserAdmin(i);
						if(AdminID != INVALID_ADMIN_ID)
							{
							GetClientName(i, AdminNames[count], sizeof(AdminNames[]));
							count++;
						}
					} 
				}
				decl String:buffer[1024];
				ImplodeStrings(AdminNames, count, ",", buffer, sizeof(buffer));
				PrintToChatAll("\x04어드민: %s", buffer);
			}
			case 2:
			{
				decl String:AdminName[MAX_NAME_LENGTH];
				AdminListMenu = CreateMenu(MenuListHandler);
				SetMenuTitle(AdminListMenu, "어드민 온라인:");
								
				for(new i = 1; i <= GetMaxClients(); i++)
				{
					if(IsClientInGame(i))
					{
						new AdminId:AdminID = GetUserAdmin(i);
						if(AdminID != INVALID_ADMIN_ID)
						{
							GetClientName(i, AdminName, sizeof(AdminName));
							AddMenuItem(AdminListMenu, AdminName, AdminName);
						}
					} 
				}
				SetMenuExitButton(AdminListMenu, true);
				DisplayMenu(AdminListMenu, client, 15);
			}
		}
	}
	return Plugin_Continue;
}public MenuListHandler(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		CloseHandle(menu);
	}
	else if (action == MenuAction_Cancel)
	{
		CloseHandle(menu);
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}