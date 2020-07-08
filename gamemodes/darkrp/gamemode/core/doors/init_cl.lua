local IsValid 		= IsValid
local ipairs 		= ipairs
local LocalPlayer 	= LocalPlayer
local Angle 		= Angle
local Vector 		= Vector

local ents_FindInSphere 		= ents.FindInSphere
local util_TraceLine 			= util.TraceLine
local draw_SimpleTextOutlined 	= draw.SimpleTextOutlined
local team_GetColor 			= team.GetColor
local team_GetName 				= team.GetName
local cam_Start3D2D 			= cam.Start3D2D
local cam_End3D2D 				= cam.End3D2D
local surface_SetDrawColor 		= surface.SetDrawColor
local surface_SetMaterial 		= surface.SetMaterial
local surface_DrawTexturedRect 	= surface.DrawTexturedRect
local rp_orgs_GetBanner 		= rp.orgs.GetBanner

local color_white 	= ui.col.White:Copy()
local color_black 	= ui.col.Black:Copy()
local color_green 	= ui.col.Green:Copy()

local off_ang 		= Angle(0,90,90)

local doorcache 	= {}

timer.Create('rp.RefreshDoorCache', 0.5, 0, function()
	if IsValid(LocalPlayer()) then
		local count = 0
		doorcache 	= {}
		for k, ent in ipairs(ents_FindInSphere(LocalPlayer():GetPos(), 350)) do
			if IsValid(ent) and ent:IsDoor() and (ent:IsPropertyOwnable() or ent:IsPropertyOwned() or ent:IsPropertyTeamOwned() or ent:IsPropertyHotelOwned()) then
				ent.PressKeyText = 'To Open/Close'
				count = count + 1
				doorcache[count] = ent
			end
		end
	end
end)

local h = 0
local a = 255
local function drawtext(text, color)
	color.a = a
	color_black.a = a
	local tw, th = draw_SimpleTextOutlined(text, '3d2d', 0, h, color, 1, 1, 2, color_black)
	h = h + th
end

local trace = {}
local drawFixes = {
	['models/props_c17/door02_double.mdl'] = function(ent, tr, lw)
		local cent = ent:OBBCenter()
		cent.y = cent.y * 0.625
		local lw = ent:LocalToWorld(cent)
		lw.z = lw.z + 17.5

		trace.start = LocalPlayer():GetPos() + LocalPlayer():OBBCenter()
		trace.endpos = lw
		trace.filter = LocalPlayer()
		local tr = util_TraceLine(trace)

		return lw, tr
	end
}
hook('PostDrawTranslucentRenderables', 'rp.doors.PostDrawTranslucentRenderables', function(bDrawingDepth, bDrawingSkybox)
	if bDrawingSkybox then return end

	for _, ent in ipairs(doorcache) do
		if IsValid(ent) and ent:InView() then
			h = 0
			local dist = ent:GetPos():DistToSqr(LocalPlayer():GetPos())
			a = (122500 - dist) / 350

			local lw, tr
			local mdl = ent:GetModel()
			if drawFixes[mdl] then
				lw, tr = drawFixes[mdl](ent)
			else
				lw = ent:LocalToWorld(ent:OBBCenter())
				lw.z = lw.z + 17.5

				trace.start = LocalPlayer():GetPos() + LocalPlayer():OBBCenter()
				trace.endpos = lw
				trace.filter = LocalPlayer()
				tr = util_TraceLine(trace)
			end

			if (tr.Entity == ent) and (lw:DistToSqr(tr.HitPos) < 65) then
				cam_Start3D2D(tr.HitPos + tr.HitNormal, tr.HitNormal:Angle() + off_ang, .03)
					if (ent:GetPropertyName() ~= nil) then
						drawtext(ent:GetPropertyName(), ent:GetPropertyColor() or color_white)
					end

					if ent:IsPropertyOwnable() then
						drawtext(rp.FormatMoney(ent:GetPropertyPrice(LocalPlayer())), color_green)

						drawtext('Press F2 to own', color_white)
					elseif ent:IsPropertyOwned() then
						-- Org own
						local owner = ent:GetPropertyOwner()
						if ent:IsPropertyOrgOwned() and IsValid(owner) and (owner:GetOrg() ~= nil) then
							local org = owner:GetOrg()
							local banner = rp.orgs.GetBanner(org)
							if banner then
								surface_SetDrawColor(255,255,255)
								surface_SetMaterial(banner)
								surface_DrawTexturedRect(-320,-720,640,640)
							end
							drawtext(org, owner:GetOrgColor())
						end

						-- Owner
						if IsValid(owner) then
							drawtext(owner:Name(), owner:GetJobColor())
						end

						-- Co-Owners
						local coOwners = ent:GetPropertyCoOwners() -- player.GetAll()
						local coOwnersCount = #coOwners

						if (coOwnersCount > 0) then
							for k, co in ipairs(coOwners) do
								if (k >= 4) then
									drawtext('and ' .. (coOwnersCount - 3) .. ' co-owners', color_white)
									drawtext('Press F2 to view deed', color_white)
									break
								elseif IsValid(co) then
									drawtext(co:Name(), co:GetJobColor())
								end
							end
						end
					end
				cam_End3D2D()
			end
		end
	end
end)
