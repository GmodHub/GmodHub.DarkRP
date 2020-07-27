--[[---------------------------------------------------------
	If false is returned then the spawn menu is never created.
	This saves load times if your mod doesn't actually use the
	spawn menu for any reason.
-----------------------------------------------------------]]
function GM:SpawnMenuEnabled()
	return true
end


--[[---------------------------------------------------------
  Called when spawnmenu is trying to be opened.
   Return false to dissallow it.
-----------------------------------------------------------]]
function GM:SpawnMenuOpen()
	return true
end

--[[---------------------------------------------------------
  Called when context menu is trying to be opened.
   Return false to dissallow it.
-----------------------------------------------------------]]
function GM:ContextMenuOpen()
	return true
end


--[[---------------------------------------------------------
  Backwards compatibility. Do Not Use!!!
-----------------------------------------------------------]]
function GM:GetSpawnmenuTools(name)
	return spawnmenu.GetToolMenu(name)
end


--[[---------------------------------------------------------
  Backwards compatibility. Do Not Use!!!
-----------------------------------------------------------]]
function GM:AddSTOOL(category, itemname, text, command, controls, cpanelfunction)
	self:AddToolmenuOption('Main', category, itemname, text, command, controls, cpanelfunction)
end


--[[---------------------------------------------------------
	Don't hook or override this function.
	Hook AddToolMenuTabs instead!
-----------------------------------------------------------]]
function GM:AddGamemodeToolMenuTabs( )

	-- This is named like this to force it to be the first tab
	spawnmenu.AddToolTab('Main', 		'#spawnmenu.tools_tab', 'icon16/wrench.png')
	spawnmenu.AddToolTab('Utilities', 	'#spawnmenu.utilities_tab', 'icon16/page_white_wrench.png')

end

--[[---------------------------------------------------------
	Add your custom tabs here.
-----------------------------------------------------------]]
function GM:AddToolMenuTabs()

	-- Hook me!

end

--[[---------------------------------------------------------
	Add categories to your tabs
-----------------------------------------------------------]]
function GM:AddGamemodeToolMenuCategories()
	spawnmenu.AddToolCategory('Main', 	'Constraints', 			'#spawnmenu.tools.constraints')
	spawnmenu.AddToolCategory('Main', 	'Construction',			'#spawnmenu.tools.construction')
	spawnmenu.AddToolCategory('Main', 	'Appearance',			'Appearance')
	spawnmenu.AddToolCategory('Main', 	'Roleplay',				'Roleplay')
	spawnmenu.AddToolCategory('Main', 	'Easy Fading Doors',	'Easy Fading Doors')
	spawnmenu.AddToolCategory('Main', 	'Adv Fading Doors',	'Adv Fading Doors')
	spawnmenu.AddToolCategory('Main', 	'VIP+', 				'VIP+')
	spawnmenu.AddToolCategory('Main', 	'Staff', 				'Staff')
end


--[[---------------------------------------------------------
	Add categories to your tabs
-----------------------------------------------------------]]
function GM:AddToolMenuCategories()

	-- Hook this function to add custom stuff

end

--[[---------------------------------------------------------
	Add categories to your tabs
-----------------------------------------------------------]]
function GM:PopulatePropMenu()

	-- This function makes the engine load the spawn menu text files.
	-- We call it here so that any gamemodes not using the default
	-- spawn menu can totally not call it.
	spawnmenu.PopulateFromEngineTextFiles()

end



--[[

	All of this model search stuff is due for an update to speed it up
	So don't rely on any of this code still being here.

--]]

local ModelIndex = {}
local ModelIndexTimer = CurTime()

local function BuildModelIndex(dir)

	-- Add models from this folder
	local files = file.Find(dir .. '*', 'GAME')
	for k, v in ipairs(files) do

		if (v:sub(-4, -1) == '.mdl') then

			-- Filter out some of the un-usable crap
			if (!v:find('_gestures') &&
				!v:find('_anim') &&
				!v:find('_gst') &&
				!v:find('_pst') &&
				!v:find('_shd') &&
				!v:find('_ss') &&
				!v:find('cs_fix') &&
				!v:find('_anm' )) then

				table.insert(ModelIndex, (dir .. v):lower())

			end

		elseif (v:sub(-4, -4) != '.') then

			--BuildModelIndex(dir..v..'/')

			-- Stagger the loading so we don't block.
			-- This means that the data is inconsistent at first
			-- but it's better than adding 5 seconds onto loadtime
			-- or pausing for 5 seconds on the first search
			-- or dumping all this to a text file and loading it
			ModelIndexTimer = ModelIndexTimer + 0.02
			timer.Simple(ModelIndexTimer - CurTime(), function() BuildModelIndex(dir..v..'/') end)

		end

	end

end



--[[---------------------------------------------------------
  Called by the toolgun to add a STOOL
-----------------------------------------------------------]]
function GM:DoModelSearch(str)

	local ret = {}

	if (#ModelIndex == 0) then
		ModelIndexTimer = CurTime()
		BuildModelIndex('models/')
	end

	if (str:len() < 3) then

		table.insert(ret, 'Enter at least 3 characters')

	else

		str = str:lower()

		for k, v in ipairs(ModelIndex) do

			if (v:find(str)) then

				table.insert(ret, v)

			end

		end

	end

	return ret

end


cvar.Register 'sup_saved_props'
	:SetDefault({}, true)

local saved_map = {}

for k, v in ipairs(cvar.GetValue('sup_saved_props')) do
	saved_map[v.model] = k
end

hook('PopulatePropMenu', 'rp.SavedProps', function()
	spawnmenu.AddPropCategory('Saved Props', 'Saved Props', cvar.GetValue('sup_saved_props'), 'icon16/heart.png', 999, 0)
end)

spawnmenu.AddContentType('model', function(container, obj)
	local icon = vgui.Create('SpawnIcon', container)

	if (obj.body) then
		obj.body = string.Trim(tostring(obj.body), 'B')
	end

	if (obj.wide) then
		icon:SetWide(obj.wide)
	end

	if (obj.tall) then
		icon:SetTall(obj.tall)
	end

	icon:InvalidateLayout(true)
	icon:SetModel(obj.model, obj.skin or 0, obj.body)
	icon:SetTooltip(string.Replace(string.GetFileFromFilename(obj.model), '.mdl', ''))
	icon.DoClick = function(icon ) surface.PlaySound('ui/buttonclickrelease.wav') RunConsoleCommand('gm_spawn', icon:GetModelName(), icon:GetSkinID() or 0, icon:GetBodyGroup() or '') end
	icon.OpenMenu = function(icon)
		local menu = DermaMenu()
		menu:AddOption('Copy to Clipboard', function() SetClipboardText(string.gsub(obj.model, '\\', '/')) end)
		menu:AddOption('Spawn using Toolgun', function() RunConsoleCommand('gmod_tool', 'creator' ) RunConsoleCommand('creator_type', '4') RunConsoleCommand('creator_name', obj.model) end)

		menu:AddSpacer()

		menu:AddOption('Save/Unsave Prop', function()
			if saved_map[obj.model] then
				local tab = cvar.GetValue('sup_saved_props')
				table.remove(tab, saved_map[obj.model])
				saved_map[obj.model] = nil
				cvar.SetValue('sup_saved_props', tab)
				icon:Remove()
			else
				local tab = cvar.GetValue('sup_saved_props')
				local k = #tab + 1
				tab[k] = {type = 'model', model = obj.model}
				saved_map[obj.model] = k
				cvar.SetValue('sup_saved_props', tab)
			end
			RunConsoleCommand('spawnmenu_reload')
		end)

		menu:Open()
	end

	icon:InvalidateLayout(true)

	if IsValid(container) then
		container:Add(icon)
	end

	return icon
end)

spawnmenu.CreationMenus = spawnmenu.CreationMenus or {}
function spawnmenu.AddCreationTab( strName, pFunction, pMaterial, iOrder, strTooltip, custom )
	iOrder = iOrder or 1000

	pMaterial = pMaterial or "icon16/exclamation.png"

	spawnmenu.CreationMenus[ strName ] = { Function = pFunction, Icon = pMaterial, Order = iOrder, Tooltip = strTooltip, CustomCheck = custom }
end

function spawnmenu.GetCreationTabs()
	return spawnmenu.CreationMenus
end