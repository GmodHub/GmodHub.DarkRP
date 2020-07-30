dash.IncludeCL 'cl_init.lua'
dash.IncludeSH 'shared.lua'

util.AddNetworkString('rp.biometric.Unlock')
util.AddNetworkString('rp.biometric.Team')
util.AddNetworkString('rp.biometric.Player')
util.AddNetworkString('rp.biometric.ToggleOrg')
util.AddNetworkString('rp.biometric.Org')
util.AddNetworkString('rp.biometric.ApplyAll')

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

function ENT:CanHack()
	return true
end

function ENT:Hack(ply)
    if(not self:IsPropsFaded()) then
        self:FadeProps()
    end
    timer.Simple(self:GetHoldLength(), function()
        if(not IsValid(self)) then return end
        self:UnFadeProps()
    end)
end
