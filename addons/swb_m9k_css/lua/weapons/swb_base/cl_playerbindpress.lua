local wep, CT

local function ZoomStep(min, max, step, steps)
	local min_dist = math.tan(math.rad(min / 2))
	local max_dist = math.tan(math.rad(max / 2))
	local pct = 1 - step / (steps - 1)
	local new_dist = min_dist + (max_dist - min_dist) * pct
	local r = math.deg(math.atan(new_dist)) * 2
	return r
end

function SWEP.PlayerBindPress(ply, b, p)
	if p then
		wep = ply:GetActiveWeapon()

		if (not wep._ZoomStep and wep.ZoomSteps) then
			wep._ZoomStep = 0
		end

		if IsValid(wep) and wep.SWBWeapon and wep.dt and wep.dt.State == SWB_AIMING and wep.AdjustableZoom then
			CT = CurTime()

			if b == "invprev" then
				CT = CurTime()

				if CT > wep.ZoomWait and wep._ZoomStep < wep.ZoomSteps - 1 then
					wep._ZoomStep = wep._ZoomStep + 1
					wep.ScopeZoomAmount = ZoomStep(wep.MinZoom, wep.MaxZoom, wep._ZoomStep, wep.ZoomSteps)
					surface.PlaySound("weapons/zoom.wav")
					wep.ZoomWait = CT + 0.15
				end

				return true
			elseif b == "invnext" then
				CT = CurTime()

				if CT > wep.ZoomWait and wep._ZoomStep > 0 then
					wep._ZoomStep = wep._ZoomStep - 1
					wep.ScopeZoomAmount = ZoomStep(wep.MinZoom, wep.MaxZoom, wep._ZoomStep, wep.ZoomSteps)
					surface.PlaySound("weapons/zoom.wav")
					wep.ZoomWait = CT + 0.15
				end

				return true
			end
		end
	end
end

hook.Add("PlayerBindPress", "SWEP.PlayerBindPress (SWB)", SWEP.PlayerBindPress)