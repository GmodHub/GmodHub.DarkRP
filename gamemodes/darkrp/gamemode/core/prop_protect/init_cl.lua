rp.pp = rp.pp or {
	Props = {}
}

--
-- Hooks
--
net('rp.PlayerSpawnProp', function()
	rp.pp.Props[net.ReadUInt(12)] = true
end)

hook('EntityRemoved', 'pp.EntityRemoved', function(ent)
	rp.pp.Props[ent:EntIndex()] = nil
end)

function GM:CanTool(pl, trace, tool)
	local ent = trace.Entity

	if (tool == "playercolorizer") then
		return pl:IsSA()
	end

	return IsValid(ent) and (rp.pp.Props[ent:EntIndex()] == true)
end

hook('PhysgunPickup', 'pp.PhysgunPickup', function(pl, ent)
	return false
end)

function GM:GravGunPunt(pl, ent)
	return pl:IsRoot()
end

function GM:GravGunPickupAllowed(pl, ent)
	return false
end

--
-- Spawnlist
--

-- Fix for the April 2017 update, fuck you rubat
spawnmenu._GetPropTable = spawnmenu._GetPropTable or spawnmenu.GetPropTable


local proptable
function spawnmenu.GetPropTable()
	if (not proptable) then
		proptable = {}

		for k, v in pairs(spawnmenu._GetPropTable()) do
			if (v.needsapp == '') or (v.needsapp == 'cstrike') then
				proptable[k] = v
			end
		end

		proptable = table.Merge(spawnmenu.GetCustomPropTable(), proptable)
	end

	return proptable
end


hook('InitPostEntity', function()
	http.Fetch('https://gmodhub.com/api/whitelist', function(body)
		local spawnlist 	= {}
		spawnlist.name 		= 'GmodHub Whitelist'
		spawnlist.id 		= 1000
		spawnlist.icon 		= 'games/16/garrysmod.png'
		spawnlist.parentid 	= 0
		spawnlist.version 	= 3
		spawnlist.contents 	= {}

		local copy = body
		body = util.JSONToTable(body)
		if (not body) then
			if (file.Exists("gmh/prop_whitelist.dat", "DATA")) then
				body = util.JSONToTable(file.Read("gmh/prop_whitelist.dat", "DATA"))
			else
				spawnmenu.AddPropCategory(spawnlist.name .. ' Offline', 'GmodHub Whitelist Offline', spawnlist.contents, spawnlist.icon, spawnlist.id, 0)
				return
			end
		else
			for k, v in ipairs(body) do
				if (mdl ~= '') then
					spawnlist.contents[#spawnlist.contents + 1] = {type = 'model', model = v}
				end
			end

			spawnmenu.AddPropCategory(spawnlist.name, spawnlist.name, spawnlist.contents, spawnlist.icon, spawnlist.id, 0)

			file.Write("gmh/prop_whitelist.dat", copy)
		end

	end)
end)

--
-- Menus
--
local ranks = {
	[0] = 'user',
	[1] = 'VIP',
	[2] = 'Admin',
	[3] = "SA",
	[4] = 'CO'
}
function rp.pp.ToolEditor()
	local tools = net.ReadTable()

	local fr = ui.Create('ui_frame', function(self)
		self:SetSize(500, 400)
		self:SetTitle('Tool editor')
		self:Center()
		self:MakePopup()
	end)

	local targ
	local list = ui.Create('DListView', function(self, p)
		self:SetPos(5, 30)
		self:SetSize(p:GetWide() - 10, p:GetTall() - 65)
		self:SetMultiSelect(false)
		self:AddColumn('Tool')
		self:AddColumn('Rank')

		self.OnRowSelected = function(parent, line)
			targ = self:GetLine(line):GetColumnText(1)
		end

		for a, b in ipairs(spawnmenu.GetTools()) do
			for c, d in ipairs(spawnmenu.GetTools()[a].Items) do
				for e, f in ipairs(spawnmenu.GetTools()[a].Items[c]) do
					if (type(f) == 'table') and string.find(f.Command, 'gmod_tool') then
						self:AddLine(f.ItemName, tools[f.ItemName] and ranks[tools[f.ItemName]] or 'user')
					end
				end
			end
		end

	end, fr)

	for i = 1, 5 do
		ui.Create('DButton', function(self, p)
			self:SetSize(p:GetWide()/5 - 6, 25)
			self:SetPos((i - 1) * (p:GetWide()/5 - 6) + (5 * i), p:GetTall() - 30)
			self:SetText(ranks[i-1])
			self.DoClick = function()
				cmd.Run('settoolgroup', targ, (i -1))
			end
		end, fr)
	end
end
net('rp.toolEditor', rp.pp.ToolEditor)

function rp.pp.SharePropMenu()
	local fr = ui.Create('ui_frame', function(self)
		self:SetSize(500, 500)
		self:SetTitle('Share Props')
		self:Center()
		self:MakePopup()
	end)

	local x, y = fr:GetDockPos()

	local sharedPlayers
	local unSharedPlayers
	ui.Create('DLabel', function(self)
		self:SetPos(x, y - 2)
		self:SetFont('ui.20')
		self:SetText('Add Player')
		self:SizeToContents()
	end, fr)

	ui.Create('DLabel', function(self)
		self:SetPos(x + (fr:GetWide() * 0.5) + 5, y - 2)
		self:SetFont('ui.20')
		self:SetText('Remove Player')
		self:SizeToContents()
	end, fr)

	local sharedKeys = LocalPlayer():GetNetVar('ShareProps') or {}

	unSharedPlayers = ui.Create('ui_playerrequest', function(self, p)
		self:SetPos(x, y + 20)
		self:SetSize((fr:GetWide() * 0.5) - 7.5, (fr:GetTall() - y) - 55)

		self.LayoutPlayers = function(self)
			self:SetPlayers(table.Filter(player.GetAll(), function(v)
				return (sharedKeys[v:SteamID()] == nil)
			end))

			self.PlayerList:AddPlayers()
		end

		self.OnSelection = function(self, row, pl)
			cmd.Run('shareprops', pl:SteamID())

			sharedKeys[pl:SteamID()] = true

			self:LayoutPlayers()
			sharedPlayers:LayoutPlayers()
		end

		self:LayoutPlayers()
	end, fr)

	sharedPlayers = ui.Create('ui_playerrequest', function(self, p)
		self:SetPos(x + unSharedPlayers:GetWide() + 7.5, y + 20)
		self:SetSize((fr:GetWide() * 0.5) - 7.5, (fr:GetTall() - y) - 55)

		self.LayoutPlayers = function(self)
			self:SetPlayers(table.Filter(player.GetAll(), function(v)
				return (sharedKeys[v:SteamID()] ~= nil)
			end))

			self.PlayerList:AddPlayers()
		end

		self.OnSelection = function(self, row, pl)
			cmd.Run('shareprops', pl:SteamID())

			sharedKeys[pl:SteamID()] = nil

			self:LayoutPlayers()
			unSharedPlayers:LayoutPlayers()
		end

		self:LayoutPlayers()
	end, fr)

	ui.Create('DButton', function(self, p)
		self:SetSize(fr:GetWide() - 10, 25)
		self:SetPos(5, p:GetTall() - 30)
		self.IsShare = (LocalPlayer():GetNetVar('OrgShareProps') == true)
		self:SetText(self.IsShare and 'Unshare Props With Org' or 'Share Props With Org')
		if (not LocalPlayer():GetOrg()) then
			self:SetDisabled(true)
		end
		self.DoClick = function()
			self.IsShare = (not self.IsShare)
			cmd.Run('orgshareprops')
			self:SetText(self.IsShare and 'Unshare Props With Org' or 'Share Props With Org')
		end
	end, fr)
end


--
-- Context menus
--
/*
properties.Add('ppWhitelist',
{
	MenuLabel	=	'Add/Remove from whitelist',
	Order		=	2001,
	MenuIcon	=	'icon16/arrow_refresh.png',

	Filter		=	function(self, ent, pl)
						if not IsValid(ent) or ent:IsPlayer() then return false end
						return pl:IsSuperAdmin()
					end,

	Action		=	function(self, ent)
						if not IsValid(ent) then return end
						cmd.Run('whitelist', ent:GetModel())
					end
})


properties.Add('ppShareProp',
{
	MenuLabel	=	'Share props',
	Order		=	2002,
	MenuIcon	=	'icon16/user.png',

	Filter		=	function(self, ent, pl)
						if not IsValid(ent) or ent:IsPlayer() then return false end
						return true
					end,

	Action		=	function(self, ent)
						rp.pp.SharePropMenu()
					end
})
