TOOL.Category = 'Easy Fading Doors'
TOOL.Name = '#tool.pad_biometric.name'

if CLIENT then
	language.Add('tool.pad_biometric.name', 'Biometric Scanner')
	language.Add('tool.pad_biometric.desc', 'Create a biometric scanner that fades prop/s')
	language.Add('tool.pad_biometric.right', 'Select prop/s to link')
	language.Add('tool.pad_biometric.left_1', 'Place biometric scanner')
	language.Add('tool.pad_biometric.reload', 'Clear selected props')
end

TOOL.Information = {
	{ name = "left_1", stage = 1 },
	{ name = "right" },
	{ name = "reload" }
}

TOOL.ClientConVar['holdlen'] = 4
TOOL.ClientConVar['orgown'] = 0

cleanup.Register('biometrics')

local function makeBiometric(pl, holdlen, orgown, pos, ang, fadeUID)
	if (not IsValid(pl)) or (not pl:CheckLimit('biometrics')) then return false end

	local biometric = ents.Create 'pad_biometric'

	biometric:CPPISetOwner(pl)

	biometric:SetAngles(pos)
	biometric:SetPos(ang)
	biometric:Spawn()

	for k, v in ipairs(rp.fadingdoor.GetProps(pl)) do
		if IsValid(v) then
			biometric:AddProp(v)
		end
	end
	rp.fadingdoor.ClearProps(pl)

	biometric:SetHoldLength(holdlen)

	if orgown and (pl:GetOrg() ~= nil) then
		biometric:SetOrg(pl:GetOrg())
	end

	pl:AddCount('biometrics', biometric)
	return biometric
end

if (SERVER) then
	local function makeBiometricFromDupe(pl, holdlen, pos, ang, fadeUID, dupeData)
		if (not IsValid(pl)) or (not pl:CheckLimit('biometrics')) then return false end
		local ent = ents.Create 'pad_biometric'

		if (dupeData.DT.Org != nil) then
			dupeData.DT.Org = pl:GetOrg()
		end

		duplicator.DoGeneric(ent, dupeData)

		ent:CPPISetOwner(pl)
		ent.FadeUID = fadeUID
		ent:Spawn()

		duplicator.DoGenericPhysics(ent, dupeData)

		ent:SetHoldLength(holdlen)
		pl:AddCount('biometrics', ent)

		return ent
	end
	duplicator.RegisterEntityClass("pad_biometric", makeBiometricFromDupe, 'HoldLength', 'Pos', 'Ang', 'FadeUID', 'Data')
end

function TOOL:ResetProps()
	self:SetStage(0)

	if SERVER then
		rp.fadingdoor.ClearProps(self:GetOwner())
	end

	if IsValid(self.GhostEntity) then
		self.GhostEntity:Remove()
	end
end

TOOL.Holster = TOOL.ResetProps
TOOL.Reload = TOOL.ResetProps

function TOOL:LeftClick(trace)
	if (IsValid(trace.Entity) and trace.Entity:IsPlayer()) or CLIENT then return false end

	local pl = self:GetOwner()

	if (#rp.fadingdoor.GetProps(pl) == 0) then
		pl:Notify(NOTIFY_ERROR, term.Get('FadingDoorNoProps'))
		return
	end

	self:SetStage(0)

	local ang = trace.HitNormal:Angle()
	ang.pitch = ang.pitch + 90

	local biometric = makeBiometric(pl, math.Clamp(tonumber(self:GetClientInfo('holdlen')), 4, 10), tobool(self:GetClientInfo('orgown')), ang, trace.HitPos)

	if (not IsValid(biometric)) then return end

	constraint.Weld(biometric, trace.Entity, 0, 0, 0, true, false)

	undo.Create('Biometrics')
		undo.AddEntity(biometric)
		undo.SetPlayer(pl)
	undo.Finish()

	pl:AddCleanup('biometrics', biometric)

	rp.Notify(pl, NOTIFY_HINT, term.Get('SboxSpawned'), pl:GetCount('biometrics'), pl:GetLimit('biometrics'), 'biometrics')

	return true
end

function TOOL:RightClick(trace)
	local prop = trace.Entity
	local pl = self:GetOwner()

	if CLIENT then return false end

	if (not IsValid(pl)) or (not pl:CheckLimit('biometrics')) then return false end

	if (not IsValid(prop)) or (not prop:IsProp()) then
		pl:Notify(NOTIFY_ERROR, term.Get('FadingDoorOnlyProps'))
		return false
	end

	local linkedProps = #rp.fadingdoor.GetProps(pl)

	if rp.fadingdoor.HasProp(pl, prop) then
		rp.fadingdoor.RemoveProp(self:GetOwner(), prop)

		linkedProps = linkedProps - 1
	else
		if (linkedProps >= 2) then
			pl:Notify(NOTIFY_ERROR, term.Get('FadingDoorMaxProps'), 2)
			return false
		end

		rp.fadingdoor.AddProp(self:GetOwner(), prop)

		linkedProps = linkedProps + 1
	end

	self:SetStage((linkedProps > 0) and 1 or 0)

	return true
end

function TOOL:UpdateGhostButton(ent, player)
	if (!IsValid(ent)) then return end

	local tr = util.GetPlayerTrace(player)
	local trace = util.TraceLine(tr)
	if (!trace.Hit) then return end

	if (trace.Entity && trace.Entity:GetClass() == 'pad_biometric' || trace.Entity:IsPlayer()) then
		ent:SetNoDraw(true)
		return
	end

	local Ang = trace.HitNormal:Angle()
	Ang.pitch = Ang.pitch + 90

	local min = ent:OBBMins()
	ent:SetPos(trace.HitPos - trace.HitNormal * min.z)
	ent:SetAngles(Ang)

	ent:SetNoDraw(false)
end

function TOOL:Think()
	if (!IsValid(self.GhostEntity )) then
		self:MakeGhostEntity('models/maxofs2d/button_04.mdl', Vector(0, 0, 0), Angle(0, 0, 0))
	end

	self:UpdateGhostButton(self.GhostEntity, self:GetOwner())
end

function TOOL.BuildCPanel(CPanel)
	CPanel:AddControl('Header', { Description = '#tool.pad_biometric.desc' })

	CPanel:NumSlider('Hold Length', 'pad_biometric_holdlen', 4, 10)
	CPanel:ControlHelp('Time the door stays open')

	CPanel:CheckBox('Org Access', 'pad_biometric_orgown')
	CPanel:ControlHelp('Allow your org to access this biometric scanner')

	CPanel:Button('Edit existing biometric pads', 'pad_biometric_menu').DoClick = function()
		net.Ping 'rp.biometric.Menu'
	end
end

if (SERVER) then
	util.AddNetworkString 'rp.biometric.Menu'

	net('rp.biometric.Menu', function(len, pl)
		local biometrics = pl:GetItems 'biometrics'

		net.Start 'rp.biometric.Menu'
			net.WriteUInt(#biometrics, 4)
			for k, v in ipairs(biometrics) do
				net.WriteEntity(v)
			end
		net.Send(pl)
	end)
else
	local fr
	net('rp.biometric.Menu', function()
		if IsValid(fr) then
			fr:Remove()
		end

		local biometrics = {}
		for i = 1, net.ReadUInt(4) do
			biometrics[#biometrics + 1] = net.ReadEntity()
		end

		fr = ui.Create('ui_frame', function(self)
			self:SetTitle('Biometric Editor')
			self:SetSize(200, 300)
			self:MakePopup()
			self:Center()
			self.OnClose = function()
				for k, v in ipairs(biometrics) do
					hook.Remove('HUDPaint', v)
				end
			end
		end)

		local listView = ui.Create('ui_listview', function(self, p)
			self:DockToFrame()

			function self:PaintOver(w, h)
				if (#self.Rows == 0) then
					draw.OutlinedBox(0, 0, w, h, ui.col.Background, ui.col.Outline)
					draw.SimpleText('No biometric pads!', 'ui.24', w * 0.5, h * 0.5, ui.col.White, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				end
			end

			for k, v in ipairs(biometrics) do
				local txt = 'Biometric #' .. k

				self:AddRow(txt).DoClick = function()
					v:SendPlayerUse(true)
				end

				hook.Add('HUDPaint', v, function()
					local pos = v:GetPos()
					pos = pos:ToScreen()

					draw.OutlinedBox(pos.x - 60, pos.y - 20, 120, 40, ui.col.FlatBlack, ui.col.Outline)
					draw.SimpleTextOutlined(txt, 'HudFont', pos.x, pos.y, ui.col.White, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, ui.col.Black)
				end)
			end
		end, fr)
	end)
end