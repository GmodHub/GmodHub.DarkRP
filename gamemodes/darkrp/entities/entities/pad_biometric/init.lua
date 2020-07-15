AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

--[[
    Concept:
      Select props with secondary mouse button and mark them with a specific material and then using primary mouse button place a biometric scanner.
    Properties:
      FadeTime float (min 4 sec)
      OrgAccess bool -- To be done
]]

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

--[[function ENT:Think() -- Why override to use inherited class if it's done by default
    self.BaseClass.Think(self)
end]]

function ENT:PlayerUse(pl)
    if(not self.ItemOwner == pl) then return end

    if(not self:IsPropsFaded()) then
        self:FadeProps()
    end
    timer.Simple(self:GetHoldLength(), function()
        if(not IsValid(self)) then return end
        self:UnFadeProps()
    end)
end