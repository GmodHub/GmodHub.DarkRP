util.AddNetworkString('rp.struggle.New')
util.AddNetworkString('rp.struggle.End')
util.AddNetworkString('rp.struggle.Progress')

function PLAYER:GetStruggle(name)
    if self.Struggle and self.Struggle[name] then return true end
    return false
end

function PLAYER:StartStruggle(name)
    local struggle = rp.struggle[name]

    self.Struggle = self.Struggle or {}

    self.Struggle[struggle.name] = struggle
    self.Struggle[struggle.name].progress = 0

    net.Start 'rp.struggle.New'
        net.WriteUInt(struggle.id, 2)
        net.WriteString(struggle.name)
        net.WriteString(struggle.caption)
        net.WriteUInt(struggle.max, 9)
    net.Send(self)

end

hook.Add( "PlayerButtonDown", "rp.Struggle.Keys", function( pl, button )
    if (button == MOUSE_FIRST or button == KEY_G) and pl.Struggle and table.Count(pl.Struggle) > 0 then
        for k,v in pairs(pl.Struggle) do
            if button != v.key then continue end
            if not v.check(pl) then
                net.Start('rp.struggle.End')
                    net.WriteUInt(v.id, 2)
                net.Send(pl)
                pl.Struggle[v.name] = nil
                continue
            end

            if v.progress > 5 then
                v.progress = v.progress + math.random(-2,3)
            else
                v.progress = v.progress + math.random(0,1)
            end

            if (v.progress >= v.max) then
                net.Start('rp.struggle.End')
                    net.WriteUInt(v.id, 2)
                net.Send(pl)
                v.func(pl)
                pl.Struggle[v.name] = nil
                return
            end

            net.Start('rp.struggle.Progress')
                net.WriteUInt(v.id, 2)
                net.WriteUInt(v.progress, 9)
            net.Send(pl)
        end
    end
end)
