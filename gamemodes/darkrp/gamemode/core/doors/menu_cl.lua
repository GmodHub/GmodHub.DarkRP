local adminMenu
local fr
local ent
local doorOptions = {
	{
		Name 	= 'Sell',
		DoClick = function()
			cmd.Run('sellproperty')
			fr:Close()
		end,
	},
	{
		Name 	= 'Add Co-Owner',
		Check 	= function()
			return (player.GetCount() > 1)
		end,
		DoClick = function()
			ui.PlayerRequest(function(pl)
				cmd.Run('addcoowner', pl:SteamID())
			end)
		end,
	},
	{
		Name 	= 'Remove Co-Owner',
		Check 	= function()
			return (#ent:GetPropertyCoOwners() > 0)
		end,
		DoClick = function()
			ui.PlayerRequest(ent:GetPropertyCoOwners(), function(pl)
				cmd.Run('removecoowner', pl:SteamID())
			end)
		end,
	},
	{
		Name 	= 'Toggle org ownership',
		Check 	= function()
			return (LocalPlayer():GetOrg() ~= nil)
		end,
		DoClick = function()
			cmd.Run('setpropertyorgowned')
		end,
	},
	{
		Name 	= 'Set Title',
		DoClick = function()
			ui.StringRequest('Title', 'What do you want the title to be?', '', function(a)
				cmd.Run('setpropertytitle', tostring(a))
			end)
		end,
	}
}
local hotelOwnerOptions = {
	{
		Name 	= 'Add Tenant',
		Check 	= function()
			return (not ent:IsPropertyOwned())
		end,
		DoClick = function()
			local ent = fr.ent

			ui.PlayerRequest(table.Filter(player.GetAll(), function(v)
				return (v:GetPos():DistToSqr(ent:GetPos()) <= 40000) and (not v:GetTeamTable().CannotOwnDoors)
			end), function(pl)
				cmd.Run('addtennant', pl:SteamID())
			end)
		end,
	},
	{
		Name 	= 'Buy',
		Check 	= function()
			return (not ent:IsPropertyOwned())
		end,
		DoClick = function()
			cmd.Run('addtennant', LocalPlayer():SteamID())
		end,
	},
	{
		Name 	= 'Remove Tenant',
		Check 	= function()
			return ent:IsPropertyOwned() and (ent:GetPropertyOwner() ~= LocalPlayer())
		end,
		DoClick = function()
			cmd.Run('evicttennant')
		end,
	}
}

local function makeFrame(ent, opts)
	fr = ui.Create('ui_frame', function(self)
		self:SetTitle('Property Options')
		self:Center()
		self:MakePopup()
		self.Think = function(self)
			ent = LocalPlayer():GetEyeTrace().Entity
			if not IsValid(ent) or (ent:GetPos():DistToSqr(LocalPlayer():GetPos()) > 13225) then
				fr:Close()
			end
		end
	end)

	fr.ent = ent

	local count = -1
		local x, y = fr:GetDockPos()
		for k, v in ipairs(opts) do
			if (v.Check == nil) or (v.Check(ent) == true) then
				count = count + 1
				fr:SetSize(ScrW() * .125, ((count + 1) * 29) + (y + 7))
				fr:Center()
				ui.Create('DButton', function(self)
					self:SetPos(x, (count * 29) + y)
					self:SetSize(ScrW() * .125 - 10, 30)
					self:SetText(v.Name)
					self.DoClick = function()
						v.DoClick(v)
						fr:Close()
					end
				end, fr)
			end
		end

	return fr
end

local function showDeed(ent)
	fr = ui.Create('ui_frame', function(self)
		self:SetTitle(ent:GetPropertyName() .. ' Deed')
		self:SetSize(ScrW() * 0.2, ScrH() * 0.25)
		self:Center()
		self:MakePopup()

		self.Think = function(self)
			ent = LocalPlayer():GetEyeTrace().Entity
			if not IsValid(ent) or (ent:GetPos():DistToSqr(LocalPlayer():GetPos()) > 13225) then
				fr:Close()
			end
		end
	end)

	fr.ent = ent

	ui.Create('ui_listview', function(self)
		self:DockToFrame()
		self:AddSpacer('Owner')
		self:AddPlayer(ent:GetPropertyOwner())
		self:AddSpacer('Co-Owners')
		for k, v in ipairs(ent:GetPropertyCoOwners()) do
			if IsValid(v) then
				self:AddPlayer(v)
			end
		end
	end, fr)
end

local function keysMenu()
	if IsValid(fr) then fr:Close() end

	ent = LocalPlayer():GetEyeTrace().Entity
	print(ent:GetPropertyOwner())
	if IsValid(ent) and ent:IsDoor() and (ent:GetPos():DistToSqr(LocalPlayer():GetPos()) < 13225) then
		if ent:IsPropertyOwned() and (ent:GetPropertyOwner() == LocalPlayer()) then
			makeFrame(ent, doorOptions)
		elseif ent:IsPropertyOwned() and (ent:GetPropertyOwner() ~= LocalPlayer()) and (#ent:GetPropertyCoOwners() >= 4) then -- change to 4
			showDeed(ent)
		elseif ent:IsPropertyOwnable() then
			cmd.Run('buyproperty')
		elseif ent:IsPropertyHotelOwned() and LocalPlayer():GetTeamTable().HotelManager then
			makeFrame(ent, hotelOwnerOptions)
		end
	end
end

net('rp.keysMenu', keysMenu)

GM.ShowTeam = keysMenu
