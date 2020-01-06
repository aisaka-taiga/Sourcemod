public Action:OnTakeDamageHook2(client, &attacker, &inflictor, &Float:damage, &damagetype)
{
	if(MaxClients >= attacker > 0 && MaxClients >= client > 0 && GetClientTeam(attacker) == 3)
	{
		if(GetClientTeam(client) == 2)
		{
			decl String:s_Weapon[32];
			GetClientWeapon(attacker, s_Weapon, 32);
			decl Float:clientposition[3], Float:targetposition[3], Float:vector[3];
			GetClientEyePosition(attacker, clientposition);
			GetClientEyePosition(client, targetposition);			
			MakeVectorFromPoints(clientposition, targetposition, vector);
			NormalizeVector(vector, vector);
			
			if(StrEqual(s_Weapon, "weapon_glock"))
			{
				if(GetEntityFlags(client) & FL_ONGROUND) //땅에 있을경우[글옵같은경우 넉백이 이상함..]
				{
					ScaleVector(vector, 500.0);
				}
				else //공중에 있을경우
				{
					ScaleVector(vector, 50.0);
				}
			}
			if(StrEqual(s_Weapon, "weapon_p250"))
			{
				if(GetEntityFlags(client) & FL_ONGROUND) //땅에 있을경우[글옵같은경우 넉백이 이상함..]
				{
					ScaleVector(vector, 500.0);
				}
				else //공중에 있을경우
				{
					ScaleVector(vector, 50.0);
				}
			}
			if(StrEqual(s_Weapon, "weapon_fiveseven"))
			{
				if(GetEntityFlags(client) & FL_ONGROUND) //땅에 있을경우[글옵같은경우 넉백이 이상함..]
				{
					ScaleVector(vector, 500.0);
				}
				else //공중에 있을경우
				{
					ScaleVector(vector, 50.0);
				}
			}
			if(StrEqual(s_Weapon, "weapon_deagle"))
			{
				if(GetEntityFlags(client) & FL_ONGROUND) //땅에 있을경우[글옵같은경우 넉백이 이상함..]
				{
					ScaleVector(vector, 500.0);
				}
				else //공중에 있을경우
				{
					ScaleVector(vector, 50.0);
				}
			}
			if(StrEqual(s_Weapon, "weapon_elite"))
			{
				if(GetEntityFlags(client) & FL_ONGROUND) //땅에 있을경우[글옵같은경우 넉백이 이상함..]
				{
					ScaleVector(vector, 500.0);
				}
				else //공중에 있을경우
				{
					ScaleVector(vector, 50.0);
				}
			}
			if(StrEqual(s_Weapon, "weapon_tec9"))
			{
				if(GetEntityFlags(client) & FL_ONGROUND) //땅에 있을경우[글옵같은경우 넉백이 이상함..]
				{
					ScaleVector(vector, 500.0);
				}
				else //공중에 있을경우
				{
					ScaleVector(vector, 50.0);
				}
			}
			if(StrEqual(s_Weapon, "weapon_hkp2000"))
			{
				if(GetEntityFlags(client) & FL_ONGROUND) //땅에 있을경우[글옵같은경우 넉백이 이상함..]
				{
					ScaleVector(vector, 500.0);
				}
				else //공중에 있을경우
				{
					ScaleVector(vector, 50.0);
				}
			}
			if(StrEqual(s_Weapon, "weapon_usp"))
			{
				if(GetEntityFlags(client) & FL_ONGROUND) //땅에 있을경우[글옵같은경우 넉백이 이상함..]
				{
					ScaleVector(vector, 500.0);
				}
				else //공중에 있을경우
				{
					ScaleVector(vector, 50.0);
				}
			}
			if(StrEqual(s_Weapon, "weapon_cz75"))
			{
				if(GetEntityFlags(client) & FL_ONGROUND) //땅에 있을경우[글옵같은경우 넉백이 이상함..]
				{
					ScaleVector(vector, 500.0);
				}
				else //공중에 있을경우
				{
					ScaleVector(vector, 50.0);
				}
			}
			if(StrEqual(s_Weapon, "weapon_mac10"))
			{
				if(GetEntityFlags(client) & FL_ONGROUND) //땅에 있을경우[글옵같은경우 넉백이 이상함..]
				{
					ScaleVector(vector, 500.0);
				}
				else //공중에 있을경우
				{
					ScaleVector(vector, 50.0);
				}
			}
			if(StrEqual(s_Weapon, "weapon_mp9"))
			{
				if(GetEntityFlags(client) & FL_ONGROUND) //땅에 있을경우[글옵같은경우 넉백이 이상함..]
				{
					ScaleVector(vector, 500.0);
				}
				else //공중에 있을경우
				{
					ScaleVector(vector, 50.0);
				}
			}
			if(StrEqual(s_Weapon, "weapon_mp7"))
			{
				if(GetEntityFlags(client) & FL_ONGROUND) //땅에 있을경우[글옵같은경우 넉백이 이상함..]
				{
					ScaleVector(vector, 500.0);
				}
				else //공중에 있을경우
				{
					ScaleVector(vector, 50.0);
				}
			}
			if(StrEqual(s_Weapon, "weapon_p90"))
			{
				if(GetEntityFlags(client) & FL_ONGROUND) //땅에 있을경우[글옵같은경우 넉백이 이상함..]
				{
					ScaleVector(vector, 500.0);
				}
				else //공중에 있을경우
				{
					ScaleVector(vector, 50.0);
				}
			}
			if(StrEqual(s_Weapon, "weapon_bizon"))
			{
				if(GetEntityFlags(client) & FL_ONGROUND) //땅에 있을경우[글옵같은경우 넉백이 이상함..]
				{
					ScaleVector(vector, 500.0);
				}
				else //공중에 있을경우
				{
					ScaleVector(vector, 50.0);
				}
			}
			if(StrEqual(s_Weapon, "weapon_nova"))
			{
				if(GetEntityFlags(client) & FL_ONGROUND) //땅에 있을경우[글옵같은경우 넉백이 이상함..]
				{
					ScaleVector(vector, 500.0);
				}
				else //공중에 있을경우
				{
					ScaleVector(vector, 50.0);
				}
			}
			if(StrEqual(s_Weapon, "weapon_xm1014"))
			{
				if(GetEntityFlags(client) & FL_ONGROUND) //땅에 있을경우[글옵같은경우 넉백이 이상함..]
				{
					ScaleVector(vector, 500.0);
				}
				else //공중에 있을경우
				{
					ScaleVector(vector, 50.0);
				}
			}
			if(StrEqual(s_Weapon, "weapon_sawedoff"))
			{
				if(GetEntityFlags(client) & FL_ONGROUND) //땅에 있을경우[글옵같은경우 넉백이 이상함..]
				{
					ScaleVector(vector, 500.0);
				}
				else //공중에 있을경우
				{
					ScaleVector(vector, 50.0);
				}
			}
			if(StrEqual(s_Weapon, "weapon_mag7"))
			{
				if(GetEntityFlags(client) & FL_ONGROUND) //땅에 있을경우[글옵같은경우 넉백이 이상함..]
				{
					ScaleVector(vector, 500.0);
				}
				else //공중에 있을경우
				{
					ScaleVector(vector, 50.0);
				}
			}
			if(StrEqual(s_Weapon, "weapon_famas"))
			{
				if(GetEntityFlags(client) & FL_ONGROUND) //땅에 있을경우[글옵같은경우 넉백이 이상함..]
				{
					ScaleVector(vector, 500.0);
				}
				else //공중에 있을경우
				{
					ScaleVector(vector, 50.0);
				}
			}
			if(StrEqual(s_Weapon, "weapon_galil"))
			{
				if(GetEntityFlags(client) & FL_ONGROUND) //땅에 있을경우[글옵같은경우 넉백이 이상함..]
				{
					ScaleVector(vector, 500.0);
				}
				else //공중에 있을경우
				{
					ScaleVector(vector, 50.0);
				}
			}
			if(StrEqual(s_Weapon, "weapon_ak47"))
			{
				if(GetEntityFlags(client) & FL_ONGROUND) //땅에 있을경우[글옵같은경우 넉백이 이상함..]
				{
					ScaleVector(vector, 500.0);
				}
				else //공중에 있을경우
				{
					ScaleVector(vector, 50.0);
				}
			}
			if(StrEqual(s_Weapon, "weapon_m4a4"))
			{
				if(GetEntityFlags(client) & FL_ONGROUND) //땅에 있을경우[글옵같은경우 넉백이 이상함..]
				{
					ScaleVector(vector, 500.0);
				}
				else //공중에 있을경우
				{
					ScaleVector(vector, 50.0);
				}
			}
			if(StrEqual(s_Weapon, "weapon_ssg08"))
			{
				if(GetEntityFlags(client) & FL_ONGROUND) //땅에 있을경우[글옵같은경우 넉백이 이상함..]
				{
					ScaleVector(vector, 500.0);
				}
				else //공중에 있을경우
				{
					ScaleVector(vector, 50.0);
				}
			}
			if(StrEqual(s_Weapon, "weapon_sg556"))
			{
				if(GetEntityFlags(client) & FL_ONGROUND) //땅에 있을경우[글옵같은경우 넉백이 이상함..]
				{
					ScaleVector(vector, 500.0);
				}
				else //공중에 있을경우
				{
					ScaleVector(vector, 50.0);
				}
			}
			if(StrEqual(s_Weapon, "weapon_aug"))
			{
				if(GetEntityFlags(client) & FL_ONGROUND) //땅에 있을경우[글옵같은경우 넉백이 이상함..]
				{
					ScaleVector(vector, 500.0);
				}
				else //공중에 있을경우
				{
					ScaleVector(vector, 50.0);
				}
			}
			if(StrEqual(s_Weapon, "weapon_g3sg1"))
			{
				if(GetEntityFlags(client) & FL_ONGROUND) //땅에 있을경우[글옵같은경우 넉백이 이상함..]
				{
					ScaleVector(vector, 500.0);
				}
				else //공중에 있을경우
				{
					ScaleVector(vector, 50.0);
				}
			}
			if(StrEqual(s_Weapon, "weapon_awp"))
			{
				if(GetEntityFlags(client) & FL_ONGROUND) //땅에 있을경우[글옵같은경우 넉백이 이상함..]
				{
					ScaleVector(vector, 500.0);
				}
				else //공중에 있을경우
				{
					ScaleVector(vector, 50.0);
				}
			}
			if(StrEqual(s_Weapon, "weapon_scar"))
			{
				if(GetEntityFlags(client) & FL_ONGROUND) //땅에 있을경우[글옵같은경우 넉백이 이상함..]
				{
					ScaleVector(vector, 500.0);
				}
				else //공중에 있을경우
				{
					ScaleVector(vector, 50.0);
				}
			}
			if(StrEqual(s_Weapon, "weapon_m4a1"))
			{
				if(GetEntityFlags(client) & FL_ONGROUND) //땅에 있을경우[글옵같은경우 넉백이 이상함..]
				{
					ScaleVector(vector, 500.0);
				}
				else //공중에 있을경우
				{
					ScaleVector(vector, 50.0);
				}
			}
			if(StrEqual(s_Weapon, "weapon_m249"))
			{
				if(GetEntityFlags(client) & FL_ONGROUND) //땅에 있을경우[글옵같은경우 넉백이 이상함..]
				{
					ScaleVector(vector, 500.0);
				}
				else //공중에 있을경우
				{
					ScaleVector(vector, 50.0);
				}
			}
			if(StrEqual(s_Weapon, "weapon_negev"))
			{
				if(GetEntityFlags(client) & FL_ONGROUND) //땅에 있을경우[글옵같은경우 넉백이 이상함..]
				{
					ScaleVector(vector, 700.0);
				}
				else //공중에 있을경우
				{
					ScaleVector(vector, 65.0);
				}
			}
			if(StrEqual(s_Weapon, "weapon_hegrenade"))
			{
				if(GetEntityFlags(client) & FL_ONGROUND) //땅에 있을경우[글옵같은경우 넉백이 이상함..]
				{
					ScaleVector(vector, 500.0);
				}
				else //공중에 있을경우
				{
					ScaleVector(vector, 50.0);
				}
			}
			if(StrEqual(s_Weapon, "weapon_molotov"))
			{
				if(GetEntityFlags(client) & FL_ONGROUND) //땅에 있을경우[글옵같은경우 넉백이 이상함..]
				{
					ScaleVector(vector, 500.0);
				}
				else //공중에 있을경우
				{
					ScaleVector(vector, 50.0);
				}
			}
			if(StrEqual(s_Weapon, "weapon_incgrenade"))
			{
				if(GetEntityFlags(client) & FL_ONGROUND) //땅에 있을경우[글옵같은경우 넉백이 이상함..]
				{
					ScaleVector(vector, 500.0);
				}
				else //공중에 있을경우
				{
					ScaleVector(vector, 50.0);
				}
			}
		}
	}
	return Plugin_Continue;
}