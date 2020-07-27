TOOL.Category = "VIP+"
TOOL.Name = "#tool.light.name"

TOOL.Information = {
	{ name = "left" },
	{ name = "right" }
}

TOOL.ClientConVar[ "model" ] = "models/MaxOfS2D/light_tubular.mdl"
TOOL.ClientConVar[ "r" ] = "255"
TOOL.ClientConVar[ "g" ] = "255"
TOOL.ClientConVar[ "b" ] = "255"
TOOL.ClientConVar[ "key" ] = "-1"
TOOL.ClientConVar[ "toggle" ] = "1"

cleanup.Register("lights")

function TOOL:LeftClick(trace, attach)

	if trace.Entity && trace.Entity:IsPlayer() then return false end
	if (CLIENT) then return true end
	if (attach == nil) then attach = true end

	-- If there's no physics object then we can't constraint it!
	if (SERVER && attach && !util.IsValidPhysicsObject(trace.Entity, trace.PhysicsBone)) then return false end

	local ply = self:GetOwner()

	local pos, ang = trace.HitPos + trace.HitNormal * 8, trace.HitNormal:Angle() - Angle(90, 0, 0)

	local r = math.Clamp(self:GetClientNumber("r"), 0, 255)
	local g = math.Clamp(self:GetClientNumber("g"), 0, 255)
	local b = math.Clamp(self:GetClientNumber("b"), 0, 255)
	local toggle = self:GetClientNumber("toggle") != 1

	local key = self:GetClientNumber("key")

	if (IsValid(trace.Entity) && trace.Entity:GetClass() == "gmod_light" && trace.Entity:CPPIGetOwner() == ply) then

		trace.Entity:SetColor(Color(r, g, b, 255))
		trace.Entity.r = r
		trace.Entity.g = g
		trace.Entity.b = b

		trace.Entity:SetToggle(!toggle)

		trace.Entity.KeyDown = key

		numpad.Remove(trace.Entity.NumDown)
		numpad.Remove(trace.Entity.NumUp)

		trace.Entity.NumDown = numpad.OnDown(ply, key, "LightToggle", trace.Entity, 1)
		trace.Entity.NumUp = numpad.OnUp(ply, key, "LightToggle", trace.Entity, 0)

		return true

	end

	if (!self:GetSWEP():CheckLimit("lights")) then return false end

	local model = self:GetClientInfo("model")

	local hasModel = false
	for k, v in pairs(list.Get('LightModels')) do
		if (k == model) then
			hasModel = true
			break
		end
	end

	if (not hasModel) then return end

	local lamp = MakeLight(ply, r, g, b, model, toggle, !toggle, key, { Pos = pos, Angle = ang })

	if (!attach) then

		undo.Create("Light")
			undo.AddEntity(lamp)
			undo.SetPlayer(self:GetOwner())
		undo.Finish()

		return true

	end

	local length = math.Clamp(self:GetClientNumber("ropelength"), 4, 1024)
	local material = self:GetClientInfo("ropematerial")

	local LPos1 = Vector(0, 0, 5)
	local LPos2 = trace.Entity:WorldToLocal(trace.HitPos)

	if (IsValid(trace.Entity)) then

		local phys = trace.Entity:GetPhysicsObjectNum(trace.PhysicsBone)
		if (IsValid(phys)) then
			LPos2 = phys:WorldToLocal(trace.HitPos)
		end

	end

	undo.Create("Light")
		undo.AddEntity(lamp)
		undo.SetPlayer(ply)
	undo.Finish()

	rp.Notify(ply, NOTIFY_HINT, term.Get('SboxSpawned'), ply:GetCount('lights'), ply:GetLimit('lights'), 'lights')

	return true

end

function TOOL:RightClick(trace)

	return self:LeftClick(trace, false)

end

if (SERVER) then

	function MakeLight(pl, r, g, b, Model, toggle, on, KeyDown, Data)

		if (IsValid(pl ) && !pl:CheckLimit("lights")) then return false end

		local lamp = ents.Create("gmod_light")

		if (!IsValid(lamp)) then return end

		duplicator.DoGeneric(lamp, Data)

		lamp:SetModel(Model)
		lamp:SetColor(Color(r, g, b, 255))
		lamp:SetToggle(!toggle)
		lamp:SetOn(on)

		lamp:Spawn()

		duplicator.DoGenericPhysics(lamp, pl, Data)

		lamp:CPPISetOwner(pl)

		if (IsValid(pl)) then
			pl:AddCount("lights", lamp)
			pl:AddCleanup("lights", lamp)
		end

		lamp.lightr = r
		lamp.lightg = g
		lamp.lightb = b
		lamp.KeyDown = KeyDown
		lamp.on = on

		lamp.NumDown = numpad.OnDown(pl, KeyDown, "LightToggle", lamp, 1)
		lamp.NumUp = numpad.OnUp(pl, KeyDown, "LightToggle", lamp, 0)

		return lamp

	end
	duplicator.RegisterEntityClass("gmod_light", MakeLight, "lightr", "lightg", "lightb", "Model", "Toggle", "on", "KeyDown", "Data")

	local function Toggle(pl, ent, onoff)

		if (!IsValid(ent)) then return false end
		if (!ent:GetToggle() ) then ent:SetOn(onoff == 1) return end

		if (numpad.FromButton()) then

			ent:SetOn(onoff == 1)
			return

		end

		if (onoff == 0) then return end

		return ent:Toggle()

	end
	numpad.Register("LightToggle", Toggle)

end

function TOOL:UpdateGhostLight(ent, player)

	if (!IsValid(ent)) then return end

	local tr = util.GetPlayerTrace(player)
	local trace	= util.TraceLine(tr)
	if (!trace.Hit) then return end

	if (trace.Entity:IsPlayer() || trace.Entity:GetClass() == "gmod_light") then

		ent:SetNoDraw(true)
		return

	end

	ent:SetPos(trace.HitPos + trace.HitNormal * 8)
	ent:SetAngles(trace.HitNormal:Angle() - Angle(90, 0, 0))

	ent:SetNoDraw(false)

end

function TOOL:Think()

	if (!IsValid(self.GhostEntity ) || self.GhostEntity:GetModel() != self:GetClientInfo("model")) then
		self:MakeGhostEntity(self:GetClientInfo("model" ), Vector(0, 0, 0), Angle(0, 0, 0))
	end

	self:UpdateGhostLight(self.GhostEntity, self:GetOwner())

end

local ConVarsDefault = TOOL:BuildConVarList()

function TOOL.BuildCPanel(CPanel)

	CPanel:AddControl("Header", { Description = "#tool.light.desc" })

	CPanel:AddControl("ComboBox", { MenuButton = 1, Folder = "light", Options = { [ "#preset.default" ] = ConVarsDefault }, CVars = table.GetKeys(ConVarsDefault) })

	CPanel:AddControl("Numpad", { Label = "#tool.light.key", Command = "light_key", ButtonSize = 22 })

	CPanel:AddControl("Checkbox", { Label = "#tool.light.toggle", Command = "light_toggle" })

	CPanel:AddControl("Color", { Label = "#tool.light.color", Red = "light_r", Green = "light_g", Blue = "light_b" })

	CPanel:AddControl("PropSelect", { Label = "#tool.button.model", ConVar = "light_model", Height = 4, Models = list.Get("LightModels") })

end

list.Set("LightModels", "models/maxofs2d/light_tubular.mdl", {})
list.Set("LightModels", "models/props_c17/light_cagelight02_on.mdl", {})
list.Set("LightModels", "models/props/cs_office/light_security.mdl", {})
list.Set("LightModels", "models/props/de_inferno/ceiling_light.mdl", {})
//list.Set("LightModels", "models/props/de_nuke/floodlight.mdl", {})