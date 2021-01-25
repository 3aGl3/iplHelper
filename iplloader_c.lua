--[[
- Loads any IPL files as advised by the server
-
-	@author: 3aGl3
-	@team: SOG Modding
-
-	@project: IPL Helper
-	@website: http://sogmods.net/
-
]]
-- register networking events
RegisterNetEvent( "_IplHelper:RequestIPL" )
RegisterNetEvent( "_IplHelper:RemoveIPL" )

--[[
- Handles requests by the server to request the given IPL file
]]
local function OnServerRequestIPL( name )
	Citizen.Trace( "Received IPL Request from Server: ".. name .."\n" )

	-- check if the IPL isn't already active, then load it
	if not IsIplActive(name) then
		RequestIpl(name)
	end
end		--[[ OnServerRequestIPL ]]
AddEventHandler( "_IplHelper:RequestIPL", OnServerRequestIPL )

--[[
- Handles requests by the server to remove the given IPL file
]]
local function OnServerRemoveIPL( name )
	Citizen.Trace( "Received IPL Remove from Server: ".. name .."\n" )

	-- check if the IPL is even active, then remove it
	if IsIplActive(name) then
		RemoveIpl(name)
	end
end		--[[ OnServerRemoveIPL ]]
AddEventHandler( "_IplHelper:RemoveIPL", OnServerRemoveIPL )

--[[
- Requests all currently loaded IPL files from the server when the resource starts
]]
local function OnClientResourceStart( name )
	if name == GetCurrentResourceName() then
		Citizen.Trace( "Starting IPL Helper, requesting current IPL files...\n" )
		TriggerServerEvent( "_IplHelper:RequestAllIPL" )
	end
end		--[[ OnClientResourceStart ]]
AddEventHandler( "onClientResourceStart", OnClientResourceStart )
