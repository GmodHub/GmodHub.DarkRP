util.AddNetworkString('rp.ApplyGenome')

net('rp.ApplyGenome', function(len, pl)
    if not pl.GenomeTeam then
        pl:Notify(NOTIFY_ERROR, term.Get("CannotAlterGenome"))
        return
    end

    local defense = math.abs(math.floor(net.ReadUInt(5)))
    local speed = math.abs(math.floor(net.ReadUInt(5)))
    local attack = math.abs(math.floor(net.ReadUInt(5)))

    if pl.Genome.d == defense and pl.Genome.s == speed and pl.Genome.a == attack then return end
    local max = (pl:IsChief() and 33 or 30) + (pl:IsVIP() and 3 or 0)
    if (defense + speed + attack) > max or (defense + speed + attack) < 0 then
        pl:Notify(NOTIFY_ERROR, term.Get("GenomeOverflowed"))
        defense = 10
        speed = 10
        attack = 10
    end

    local name, model = rp.GetGenomeSpecialName(defense, speed, attack)
    pl.Genome = { d = defense, s = speed, a = attack}

    local defenseVal = (defense - 10) * 2.5
    local speedVal = (speed - 10) * 2.5
    local attackVal = (attack - 10) * 2.5

    pl:Notify(NOTIFY_SUCCESS, term.Get("GenomeAltered"), (defenseVal < 0 and "-" or "+"), math.abs(defenseVal), 100 + math.floor(speedVal), 100 + attackVal)
    rp.NotifyAll(NOTIFY_GENERIC, term.Get('ChangeJob'), pl, name)
	pl:SetNetVar('job', name)

    pl:StripWeapons()
    hook.Call("PlayerLoadout", GAMEMODE, pl)
    pl.GenomeTeam = false
end)

hook('PlayerLoadout', 'rp.Genome.PlayerLoadout', function(pl)
    if not pl:IsCP() then return end
    pl:SetNetVar('CanGenomeDisguise', nil)
    local name, model = rp.GetGenomeSpecialName(pl.Genome.d, pl.Genome.s, pl.Genome.a)
    local loadout = rp.GetGenomeLoadout(pl.Genome.d, pl.Genome.s, pl.Genome.a)
    local speedVal = (pl.Genome.s - 10) * 2.5

    pl:SetModel(model)
    for k,v in pairs(loadout) do
        if (v == "\0") then
            pl:SetNetVar('CanGenomeDisguise', true)
            continue
        end
        pl:Give(v)
    end
    pl:SetRunSpeed(pl:GetRunSpeed() + speedVal)
    pl:SetWalkSpeed(pl:GetWalkSpeed() + speedVal)
end)

hook('ScalePlayerDamage', 'rp.Genome.ScalePlayerDamage', function(pl, hit, dmginfo)
    if pl:IsCP() then
        local defenseVal = (100 + ((pl.Genome.d - 10) * 2.5))/100
        dmginfo:ScaleDamage( defenseVal )
    elseif dmginfo:GetAttacker():IsCP() then
        local attackVal = (100 + ((dmginfo:GetAttacker().Genome.a - 10) * 2.5))/100
        dmginfo:ScaleDamage( attackVal )
    end
end)

hook('OnPlayerChangedTeam', 'rp.Genome.OnPlayerChangedTeam', function(pl, prev, team)
    pl:SetNetVar('CanGenomeDisguise', nil)
    if rp.teams[team].police and not pl.GenomeTeam then
        pl.GenomeTeam = true
        pl.Genome = { d = 10, s = 10, a = 10}
        local max = (pl:IsChief() and 33 or 30) + (pl:IsVIP() and 3 or 0)
        net.Start('rp.ApplyGenome')
            net.WriteUInt(max, 6)
            net.WriteBool(true)
            net.WriteBool(false)
        net.Send(pl)
    end
end)
