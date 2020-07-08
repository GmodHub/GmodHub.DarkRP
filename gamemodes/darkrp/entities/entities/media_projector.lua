AddCSLuaFile()

ENT.Base				= 'media_base'
ENT.PrintName			= 'Projector'
ENT.Category 			= 'RP Media'
ENT.Spawnable			= false

ENT.MediaPlayer = true
ENT.RemoveOnJobChange 	= true

if (not rp.cfg.Theaters[game.GetMap()]) then
	print 'No projector pos set!'
	return
end

ENT.Model = rp.cfg.Theaters[game.GetMap()].Projector.BindModel or 'models/props/cs_office/projector.mdl'

if (SERVER) then
	function ENT:CanUse(pl)
		return (pl:Team() == TEAM_CINEMAOWNER) or pl:IsSuperAdmin()
	end

	hook('InitPostEntity', 'theater.InitPostEntity', function()
		local cfg = rp.cfg.Theaters[game.GetMap()].Projector

		if cfg.BindModel then
			local found = false

			for k, v in ipairs(ents.FindByClass('func_brush')) do
				if (v:GetModel() == cfg.BindModel) then
					found = true
					cfg.Pos = v:GetPos()
					cfg.Ang = v:GetAngles()
					v:Remove()
					break
				end
			end

			if (!found) then
				print("Couldn't find BindModel entity for theater projector!")
				return
			end
		end

		if cfg.SoundOrigin then
			scripted_ents.Register({Type = 'anim'}, 'media_sound')
			local sorig = ents.Create 'media_sound'
			sorig:SetPos(cfg.SoundOrigin)
			sorig:Spawn()
		end

		local proj = ents.Create 'media_projector'
		proj:SetPos(cfg.Pos)
		proj:SetAngles(cfg.Ang)
		proj:Spawn()
		proj:SetMoveType(MOVETYPE_NONE)
		proj:SetFrozen(1)
	end)
else
	function ENT:OnPlay(media)
		media:set3DFadeMax(3000)
	end

	local orig
	function ENT:GetSoundOrigin()
		if (not orig) then
			orig = ents.FindByClass('media_sound')[1]
		end
		return orig
	end

	function ENT:Draw()
		self:DrawModel()
	end

	local proj
	local dat = rp.cfg.Theaters[game.GetMap()].Screen
	hook.Add('PostDrawOpaqueRenderables', 'theater.PostDrawOpaqueRenderables', function()
		if IsValid(proj) and IsValid(LocalPlayer()) and LocalPlayer():GetPos():Distance(proj:GetPos()) < 450 then
			cam.Start3D2D(rp.cfg.Theaters[game.GetMap()].Screen.Pos, rp.cfg.Theaters[game.GetMap()].Screen.Ang, rp.cfg.Theaters[game.GetMap()].Screen.Scale)
				proj:DrawScreen(-360,400,1920,1080)
			cam.End3D2D()
		else
			proj = ents.FindByClass('media_projector')[1]
		end
	end)
end
