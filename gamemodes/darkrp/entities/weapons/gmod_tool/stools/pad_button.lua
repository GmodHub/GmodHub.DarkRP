TOOL.Category = 'Easy Fading Doors'
TOOL.Name = '#tool.pad_button.name'

if CLIENT then
	language.Add('tool.pad_button.name', 'Button')
	language.Add('tool.pad_button.desc', 'Create a button that fades prop/s')
	language.Add('tool.pad_button.right', 'Select prop/s to link')
	language.Add('tool.pad_button.left_1', 'Place button')
	language.Add('tool.pad_button.reload', 'Clear selected props')
end

TOOL.Information = {
	{ name = "left_1", stage = 1 },
	{ name = "right" },
	{ name = "reload" }
}

TOOL.ClientConVar['model'] = 'models/maxofs2d/button_05.mdl'
TOOL.ClientConVar['toggle'] = '1'

cleanup.Register('buttons')

local function makeButton(pl, model, toogle, pos, ang)
	if (not IsValid(pl)) or (not pl:CheckLimit('buttons')) then return false end

	local hasModel = false
	for k, v in pairs(list.Get('PadButtonModels')) do
		if (k == model) then
			hasModel = true
			break
		end
	end

	if (not hasModel) then return end

	local button = ents.Create 'pad_button'

	if (not IsValid(button)) then return false end

	button:CPPISetOwner(pl)

	button:SetAngles(pos)
	button:SetPos(ang)
	button:Spawn()
	button.ToggleMode = tobool(toogle)
	button:SetModel(model)

	duplicator.StoreEntityModifier(button, "ToggleMode", {button.ToggleMode})

	for k, v in ipairs(rp.fadingdoor.GetProps(pl)) do
		if IsValid(v) then
			button:AddProp(v)
		end
	end
	rp.fadingdoor.ClearProps(pl)

	pl:AddCount('buttons', button)

	return button
end

if (SERVER) then
	local function makeButtonFromDupe(pl, fadeUID, ToggleMode, dupeData)
		if (not IsValid(pl)) or (not pl:CheckLimit('buttons')) then return false end
		local ent = ents.Create 'pad_button'

		ent:SetAngles(dupeData.Angle)
		ent:SetPos(dupeData.Pos)

		ent:CPPISetOwner(pl)
		ent.FadeUID = fadeUID
		ent.ToggleMode = ToggleMode
		ent:Spawn()

		ent:SetModel(dupeData.Model)

		duplicator.DoGenericPhysics(ent, dupeData)

		pl:AddCount('buttons', ent)

		return ent
	end
	duplicator.RegisterEntityClass("pad_button", makeButtonFromDupe, 'FadeUID', 'ToggleMode', 'Data')

	duplicator.RegisterEntityModifier("ToggleMode", function(player, ent, data)
		ent.ToggleMode = data[1]
	end)
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

	local button = makeButton(pl, self:GetClientInfo('model'), self:GetClientInfo('toggle'), ang, trace.HitPos)

	if (not IsValid(button)) then return end

	undo.Create('Button')
		undo.AddEntity(button)
		undo.SetPlayer(pl)
	undo.Finish()

	pl:AddCleanup('buttons', button)

	rp.Notify(pl, NOTIFY_HINT, term.Get('SboxSpawned'), pl:GetCount('buttons'), pl:GetLimit('buttons'), 'buttons')

	return true
end

function TOOL:RightClick(trace)
	local prop = trace.Entity
	local pl = self:GetOwner()

	if CLIENT then return false end

	if (not IsValid(pl)) or (not pl:CheckLimit('buttons')) then return false end

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

	if (trace.Entity && trace.Entity:GetClass() == 'pad_button' || trace.Entity:IsPlayer()) then
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
	if (!IsValid(self.GhostEntity ) || self.GhostEntity:GetModel() != self:GetClientInfo('model')) then
		self:MakeGhostEntity(self:GetClientInfo('model'), Vector(0, 0, 0), Angle(0, 0, 0))
	end

	self:UpdateGhostButton(self.GhostEntity, self:GetOwner())
end

function TOOL.BuildCPanel(CPanel)
	CPanel:AddControl('Header', { Description = '#tool.pad_button.desc' })

	CPanel:AddControl("CheckBox", { Label = "Toggle Mode", Command = "pad_button_toggle" })
	CPanel:ControlHelp('The button will toggle between on and off, instead of having to be held down.')

	CPanel:AddControl('PropSelect', { Label = 'Model', ConVar = 'pad_button_model', Height = 4, models = list.Get('PadButtonModels') })
end

list.Set('PadButtonModels', 'models/maxofs2d/button_01.mdl', {})
list.Set('PadButtonModels', 'models/maxofs2d/button_02.mdl', {})
list.Set('PadButtonModels', 'models/maxofs2d/button_03.mdl', {})
list.Set('PadButtonModels', 'models/maxofs2d/button_04.mdl', {})
list.Set('PadButtonModels', 'models/maxofs2d/button_05.mdl', {})
list.Set('PadButtonModels', 'models/maxofs2d/button_06.mdl', {})
list.Set('PadButtonModels', 'models/maxofs2d/button_slider.mdl', {})
--list.Set('PadButtonModels', 'models/dav0r/buttons/button.mdl', {})
list.Set('PadButtonModels', 'models/dav0r/buttons/switch.mdl', {})