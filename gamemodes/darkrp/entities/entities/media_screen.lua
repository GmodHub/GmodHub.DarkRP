AddCSLuaFile()

ENT.Base		= 'media_base'
ENT.PrintName	= 'Screen'
ENT.Category 	= 'RP Media'
ENT.Spawnable	= false

ENT.MediaPlayer = true

ENT.Model 		= 'models/props_building_details/storefront_template001a_bars.mdl'

if (CLIENT) then
	function ENT:Draw()
	end

	hook.Add('PostDrawOpaqueRenderables', 'screens.PostDrawOpaqueRenderables', function()
		for k, v in ipairs(ents.FindByClass('media_screen')) do
			if LocalPlayer():GetPos():Distance(v:GetPos()) < 450 then
				local ang = v:GetAngles()
				ang:RotateAroundAxis(ang:Right(), 90)

				cam.Start3D2D(v:GetPos(), ang, 0.065)
					v:DrawScreen(-950, -560, 1900, 1120)
				cam.End3D2D()
			end
		end
	end)
else
	if (not rp.cfg.Screens[game.GetMap()]) then
		print 'No screens set!'
		return
	end

	hook.Add('InitPostEntity', 'screens.InitPostEntity', function()
		for k, v in ipairs(rp.cfg.Screens[game.GetMap()]) do
			local ent = ents.Create 'media_screen'
			ent:SetPos(v.Pos)
			ent:SetAngles(v.Ang)
			ent:Spawn()
			ent:Activate()
			ent:SetFrozen(1)
			ent:GetPhysicsObject():EnableMotion(false)
		end
	end)
end
