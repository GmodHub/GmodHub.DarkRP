require 'fps'

if not engine.RealFrameTime then return end

local FPS       = engine.RealFrameTime

local LagTime   	= 0
local FullTick 		= engine.TickInterval()
local AdjustedTick	= FullTick * 1.3
local PropsFroze 	= false

local function FreezeProps()
    for k, v in ipairs(ents.GetAll()) do
        if IsValid(v) and rp.nodamage[v:GetClass()] then
            local phys = v:GetPhysicsObject()
            if IsValid(phys) then
                phys:EnableMotion(false)
            end
            constraint.RemoveAll(v)
        end
    end
end

local function RemoveHighRisk()
	for k, v in ipairs(ents.GetAll()) do
		if v.HighLagRisk or (v:IsNPC() and not scripted_ents.IsBasedOn("npc_rp_base", v:GetClass())) or v:IsVehicle() then
			v:Remove()
		end
	end
end

hook('Tick', 'rp.antilag.Tick', function()
    if (AdjustedTick <= FPS()) then
        LagTime = LagTime + FullTick
        if (LagTime >= 3) and (not PropsFroze) then
            ba.notify_staff('Сервер очень сильно тормозит, все пропы были заморожены и отсоединены, пожалуйста, будьте бдительны, если это повториться, быстро найдите причину.')
            FreezeProps()
            PropsFroze = true
        elseif (LagTime >= 5) then
            ba.notify_staff('Сервер очень сильно тормозит уже больше 5 секунд, опасные энтити были удалены, все пропы снова заморожены, быстро найдите причину СЕЙЧАС ЖЕ!!')
            FreezeProps()
            RemoveHighRisk()
            LagTime = 0
        end
    else
        LagTime = 0
        PropsFroze = false
    end
end)
