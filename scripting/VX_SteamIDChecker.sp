#include <sourcemod>
#include <cstrike>
//#include <csteamid>
#include <SteamWorks>

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION "0.1.1"

public Plugin myinfo = 
{
    name = "[VX] SteamID Checker", 
    author = "SoupSpy!#5006", 
    description = "Steam bağlantısı kopmuş kişiler oyuna alınmaz.", 
    version = PLUGIN_VERSION, 
    url = ""
};

ConVar g_cPluginEnabled;
bool g_bPluginEnabled;

char g_szPath[PLATFORM_MAX_PATH];

char g_sKickText[512] = "";

public void OnPluginStart()
{
    g_cPluginEnabled = CreateConVar("sm_vxauthcheck_enable", "1", "Plugini açar kapatır", _, true, 0.0, true, 1.0);
}

public void OnConfigsExecuted()
{
    g_bPluginEnabled = GetConVarBool(g_cPluginEnabled);
    
    char szMainPath[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, szMainPath, sizeof(szMainPath), "configs");
    
    Format(g_szPath, sizeof(g_szPath), "%s\\vx_authchecker.txt", szMainPath);
    
    g_sKickText = "\n";
    Handle hFile = INVALID_HANDLE;
    hFile = OpenFile(g_szPath, "r");
    
    if (hFile == INVALID_HANDLE)
    {
        g_sKickText = "\n- TR: - - - - - - - - - - - -\nSteam Doğrulamanısını Geçemediniz, lütfen tekrar deneyin\n\n- EN: - - - - - - - - - - - -\nYou couldn't pass the steam authenticator, please try again later";
        PrintToServer("[VX CHECK AUTH] %s IS NOT FOUND!", g_szPath);
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

bool g_serverSteamConnection = true;
char g_sClientAuth[MAXPLAYERS + 1][21];

public void OnClientAuthorized(int client, const char[] auth)
{
    if (g_bPluginEnabled)
        strcopy(g_sClientAuth[client], 21, auth);
}

public void OnClientPutInServer(int client)
{
    if (g_bPluginEnabled == true && g_serverSteamConnection && strcmp(g_sClientAuth[client], "", false) == 0)
        KickClient(client, g_sKickText);
}

public void OnClientDisconnect(int client)
{
    if (g_bPluginEnabled)
        g_sClientAuth[client] = "";
}

public int SteamWorks_SteamServersConnected()
{
    if (!g_serverSteamConnection)
        g_serverSteamConnection = true;
}

public int SteamWorks_SteamServersConnectFailure()
{
    if (g_serverSteamConnection)
        g_serverSteamConnection = false;
}

public int SteamWorks_SteamServersDisconnected()
{
    if (g_serverSteamConnection)
        g_serverSteamConnection = false;
}

stock bool IsClientValid(int id)
{
    if (id > 0 && id <= MaxClients && IsClientConnected(id) && IsClientInGame(id) && !IsFakeClient(id))
        return true;
    return false;
}


