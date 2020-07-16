AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

function ENT:Initialize()
    self:SetModel("models/maxofs2d/button_04.mdl")
    self:PhysicsInit( SOLID_VPHYSICS )
    self:SetMoveType( MOVETYPE_VPHYSICS )
    self:SetSolid( SOLID_VPHYSICS )
    self:SetUseType( SIMPLE_USE )
end

function ENT:Use(activator, caller, type, value)
    if IsValid(activator) and activator:IsPlayer() then
        self.User = activator
    end

    self.BaseClass.Use(self, activator, caller, type, value)
end

function ENT:Think()
    self.BaseClass.Think(self)
end

function ENT:PlayerUse(pl)
    if(not pl:CanAfford(self:Getprice())) then return end

    if(self:GetOneTimeUse()) then
        if(not self:IsPropsFaded()) then
            self:FadeProps()
            if(self.ItemOwner ~= pl) then
                pl:AddMoney(-self:Getprice())
            end
        end
    else
        self:FadeProps()
        timer.Simple(self:GetHoldLength(), function()
            if(not IsValid(self)) then return end
            self:UnFadeProps()
        end)
        if(self.ItemOwner ~= pl) then
            pl:AddMoney(-self:Getprice())
        end
    end
end