--
-- The server only runs this file so it can send it to the client
--

if ( SERVER ) then AddCSLuaFile( "utilities_menu.lua" ) return end


local function Undo( CPanel )

	-- This is added by the undo module dynamically
	
end

local function User_Cleanup( CPanel )

	-- This is added by the cleanup module dynamically
	
end


--[[
-- Tool Menu
--]]
local function PopulateUtilityMenus()
	spawnmenu.AddToolMenuOption( "Utilities", "User", "User_Cleanup",	"#spawnmenu.utilities.cleanup", "", "", User_Cleanup )
	spawnmenu.AddToolMenuOption( "Utilities", "User", "Undo",			"#spawnmenu.utilities.undo", "", "", Undo )
end

hook.Add( "PopulateToolMenu", "PopulateUtilityMenus", PopulateUtilityMenus )

--[[ 
-- Categories
--]]
local function CreateUtilitiesCategories()

	spawnmenu.AddToolCategory( "Utilities", 	"User", 	"#spawnmenu.utilities.user" )

end	

hook.Add( "AddToolMenuCategories", "CreateUtilitiesCategories", CreateUtilitiesCategories )