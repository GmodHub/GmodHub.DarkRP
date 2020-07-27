function ENTITY:MakeFadingDoor(pl, key, inversed, toggleactive)
	local makeundo = true
	if (self.FadingDoor) then
		self:UnFade()
		numpad.Remove(self.NumpadFadeUp)
		numpad.Remove(self.NumpadFadeDown)
		makeundo = false
	end

	self.FadeKey = key
	self.FadingDoor = true
	self.FadeInversed = inversed
	self.FadeToggle = toggleactive

	self.NumpadFadeUp = numpad.OnUp(pl, key, "FadeDoor", self, false)
	self.NumpadFadeDown = numpad.OnDown(pl, key, "FadeDoor", self, true)

	local impD = self.NumpadFadeDown
	local impU = self.NumpadFadeUp

	self.FadingDoorID = os.clock()

	if makeundo then
		undo.Create('fading_door')
			undo.AddFunction(function()
				if IsValid(ent) then
					ent:UnFade()
					ent.FadingDoor = nil
				end
				numpad.Remove(impD)
				numpad.Remove(impU)
			end, self.FadingDoorID)
			undo.SetPlayer(pl)
		undo.Finish()

		local uniqueID, fadingDoorID = pl:UniqueID(), self.FadingDoorID
		self:CallOnRemove("Fading Door", function()
			local undos = undo:GetTable()[uniqueID]

			if undos then
				for k, v in ipairs(undos) do
					if v.Functions and v.Functions[1] and v.Functions[1][2] and v.Functions[1][2][1] and (v.Functions[1][2][1] == fadingDoorID) then
						table.remove(undos, k)
						break
					end
				end
			end
		end)
	end

	if (inversed) then self:Fade() end
	return makeundo
end

-- Utility Functions
local function ValidTrace(tr)
	return ((tr.Entity) and (tr.Entity:IsValid())) and !((tr.Entity:IsPlayer()) or (tr.Entity:IsNPC()) or (tr.Entity:IsVehicle()) or (tr.HitWorld))
end

local function ChangeState(pl, ent, state)
	if !(ent:IsValid()) then return end

	if ((pl:GetCount('keypads') > 0) or (pl:GetCount('buttons') > 0)) and (not pl.UsingKeypad) then
		pl:Notify(NOTIFY_ERROR, term.Get('CantMetagameKeypad'))
		return
	end

	if (ent.FadeToggle) then
		if (state == false) then return end
		if (ent.Faded) then ent:UnFade() else ent:Fade() end
		return
	end

	if ((ent.FadeInversed) and (state == false)) or ((!ent.FadeInversed) and (state == true)) then
		ent:Fade()
	else
		ent:UnFade()
	end
end
if (SERVER) then numpad.Register("FadeDoor", ChangeState) end

TOOL.Category	= "Adv Fading Doors"
TOOL.Name		= "#tool.fading_door.name"
TOOL.Stage = 1

TOOL.ClientConVar["key"] = "5"
TOOL.ClientConVar["toggle"] = "0"
TOOL.ClientConVar["reversed"] = "0"
TOOL.ClientConVar["length"] = "4"
TOOL.ClientConVar["password"] = ""

TOOL.Information = {
	{ name = "left" },
	{ name = "right" }
}

if (CLIENT) then
	language.Add("Tool.fading_door.name", "Fading Door")
	language.Add("Tool.fading_door.desc", "Makes things into fadable doors.")
	language.Add("Tool.fading_door.left", "Create fading door")
	language.Add("Tool.fading_door.right", "Create fading door then press again to place keypad")

	language.Add("Undone_fading_door", "Undone Fading Door")

	function TOOL:BuildCPanel()
		self:AddControl("Header",   {Text = "#Tool_fading_door_name", Description = "#Tool_fading_door_desc"})
		self:AddControl("CheckBox", {Label = "Reversed (Starts invisible, becomes solid)", Command = "fading_door_reversed"})
		self:AddControl("CheckBox", {Label = "Toggle Active", Command = "fading_door_toggle"})
		self:AddControl("Numpad",   {Label = "Button", ButtonSize = "22", Command = "fading_door_key"})

		self:AddControl( "Slider", {	Label 	= "Hold Length",
									Type	= "Float",
									Min		= "4",
									Max		= "10",
									Command	= "fading_door_length" } )
		self:AddControl( "TextBox", {	Label		= "Password",
									MaxLength	= "4",
									Command		= "fading_door_password" })
	end

	TOOL.LeftClick = ValidTrace
	return
end

function TOOL:LeftClick(tr)
	if (!ValidTrace(tr)) then return false end
	if !IsValid(tr.Entity) then return false end

	local ent = tr.Entity
	local pl = self:GetOwner()
	if (ent:MakeFadingDoor(pl, self:GetClientNumber("key"), self:GetClientNumber("reversed") == 1, self:GetClientNumber("toggle") == 1)) then
		self.key = self:GetClientNumber("key")
		self.key2 = -1
	end
	rp.Notify(pl, NOTIFY_SUCCESS, term.Get('FadeDoorCreated'))
	return true
end

function TOOL:LinkKeypad(Ent, Key, Password, HoldLength)
	local data = {
		Owner 		= self:GetOwner(),
		Password	= Password,
		Granted		= {
			Num				= Key,
			Hold			= math.Clamp(HoldLength, 4, 10),
			Delay			= 0,
			Reps			= 0,
			DelayBetween	= 0
		},
		Denied		= {
			Num				= 0,
			Hold			= 0,
			Delay			= 0,
			Reps			= 0,
			DelayBetween	= 0
		}
	}

	Ent:SetData(data)
	Ent:GetPhysicsObject():EnableMotion(false)
	Ent:CPPISetOwner(self:GetOwner())
	self:GetOwner():AddCount("keypads", Ent)
	self:GetOwner():AddCleanup("keypads", Ent)

	Ent.keypad_keygroup1 = self:GetClientNumber("key")
	Ent.keypad_keygroup2 = -1
	Ent.keypad_length1 = self:GetClientNumber("length") or 3
	Ent.keypad_length2 = -1
end

function TOOL:RightClick(tr)
	if not SERVER then return end

	local pl = self:GetOwner()

	if not self.Stage or self.Stage == 1 then
		if (!ValidTrace(tr)) then return false end
		local ent = tr.Entity

		ent:MakeFadingDoor(pl, self:GetClientNumber("key"), self:GetClientNumber("reversed") == 1, self:GetClientNumber("toggle") == 1)

		rp.Notify(pl, NOTIFY_SUCCESS, term.Get('FadeDoorCreatedExtra'))
		self.Stage = 2
	else
		if not (pl:CheckLimit("keypads")) then return false end

		local Password = tostring(tonumber(self:GetClientNumber("password")))

		if (Password == nil) or (#Password > 4) or (string.find(Password, "0")) then
			rp.Notify(pl, NOTIFY_ERROR, term.Get('InvalidPassword'))
			return false
		end

		if tonumber(self:GetClientNumber("length")) < 4 then
			rp.Notify(pl, NOTIFY_ERROR, term.Get('KeypadHoldLength'), 4)
			return false
		end

		local pl = self:GetOwner()
		local ent = ents.Create("pad_containing_some_keys_for_fading_doors")
		ent:SetPos(tr.HitPos)
		ent:SetAngles(tr.HitNormal:Angle())
		ent:Spawn()
		ent:SetAngles(tr.HitNormal:Angle())
		ent:Activate()
		ent:CPPISetOwner(pl)

		self:LinkKeypad(ent, self:GetClientNumber("key"), Password, self:GetClientNumber("length"))

		undo.Create("Keypad")
			undo.AddEntity(ent)
			undo.SetPlayer(pl)
		undo.Finish()

		rp.Notify(pl, NOTIFY_HINT, term.Get('SboxSpawned'), pl:GetCount('keypads'), pl:GetLimit('keypads'), 'keypads')
		self.Stage = 1
	end

	return true
end
