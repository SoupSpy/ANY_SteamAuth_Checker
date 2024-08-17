#include <sourcemod>
#include <cstrike>
#include <SteamWorks>

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION "0.1.4"

public Plugin myinfo = 
{
	name = "[VX] SteamID Checker", 
	author = "Yekta.T", 
	description = "Oyuna giren kullanıcalar SteamID sine ulaşılamazsa kicklenir.", 
	version = PLUGIN_VERSION, 
	url = "vortexguys.com"
};

ConVar g_cPluginEnabled;

bool g_bPluginEnabled;
bool g_bSteamConnection = true;

static char g_sKickText[512] = "";

public void OnPluginStart()
{
	g_cPluginEnabled = CreateConVar("sm_vxauthcheck_enable", "1", "Plugini açar kapatır", _, true, 0.0, true, 1.0);
}

public void OnConfigsExecuted()
{
	g_bPluginEnabled = GetConVarBool(g_cPluginEnabled);
}

public void OnMapStart()
{
	char szMainPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, szMainPath, sizeof(szMainPath), "configs");
	
	Format(szMainPath, sizeof(szMainPath), "%s\\vx_authchecker.txt", szMainPath);
	
	g_sKickText = "\n";
	Handle hFile = INVALID_HANDLE;
	hFile = OpenFile(szMainPath, "r");
	
	if (hFile == INVALID_HANDLE)
	{
		g_sKickText = "\n- TR: - - - - - - - - - - - -\nSteam Kimliğinize ulaşamadık, lütfen tekrar deneyin.\n\n- EN: - - - - - - - - - - - -\nUnable to access your Steam identity, please try again.";
		LogError("[VX CHECK AUTH] FILE \"%s\" IS NOT FOUND!", szMainPath);
	} else
	{
		char buffer[128];
		while (!IsEndOfFile(hFile))
		{
			ReadFileLine(hFile, buffer, sizeof(buffer));
			StrCat(g_sKickText, 512, buffer);
		}
	}
}

public void OnClientPutInServer(int client)
{
	if (!g_bPluginEnabled || !g_bSteamConnection)return;
	VX_iBanCheck(client);
}

void VX_iBanCheck(int client)
{
	
	char steamid[64];
	bool id = GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));
	if (!id || (
			StrContains(steamid, "STEAM_ID_STOP_IGNORING_RETVALS", false) != -1
			 || StrContains(steamid, "STEAM_ID_STOP", false) != -1
			))
	{
		KickClient(client, g_sKickText);
	}
	return;
}


public void SteamWorks_SteamServersConnected()
{
	if (!g_bSteamConnection)
	{
		g_bSteamConnection = true;
	}
	LogMessage("VX-STEAMID-CHECKER: Connection to Steam Servers Success");
}

public void SteamWorks_SteamServersConnectFailure()
{
	if (g_bSteamConnection)
	{
		g_bSteamConnection = false;
	}
	LogMessage("VX-STEAMID-CHECKER: Connection to Steam Servers ERROR");
}

public void SteamWorks_SteamServersDisconnected()
{
	if (g_bSteamConnection)
	{
		g_bSteamConnection = false;
	}
	LogMessage("VX-STEAMID-CHECKER: Connection to Steam Servers ERROR");
} 