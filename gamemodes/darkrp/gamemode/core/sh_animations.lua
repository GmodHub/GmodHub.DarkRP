-- slightly faster than base

function GM:HandlePlayerSwimming()
end

local function GetFlexIndexByName(self, name)
	self.LastModelName = self.LastModelName or ''
	self.FlexIndexCache = self.FlexIndexCache or {}
	local mdl = self:GetModel()

	if mdl ~= self.LastModelName then
		self.LastModelName = mdl
		self.FlexIndexCache = {}
		local count = self:GetFlexNum() - 1
		if count <= 0 then return end

		for i = 0, count do
			self.FlexIndexCache[self:GetFlexName(i)] = i
		end
	end

	return self.FlexIndexCache[name]
end

local MOVING_MOUTH_PARTS = {
	'jaw_drop',
	'right_part',
	'left_part',
	'right_mouth_drop',
	'left_mouth_drop'
}

function GM:MouthMoveAnimation(ply)
	local isSpeaking = ply:IsSpeaking()
	local moveMouth = isSpeaking or ply.m_bSpeaking
	ply.m_bSpeaking = isSpeaking
	if moveMouth ~= true then
		return
	end
	local vol = math.Clamp(ply:VoiceVolume() * 2, 0, 2)
	for _,v in ipairs(MOVING_MOUTH_PARTS) do
		local index = GetFlexIndexByName(ply, v)
		if index ~= nil then
			ply:SetFlexWeight(index, vol)
		end
	end
end


function GM:HandlePlayerJumping( ply, velocity )
	if ( ply:GetMoveType() == MOVETYPE_NOCLIP ) then
		ply.m_bJumping = false
		return
	end

	-- airwalk more like hl2mp, we airwalk until we have 0 velocity, then it's the jump animation
	-- underwater we're alright we airwalking
	if ( !ply.m_bJumping && !ply:OnGround() && ply:WaterLevel() <= 0 ) then

		if ( !ply.m_fGroundTime ) then

			ply.m_fGroundTime = CurTime()

		elseif ( CurTime() - ply.m_fGroundTime ) > 0 && velocity:Length2DSqr() < 0.25 then

			ply.m_bJumping = true
			ply.m_bFirstJumpFrame = false
			ply.m_flJumpStartTime = 0

		end
	end

	if ply.m_bJumping then

		if ply.m_bFirstJumpFrame then

			ply.m_bFirstJumpFrame = false
			ply:AnimRestartMainSequence()

		end

		if ( ply:WaterLevel() >= 2 ) || ( ( CurTime() - ply.m_flJumpStartTime ) > 0.2 && ply:OnGround() ) then

			ply.m_bJumping = false
			ply.m_fGroundTime = nil
			ply:AnimRestartMainSequence()

		end

		if ply.m_bJumping then
			ply.CalcIdeal = ACT_MP_JUMP
			return true
		end
	end

	return false
end

function GM:HandlePlayerDucking( ply, velocity )

	if ( !ply:Crouching() ) then return false end

	if ( velocity:Length2DSqr() > 0.25 ) then
		ply.CalcIdeal = ACT_MP_CROUCHWALK
	else
		ply.CalcIdeal = ACT_MP_CROUCH_IDLE
	end

	return true

end

function GM:HandlePlayerNoClipping( ply, velocity )
	if ( ply:GetMoveType() != MOVETYPE_NOCLIP || ply:InVehicle() ) then

		if ( ply.m_bWasNoclipping ) then

			ply.m_bWasNoclipping = nil
			ply:AnimResetGestureSlot( GESTURE_SLOT_CUSTOM )
			if ( CLIENT ) then ply:SetIK( true ) end

		end

		return

	end

	if ( !ply.m_bWasNoclipping ) then

		ply:AnimRestartGesture( GESTURE_SLOT_CUSTOM, ACT_GMOD_NOCLIP_LAYER, false )
		if ( CLIENT ) then ply:SetIK( false ) end

	end

	return true
end

function GM:HandlePlayerVaulting( ply, velocity )
	if ( velocity:LengthSqr() < 1000000 ) then return end
	if ( ply:IsOnGround() ) then return end

	ply.CalcIdeal = ACT_MP_SWIM

	return true
end


function GM:HandlePlayerLanding( ply, velocity, WasOnGround )
	if ( ply:GetMoveType() == MOVETYPE_NOCLIP ) then return end

	if ( ply:IsOnGround() && !WasOnGround ) then
		ply:AnimRestartGesture( GESTURE_SLOT_JUMP, ACT_LAND, true )
	end
end

function GM:HandlePlayerDriving( ply )
	if ( !ply:InVehicle() ) then return false end

	local pVehicle = ply:GetVehicle()

	if ( !pVehicle.HandleAnimation && pVehicle.GetVehicleClass ) then
		local c = pVehicle:GetVehicleClass()
		local t = list.Get( "Vehicles" )[ c ]
		if ( t && t.Members && t.Members.HandleAnimation ) then
			pVehicle.HandleAnimation = t.Members.HandleAnimation
		else
			pVehicle.HandleAnimation = true -- Prevent this if block from trying to assign HandleAnimation again.
		end
	end

	local class = pVehicle:GetClass()

	if ( isfunction( pVehicle.HandleAnimation ) ) then
		local seq = pVehicle:HandleAnimation( ply )
		if ( seq != nil ) then
			ply.CalcSeqOverride = seq
		end
	end

	if ( ply.CalcSeqOverride == -1 ) then -- pVehicle.HandleAnimation did not give us an animation
		if ( class == "prop_vehicle_jeep" ) then
			ply.CalcSeqOverride = ply:LookupSequence( "drive_jeep" )
		elseif ( class == "prop_vehicle_airboat" ) then
			ply.CalcSeqOverride = ply:LookupSequence( "drive_airboat" )
		elseif ( class == "prop_vehicle_prisoner_pod" && pVehicle:GetModel() == "models/vehicles/prisoner_pod_inner.mdl" ) then
			-- HACK!!
			ply.CalcSeqOverride = ply:LookupSequence( "drive_pd" )
		else
			ply.CalcSeqOverride = ply:LookupSequence( "sit_rollercoaster" )
		end
	end

	local use_anims = ( ply.CalcSeqOverride == ply:LookupSequence( "sit_rollercoaster" ) || ply.CalcSeqOverride == ply:LookupSequence( "sit" ) )
	if ( use_anims && ply:GetAllowWeaponsInVehicle() && IsValid( ply:GetActiveWeapon() ) ) then
		local holdtype = ply:GetActiveWeapon():GetHoldType()
		if ( holdtype == "smg" ) then holdtype = "smg1" end

		local seqid = ply:LookupSequence( "sit_" .. holdtype )
		if ( seqid != -1 ) then
			ply.CalcSeqOverride = seqid
		end
	end

	return true
end

--[[---------------------------------------------------------
   Name: gamemode:UpdateAnimation()
   Desc: Animation updates (pose params etc) should be done here
-----------------------------------------------------------]]
function GM:UpdateAnimation( ply, velocity, maxseqgroundspeed )
	local lensqr = velocity:LengthSqr()
	local movement = 1.0

	if ( lensqr > 0.04 ) then
		movement = ( math.sqrt(lensqr) / maxseqgroundspeed )
	end

	local rate = math.min( movement, 2 )

	if ( !ply:IsOnGround() && lensqr >= 1000000 ) then
		rate = 0.1
	end

	ply:SetPlaybackRate( rate )

	if ( CLIENT ) then
		if ( ply:InVehicle() ) then

			local Vehicle = ply:GetVehicle()
			--
			-- This is used for the 'rollercoaster' arms
			--
			local Velocity = Vehicle:GetVelocity()
			local fwd = Vehicle:GetUp()
			local dp = fwd:Dot( Vector( 0, 0, 1 ) )
			local dp2 = fwd:Dot( Velocity )

			ply:SetPoseParameter( "vertical_velocity", ( dp < 0 and dp or 0 ) + dp2 * 0.005 )

			-- Pass the vehicles steer param down to the player
			local steer = Vehicle:GetPoseParameter( "vehicle_steer" )
			steer = steer * 2 - 1 -- convert from 0..1 to -1..1
			if ( Vehicle:GetClass() == "prop_vehicle_prisoner_pod" ) then steer = 0 ply:SetPoseParameter( "aim_yaw", math.NormalizeAngle( ply:GetAimVector():Angle().y - Vehicle:GetAngles().y - 90 ) ) end
			ply:SetPoseParameter( "vehicle_steer", steer )
		end

		GAMEMODE:GrabEarAnimation( ply )
		GAMEMODE:MouthMoveAnimation( ply )
	end
end

--
-- If you don't want the player to grab his ear in your gamemode then
-- just override this.
--
function GM:GrabEarAnimation( ply )
	ply.ChatGestureWeight = ply.ChatGestureWeight or 0

	-- Don't show this when we're playing a taunt!
	if ( ply:IsPlayingTaunt() ) then return end

	if ( ply:IsTyping() ) then
		ply.ChatGestureWeight = math.Approach( ply.ChatGestureWeight, 1, FrameTime() * 5.0 )
	else
		ply.ChatGestureWeight = math.Approach( ply.ChatGestureWeight, 0, FrameTime() * 5.0 )
	end

	if ( ply.ChatGestureWeight > 0 ) then

		ply:AnimRestartGesture( GESTURE_SLOT_VCD, ACT_GMOD_IN_CHAT, true )
		ply:AnimSetGestureWeight( GESTURE_SLOT_VCD, ply.ChatGestureWeight )

	end
end

function GM:CalcMainActivity( ply, velocity )

	ply.CalcIdeal = ACT_MP_STAND_IDLE
	ply.CalcSeqOverride = -1

	self:HandlePlayerLanding( ply, velocity, ply.m_bWasOnGround )

	if ( self:HandlePlayerNoClipping( ply, velocity ) ||
		self:HandlePlayerDriving( ply ) ||
		self:HandlePlayerVaulting( ply, velocity ) ||
		self:HandlePlayerJumping( ply, velocity ) ||
		self:HandlePlayerDucking( ply, velocity ) ) then

	else
		local len2dsqr = velocity:Length2DSqr()
		if ( len2dsqr > 22500 ) then ply.CalcIdeal = ACT_MP_RUN elseif ( len2dsqr > 0.25 ) then ply.CalcIdeal = ACT_MP_WALK end
	end

	ply.m_bWasOnGround = ply:IsOnGround()
	ply.m_bWasNoclipping = ( ply:GetMoveType() == MOVETYPE_NOCLIP && !ply:InVehicle() )

	return ply.CalcIdeal, ply.CalcSeqOverride
end

--sliding
/*

local slideDuration = .75
local slideCooldown = 1
local duckTrapped = false
local slideButton = IN_DUCK

nw.Register 'srp.player.sliding'
	:Write(net.WriteBool)
	:Read(net.ReadBool)
	:SetPlayer()

function PLAYER:SetCanSlide(b)
	self.CanSlide = true
end

function PLAYER:CanSlide()
	return true // self.CanSlide
end

function PLAYER:IsSliding()
	return self:GetNetVar('srp.player.sliding') and self.slidevec and self.sliderduration
end

function PLAYER:SetSliding(b)
	self:SetNetVar('srp.player.sliding', b)
end

hook('SetupMove', 'sliding', function(pl, mv, cmd)
	if (not pl:CanSlide()) then
		return
	end

	local ducking = mv:KeyDown(slideButton)
	local grounded = pl:IsOnGround()
	local sliding = pl:IsSliding()

	if grounded and ducking and not duckTrapped and not sliding and (not pl.nextslide or pl.nextslide < CurTime()) then
		pl.slidevec = pl:GetForward()
		pl.sliderduration = CurTime() + slideDuration
		if (SERVER) then
			pl:SetSliding(true)
		end
	elseif ((not grounded or not ducking) and sliding) or (sliding and pl.sliderduration < CurTime()) or (sliding and not pl:Alive()) then
		pl.slidevec = nil
		pl.sliderduration = nil
		if (SERVER) then
			pl:SetSliding(false)
		end
		pl.nextslide = CurTime() + slideCooldown
	end

	duckTrapped = ducking
end)

hook('Move', 'sliding', function(pl, mv)
	if pl:IsSliding() then
		local ang = mv:GetMoveAngles()
		local vel = mv:GetVelocity()

		vel = vel + pl.slidevec * (pl:IsOnGround() and 300 or 10)
		mv:SetVelocity(vel)
	end
end)

hook('CalcMainActivity', 'sliding', function(pl)
	if pl:IsSliding() then
		local anim = pl:LookupSequence 'zombie_slump_idle_02'
		if anim and anim > 0 then
			return ACT_MP_RUN, anim
		end
	end
end)
