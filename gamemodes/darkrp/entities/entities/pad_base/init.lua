dash.IncludeCL 'cl_init.lua'
dash.IncludeSH 'shared.lua'

ENT.Props = {}

function ENT:Initialize()
    self:PhysicsInit( SOLID_VPHYSICS )
    self:SetMoveType( MOVETYPE_VPHYSICS )
    self:SetSolid( SOLID_VPHYSICS )
    //self:SetUseType( ONOFF_USE )
    self:SetUseType( SIMPLE_USE )
    local phys = self:GetPhysicsObject()
    phys:EnableMotion(false)
    phys:EnableCollisions(false)

    self.HoldLength = 4
end

function ENT:CanUse(pl)
    return not self:IsBusy()
end

function ENT:SetHoldLength(time)
    self.HoldLength = time
end

function ENT:GetHoldLength()
    return self.HoldLength
end

function ENT:FadeProps()
    for k,v in pairs(self.Props) do
        if (!v:IsValid()) then continue end
        v:Fade()
    end

	self:SetStatus(1)
end

function ENT:UnFadeProps()
    for k,v in pairs(self.Props) do
        if (!v:IsValid()) then continue end
        v:UnFade()
    end

	self:SetStatus(0)
end

function ENT:InValidUse()
    self:SetStatus(2)
    self:EmitSound("buttons/button11.wav")

    timer.Simple(1, function() 
        if(not IsValid(self)) then return end
        self:SetStatus(0) 
    end)
end

function ENT:ValidUse()
    self:FadeProps()
    self:EmitSound("buttons/button9.wav")
    self:SetStatus(1)

    timer.Simple(self:GetHoldLength(), function()
        if(not IsValid(self)) then return end
        self:UnFadeProps()
    end)
end

function ENT:GetHoldLength()
    return self.HoldLength
end

function ENT:AddProp(prop)
	table.insert(self.Props, prop)
end
