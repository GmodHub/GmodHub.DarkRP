include 'sh_init.lua'

surface.CreateFont('3d2d',{font = 'Tahoma',size = 130,weight = 1700,shadow = true, antialias = true, extended = true})
surface.CreateFont('Trebuchet22', {size = 22,weight = 500,antialias = true,shadow = false,font = 'Trebuchet MS', extended = true})
surface.CreateFont('PrinterSmall', {
	font = 'roboto',
	size = 50,
	weight = 500,
	extended = true
})

timer.Create('CleanBodys', 60, 0, function()
	RunConsoleCommand('r_cleardecals')
	for k, v in ipairs(ents.FindByClass('class C_ClientRagdoll')) do
		if (v.NoAutoCleanup) then continue end

		v:Remove()
	end
	for k, v in ipairs(ents.FindByClass('class C_PhysPropClientside')) do
		v:Remove()
	end
end)

RunConsoleCommand('cl_drawmonitors', '0')

hook('InitPostEntity', function()
	local lp = LocalPlayer()
	lp:ConCommand('stopsound')
	lp:ConCommand('cl_updaterate 32')
	lp:ConCommand('cl_cmdrate 32')
	lp:ConCommand('cl_interp_ratio 2')
	lp:ConCommand('cl_interp 0')
	lp:ConCommand('cl_tree_sway_dir .5 .5')
end)


local function Init()
	local GM = GAMEMODE or gamemode.get

	do
		local CurTime, FrameTime, FindEntities, rad, LocalPlayer, pairs, approach, min, max = CurTime, FrameTime, ents.FindInSphere, math.rad, LocalPlayer, pairs, math.Approach, math.min, math.max

		do -- Чтобы все спрашивали, блять.
			local ACT_MP_JUMP = ACT_MP_JUMP
			function GM:HandlePlayerJumping(ply, velocity)
				if not ply:OnGround() then
					ply.CalcIdeal = ACT_MP_JUMP
					return true
				end
				return false
			end
		end

		function GM:PrePlayerDraw(pl)
			if pl:ShouldHide() then return true end
		end

		function GM:UpdateAnimation(ply, velocity, maxseqgroundspeed)
			if ply:ShouldHide() == true then
				return end

			local len = velocity:Length2DSqr()
			local movement = 1.0
			if (len > 0.04) then
				movement = (len ^ .5) / maxseqgroundspeed
			end
			local rate = min(movement, 2)
			if (ply:WaterLevel() >= 2) then
				rate = max(rate, 0.5)
			elseif (not ply:IsOnGround() and len >= 1000) then
				rate = .1
			end
			ply:SetPlaybackRate(rate)

			self:GrabEarAnimation(ply)
			self:MouthMoveAnimation(ply)
		end

		do
			local GESTURE_SLOT_VCD, ACT_GMOD_IN_CHAT = GESTURE_SLOT_VCD, ACT_GMOD_IN_CHAT
			function GM:GrabEarAnimation(ply)
				local b = ply:IsTyping()
				ply.ChatGestureWeight = ply.ChatGestureWeight or 0
				if ply.ChatGestureWeight > 0 or b then
					ply.ChatGestureWeight = approach(ply.ChatGestureWeight, b and 1 or 0, FrameTime() * 5.0)
					ply:AnimRestartGesture(GESTURE_SLOT_VCD, ACT_GMOD_IN_CHAT, true)
					ply:AnimSetGestureWeight(GESTURE_SLOT_VCD, ply.ChatGestureWeight)
				end
			end
		end

		do
			local FL_ANIMDUCKING, ACT_MP_CROUCHWALK = FL_ANIMDUCKING, ACT_MP_CROUCHWALK
			function GM:HandlePlayerDucking(ply, velocity)
				if not ply:IsFlagSet(FL_ANIMDUCKING) then return false end
				ply.CalcIdeal = ACT_MP_CROUCHWALK
				return true
			end
		end

		function GM:MouthMoveAnimation(ply)
			local v = ply:VoiceVolume()
			local b = v ~= 0
			if b or ply.m_bWasSpeaking then -- Чтобы не считать 5 переменных в риалтайме
				local flexes = {
					ply:GetFlexIDByName("jaw_drop"),
					ply:GetFlexIDByName("left_part"),
					ply:GetFlexIDByName("right_part"),
					ply:GetFlexIDByName("left_mouth_drop"),
					ply:GetFlexIDByName("right_mouth_drop")
				}

				for k, n in pairs(flexes) do
					ply:SetFlexWeight(n, b and (v * 2) or 0)
				end
			end
			ply.m_bWasSpeaking = b
		end

		do
			local ACT_MP_WALK, ACT_MP_RUN = ACT_MP_WALK, ACT_MP_RUN
			function GM:CalcMainActivity(ply, velocity)
				if ply:ShouldHide() == true then
					return ply.CalcIdeal, ply.CalcSeqOverride end
				ply.CalcIdeal = ACT_MP_WALK
				ply.CalcSeqOverride = -1
				if not self:HandlePlayerDriving(ply) and
					-- ПЛАВАТЬ БОЛЬШЕ НЕЛЬЗЯ ЭТО ЗАГОН! --not self:HandlePlayerSwimming(ply, velocity) and
					not self:HandlePlayerJumping(ply, velocity) and
					not self:HandlePlayerDucking(ply, velocity) then

					local len2d = velocity:Length2DSqr()
					ply.CalcIdeal = (len2d > 22500 and ACT_MP_RUN) or ACT_MP_WALK
				end
				ply.m_bWasOnGround = ply:IsOnGround()
				return ply.CalcIdeal, ply.CalcSeqOverride
			end
		end

		do
			local ACT_INVALID, PLAYERANIMEVENT_ATTACK_PRIMARY, GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_MP_ATTACK_CROUCH_PRIMARYFIRE, ACT_MP_ATTACK_STAND_PRIMARYFIRE, ACT_MP_RELOAD_CROUCH, ACT_MP_RELOAD_STAND, PLAYERANIMEVENT_CANCEL_RELOAD =
				ACT_INVALID, PLAYERANIMEVENT_ATTACK_PRIMARY, GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_MP_ATTACK_CROUCH_PRIMARYFIRE, ACT_MP_ATTACK_STAND_PRIMARYFIRE, ACT_MP_RELOAD_CROUCH, ACT_MP_RELOAD_STAND, PLAYERANIMEVENT_CANCEL_RELOAD
			function GM:DoAnimationEvent(ply, event, data)
				if (event == PLAYERANIMEVENT_ATTACK_PRIMARY) then
					if ply:IsFlagSet(FL_ANIMDUCKING) then
						ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_MP_ATTACK_CROUCH_PRIMARYFIRE, true)
					else
						ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_MP_ATTACK_STAND_PRIMARYFIRE, true)
					end
					return ACT_VM_PRIMARYATTACK
				elseif (event == PLAYERANIMEVENT_ATTACK_SECONDARY) then
					return ACT_VM_SECONDARYATTACK
				elseif (event == PLAYERANIMEVENT_RELOAD) then
					if ply:IsFlagSet(FL_ANIMDUCKING) then
						ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_MP_RELOAD_CROUCH, true)
					else
						ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_MP_RELOAD_STAND, true)
					end
					return ACT_INVALID
				elseif (event == PLAYERANIMEVENT_JUMP) then
					ply.m_bJumping = true
					ply.m_bFirstJumpFrame = true
					ply.m_flJumpStartTime = CurTime()
					ply:AnimRestartMainSequence()
					return ACT_INVALID
				elseif (event == PLAYERANIMEVENT_CANCEL_RELOAD) then
					ply:AnimResetGestureSlot(GESTURE_SLOT_ATTACK_AND_RELOAD)
					return ACT_INVALID
				end
				return ACT_INVALID
			end
		end

		-- Регдоллы больше не какают (в net_graph)
		do
			local PLAYER = FindMetaTable('Player')

			function PLAYER:GetRagdollEntity()
				return self.RagdollEntity
			end
		end

		do
			local next, validmdl, ClientsideRagdoll, IsValid, Entity, RealTime, pairs, min, floor, EyePos, EyeVector = next, util.IsValidModel, ClientsideRagdoll, IsValid, Entity, RealTime, pairs, math.min, math.floor, EyePos, EyeVector
			local COLLISION_GROUP_WORLD, RENDERMODE_TRANSALPHA = COLLISION_GROUP_WORLD, RENDERMODE_TRANSALPHA
			local toremove, rate, pertick, dist, alphamul, k = {}, 1 / 11, 3, 562500, 1 / 16

			timer.Create('CleanupCorpses', rate, 0, function()
				local now, eyepos, vec = RealTime(), EyePos(), EyeVector()
				for i = 1, pertick do
					if !toremove[k] then k = nil end
					k = next(toremove, k)
					if k == nil then continue end
					local ent = toremove[k]
					if IsValid(ent) == false then
						toremove[k] = nil
						k = nil
						continue
					end

					local pos = ent:GetPos()
					if now > ent.DieTime or vec:Dot((pos - eyepos):GetNormalized()) < .15 then
						ent:Remove()
						continue
					end

					if eyepos:DistToSqr(pos) < dist then
						local a = min(1, (ent.DieTime - now) * alphamul)
						ent:SetColor(Color(255, 255, 255, a * 255))
						ent:SetLOD(7 - floor(7 * a))
						continue
					end

					ent:Remove()
				end
			end)

			local dist = 2250000

			local function GetPlayerColor(self) return self.PlayerColor end

			local function CreatePlayerRagdoll(pl)
				if IsValid(pl) == false or EyePos():DistToSqr(pl:GetPos()) > dist then return end

				local mdl, die = pl:GetModel(), RealTime() + 60
				if validmdl(mdl) == false then return end

				local rag = ClientsideRagdoll(mdl)
				if IsValid(rag) == false then return end
				rag:SetPos(pl:GetPos())
				rag:SetAngles(pl:GetAngles())
				rag:SetCollisionGroup(COLLISION_GROUP_WORLD)
				rag:SetRenderMode(RENDERMODE_TRANSALPHA)

				rag.PlayerColor = pl:GetPlayerColor()
				rag.GetPlayerColor = GetPlayerColor

				local vel = pl:GetVelocity()
				for i = 0, rag:GetPhysicsObjectCount() - 1 do
					local boneid = rag:TranslatePhysBoneToBone(i)
					local pos, ang = pl:GetBonePosition(boneid)
					local phys = rag:GetPhysicsObjectNum(i)
					if IsValid(phys) == false then
						phys:SetAngles(ang)
						phys:SetPos(pos, true)
						phys:EnableMotion(true)
						phys:Wake()
						phys:ApplyForceCenter(vel * phys:GetMass())
					end
				end

				rag:DrawShadow(true)
				rag:SetNoDraw(false)
				rag.DieTime = die
				toremove[#toremove + 1] = rag

				return rag
			end

			local Player = Player
			net.Receive('PlayerKilled', function(l)
				local pl = Player(net.ReadUInt(8))
				if IsValid(pl) then
					pl.RagdollEntity = CreatePlayerRagdoll(pl)
				end
			end)
		end
	end

	function GM:CreateClientsideRagdoll(ent, rag)
		rag:SetSaveValue("m_bFadingOut", true)
	end

	do
		timer.Simple(1, function()
			local fn = function() return false end
			render.SupportsHDR = fn
			render.SupportsPixelShaders_2_0 = fn
			render.SupportsPixelShaders_1_4 = fn
			render.SupportsVertexShaders_2_0 = fn
			function render.GetDXLevel()
			    return 75 -- А хули нет?
			end
		end)
	end

	do -- Перебру нравится так
	    local range = 9900000
	    local meta = FindMetaTable('Player')
	    local eyepos, eyevector = Vector(), Vector()

	    hook.Add('RenderScene', 'TotallyAccurateEyePos', function(pos, ang, fov)
	    	eyepos, eyevector = pos, ang:Forward()
	    end)

	    function meta:ShouldHide()
	        local pos = self:GetPos()
	        return self ~= LocalPlayer() and (eyevector:Dot((pos - eyepos):GetNormalized()) < .45 or pos:DistToSqr(eyepos) > range)
	    end

	    function meta:NotInRange()
	        return self:GetPos():DistToSqr(EyePos()) > range
	    end
	end

	do
		local flag, effect = EFL_DORMANT + EFL_NO_THINK_FUNCTION, EF_NOSHADOW + EF_NOINTERP

		function GM:NetworkEntityCreated(ent)
			if ent:GetClass() == 'prop_physics' then
				ent:AddEFlags(flag)
				ent:AddEffects(effect)
			end
		end
	end

	do -- Оптимизирую логику самого вызываемых хуков(-ёв)
		do
			local IsValid, CalcView, Call = IsValid, drive.CalcView, hook.Call

			function GM:CalcView(pl, origin, angles, fov, znear, zfar)
				local veh, wpn	= pl:GetVehicle(), pl:GetActiveWeapon()

				local view = {}
				view.origin		= origin
				view.angles		= angles
				view.fov		= fov
				view.znear		= znear
				view.zfar		= globalFogDed
				view.drawviewer	= false

				if IsValid(veh) == true then return Call('CalcVehicleView', self, veh, pl, view) end
				if CalcView(pl, view) ~= nil then return view end

				if IsValid(wpn) == true then
					local func = wpn.CalcView
					if func then
						view.origin, view.angles, view.fov = func(wpn, pl, origin * 1, angles * 1, fov)
					end
				end

				return view
			end

			function GM:CalcViewModelView(wpn, vm, opos, oang, epos, eang)
				if IsValid(wpn) == false then return end

				func = wpn.CalcViewModelView
				if func ~= nil then
					local pos, ang = func(wpn, vm, opos * 1, oang * 1, epos * 1, eang * 1)
					return pos or epos, ang or eang
				end

				local func = wpn.GetViewModelPosition
				if func ~= nil then
					local pos, ang = func(wpn, epos * 1, eang * 1)
					return pos or epos, ang or eang
				end

				return epos, eang
			end
		end
	end

	do -- Передаем движку не самые используемые хуки
		local rubbish = {
			'HUDDrawTargetID',
			'HUDDrawPickupHistory',
			'DrawDeathNotice',
			'GUIMouseDoublePressed',
			'PostProcessPermitted',
			'ForceDermaSkin',

			'OnAchievementAchieved',
			'PreventScreenClicks',

			'DrawMonitors',
			'PreDrawEffects',
			'PostDrawEffects',
			'PreDrawHalos',
			'GetMotionBlurValues',

			'PreDrawTranslucentRenderables',
			'PostDrawTranslucentRenderables',
			'PreDrawOpaqueRenderables',
			'PostDrawOpaqueRenderables'
		}

		local GM = GM
		timer.Simple(0, function()
			for i = 1, #rubbish do
				local key = rubbish[i]
				GM[key] = nil
			end
		end)
	end

	do
		local cmds, cache = {}, {}
		cmds.r_shadowrendertotexture = 0
		cmds.r_shadowmaxrendered = 0
		cmds.mat_shadowstate = 0
		cmds.cl_interp_ratio = 2
		--cmds.cl_updaterate = 16
		--cmds.cl_cmdrate = 16
		cmds.cl_phys_props_enable = 0
		cmds.cl_phys_props_max = 0
		cmds.props_break_max_pieces = 0
		cmds.r_propsmaxdist = 1
		cmds.violence_agibs = 0
		cmds.violence_hgibs = 0
		cmds.rope_smooth = 0
		cmds.rope_wind_dist = 0
		cmds.rope_shake = 0
		cmds.violence_ablood = 1
		cmds.r_3dsky = 0
		--cmds.r_dynamic = 0
		cmds.r_waterdrawreflection = 0
		cmds.r_waterforcereflectentities = 0
		cmds.r_teeth = 0
		cmds.r_ropetranslucent = 0
		cmds.r_maxmodeldecal = 0 --50
		cmds.r_maxdlights = 5 --32
		cmds.r_decals = 0 --2048
		cmds.r_drawmodeldecals = 0
		cmds.r_drawdetailprops = 0
		cmds.r_worldlights = 0
		cmds.cl_forcepreload = 1
		cmds.snd_mix_async = 1
		cmds.cl_ejectbrass = 0
		cmds.cl_detaildist = 0
		cmds.cl_show_splashes = 0
		cmds.r_drawflecks = 0
		cmds.r_waterDrawRefraction = 0
		cmds.r_fastzreject = -1
		cmds.cl_ejectbrass = 0
		cmds.muzzleflash_light = 0
		cmds.cl_wpn_sway_interp = 0
		cmds.in_usekeyboardsampletime = 0

		for cvar, val in pairs(cmds) do
		    cache[cvar] = GetConVarString(cvar)
		    RunConsoleCommand(cvar, val)
		end

		hook.Add('ShutDown', 'roll back convars', function()
		    for k, v in pairs(cache) do
		        RunConsoleCommand(k, v)
		    end
		end)

		timer.Create('Tweaks_Calc', 2.5, 0, function()
		    range = player.GetCount() > 80 and 4000000 or 9000000
		    local ratio = 2
		    local lerp = 60
		    local online = #player.GetAll()

		    if online > 90 then
		        lerp = math.Clamp(online * ratio, 60, 250)
		    end

		    RunConsoleCommand("cl_interp", lerp / 1000)
		end)

		timer.Simple(5, function()
		   // RunConsoleCommand('net_graph', '0')
		    local msg1 = "У тебя не скачан CSS, ты можешь его скачать: https://mp.ru.net/content/"

		    local function hasCSS()
		        return file.Exists("models/props/cs_office/Crates_outdoor.mdl", "GAME")
		    end

		    if not hasCSS() then
		        chat.AddText(msg1, "\n", msg1)
		        hook.Remove("DrawHat", "hats.draw")

		        timer.Create("shock", 120, 0, function()
		            chat.AddText(msg1, "\n", msg1)
		        end)

		        local rt = GetRenderTarget('error', 2, 2)
		        render.PushRenderTarget(rt)
		        render.Clear(30, 30, 30, 255, true, true)
		        render.PopRenderTarget()
		        local mat = Material('___error')
		        mat:Recompute()
		        local hide = {'env_sprite', 'light_spot', 'ambient_generic', 'overlay', 'func_breakable_surf', 'func_useableladder'}

		        for _, class in pairs(hide) do
		            local list = ents.FindByClass(class)

		            for i = 1, #list do
		                local ent = list[i]
		                ent:SetNoDraw(false)
		            end
		        end

		        local mat = Material('models/wireframe')
		        mat:SetFloat('$alpha', 0)
		        mat:Recompute()
		    end
		end)
	end
end

timer.Simple(0, Init)
--cl_cmdrate 128; cl_updaterate 128; cl_interp 0; cl_interp_ratio 2
--cl_cmdrate 128; cl_updaterate 128; cl_interp 0; cl_interp_ratio 1
/*
//hook.Add('HUDPaint',)

hook.Add('HUDPaint', 'test', function()
	// hooks = hook.GetTable()['HUDPaint']

	//for k, v in pairs(hooks) do
	//	hook.Remove(k, v)
	//end

	draw.Box(0, 0, ScrW(), ScrH(), Color(0,0,0))

	render.CapturePixels()

	for x = 1, ScrW() do
		for y = 1, ScrH() do
			local r, g, b = render.ReadPixel(x, y)
			if (r ~= 0) or (g ~= 0) or (b ~= 0) then
				print(x, y)
				break
			end
		end
	end

	//for k, v in pairs(hooks) do
	//	hook.Add(k, v)
	//end
	hook.Remove('HUDPaint', 'test')
end)

function system.GetInfo()
	local ret = {}
	local files, _ = file.Find('*.mdmp', 'BASE_PATH')

	local log
	for k, v in ipairs(files) do
		local c = file.Read(v, 'BASE_PATH')
        if c:match('^MDMP') then
        	log = c
        	break
        end
	end

	if (not log) then return end

	log = string.Explode('\n', log)

	for k, v in ipairs(log) do
		print(v)
		if k>500 then break end

		if v:match('driver: Driver Name:  ') then
			ret['GPU'] = v:gsub('driver: Driver Name:  ','')
		end

		if v:match('totalPhysical Mb%(') then
			ret['Ram'] = v:gsub('totalPhysical Mb%(',''):gsub('%)','')
		end

		if v:match('Users\\') and (not v:match('awesomium')) then
			ret['Username'] = v:match('Users\\.+\\'):gsub('Users\\',''):gsub('\\.*$','')
		end

		--if v:match('VendorId / DeviceId:  ') then
		--	ret['gfx vid/did'] = v:gsub('VendorId / DeviceId:  ','') -- idk?
		--end

		if v:match('^OS:  ') then
			ret['OS'] = v:gsub('OS:  ','')
		end

		if v:match('Driver Version: ') then
			ret['GPUDriver'] = v:gsub('Driver Version: ','')
		end

		if v:match('Vid:  ') then
			ret['Resolution'] = v:gsub('Vid:  ','')
		end

		if v:match('Game: ') then
			ret['InstallDir'] = v:gsub('Game: ',''):gsub("[\\/]+", '/')
		end
	end

	return ret
end
