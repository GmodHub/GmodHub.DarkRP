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
    local ent = net.ReadEntity()
    local add = tobool(net.ReadBit() or 0)
    local targ = net.ReadPlayer()

    if not IsValid(ent) or ent:GetClass() ~= "pad_biometric" then return end
    if not IsValid(targ) or not isplayer(targ) then return end
    if ent:CPPIGetOwner() ~= pl then return end

    if add and not table.HasValue(ent.AllowedPlayers, targ) then
        table.insert(ent.AllowedPlayers, targ)
        pl:Notify(NOTIFY_SUCCESS, term.Get('BiometricAddedAccess'), targ)
    elseif table.HasValue(ent.AllowedPlayers, targ) then
        table.RemoveByValue(ent.AllowedPlayers, targ)
        pl:Notify(NOTIFY_SUCCESS, term.Get('BiometricRemovedAccess'), targ)
    end
end)

net('rp.biometric.Team', function(len, pl)
    local ent = net.ReadEntity()
    local add = net.ReadBool()
    local team = net.ReadInt(9) or 1

    if not IsValid(ent) or ent:GetClass() ~= "pad_biometric" then return end
    if not rp.teams[team] then return end
    if ent:CPPIGetOwner() ~= pl then return end

    if add and not table.HasValue(ent.AllowedTeams, team) then
        table.insert(ent.AllowedTeams, team)
        pl:Notify(NOTIFY_SUCCESS, term.Get('BiometricAddedAccess'), rp.teams[team].name)
    elseif table.HasValue(ent.AllowedTeams, team) then
        table.RemoveByValue(ent.AllowedTeams, team)
        pl:Notify(NOTIFY_SUCCESS, term.Get('BiometricRemovedAccess'), rp.teams[team].name)
    end
end)

net('rp.biometric.ToggleOrg', function(len, pl)
    local ent = net.ReadEntity()
    local add = net.ReadBool()

    if not IsValid(ent) or ent:GetClass() ~= "pad_biometric" then return end
    if not pl:GetOrg() then return end
    if ent:CPPIGetOwner() ~= pl then return end

    pl:Notify(NOTIFY_SUCCESS, term.Get('BiometricToggledOrgOwn'))

    if add then
        ent:SetOrg(pl:GetOrg())
    else
        ent:SetOrg('')
    end
end)

net('rp.biometric.Org', function(len, pl)
    local ent = net.ReadEntity()
    local org = net.ReadString()
    local remove = net.ReadBool()

    if not IsValid(ent) or ent:GetClass() ~= "pad_biometric" then return end
    if ent:CPPIGetOwner() ~= pl then return end

    local exists = false
    for _, v in ipairs(rp.orgs.GetOnline()) do
        if (org == v.Name) then
            exists = true
            break
        end
    end
    if not exists then return end

    if remove and org == ent:GetOrg1() or org == ent:GetOrg2() or org == ent:GetOrg3() then
        if ent:GetOrg1() == org then
            ent:SetOrg1('')
        elseif ent:GetOrg2() == org then
            ent:SetOrg2('')
        else
            ent:SetOrg3('')
        end

        pl:Notify(NOTIFY_SUCCESS, term.Get('BiometricRemovedAccess'), org)
    else
        if ent:GetOrg1() == '' then
            ent:SetOrg1(org)
        elseif ent:GetOrg2() == ''  then
            ent:SetOrg2(org)
        elseif ent:GetOrg3() == '' then
            ent:SetOrg3(org)
        end

        pl:Notify(NOTIFY_SUCCESS, term.Get('BiometricAddedAccess'), org)
    end
end)

net('rp.biometric.ApplyAll', function(len, pl)
    local ent = net.ReadEntity()

    if not IsValid(ent) or ent:GetClass() ~= "pad_biometric" then return end
    if ent:CPPIGetOwner() ~= pl then return end

    local i = 0

    for k,v in pairs(pl:GetItems('biometrics')) do
        if v:CPPIGetOwner() == pl and v ~= ent then
            v.AllowedPlayers = ent.AllowedPlayers
            v.AllowedTeams = ent.AllowedTeams
            v:SetOrg(ent:GetOrg())
            v:SetOrg1(ent:GetOrg1())
            v:SetOrg2(ent:GetOrg2())
            v:SetOrg3(ent:GetOrg3())

            i = i + 1
        end
    end

    if i > 0 then
        pl:Notify(NOTIFY_SUCCESS, term.Get('BiometricCopiedSettings'), i)
    end

end)

function ENT:Initialize()
    self:SetModel("models/maxofs2d/button_04.mdl")
    self:SetUseType( SIMPLE_USE )
	self.AllowedPlayers 	= {}
	self.AllowedTeams 		= {}

    self.BaseClass.Initialize(self)
end

function ENT:Use(pl)
    if self:CPPIGetOwner() == pl then
        net.Start("rp.EntityUse")
            net.WriteEntity(self)
            net.WriteUInt(table.Count(self.AllowedPlayers), 9)
            for k,v in pairs(self.AllowedPlayers) do 
                net.WritePlayer(v)
            end
            net.WriteUInt(table.Count(self.AllowedTeams), 9)
            for k,v in pairs(self.AllowedTeams) do 
                net.WriteUInt(v, 9)
            end
        net.Send(pl)
        return
    end
end

function ENT:PlayerUse(pl)
    if self:CPPIGetOwner() == pl then self:ValidUse() return end
    if table.HasValue(self.AllowedPlayers, pl) then self:ValidUse() return end
    if table.HasValue(self.AllowedTeams, pl:Team()) then self:ValidUse() return end
    if table.HasValue(self.AllowedTeams, pl:Team()) then self:ValidUse() return end
    if (pl:GetOrg() == self:GetOrg()) or (pl:GetOrg() == self:GetOrg1()) or (pl:GetOrg() == self:GetOrg2()) or (pl:GetOrg() == self:GetOrg3()) then self:ValidUse() return end

    self:InValidUse()
end

function ENT:CanHack()
	return true
end

function ENT:Hack(ply)
    self:ValidUse()
end
