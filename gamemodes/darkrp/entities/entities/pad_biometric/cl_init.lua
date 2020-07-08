dash.IncludeSH 'shared.lua'

local mat_faceID = Material('sup/entities/keypad/faceid.png', 'smooth')
local mat_lense = Material('sup/entities/biometric/lens.png', 'smooth')
local mat_locked = Material('sup/entities/biometric/locked.png', 'smooth')
local mat_unlocked = Material('sup/entities/biometric/unlocked.png', 'smooth')

local lookEnt, fr, ent
function ENT:Draw()
	self.BaseClass.Draw(self)

	local distance = LocalPlayer():EyePos():DistToSqr(self:GetPos())
	if (distance > 562500) then return end

	local pos = self:GetPos() + (self:GetUp() * 2.52) + (self:GetRight() * 15)
	local ang = self:GetAngles()

	ang:RotateAroundAxis(ang:Up(), 90)

	cam.Start3D2D(pos, ang, 0.05)
		local x, y, w, h = 0, -45, 315, 265

		draw.Box(x, y, w, h, ui.col.Black)

		local org = self:GetOrg()
		if (org ~= nil) and (org ~= '') then
			local banner = rp.orgs.GetBanner(org)
			if banner then
				surface.SetDrawColor(255, 255, 255, 255)
				surface.SetMaterial(banner)
				surface.DrawTexturedRect(x + 10, y + h - 42, 32, 32)
			end
		end

		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(mat_lense)
		surface.DrawTexturedRect((w * 0.5) - 16, y + 10, 32, 32)

		local status = self:GetStatus()

		if (status == 1) then -- unlocked
			surface.SetDrawColor(25, 225, 25, 255)
			surface.SetMaterial(mat_unlocked)
			surface.DrawTexturedRect(x + (w * 0.5) - 64, y + (h * 0.5) - 64, 128, 128)
		elseif (status == 2) then -- locked & denied
			surface.SetDrawColor(225, 25, 25, 255)
			surface.SetMaterial(mat_locked)
			surface.DrawTexturedRect(x + (w * 0.5) - 64, y + (h * 0.5) - 64, 128, 128)
		else -- locked
			if lookEnt and (lookEnt == self) then
				surface.SetMaterial(mat_faceID)
				surface.SetDrawColor(255, 255, 255, (SysTime() % .5) >= .25 and 255 or 0)
				surface.DrawTexturedRect(x + (w * 0.5) - 64, y + (h * 0.5) - 64, 128, 128)
			else
				surface.SetDrawColor(255, 255, 255, 255)
				surface.SetMaterial(mat_locked)
				surface.DrawTexturedRect(x + (w * 0.5) - 64, y + (h * 0.5) - 64, 128, 128)
			end
		end

	cam.End3D2D()
end

function ENT:Initialize()
	self.LookTime = 0
end

function ENT:Think()
	self:UpdateLever()

	self.LookTime = self.LookTime or 0

	local wep = LocalPlayer():GetActiveWeapon()
	if lookEnt and (lookEnt == self) and (not self:IsBusy()) and (not IsValid(fr)) and ((not IsValid(wep)) or (wep:GetClass() ~= 'keypad_cracker') or (not wep.IsCracking)) then
		self.LookTime = self.LookTime + FrameTime()

		if (self.LookTime >= 1) then
			net.Start('rp.biometric.Unlock')
				net.WriteEntity(self)
			net.SendToServer()

			self.LookTime = -5
		end
	elseif (self.LookTime ~= 0) then
		self.LookTime = math.Approach(self.LookTime, 0, FrameTime())
	end
end

function ENT:UpdateLever()
	self.PosePosition = self.PosePosition or 0

	self.PosePosition = math.Approach(self.PosePosition, self:IsBusy() and 1 or 0, 0.1)

	self:SetPoseParameter('switch', self.PosePosition)
	self:InvalidateBoneCache()
end

function ENT:ReadPlayerUse()
	self.AllowedPlayers 	= {}
	self.AllowedTeams 		= {}

	for i = 1, net.ReadUInt(9) do
		self.AllowedPlayers[i] = net.ReadPlayer()
	end

	for i = 1, net.ReadUInt(9) do
		self.AllowedTeams[i] = net.ReadUInt(9)
	end
end

local function jobSelect(teams, add)
	local jFr = ui.Create('ui_frame', function(self, p)
		self:SetSize(ScrW() * 0.65, ScrH() * 0.6)
		self:SetTitle('Add Team')
		self:Center()
		self:MakePopup()
		self.Think = function()
			if (not IsValid(fr)) then self:Close() end
		end
	end)

	ui.Create('rp_jobslist', function(self, p)
		local x, y = fr:GetDockPos()
		x, y = x - 5, y - 5
		self:SetPos(x, y)
		self:SetSize(p:GetWide() - x, p:GetTall() - y)
		self.DoClick = function()
			net.Start 'rp.biometric.Team'
				net.WriteEntity(ent)
				net.WriteBool(add)
				net.WriteInt(self.job.team, 9)
			net.SendToServer()

			fr:Close()
			jFr:Close()
		end

		self.JobList:Reset()

		if teams then
			for k, v in ipairs(teams or rp.teams) do
				if rp.teams[v] then
					self:AddJob(rp.teams[v])
				end
			end
		else
			for k, v in ipairs(rp.teams) do
				self:AddJob(v)
			end
		end

	end, jFr)
end

local padOptions = {
	{
		Name 	= 'Add Player',
		Check 	= function()
			return (player.GetCount() > 1)
		end,
		DoClick = function()
			fr:Close()
			ui.PlayerRequest(function(pl)
				net.Start 'rp.biometric.Player'
					net.WriteEntity(ent)
					net.WriteBit(true)
					net.WritePlayer(pl)
				net.SendToServer()
			end)
		end
	},
		{
		Name 	= 'Remove Player',
		Check 	= function()
			return (#ent.AllowedPlayers > 0)
		end,
		DoClick = function()
			fr:Close()
			ui.PlayerRequest(ent.AllowedPlayers, function(pl)
				net.Start 'rp.biometric.Player'
					net.WriteEntity(ent)
					net.WriteBit(false)
					net.WritePlayer(pl)
				net.SendToServer()
			end)
		end,
	},
	{
		Name 	= 'Add Team',
		DoClick = function()
			jobSelect(nil, true)
		end
	},
		{
		Name 	= 'Remove Team',
		Check 	= function()
			return (#ent.AllowedTeams > 0)
		end,
		DoClick = function()
			jobSelect(ent.AllowedTeams, false)
		end,
	},
	{
		Name 	= 'Toggle org ownership',
		Check 	= function()
			return (LocalPlayer():GetOrg() ~= nil)
		end,
		DoClick = function()
			fr:Close()
			net.Start 'rp.biometric.Org'
				net.WriteEntity(ent)
				net.WriteBit(ent:GetOrg() ~= LocalPlayer():GetOrg())
			net.SendToServer()
		end,
	},
	{
		Name 	= 'Copy settings to all biometrics',
		DoClick = function()
			fr:Close()

			net.Start 'rp.biometric.ApplyAll'
				net.WriteEntity(ent)
			net.SendToServer()
		end,
	},
}

function ENT:PlayerUse()
	if IsValid(fr) then fr:Close() end

	fr = ui.Create('ui_frame', function(self)
		self:SetTitle('Scanner Options')
		self:Center()
		self:MakePopup()
		self.Think = function(self)
			if (not IsValid(ent)) then
				fr:Close()
			end
		end
	end)

	ent = self

	local count = -1
	local x, y = fr:GetDockPos()
	for k, v in ipairs(padOptions) do
		if (v.Check == nil) or (v.Check(ent) == true) then
			count = count + 1
			fr:SetSize(275, ((count + 1) * 29) + (y + 7))
			fr:Center()
			ui.Create('DButton', function(self)
				self:SetPos(x, (count * 29) + y)
				self:SetSize(265, 30)
				self:SetText(v.Name)
				self.DoClick = function()
					v.DoClick(v)
				end
			end, fr)
		end
	end
end

local traceBase = {}
hook.Add('Think', 'rp.biometric.Think', function()
	local LP = LocalPlayer()
	if IsValid(LP) then
		traceBase.start = LP:GetShootPos()
		traceBase.endpos = LP:GetAimVector() * 32 + traceBase.start
		traceBase.filter = LP
		local tr = util.TraceLine(traceBase)

		lookEnt = tr.Entity
	end
end)