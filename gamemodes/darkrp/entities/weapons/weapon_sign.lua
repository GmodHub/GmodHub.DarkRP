AddCSLuaFile()

SWEP.PrintName = 'Sign'
SWEP.Spawnable = true
SWEP.Category = 'RP'
SWEP.Slot = 2
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false

SWEP.ViewModel = 'models/weapons/v_hands.mdl'
SWEP.WorldModel = ''
SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false

function SWEP:SetupDataTables()
	self:NetworkVar('Entity', 0, 'Prop')
end

function SWEP:SetupProp()
	if CLIENT then return end

	local attach = self:GetOwner():LookupAttachment('anim_attachment_RH')
	if (attach == nil) or (attach == 0) then
		return
	end

	self.Prop = ents.Create('ent_sign')
	self.Prop:Spawn()
	self:SetProp(self.Prop)

	local attachTable = self:GetOwner():GetAttachment(attach)
	self.Prop:SetPos(attachTable.Pos)
	self.Prop:SetAngles(attachTable.Ang)
	self.Prop:SetParent(self:GetOwner(), attach)

	if (self.Text1 and self.Text2 and self.Text3) then
		self.Prop:SetText1(self.Text1)
		self.Prop:SetText2(self.Text2)
		self.Prop:SetText3(self.Text3)
	end
end

function SWEP:PrimaryAttack()
	if SERVER then
		self:SetNextPrimaryFire(CurTime() + 2)

		math.randomseed(os.clock())

		net.Start('rp.SignPlaySound')
			net.WritePlayer(self:GetOwner())
			net.WriteUInt(math.random(121), 8)
		net.Broadcast()
	end
end

function SWEP:SecondaryAttack()
end

local frame
function SWEP:Reload()
	if SERVER then return end

	if IsValid(frame) then
		frame:Remove()
	end

	local ent = self:GetProp()

	if (not IsValid(ent)) then return end

	frame = ui.Create('ui_frame', function(s)
		local x, y = s:GetDockPos()

		s:SetTitle('Set Sign Text')
		s:SetSize(400, y + (30 * 4))
		s:Center()
		s:MakePopup()
		s.TextEntrys = {}

		for i = 1, 3 do
			table.insert(s.TextEntrys, ui.Create('DTextEntry', function(s, p)
				s:SetSize(p:GetWide() - 10, 25)
				s:SetPos(x, y + ((i -1) * 30))
				s:SetValue(ent['GetText' .. i](ent))
				function s:OnValueChange(value)
					if value and (value:len() > 12) then
						s:SetValue(value:sub(1, 12))
					end
				end
			end, s))
		end

		ui.Create('DButton', function(s, p)
			s:SetSize(p:GetWide() - 10, 25)
			s:SetPos(x, y + (30 * 3))
			s:SetText('Submit')
			function s:DoClick()
				p:Close()
				net.Start 'rp.SetSignText'
					for i = 1, 3 do
						net.WriteString(p.TextEntrys[i]:GetValue() or '')
					end
				net.SendToServer()
			end
		end, s)
	end)
end

function SWEP:Deploy()
	self:SetHoldType('pistol')
	self:SetupProp()
	return true
end

function SWEP:Holster()
	if IsValid(self.Prop) then
		self.Prop:Remove()
		self:SetProp(nil)
	end
	return true
end

function SWEP:OnDrop()
	if IsValid(self.Prop) then
		self.Prop:Remove()
		self:SetProp(nil)
	end
	return true
end

function SWEP:OnRemove()
	if IsValid(self.Prop) then
		self.Prop:Remove()
		self:SetProp(nil)
	end
	return true
end

if (SERVER) then
	util.AddNetworkString 'rp.SignPlaySound'
	util.AddNetworkString 'rp.SetSignText'

	net('rp.SetSignText', function(len, pl)
		local wep = pl:GetActiveWeapon()
		if IsValid(wep) and (wep:GetClass() == 'weapon_sign') and IsValid(wep:GetProp()) then
			local sign = wep:GetProp()
			wep.Text1 = net.ReadString():sub(1, 12)
			wep.Text2 = net.ReadString():sub(1, 12)
			wep.Text3 = net.ReadString():sub(1, 12)
			sign:SetText1(wep.Text1)
			sign:SetText2(wep.Text2)
			sign:SetText3(wep.Text3)
		end
	end)
else
	net('rp.SignPlaySound', function()
		local pl = net.ReadPlayer()
		if (not IsValid(pl)) or (pl:GetPos():Distance(LocalPlayer():GetPos()) > 500) or (not system.HasFocus()) then return end

		sound.PlayURL('http://cdn.superiorservers.co/rp/sign_sounds/' .. net.ReadUInt(8) .. '.mp3', '3d', function(station)
			if IsValid(station) and IsValid(pl) then
				station:SetVolume(1)
				station:Set3DCone(360, 360, 1)
				station:SetPos(pl:EyePos())
				station:Play()
				hook.Add('Think', station, function()
					if system.HasFocus() and IsValid(pl) and IsValid(pl:GetActiveWeapon()) and (station:GetState() ~= GMOD_CHANNEL_STOPPED) and (pl:GetActiveWeapon():GetClass() == 'weapon_sign') then
						station:SetPos(pl:EyePos())
					else
						station:Stop()
						hook.Remove('Think', station)
					end
				end)
			end
		end)
	end)

	local function addfilter(filter)
		local wep = LocalPlayer():GetActiveWeapon()
		if IsValid(wep) and (wep:GetClass() == 'weapon_sign') and wep.GetProp and IsValid(wep:GetProp()) then
			table.insert(filter, wep:GetProp())
		end
	end
	hook('GetThirdPersonHullFilter', 'rp.sign.GetThirdPersonHullFilter', addfilter)
	hook('GetThirdPersonEyeFilter', 'rp.sign.GetThirdPersonEyeFilter', addfilter)
end