
hook.Add("PlayerBindPress", "Keypad", function(ply, bind, pressed)
	if not pressed then
		return
	end

	local tr = util.TraceLine({
		start = ply:EyePos(),
		endpos = ply:EyePos() + ply:GetAimVector() * 65,
		filter = ply
	})

	local ent = tr.Entity

	if not IsValid(ent) or not ent.IsKeypad then
		return
	end

	if string.find(bind, "+use", nil, true) then
		local element = ent:GetHoveredElement()

		if not element or not element.click then
			return
		end

		element.click(ent)
	end
end)


local physical_keypad_commands = {

	[KEY_ENTER] = function(self)
		self:SendCommand(self.Command_Accept)
	end,

	[KEY_PAD_ENTER] = function(self)
		self:SendCommand(self.Command_Accept)
	end,

	[KEY_PAD_MINUS] = function(self)
		self:SendCommand(self.Command_Abort)
	end,

	[KEY_PAD_PLUS] = function(self)
		self:SendCommand(self.Command_Abort)
	end

}

for i = KEY_PAD_1, KEY_PAD_9 do
	physical_keypad_commands[i] = function(self)
		self:SendCommand(self.Command_Enter, i - KEY_PAD_1 + 1)
	end
end

local last_press = 0

local enter_strict = CreateConVar("keypad_willox_enter_strict", "0", FCVAR_ARCHIVE, "Only allow the numpad's enter key to be used to accept keypads' input")

hook.Add("CreateMove", "Keypad", function(cmd)
	
	if RealTime() - 0.1 < last_press then
		return
	end

	for key, handler in pairs(physical_keypad_commands) do
		if input.WasKeyPressed(key) then

			if enter_strict:GetBool() and key == KEY_ENTER then
				continue
			end

			local ply = LocalPlayer()

			local tr = util.TraceLine({
				start = ply:EyePos(),
				endpos = ply:EyePos() + ply:GetAimVector() * 65,
				filter = ply
			})

			local ent = tr.Entity

			if not IsValid(ent) or not ent.IsKeypad then
				return
			end

			last_press = RealTime()
			
			handler(ent)

			return

		end
	end

end)



ENT.Base = "base_gmodentity"
ENT.Type = "anim"

ENT.Model = Model("models/props_lab/keypad.mdl")

ENT.Spawnable = true

ENT.Scale = 0.02
ENT.Value = ""

ENT.Status_None = 0
ENT.Status_Granted = 1
ENT.Status_Denied = 2

ENT.Command_Enter = 0
ENT.Command_Accept = 1
ENT.Command_Abort = 2

ENT.IsKeypad = true

AccessorFunc(ENT, "m_Password", "Password", FORCE_STRING)
AccessorFunc(ENT, "m_KeypadOwner", "KeypadOwner")

function ENT:Initialize()
	self:SetModel(self.Model)

	if CLIENT then
		self.Mins = self:OBBMins()
		self.Maxs = self:OBBMaxs()

		self.Width2D, self.Height2D = (self.Maxs.y - self.Mins.y) / self.Scale , (self.Maxs.z - self.Mins.z) / self.Scale
	end

	if SERVER then
		self:PhysicsInit(SOLID_VPHYSICS)

		local phys = self:GetPhysicsObject()

		if IsValid(phys) then
			phys:Wake()
		end

		self:SetValue("")
		self:SetPassword("1337")
		self:SetKeypadOwner(NULL)

		-- Initialize defaults
		self:GetData()

		self:Reset()
	end
end

function ENT:SetupDataTables()
	self:NetworkVar( "String", 0, "Text" )

	self:NetworkVar( "Int", 0, "Status" )

	self:NetworkVar( "Bool", 0, "Secure" )
end

function ENT:Hackable()
	return true
end