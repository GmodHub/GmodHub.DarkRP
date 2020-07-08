TOOL.Category = "Adv Fading Doors"
TOOL.Name = "Keypad"
TOOL.Command = nil

TOOL.ClientConVar['faceid'] = '1'
TOOL.ClientConVar['password'] = ''

TOOL.ClientConVar['repeats_granted'] = '0'
TOOL.ClientConVar['repeats_denied'] = '0'

TOOL.ClientConVar['length_granted'] = '4'
TOOL.ClientConVar['length_denied'] = '0.1'

TOOL.ClientConVar['delay_granted'] = '0'
TOOL.ClientConVar['delay_denied'] = '0'

TOOL.ClientConVar['init_delay_granted'] = '0'
TOOL.ClientConVar['init_delay_denied'] = '0'

TOOL.ClientConVar['key_granted'] = '0'
TOOL.ClientConVar['key_denied'] = '0'

cleanup.Register("keypads")

TOOL.Information = {
	{ name = "left" },
	{ name = "right" }
}

if(CLIENT) then
	language.Add("tool.keypad.name", "Keypad")
	language.Add("tool.keypad.desc", "Creates a keypad to be used with fading door tool")
	language.Add("tool.keypad.left", "Create a keypad")
	language.Add("tool.keypad.right", "Update an existing keypad")
	language.Add("Undone_Keypad", "Undone Keypad")
	language.Add("Cleanup_keypads", "Keypads")
	language.Add("Cleaned_keypads", "Cleaned up all Keypads")

	language.Add("SBoxLimit_keypads", "You've hit the Keypad limit!")
end

function TOOL:SetupKeypad(ent, pass)
	local data = {
		Owner		= self:GetOwner(),
		Password	= pass,
		Granted		= {
			Num				= self:GetClientNumber("key_granted"),
			Hold			= math.Clamp(self:GetClientNumber("length_granted"), 4, 10),
			Delay			= math.Clamp(self:GetClientNumber("init_delay_granted"), 0, 5),
			Reps			= math.Clamp(self:GetClientNumber("repeats_granted"), 0, 4),
			DelayBetween	= math.Clamp(self:GetClientNumber("delay_granted"), 4, 10),
		},
		Denied = {
			Num				= self:GetClientNumber("key_denied"),
			Hold			= math.Clamp(self:GetClientNumber("length_denied"), 4, 10),
			Delay			= math.Clamp(self:GetClientNumber("init_delay_denied"), 0, 5),
			Reps			= math.Clamp(self:GetClientNumber("repeats_denied"), 0, 4),
			DelayBetween	= math.Clamp(self:GetClientNumber("delay_denied"), 4, 10),
		}
	}

	ent:SetFaceIDEnabled(tobool(self:GetClientNumber("faceid")))
	ent:SetData(data)
end

function TOOL:RightClick(tr)
	if(IsValid(tr.Entity) and tr.Entity:GetClass() ~= "pad_containing_some_keys_for_fading_doors") then return false end

	if(CLIENT) then return true end

	local ply = self:GetOwner()
	local password = tostring(tonumber(ply:GetInfo("keypad_password")))

	local spawn_pos = tr.HitPos
	local trace_ent = tr.Entity

	if(password == nil or (#password > 4) or (string.find(password, "0"))) then
		rp.Notify(ply, NOTIFY_ERROR, term.Get('InvalidPassword'))
		return false
	end

	if(trace_ent:GetClass() == "pad_containing_some_keys_for_fading_doors" and trace_ent.Data.Owner == ply) then
		self:SetupKeypad(trace_ent, password) -- validated password

		return true
	end
end

function TOOL:LeftClick(tr)
	if(IsValid(tr.Entity) and tr.Entity:GetClass() == "player") then return false end

	if(CLIENT) then return true end

	local ply = self:GetOwner()
	local password = tostring(tonumber(ply:GetInfo("keypad_password")))

	local trace_ent = tr.Entity

	if(password == nil or (#password > 4) or (string.find(password, "0"))) then
		rp.Notify(ply, NOTIFY_ERROR, term.Get('InvalidPassword'))
		return false
	end

	if(not self:GetWeapon():CheckLimit("keypads")) then return false end

	local pl = self:GetOwner()
	local ent = ents.Create("pad_containing_some_keys_for_fading_doors")
	ent:SetPos(tr.HitPos)
	ent:SetAngles(tr.HitNormal:Angle())
	ent:Spawn()
	ent:SetAngles(tr.HitNormal:Angle())
	ent:Activate()
	ent:CPPISetOwner(pl)

	self:SetupKeypad(ent, password) -- validated password

	undo.Create("Keypad")
		ent:Prepare(tr.Entity, tr.PhysicsBone)
		undo.AddEntity(ent)
		undo.SetPlayer(ply)
	undo.Finish()

	ply:AddCount("keypads", ent)
	ply:AddCleanup("keypads", ent)

	rp.Notify(ply, NOTIFY_HINT, term.Get('SboxSpawned'), ply:GetCount('keypads'), ply:GetLimit('keypads'), 'keypads')

	return true
end


if(CLIENT) then
	local function ResetSettings(ply)
		ply:ConCommand("keypad_repeats_granted 0")
		ply:ConCommand("keypad_repeats_denied 0")
		ply:ConCommand("keypad_length_granted 4")
		ply:ConCommand("keypad_length_denied 0.1")
		ply:ConCommand("keypad_delay_granted 0")
		ply:ConCommand("keypad_delay_denied 0")
		ply:ConCommand("keypad_init_delay_granted 0")
		ply:ConCommand("keypad_init_delay_denied 0")
	end

	concommand.Add("keypad_reset", ResetSettings)

	function TOOL.BuildCPanel(CPanel)
		local r, l = CPanel:TextEntry("4 Digit Password", "keypad_password")
		r:SetTall(22)

		CPanel:ControlHelp("Allowed Digits: 1-9")

		CPanel:CheckBox("Enable FaceID", "keypad_faceid")

		local ctrl = vgui.Create("CtrlNumPad", CPanel)
			ctrl:SetConVar1("keypad_key_granted")
			ctrl:SetConVar2("keypad_key_denied")
			ctrl:SetLabel1("Access Granted")
			ctrl:SetLabel2("Access Denied")
		CPanel:AddPanel(ctrl)

		CPanel:Button("Reset Settings", "keypad_reset")

		CPanel:Help("")
		CPanel:Help("Settings when access granted")

		CPanel:NumSlider("Hold Length", "keypad_length_granted", 4, 10)
		CPanel:NumSlider("Initial Delay", "keypad_init_delay_granted", 0, 5)
		CPanel:NumSlider("Multiple Press Delay", "keypad_delay_granted", 0, 4)
		CPanel:NumSlider("Additional Repeats", "keypad_repeats_granted", 0, 4)


		CPanel:Help("")
		CPanel:Help("Settings when access denied")

		CPanel:NumSlider("Hold Length", "keypad_length_denied", 4, 10)
		CPanel:NumSlider("Initial Delay", "keypad_init_delay_denied", 0, 5)
		CPanel:NumSlider("Multiple Press Delay", "keypad_delay_denied", 0, 4)
		CPanel:NumSlider("Additional Repeats", "keypad_repeats_denied", 0, 4)
	end
end