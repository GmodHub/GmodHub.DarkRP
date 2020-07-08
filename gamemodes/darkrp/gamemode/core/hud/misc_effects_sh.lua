if (SERVER) then
    util.AddNetworkString("rp.misc_effect_whiteflash")

    function PLAYER:MiscEffect(name)
        net.Ping("rp.misc_effect_" .. name, self)
    end

    return
end

local function whiteFlash()
    local start = RealTime()

    hook.Add("RenderScreenspaceEffects", "Misc_Effect_WhiteFlash", function()
        local mul = 1 - math.min(RealTime() - start, 0.5) * 2
        DrawBloom(-0.5, mul, 1, 1, 1, 1, 0.7, 0.7, 0.7)

        if (mul <= 0) then hook.Remove("RenderScreenspaceEffects", "Misc_Effect_WhiteFlash") end
    end)
end
net.Receive("rp.misc_effect_whiteflash", whiteFlash)
