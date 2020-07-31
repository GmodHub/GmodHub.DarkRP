AddCSLuaFile("cl_init.lua")
AddCSLuaFile("sh_init.lua")
include("sh_init.lua")

util.AddNetworkString('rp.keypad.FaceID')
util.AddNetworkString('rp.keypad.Number')
util.AddNetworkString('rp.keypad.Func')

net('rp.keypad.Number', function(len, pl)
    local ent = net.ReadEntity()
    if not IsValid(ent) or ent:GetClass() ~= "pad_containing_some_keys_for_fading_doors" or ent:GetPos():Distance(pl:GetPos()) > 80 then return end
    local num = math.Clamp( net.ReadUInt(4) or 1, 1, 9)
    ent:EnterNum(num)
end)

net('rp.keypad.Func', function(len, pl)
    local ent = net.ReadEntity()
    if not IsValid(ent) or ent:GetClass() ~= "pad_containing_some_keys_for_fading_doors" or ent:GetPos():Distance(pl:GetPos()) > 80 then return end
    if net.ReadBool() then
        ent:Submit()
    else
        ent:ResetButton()
    end
end)

AccessorFunc(ENT, "var_Input", "Input", FORCE_STRING)

function ENT:Initialize()
	self:SetModel("models/props_lab/keypad.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)

	self:PhysWake()

	self.Password = false

	if (not self.KeypadData) then
		self.KeypadData = {
            Owner		= NULL,
            Password	= 1234,
            Granted		= {
                Num				= 0,
                Hold			= 4,
                Delay			= 0,
                Reps			= 0,
                DelayBetween	= 4,
            },
            Denied = {
                Num				= 0,
                Hold			= 4,
                Delay			= 0,
                Reps			= 0,
                DelayBetween	= 4,
            }
		}
	end

	self:ResetData()
end

function ENT:Prepare(ent, physNum)
    local phys = self:GetPhysicsObjectNum(physNum)
    phys:EnableMotion(false)

    timer.Simple(0, function()
        if(IsValid(self) and IsValid(ent)) then
            local weld = constraint.Weld(self, ent)
        end
    end)

    self:GetPhysicsObject():EnableCollisions(false)
end

function ENT:SetPassword(pass)
	self.KeypadData.Password = tostring(pass)

	self:ResetData()
end

function ENT:GetPassword(pass)
	return self.KeypadData.Password or ""
end

function ENT:SetData(data)
	self.KeypadData = data

	self:ResetData()
end

function ENT:ResetData()
	self:SetNumStars(0)
	self:SetInput("")
	self:SetStatus(self.Status_None)
end

function ENT:EnterNum(num)
	if (self:GetStatus() == self.Status_None) then
		local num = tostring(num)
		local new_input = self:GetInput()..num
		self:SetInput(new_input:sub(1, 4))
		self:SetNumStars(new_input:len())

		self:EmitSound("buttons/button15.wav")
	end
end

function ENT:Submit()
	if (self:GetStatus() == self.Status_None) then
		local success = tostring(self:GetInput()) == tostring(self:GetPassword())

		self:Process(success)
	end
end

function ENT:ResetButton()
	if (self:GetStatus() == self.Status_None) then
		self:EmitSound("buttons/button14.wav")
		self:ResetData()
	end
end

function ENT:Process(granted)
	local length, repeats, delay, initdelay, owner, key

	if(granted) then
		self:SetStatus(self.Status_Granted)

		length = self.KeypadData.Granted.Hold
		repeats = math.min(self.KeypadData.Granted.Reps, 4)
		delay = self.KeypadData.Granted.DelayBetween
		initdelay = self.KeypadData.Granted.Delay
		owner = self.KeypadData.Owner
		key = tonumber(self.KeypadData.Granted.Num) or 0
	else
		self:SetStatus(self.Status_Denied)

		length = self.KeypadData.Denied.Hold
		repeats = math.min(self.KeypadData.Denied.Reps, 4)
		delay = self.KeypadData.Denied.DelayBetween
		initdelay = self.KeypadData.Denied.Delay
		owner = self.KeypadData.Owner
		key = tonumber(self.KeypadData.Denied.Num) or 0
	end

	timer.Simple(math.max(initdelay + length * (repeats + 1) + delay * repeats + 0.25, 2), function() -- 0.25 after last timer
		if(IsValid(self)) then
			self:ResetData()
		end
	end)

	timer.Simple(initdelay, function()
		if(IsValid(self)) then
			for i = 0, repeats do
				timer.Simple(length * i + delay * i, function()
					if(IsValid(self) and IsValid(owner)) then
                        owner.UsingKeypad = true
						numpad.Activate(owner, key)
                        owner.UsingKeypad = false
					end
				end)

				timer.Simple(length * (i + 1) + delay * i, function()
					if(IsValid(self) and IsValid(owner)) then
                        owner.UsingKeypad = true
						numpad.Deactivate(owner, key)
                        owner.UsingKeypad = false
					end
				end)
			end
		end
	end)

	if (granted) then
		self:EmitSound("buttons/button9.wav")
	else
		self:EmitSound("buttons/button11.wav")
	end
end