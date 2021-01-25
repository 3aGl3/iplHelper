--[[
- Provides functionality for consistently loading and unloading IPL/YMAP files
-
-	@author: 3aGl3
-	@team: SOG Modding
-
-	@project: IPL Helper
-	@website: http://sogmods.net/
-
]]
-- setup tables to store temporary data
local LoadedIPLFiles = {}	-- holds all loaded IPL files, to load on new clients

-- register events
RegisterServerEvent( "_IplHelper:RequestAllIPL" )

----
-- Basic functions

--[[
- Sends the given IPL Request to all, or the given, clients and saves it as loaded
]]
function RequestIpl( name, client )
	assert( type(name) == "string", "Expected string as argument 1 for function RequestIpl, got ".. type(name) )
	assert( not client or type(client) == "number", "Expected number as argument 2 for function RequestIpl, got ".. type(client) )

	-- send to the given client, if any
	if client then
		TriggerClientEvent( "_IplHelper:RequestIPL", client, name )
	else
		TriggerClientEvent( "_IplHelper:RequestIPL", -1, name )
		LoadedIPLFiles[name] = true
	end
end		-- [[ RequestIpl ]]

--[[
- Sends the given IPL delete to all, or the given, clients and removes it's loaded status
]]
function RemoveIpl( name, client )
	assert( type(name) == "string", "Expected string as argument 1 for function RemoveIpl, got ".. type(name) )
	assert( not client or type(client) == "number", "Expected number as argument 2 for function RequestIpl, got ".. type(client) )

	-- send to the given client, if any
	if client then
		TriggerClientEvent( "_IplHelper:RemoveIPL", client, name )
	else
		TriggerClientEvent( "_IplHelper:RemoveIPL", -1, name )
		LoadedIPLFiles[name] = false
	end
end		--[[ RemoveIpl ]]

--[[
- Returns true if the IPL is loaded, false otherwise
]]
function IsIplActive( name )
	assert( type(name) == "string", "Expected string as argument 1 for function IsIplActive, got ".. type(name) )

	return LoadedIPLFiles[name]
end		--[[ IsIplActive ]]

----
-- Resource start and stop

--[[
- Loads default IPL files as defined in defaultipls.json
]]
local function OnResourceStart( name )
	if name == GetCurrentResourceName() then
		iprint( "Starting IPL Helper, loading default IPL files..." )
		local fcontent = LoadResourceFile( "iplHelper", "defaultipls.json" )
		if fcontent then
			local data = json.decode( fcontent )
			for ipl, load in pairs(data) do
				if load then
					iprint( "Loading IPL file automatically: ".. ipl )
					RequestIpl( ipl )
				else
					iprint( "Unloading IPL file automatically: ".. ipl )
					RemoveIpl( ipl )
				end
			end
		else
			iprint( "Can't load defaultipls.json, not loading any IPL files." )
		end
	end
end		--[[ OnResourceStart ]]
AddEventHandler( "onResourceStart", OnResourceStart )

--[[
- Unloads all IPL files when the resource stops
]]
local function OnClientRequestAllIPL()
	iprint( "Client(".. source ..") requesting IPL files." )
	for ipl,load in pairs(LoadedIPLFiles) do
		if load then
			RequestIpl( ipl, source )
		else
			RemoveIpl( ipl, source )
		end
	end
end		--[[ OnClientRequestAllIPL ]]
AddEventHandler( "_IplHelper:RequestAllIPL", OnClientRequestAllIPL )

----
-- Admin commands

--[[
- Admin command to manually load IPL files
]]
local function LoadIpl( pid, args, cmdstr )
	-- go through all arguments and try to load the IPL files
	for i,arg in ipairs(args) do
		-- check if the IPL is already loaded
		if not IsIplActive( arg ) then
			iprint( "Loading IPL manually: ".. arg )
			RequestIpl( arg )
		else
			iprint( "The IPL is already loaded." )
		end
	end
end		--[[ LoadIpl ]]
RegisterCommand( "loadipl", LoadIpl, true )

--[[
- Admin command to manually unload IPL files
]]
local function UnloadIpl( pid, args, cmdstr )
	-- go through all arguments and try to load the IPL files
	for i,arg in ipairs(args) do
		-- check if the IPL is loaded
		if IsIplActive( arg ) then
			iprint( "Unloading IPL manually: ".. arg )
			RemoveIpl( arg )
		else
			iprint( "This IPL was not loaded by IPL helper." )
		end
	end
end		--[[ UnloadIpl ]]
RegisterCommand( "unloadipl", UnloadIpl, true )

----
-- common functions
--[[
- Pretty prints a message to the console and log
]]
function iprint( msg, ... )
	local arg = { ... }

	-- check if we gave a verbose level as first argument
	if type(msg) == "number" and arg[1] then
		-- check if the given verbose level is higher than what's set as convar
		if msg > GetConvatInt("scr_verbose", 0) then
			return
		end
		-- set the first argument as message
		msg = arg[1]
		table.remove( arg, 1 )
	end

	-- check if there is a message and print it, after formatting
	if msg and msg ~= "" then
		-- Output the message as "[Resource] message \new line"
		Citizen.Trace( msg:format( table.unpack(arg) ) .. "\n" )
	end
end		--[[ iprint ]]
