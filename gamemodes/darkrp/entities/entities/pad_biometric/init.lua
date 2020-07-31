dash.IncludeCL 'cl_init.lua'
dash.IncludeSH 'shared.lua'

util.AddNetworkString('rp.biometric.Unlock')
util.AddNetworkString('rp.biometric.Team')
util.AddNetworkString('rp.biometric.Player')
util.AddNetworkString('rp.biometric.ToggleOrg')
util.AddNetworkString('rp.biometric.Org')
util.AddNetworkString('rp.biometric.ApplyAll')

net('rp.biometric.Unlock', function(len, pl)
    local pad = pl:GetEyeTrace().Entity
    if not IsValid(pad) or pad:GetClass() ~= "pad_biometric" then return end
    pad:PlayerUse(pl)
end)

net('rp.biometric.Player', function(len, pl)
    local pad = pl:GetEyeTrace().Entity
    if not IsValid(pad) or pad:GetClass() ~= "pad_biometric" then return end
    local add = net.ReadBit()
    local targ = net.ReadPlayer()
end)

function ENT:Initialize()
    self:SetModel("models/maxofs2d/button_04.mdl")
    self:SetUseType( SIMPLE_USE )

    self.BaseClass.Initialize(self)
end

function ENT:CanNetworkUse(pl)
	return self:CPPIGetOwner() == pl
end

function ENT:CanUse(pl)
	return self:CPPIGetOwner() == pl
end

function ENT:PlayerUse(pl)
    if self:CPPIGetOwner() == pl then
        self:ValidUse()
        return
    end
end

function ENT:CanHack()
	return true
end

function ENT:Hack(ply)
    self:ValidUse()
end
