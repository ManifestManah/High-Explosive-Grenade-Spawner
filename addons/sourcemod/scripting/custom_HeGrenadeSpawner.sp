// List of Includes
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

// The code formatting rules we wish to follow
#pragma semicolon 1;
#pragma newdecls required;


// The retrievable information about the plugin itself 
public Plugin myinfo =
{
	name		= "[CS:GO] High Explosive Grenade Spawner",
	author		= "Manifest @Road To Glory",
	description	= "Spawns High Explosive Grenades around on the map.",
	version		= "V. 1.0.0 [Beta]",
	url			= ""
};



//////////////////////////
// - Forwards & Hooks - //
//////////////////////////


// This happens when the plugin is loaded
public void OnPluginStart()
{
	// Hooks the event that we intend to use in our plugin
	HookEvent("round_start", Event_RoundStart, EventHookMode_Post);

	RegAdminCmd("sm_position", Command_Position, ADMFLAG_GENERIC);
}


// This happens when a new map is loaded
public void OnMapStart()
{
	// Calls upon our SpawnEntity function to place entities around the map
	SpawnEntity();
}



//////////////////
// - Commands - //
//////////////////


public Action Command_Position(int client, int args)
{
	// Creates a variable named PlayerLocation which we will use to store data within
	char CurrentMapName[64];

	float PlayerPosition[3];

	GetCurrentMap(CurrentMapName, sizeof(CurrentMapName));

	GetClientAbsOrigin(client, PlayerPosition);

	PrintToChat(client, "Look in the console for the coordinate output.");

	PrintToConsole(client, "");
	PrintToConsole(client, "");
	PrintToConsole(client, "");
	PrintToConsole(client, "    \"KeyNameExample\"");
	PrintToConsole(client, "    {");
	PrintToConsole(client, "        \"map\"    \"%s\"", CurrentMapName);
	PrintToConsole(client, "");
	PrintToConsole(client, "        \"location_x\"               \"%0.2f\"", PlayerPosition[0]);
	PrintToConsole(client, "        \"location_y\"               \"%0.2f\"", PlayerPosition[1]);
	PrintToConsole(client, "        \"location_z\"               \"%0.2f\"", PlayerPosition[2]);
	PrintToConsole(client, "    }");
	PrintToConsole(client, "");
	PrintToConsole(client, "");
	PrintToConsole(client, "");
}



////////////////
// - Events - //
////////////////


// This happens whenever a new round starts
public Action Event_RoundStart(Handle event, const char[] name, bool dontBroadcast)
{
	// Calls upon our SpawnEntity function to place entities around the map
	SpawnEntity();
}



///////////////////////////
// - Regular Functions - //
///////////////////////////


// This function is called upon whenever a new round starts or a new map is loaded
void SpawnEntity()
{
	// Creates a variable named CurerntMapName
	char CurrentMapName[64];

	// Obtains the name of the current map and st ore it within our CurrentMapName variable
	GetCurrentMap(CurrentMapName, sizeof(CurrentMapName));

	// Creates a KeyValue structure which we store within our handle named kv
	Handle kv = CreateKeyValues("SpawnedHeGrenades");

	// Defines the destination and used file of our located keyvalue tree 
	FileToKeyValues(kv, "addons/sourcemod/configs/custom_HeGrenadeSpawner.txt");

	// If there isn't a first sub key then execute this section
	if(!KvGotoFirstSubKey(kv))
	{
		return;
	}

	// Loops through all the sub keys
	do
	{
		// Creates a variable named KeyValueSection which we will use to store data within
		char KeyValueSection[32];

		// Creates a variable named KeyValueMapName which we will use to store data within
		char KeyValueMapName[PLATFORM_MAX_PATH];

		// Obtains the name of the KeyValue trees section and store it within the kv handle
		KvGetSectionName(kv, KeyValueSection, sizeof(KeyValueSection));

		// Obtains the string value that is stored within our sub key value "map" and store it within our variable named KeyValueMapName
		KvGetString(kv, "map", KeyValueMapName, sizeof(KeyValueMapName));

		// If the current map contains the same name as the data that was stored within our KeyValueMapName variable then execute this section
		if(StrContains(CurrentMapName, KeyValueMapName, false) != -1)
		{
			// Obtains the values stored within our keyvalues, x_coord, y_coord and z_coord and store them within our variables KeyValueX, KeyValueY, and KeyValueZ respectively
			float KeyValueX = KvGetFloat(kv, "location_x");
			float KeyValueY = KvGetFloat(kv, "location_y");
			float KeyValueZ = KvGetFloat(kv, "location_z");

			KeyValueZ += 3.0;

			// Creates and places an entity at the defined X, Y, Z coordinate location within the map / level
			PlaceEntity(KeyValueX, KeyValueY, KeyValueZ);
		}
	}

	while (KvGotoNextKey(kv));

	// Closes our kv handle once we are done using it
	CloseHandle(kv);
}


// We call upon this function to add a death to the player's already saved death stat
public void PlaceEntity(float x_coordinate, float y_coordinate, float z_coordinate)
{
	// Creates a prop_dynamic and store the entity's index within our entity variable
	int entity = CreateEntityByName("weapon_hegrenade");

	// If the entity meets our criteria for validation then execute this section
	if(IsValidEntity(entity))
	{
		// Creates a variable named Location which we will use to store data within
		float Location[3];

		// Changes our location by modifying our X, Y and Z coordinate values
		Location[0] = x_coordinate;
		Location[1] = y_coordinate;
		Location[2] = z_coordinate;

		// Spawns the entity
		DispatchSpawn(entity);

		// Moves our entity to the location coordinates and rotates the entity accordingly
		TeleportEntity(entity, Location, NULL_VECTOR, NULL_VECTOR);
	}
}
