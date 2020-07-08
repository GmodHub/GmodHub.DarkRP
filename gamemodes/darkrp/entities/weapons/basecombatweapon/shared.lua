require 'minstd'

-- Fix; make sure to scale movement speeds to everything based on a custom convar

SWEP.Base = "basecombatweapon" -- This is our new superclass
SWEP.Spawnable = false
SWEP.Category = "Source Engine"
SWEP.Author = "code_gs"
SWEP.DrawCrosshair = true
SWEP.HoldType = "none"

SWEP.ReloadsSingly = false	// True if this weapon reloads 1 round at a time
SWEP.Damage = 0
SWEP.UnderwaterCooldown = 0.2
SWEP.EmptyCooldown = 0.5
SWEP.AutoReload = true -- FIX implement auto-reload

-- Fix; add Viewmodel1, 2, etc?

SWEP.Primary =
{
	Ammo = "none",
	ClipSize = -1,
	DefaultClip = -1,
	Automatic = true,
	Cooldown = 0.0,
	FiresUnderwater = true -- Fix; find default value
}

SWEP.Secondary =
{
	Ammo = "none",
	ClipSize = -1,
	DefaultClip = 0,
	Automatic = true,
	Cooldown = 0.0,
	FiresUnderwater = true -- m_bAltFiresUnderwater
}

SWEP.Sounds = {
	[ "primary" ] = "",
	[ "secondary" ] = "",
	[ "reload" ] = "",
	[ "empty" ] = "",
	[ "special" ] = ""
}

SWEP.ActTable =
{
	[ "ACT_MP_STAND_IDLE" ] = "ACT_HL2MP_IDLE",
	[ "ACT_MP_WALK" ] = "ACT_HL2MP_WALK",
	[ "ACT_MP_RUN" ] = "ACT_HL2MP_RUN",
	[ "ACT_MP_CROUCH_IDLE" ] = "ACT_HL2MP_IDLE_CROUCH",
	[ "ACT_MP_CROUCHWALK" ] = "ACT_HL2MP_WALK_CROUCH",
	[ "ACT_MP_ATTACK_STAND_PRIMARYFIRE" ] = "ACT_HL2MP_GESTURE_RANGE_ATTACK",
	[ "ACT_MP_ATTACK_CROUCH_PRIMARYFIRE" ] = "ACT_HL2MP_GESTURE_RANGE_ATTACK",
	[ "ACT_MP_RELOAD_STAND" ] = "ACT_HL2MP_GESTURE_RELOAD",
	[ "ACT_MP_RELOAD_CROUCH" ] = "ACT_HL2MP_GESTURE_RELOAD",
	[ "ACT_MP_JUMP" ] = "ACT_HL2MP_JUMP_SLAM",
	[ "ACT_MP_SWIM" ] = "ACT_HL2MP_SWIM",
	[ "ACT_MP_SWIM_IDLE" ] = "ACT_HL2MP_SWIM_IDLE"
}

SWEP.ShouldIdle = true

SWEP.Activities =
{
	[ "primary" ] = ACT_VM_PRIMARYATTACK,
	[ "secondary" ] = ACT_VM_SECONDARYATTACK,
	[ "reload" ] = ACT_VM_RELOAD,
	[ "deploy" ] = ACT_VM_DRAW,
	[ "holster" ] = ACT_VM_HOLSTER,
	[ "idle" ] = ACT_VM_IDLE
}

-- Constructor/spawn method
-- Inherited SWEPs should always call the baseclass for this method
function SWEP:Initialize()
	self:SetThinkFunction(self.ItemFrame)
	self:SetHoldType(self.HoldType)
end

-- And this one
function SWEP:SetupDataTables()
	-- self:NetworkVar("Entity", nil, "Owner")
	-- self:NetworkVar("Float", nil, "PrimaryAttack")
	-- self:NetworkVar("Float", nil, "SecondaryAttack")
	self:NetworkVar("Float", 0, "NextIdle")
	-- self:NetworkVar("Int", nil, "ViewModelIndex")
	-- self:NetworkVar("Int", nil, "WorldModelIndex")
	-- self:NetworkVar("Int", nil, "State")
	-- self:NetworkVar("Int", nil, "PrimaryAmmoType")
	-- self:NetworkVar("Int", nil, "SecondaryAmmoType")
	-- self:NetworkVar("Int", nil, "Clip1")
	-- self:NetworkVar("Int", nil, "Clip2")
	self:NetworkVar("Float", 1, "NextReload")
	self:NetworkVar("Float", 2, "NextThink")
end

-- As well as this one!
function SWEP:Precache()
	util.PrecacheModel(self.ViewModel)
	util.PrecacheModel(self.WorldModel)

	for _, sound in pairs(self.Sounds) do
		if (istable(sound)) then
			for i = 0, #sound do
				util.PrecacheSound(sound[i])
			end
		elseif (sound ~= "") then
			util.PrecacheSound(sound)
		end
	end
end

function SWEP:GetViewModel()
	return self.ViewModel
end

function SWEP:SetViewModel(sViewModel, iIndex)
	local pOwner = self:GetOwner()
	if (pOwner == NULL) then
		return false
	end

	local vm = pOwner:GetViewModel(iIndex)
	if (vm == NULL) then
		return false
	end

	if (iIndex == 0) then
		self.ViewModel = sViewModel
	end

	vm:SetWeaponModel(sViewModel, self)
end

function SWEP:GetWorldModel()
	return self.WorldModel
end

function SWEP:GetPrintName()
	return self.PrintName
end

function SWEP:GetMaxClip1()
	return self.Primary.ClipSize
end

function SWEP:GetMaxClip2()
	return self.Secondary.ClipSize
end

function SWEP:GetDefaultClip1()
	return self.Primary.DefaultClip
end

function SWEP:GetDefaultClip2()
	return self.Secondary.DefaultClip
end

function SWEP:UsesClipsForAmmo1()
	return (self.Primary.ClipSize > 0)
end

function SWEP:UsesClipsForAmmo2()
	return (self.Secondary.ClipSize > 0)
end

function SWEP:GetWeight()
	return self.Weight
end

function SWEP:AllowsAutoSwitchTo()
	return self.AutoSwitchTo
end

function SWEP:AllowsAutoSwtichFrom()
	return self.AutoSwitchFrom
end

function SWEP:GetSlot()
	return self.Slot
end

function SWEP:GetPosition()
	return self.SlotPos
end

function SWEP:GetOwner()
	return self.Owner -- Will always be an entity (NULL included)
end

function SWEP:UsesHands()
	return self.UseHands
end

function SWEP:FlipsViewModel()
	return self.ViewModelFlip
end

function SWEP:LookupSound(sIndex)
	local sound = self.Sounds[ sIndex:lower() ]

	if (istable(sound)) then
		return sound[ minstd:RandomInt(1, #sound) ]
	end

	return sound or ""
end

function SWEP:LookupActivity(sName)
	return self.Activities[ sName:lower() ] or ACT_INVALID
end

function SWEP:CanBeSelected()
	return (self:VisibleInWeaponSelection() and self:HasAmmo() or false)
end

function SWEP:HasAmmo()
	// Weapons with no ammo types can always be selected
	if (self.Primary.Ammo == -1 and self.Secondary.Ammo == -1) then
		return true
	elseif (bit.band(self:GetFlags(), ITEM_FLAG_SELECTONEMPTY)) then -- Fix
		return true
	end

	local player = self:GetOwner()

	return player ~= NULL and (self:Clip1() > 0 or player:GetAmmoCount(self.Primary.Ammo ) or self:Clip2() > 0 or player:GetAmmoCount(self.Secondary.Ammo)) or false
end

function SWEP:HasIdleTimeElapsed()
	local iTime = self:GetNextIdle()

	if (iTime ~= -1 and CurTime() > self:GetNextIdle()) then
		return true
	end

	return false
end

function SWEP:MakeTracer(vecTracerSrc, tr, iTracerType)
	local pOwner = self:GetOwner()

	if (pOwner == NULL) then
		-- BaseClass.MakeTracer(self, vecTracerSrc, tr, iTracerType) -- Fix
		return
	end

	local pszTracerName = self:GetTracerType()

	local iEntIndex = pOwner:EntIndex()

	if (game.Multiplayer()) then
		iEntIndex = self:EntIndex()
	end

	local iAttachment = self:GetTracerAttachment()

	if (iTracerType == TRACER_LINE or iTracerType == TRACER_LINE_AND_WHIZ) then -- FIX
		util.Tracer(vecTracerSrc, tr.HitPos, iEntIndex, iAttachment, 0.0, true, pszTracerName)
	end
end

SWEP.m_ActivityTimes = {}

function SWEP:IsViewModelSequenceFinished()
	local iActivity = self:_GetActivity()

	// These are not valid activities and always complete immediately
	if (iActivity == ACT_RESET or iActivity == ACT_INVALID) then
		return true
	end

	local pOwner = self:GetOwner()
	if (pOwner == NULL) then
		return false
	end

	local vm = pOwner:GetViewModel()
	if (vm == NULL) then
		return false
	end

	if (not self.m_ActivityTimes[ iActivity ]) then
		ErrorNoHalt("Activity ", iActivity, " not registered!")
		return true
	end

	return (self.m_ActivityTimes[ iActivity ] <= CurTime())
	--return vm:IsSequenceFinished() -- Fix; add this function
end

function SWEP:_SendWeaponAnim(iActivity, iDelay, bEnableIdle) -- Fix; after switch and restore, the idle breaks. Resaving the file fixes
	self:SendWeaponAnim(iActivity)

	if (self.ShouldIdle) then
		local iTime = CurTime() + self:SequenceDuration() + (iDelay or 0)
		self.m_ActivityTimes[ iActivity ] = iTime

		if (bEnableIdle or self:GetNextIdle() ~= -1) then -- Idle is disabled; we have to manually re-enable it first
			self:SetNextIdle(iTime) -- SetIdealActivity carry over
		end
	end
end

function SWEP:HasAnyAmmo()
	// If I don't use ammo of any kind, I can always fire
	if (not (self:UsesPrimaryAmmo() or self:UsesSecondaryAmmo())) then
		return true
	end

	// Otherwise, I need ammo of either type
	return (self:HasPrimaryAmmo() or self:HasSecondaryAmmo())
end

function SWEP:HasPrimaryAmmo()
	// If I use a clip, and have some ammo in it, then I have ammo
	if (self:UsesClipsForAmmo1()) then
		if (self:Clip1() > 0) then
			return true
		end
	else
		return true
	end

	// Otherwise, I have ammo if I have some in my ammo counts
	local pOwner = self:GetOwner()
	if (pOwner ~= NULL) then
		if (pOwner:GetAmmoCount(self.Primary.Ammo) > 0) then -- Fix; accessor
			return true
		end
	else
		// No owner, so return how much primary ammo I have along with me
		if (self:GetPrimaryAmmoCount() > 0) then
			return true
		end
	end

	return false
end

function SWEP:HasSecondaryAmmo()
	// If I use a clip, and have some ammo in it, then I have ammo
	if (self:UsesClipsForAmmo2()) then
		if (self:Clip2() > 0) then
			return true
		end
	else
		return true
	end

	// Otherwise, I have ammo if I have some in my ammo counts
	local pOwner = self:GetOwner()
	if (pOwner ~= NULL) then
		if (pOwner:GetAmmoCount(self.Secondary.Ammo) > 0) then
			return true
		end
	else
		// No owner, so return how much primary ammo I have along with me
		if (self:GetPrimaryAmmoCount() > 0) then
			return true
		end
	end

	return false
end

function SWEP:UsesPrimaryAmmo()
	return game.GetAmmoID(self.Primary.Ammo) > 0
end

function SWEP:UsesSecondaryAmmo()
	return game.GetAmmoID(self.Secondary.Ammo) > 0
end

function SWEP:SetWeaponVisible(visible)
	local vm = NULL

	local pOwner = self:GetOwner()
	if (pOwner ~= NULL) then
		vm = pOwner:GetViewModel()
	end

	if (visible) then
		self:RemoveEffects(EF_NODRAW)
		if (vm ~= NULL) then
			vm:RemoveEffects(EF_NODRAW)
		end
	else
		self:AddEffects(EF_NODRAW)
		if (vm ~= NULL) then
			vm:AddEffects(EF_NODRAW)
		end
	end
end

function SWEP:IsWeaponVisible()
	local pOwner = self:GetOwner()

	if (pOwner == NULL) then return false end

	local vm = pOwner:GetViewModel()

	return vm ~= NULL and not vm:IsEffectActive(EF_NODRAW) or false
end

function SWEP:HandleOutOfAmmo()
	local pOwner = self:GetOwner()
	if (pOwner == NULL) then return end

	local curtime = CurTime()
	local bNextPrimaryAttack = self:GetNextPrimaryFire() < curtime
	local bNextSecondaryAttack = self:GetNextSecondaryFire() < cutime

	self.m_bFireOnEmpty = false

	// If we don't have any ammo, switch to the next best weapon
	if (bNextPrimaryAttack and bNextSecondaryAttack) then
		if (not self:HasPrimaryAmmo() and -- Fix
			self.SwitchOnEmpty ) then
			// weapon isn't useable, switch.
			pOwner:SwitchToNextBestWeapon()
		// Weapon is useable. Reload if empty and weapon has waited as long as it has to after firing
		elseif (self.ReloadOnEmpty) then
			// if we're successfully reloading, we're done
			self:Reload()
		end
	end
end

function SWEP:DefaultDeploy()
	// Weapons that don't autoswitch away when they run out of ammo
	// can still be deployed when they have no ammo.
	if (not self:CanDeploy()) then return end
	// Dead men deploy no weapons
	local pOwner = self:GetOwner()
	if (pOwner == NULL or not pOwner:Alive()) then return end

	self:SetThinkFunction(self.ItemFrame)

	self:SetNextIdle(0) -- In-case our _SendWeaponAnim doesn't set the idle time
	self:_SendWeaponAnim(self:LookupActivity("deploy"))
	timer.Simple(0, function()
		if (!IsValid(self) or !self.SetWeaponvisible) then return end
		self:SetWeaponVisible(true)
	end)

	// Can't shoot again until we've finished deploying
	local iNewTime = CurTime() + self:SequenceDuration()
	self:SetNextPrimaryFire(iNewTime)
	self:SetNextSecondaryFire(iNewTime)
	self:SetNextReload(iNewTime)
end

function SWEP:Deploy()
	if (self:GetOwner() == NULL) then
		return false
	end

	if (SERVER) then
		local retval = self:SharedDeploy()
		-- We network this so that singleplayer/SelectWeapon will deploy shared
		self:CallOnClient("SharedDeploy")

		return true
	end
	-- Rely on established clientside method for prediction
	return self:CanDeploy()
end

function SWEP:SharedDeploy()
	self:DefaultDeploy(self:LookupActivity("deploy"))
end

function SWEP:SetThinkFunction(func)
	self.m_fThinkFunc = func
end

local nullFunc = function() end
function SWEP:GetThink()
	return self.m_fThinkFunc or nullFunc
end
-- Fix
function SWEP:CanLower()
	return false
end

function SWEP:Ready()
	return false
end

function SWEP:Lower()
	return false
end

function SWEP:_GetActivity() -- fix
	return self:GetSequenceActivity(self:GetSequence())
end
-- Fix; should we unhide weapon here just in case?
function SWEP:DefaultHolster(pSwitchingTo, iActivity)
	local curtime = CurTime()
	// cancel any reload in progress.
	self:SetNextReload(curtime)
	-- Hacky delay to prevent any refires during our switch
	self:SetNextPrimaryFire(curtime + 0.5)
	self:SetNextSecondaryFire(curtime + 0.5)

	// kill any think functions
	-- If for some reason the weapon is still active after a holster frame,
	-- make the think do nothing to prevent errors
	timer.Simple(0, function()
		if (IsValid(self)) then
			self:SetThinkFunction(util.EmptyFunction)
		end
	end )

	-- Kill our context thinks and key listeners
	self.m_ContextFunctions = {}
	self.m_ContextTimes = {}
	self.m_KeyFunctions = {}
	self.m_KeyEnums = {}

	-- Disabled: Holster animations cause the viewmodel to break when weapons are switched

	// Send holster animation
	--[[self:_SendWeaponAnim(iActivity)

	// Some weapon's don't have holster anims yet, so detect that
	local flSequenceDuration = 0
	if (self:_GetActivity() == self:GetHolsterActivity()) then
		flSequenceDuration = self:SequenceDuration()
	end

	local pOwner = self:GetOwner()
	if (IsValid(pOwner)) then
		pOwner:SetFOV(0, 0) // reset the default FOV
	end

	// If we don't have a holster anim, hide immediately to avoid timing issues
	if (flSequenceDuration == 0) then
		--self:SetWeaponVisible(false)
	else
		// Hide the weapon when the holster animation's finished
		timer.Simple(flSequenceDuration + 0.1, function()
			print"timer ran"
			if (IsValid(pOwner)) then
				local newWep = owner:GetActiveWeapon()
				print(newWep)
				if (newWep == self) then
					self:SetWeaponVisible(false)
				else
					local vm = owner:GetViewModel()
					if (IsValid(vm)) then
						vm:SetModel(newWep:GetViewModel())
					end
				end
			end
		end )

	end]]

	return true
end

function SWEP:Holster(pSwitchingTo)
	return self:DefaultHolster(pSwitchingTo, self:LookupActivity("holster"))
end

function SWEP:CanHolster()
	return true
end

function SWEP:ItemFrame()
	if (self.ShouldIdle) then
		self:Idle()
	end
end

function SWEP:Think()
	if (self:GetOwner() == NULL or (CLIENT and self:GetOwner() != LocalPlayer())) then return end
	-- FIXME: Should context thinks/key listeners have priority?
	self:SimulateContextThink()
	self:SimulateKeyListeners()

	if (self:GetNextThink() <= CurTime()) then
		self:GetThink()(self)
	end

	if (not self:InReload() and self:Clip1() == 0) then -- Fix
		self:HandleOutOfAmmo()
	end
end

SWEP.m_Contexts = {}
-- Contextual thinking: Timer based think simulation
function SWEP:AddContextThink(fThink, flInterval)
	if (not IsFirstTimePredicted()) then return end

	self.m_Contexts[ #self.m_Contexts + 1 ] =
		{ [1] = fThink, [2] = flInterval, [3] = flInterval + CurTime() }
end

function SWEP:SimulateContextThink()
	local flCurTime = CurTime()

	for i = 1, #self.m_Contexts do
		if (self.m_Contexts[i][3] <= flCurTime) then
			if (self.m_Contexts[i][1](self)) then
				self.m_Contexts[i] = nil
			else
				self.m_Contexts[i][3] = flCurTime + self.m_Contexts[i][2]
			end
		end
	end
end

SWEP.m_Keys = {}

function SWEP:AddKeyListener(fListener, tKeys, bDown)
	if (not IsFirstTimePredicted()) then return end

	if (not istable(tKeys)) then
		tKeys = { tKeys }
	end

	self.m_Keys[ #self.m_Keys + 1 ] =
		{ [1] = fListener, [2] = tKeys, [3] = bDown }
end

function SWEP:SimulateKeyListeners()
	local pPlayer = self:GetOwner()
	local bPassed = true

	for i = 1, #self.m_Keys do
		for j = 1, #self.m_Keys[i][2] do
			if (pPlayer:KeyDown(self.m_Keys[i][2][j])) then
				if (not self.m_Keys[i][3]) then
					bPassed = false
					break
				end
			else
				if (self.m_Keys[i][3]) then
					bPassed = false
					break
				end
			end
		end

		if (bPassed) then
			if (self.m_Keys[i][1](self)) then
				self.m_Keys[i] = nil
			end
		end
	end
end

-- Fix; ItemBusyFrame = PostThink. Find an implementation for this?

function SWEP:HandleFireOnEmpty(bSecondary)
	self:PlaySound("empty")

	-- The engine has a variable for this instead of setting the next fire time
	-- But almost all children games do it this way so we'll save a NetworkVar
	if (bSecondary) then
		self:SetNextSecondaryFire(CurTime() + self.EmptyCooldown)
	else
		self:SetNextPrimaryFire(CurTime() + self.EmptyCooldown)
	end
end

function SWEP:GetPrimaryFireRate()
	return self.Primary.Cooldown
end

function SWEP:GetSecondaryFireRate()
	return self.Secondary.Cooldown
end

function SWEP:GetDamage()
	return self.Damage
end

function SWEP:AddViewModelBob(origin, angles)
end

function SWEP:CalcViewmodelBob()
	return 0.0
end

function SWEP:DoDrawCrosshair()
end

function SWEP:GetPrimaryAmmoType()
	return self.Primary.Ammo
end

function SWEP:GetSecondaryAmmoType()
	return self.Secondary.Ammo
end

function SWEP:PlaySound(sound_type, soundtime)
	soundtime = soundtime or 0
	local pPlayer = self:GetOwner()

	// If we have some sounds from the weapon classname.txt file, play a random one of them
	local shootsound = self:LookupSound(sound_type)
	if (shootsound == "") then
		shootsound = sound_type
	end

	local params
	-- Fix; do all this sound shit
	self.Owner:EmitSound(shootsound)
end

function SWEP:StopSound(sound_type)
end

function SWEP:CanReload()
	if (self:InReload()) then
		return false
	end

	local pOwner = self:GetOwner()
	if (pOwner == NULL) then
		return false
	end

	// If I don't have any spare ammo, I can't reload
	if (pOwner:GetAmmoCount(self.Primary.Ammo) <= 0) then
		return false
	end

	// If you don't have clips, then don't try to reload them.
	if (self:UsesClipsForAmmo1()) then
		// need to reload primary clip?
		local primary = math.min(self:GetMaxClip1() - self:Clip1(), pOwner:GetAmmoCount(self.Primary.Ammo))
		if (primary ~= 0) then
			return true
		end
	end

	if (self:UsesClipsForAmmo2()) then
		// need to reload secondary clip?
		local secondary = math.min(self:GetMaxClip2() - self:Clip2(), pOwner:GetAmmoCount(self.Secondary.Ammo))
		if (secondary ~= 0) then
			return true
		end
	end

	return false
end

function SWEP:_DefaultReload()
	if (CLIENT or not self:CanReload()) then -- Fix; temp hacky fix
		return false
	end

	local pOwner = self:GetOwner()

	self:PlaySound("reload")
	self:_SendWeaponAnim(self:LookupActivity("reload"))
	// Play the player's reload animation
	pOwner:SetAnimation(pOwner:LookupAnimation("reload")) -- Fix; override SetAnimation to accept strings

	local flSequenceEndTime = self:SequenceDuration()
	self:AddContextThink(function() self:FinishReload() return true end, flSequenceEndTime)

	flSequenceEndTime = flSequenceEndTime + CurTime()
	self:SetNextPrimaryFire(flSequenceEndTime)
	self:SetNextSecondaryFire(flSequenceEndTime)
	self:SetNextReload(flSequenceEndTime)

	return true
end

function SWEP:Reload()
	return self:_DefaultReload()
end

function SWEP:InReload()
	return self:GetNextReload() > CurTime()
end

function SWEP:Idle()
	//Idle again if we've finished
	if (self:HasIdleTimeElapsed()) then
		self:_SendWeaponAnim(self:LookupActivity("idle"))
	end
end

function SWEP:CheckReload() -- Fix
	if (self.m_bReloadsSingly) then
		local pOwner = self:GetOwner()
		local iClip1 = self:Clip1()
		if (pOwner == NULL) then
			return
		end

		if ((self:InReload() ) and (self:GetNextPrimaryFire() <= CurTime())) then
			if (not self:MouseLifted() and iClip1 > 0) then
				self:SetNextReload(CurTime())
				return
			end

			// If out of ammo end reload
			if (pOwner:GetAmmoCount(self.Primary.Ammo) <= 0) then
				self:FinishReload()
				return
			// If clip not full reload again
			elseif (iClip1 < self:GetMaxClip1()) then
				// Add them to the clip
				self:SetClip1(iClip1 + 1)
				pOwner:RemoveAmmo(1, self.Primary.Ammo)

				self:Reload()
				return
			// Clip full, stop reloading
			else
				self:FinishReload()
				self:SetNextPrimaryFire(CurTime())
				self:SetNextSecondaryFire(CurTime())
				return
			end
		end
	end
end

function SWEP:FinishReload()
	local pOwner = self:GetOwner()

	if (pOwner == NULL) then return end

	local iClip1 = self:Clip1()
	local iClip2 = self:Clip2()

	// If I use primary clips, reload primary
	if (self:UsesClipsForAmmo1()) then
		local primary = math.min(self:GetMaxClip1() - iClip1, pOwner:GetAmmoCount(self.Primary.Ammo))
		self:SetClip1(iClip1 + primary)
		pOwner:RemoveAmmo(primary, self.Primary.Ammo)
	end

	// If I use secondary clips, reload secondary
	if (self:UsesClipsForAmmo2()) then
		local secondary = math.min(self:GetMaxClip2() - iClip2, pOwner:GetAmmoCount(self.Secondary.Ammo))
		self:SetClip2(iClip2 + secondary)
		pOwner:RemoveAmmo(secondary, self.Secondary.Ammo)
	end

	if (self.m_bReloadsSingly) then
		self:SetNextReload(CurTime())
	end
end

function SWEP:AbortReload()
	self:StopSound("reload")
	self:SetNextReload(CurTime())
end

function SWEP:HandleFireUnderwater(bSecondary)
	self:PlaySound("empty")

	if (bSecondary) then
		self:SetNextSecondaryFire(CurTime() + self.UnderwaterCooldown)
	else
		self:SetNextPrimaryFire(CurTime() + self.UnderwaterCooldown)
	end
end

function SWEP:CanPrimaryAttack() -- FIX; start implementing this into classes
	if (self:GetNextPrimaryFire() == -1) then
		return false
	end

	local pPlayer = self:GetOwner()

	if (pPlayer == NULL) then
		return false
	end

	local iClip1 = self:Clip1()

	// If my clip is empty (and I use clips) start reload
	if (not self:HasPrimaryAmmo()) then
		self:HandleFireOnEmpty(false)
		return false
	end

	if (pPlayer:WaterLevel() == 3) then
		self:HandleFireUnderwater(false)
		return self.Primary.FiresUnderwater
	end

	return true
end

function SWEP:PrimaryAttack()
	if (not self:CanPrimaryAttack()) then
		return
	end

	self:DoFireEffects()

	// Only the player fires this way so we can cast
	local pPlayer = self:GetOwner()

	local info = {}
	info.Src = pPlayer:GetShootPos()

	info.Dir = pPlayer:GetAimVector()

	// To make the firing framerate independent, we may have to fire more than one bullet here on low-framerate systems,
	// especially if the weapon we're firing has a really fast rate of fire.
	info.Num = 0
	local fireRate = self:GetPrimaryFireRate()
	local flNextPrimaryAttack = self:GetNextPrimaryFire()

	while (flNextPrimaryAttack <= CurTime()) do
		// MUST call sound before removing a round from the clip of a CMachineGun
		self:PlaySound("primary", flNextPrimaryAttack)
		self:SetNextPrimaryFire(flNextPrimaryAttack + fireRate)
		info.Num = info.Num + 1
		if (fireRate == 0) then
			break
		end
	end

	local iClip = self:Clip1()

	// Make sure we don't fire more than the amount in the clip
	if (self:UsesClipsForAmmo1()) then
		info.Num = math.min(info.Num, iClip1)
		iClip1 = iClip1 - info.Num
		self:SetClip1(iClip1)
	else
		info.Num = math.min(info.Num, pPlayer:GetAmmoCount(self.Primary.Ammo))
		pPlayer:RemoveAmmo(info.Num, self.Primary.Ammo)
	end

	info.Distance = MAX_TRACE_LENGTH
	info.AmmoType = self.Primary.Ammo
	info.Tracer = 2
	info.Spread = VECTOR_CONE_15DEGREES

	self:FireBullets(info)

	if (iClip1 <= 0 and pPlayer:GetAmmoCount(self.Primary.Ammo) <= 0) then
		// HEV suit - indicate out of ammo condition
		-- pPlayer:SetSuitUpdate("!HEV_AMO0", false, 0) -- Fix; add HEV suit stuff
	end
end

function SWEP:CanSecondaryAttack()
	if (self:GetNextSecondaryFire() == -1) then
		return false
	end

	local pPlayer = self:GetOwner()

	if (pPlayer == NULL) then
		return false
	end

	local iClip1 = self:Clip1()

	// If my clip is empty (and I use clips) start reload
	if (not self:HasSecondaryAmmo()) then
		self:HandleFireOnEmpty(true)
		return false
	end

	if (pPlayer:WaterLevel() == 3) then
		self:HandleFireUnderwater(true)
		return self.Secondary.FiresUnderwater
	end

	return true
end

function SWEP:SecondaryAttack()
	-- We don't do anything so don't bother asking if we can fire
end

function SWEP:FireBullets(info) -- Fix
	pPlayer:FireBullets(info)
end

--[[
function SWEP:SetIdealActivity(ideal)
	local idealSequence = self:SelectWeightedSequence(ideal)

	if (idealSequence == -1) then
		return false
	end

	// take the new activity
	self.m_IdealActivity = ideal
	self.m_nIdealSequence = idealSequence

	//Find the next sequence in the potential chain of sequences leading to our ideal one
	local nextSequence = self:FindTransitionSequence(self:GetSequence(), idealSequence)

	// Don't use transitions when we're deploying
	if (ideal ~= ACT_VM_DRAW and self:IsWeaponVisible() and nextSequence ~= idealSequence) then
		//Set our activity to the next transitional animation
		self:Weapon_SetActivity(ACT_TRANSITION) -- Fix. This function is so stupid
		self:SetSequence(nextSequence)
		self:SendViewModelAnim(nextSequence) -- Fix
	else
		//Set our activity to the ideal
		self:Weapon_SetActivity(ideal)
		self:SetSequence(idealSequence)
		self:SendViewModelAnim(idealSequence) -- Fix
	end

	self:SetNextIdle(CurTime() + self:SequenceDuration())
	return true
end
]]
--[[
function SWEP:ActivityOverride(baseAct, pRequired)
end -- Fix, do activities


function SWEP:ActivityList()
	return
end

function SWEP:ActivityListCount()
	return 0
end
]]

function SWEP:CanDeploy()
	return true -- (not self:HasAnyAmmo() and self:AllowsAutoSwtichFrom()) -- FIx
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--SWEP.HoldType = "normal"

ACT_HL2MP_SWIM = ACT_HL2MP_IDLE + 9 -- Fix; temp hack
ACT_RANGE_ATTACK = ACT_HL2MP_IDLE + 8
ACT_HL2MP_SWIM_IDLE = 2057

-- FIX: Investigate the 1784 - 1787 gap

SWEP.HoldTypes =
{
	[ "normal" ] =
	{
		[ ACT_MP_STAND_IDLE ] = ACT_HL2MP_IDLE,
		[ ACT_MP_WALK ] = ACT_HL2MP_WALK,
		[ ACT_MP_RUN ] = ACT_HL2MP_RUN,
		[ ACT_MP_CROUCH_IDLE ] = ACT_HL2MP_IDLE_CROUCH,
		[ ACT_MP_CROUCHWALK ] = ACT_HL2MP_WALK_CROUCH,
		[ ACT_MP_ATTACK_STAND_PRIMARYFIRE ] = ACT_HL2MP_GESTURE_RANGE_ATTACK,
		[ ACT_MP_ATTACK_CROUCH_PRIMARYFIRE ] = ACT_HL2MP_GESTURE_RANGE_ATTACK,
		[ ACT_MP_RELOAD_STAND ] = ACT_HL2MP_GESTURE_RELOAD,
		[ ACT_MP_RELOAD_CROUCH ] = ACT_HL2MP_GESTURE_RELOAD,
		[ ACT_MP_JUMP ] = ACT_HL2MP_JUMP_SLAM, -- Fix
		[ ACT_RANGE_ATTACK1 ] = ACT_HL2MP_GESTURE_RANGE_ATTACK, -- Fix
		[ ACT_MP_SWIM ] = ACT_HL2MP_SWIM,
		[ ACT_MP_SWIM_IDLE ] = ACT_HL2MP_SWIM_IDLE
	},

	[ "pistol" ] =
	{
		[ ACT_MP_STAND_IDLE ] = ACT_HL2MP_IDLE_PISTOL,
		[ ACT_MP_WALK ] = ACT_HL2MP_WALK_PISTOL,
		[ ACT_MP_RUN ] = ACT_HL2MP_RUN_PISTOL,
		[ ACT_MP_CROUCH_IDLE ] = ACT_HL2MP_IDLE_CROUCH_PISTOL,
		[ ACT_MP_CROUCHWALK ] = ACT_HL2MP_WALK_CROUCH_PISTOL,
		[ ACT_MP_ATTACK_STAND_PRIMARYFIRE ] = ACT_HL2MP_GESTURE_RANGE_ATTACK_PISTOL,
		[ ACT_MP_ATTACK_CROUCH_PRIMARYFIRE ] = ACT_HL2MP_GESTURE_RANGE_ATTACK_PISTOL,
		[ ACT_MP_RELOAD_STAND ] = ACT_HL2MP_GESTURE_RELOAD_PISTOL,
		[ ACT_MP_RELOAD_CROUCH ] = ACT_HL2MP_GESTURE_RELOAD_PISTOL,
		[ ACT_MP_JUMP ] = ACT_HL2MP_JUMP_PISTOL,
		[ ACT_RANGE_ATTACK1 ] = ACT_HL2MP_GESTURE_RANGE_ATTACK_PISTOL,
		[ ACT_MP_SWIM ] = ACT_HL2MP_SWIM_PISTOL,
		[ ACT_MP_SWIM_IDLE ] = ACT_HL2MP_SWIM_IDLE_PISTOL
	},

	[ "fist" ] =
	{
		[ ACT_MP_STAND_IDLE ] = ACT_HL2MP_IDLE_FIST,
		[ ACT_MP_WALK ] = ACT_HL2MP_WALK_FIST,
		[ ACT_MP_RUN ] = ACT_HL2MP_RUN_FIST,
		[ ACT_MP_CROUCH_IDLE ] = ACT_HL2MP_IDLE_CROUCH_FIST,
		[ ACT_MP_CROUCHWALK ] = ACT_HL2MP_WALK_CROUCH_FIST,
		[ ACT_MP_ATTACK_STAND_PRIMARYFIRE ] = ACT_HL2MP_GESTURE_RANGE_ATTACK_FIST,
		[ ACT_MP_ATTACK_CROUCH_PRIMARYFIRE ] = ACT_HL2MP_GESTURE_RANGE_ATTACK_FIST,
		[ ACT_MP_RELOAD_STAND ] = ACT_HL2MP_GESTURE_RELOAD_FIST,
		[ ACT_MP_RELOAD_CROUCH ] = ACT_HL2MP_GESTURE_RELOAD_FIST,
		[ ACT_MP_JUMP ] = ACT_HL2MP_JUMP_FIST,
		[ ACT_RANGE_ATTACK1 ] = ACT_HL2MP_GESTURE_RANGE_ATTACK_FIST,
		[ ACT_MP_SWIM ] = ACT_HL2MP_SWIM_FIST,
		[ ACT_MP_SWIM_IDLE ] = ACT_HL2MP_SWIM_IDLE_FIST
	},

	[ "passive" ] =
	{
		[ ACT_MP_STAND_IDLE ] = ACT_HL2MP_IDLE_PASSIVE,
		[ ACT_MP_WALK ] = ACT_HL2MP_WALK_PASSIVE,
		[ ACT_MP_RUN ] = ACT_HL2MP_RUN_PASSIVE,
		[ ACT_MP_CROUCH_IDLE ] = ACT_HL2MP_IDLE_CROUCH_PASSIVE,
		[ ACT_MP_CROUCHWALK ] = ACT_HL2MP_WALK_CROUCH_PASSIVE,
		[ ACT_MP_ATTACK_STAND_PRIMARYFIRE ] = ACT_HL2MP_GESTURE_RANGE_ATTACK_PASSIVE,
		[ ACT_MP_ATTACK_CROUCH_PRIMARYFIRE ] = ACT_HL2MP_GESTURE_RANGE_ATTACK_PASSIVE,
		[ ACT_MP_RELOAD_STAND ] = ACT_HL2MP_GESTURE_RELOAD_PASSIVE,
		[ ACT_MP_RELOAD_CROUCH ] = ACT_HL2MP_GESTURE_RELOAD_PASSIVE,
		[ ACT_MP_JUMP ] = ACT_HL2MP_JUMP_PASSIVE,
		[ ACT_RANGE_ATTACK1 ] = ACT_HL2MP_GESTURE_RANGE_ATTACK_PASSIVE,
		[ ACT_MP_SWIM ] = ACT_HL2MP_SWIM_PASSIVE,
		[ ACT_MP_SWIM_IDLE ] = ACT_HL2MP_SWIM_IDLE_PASSIVE
	},

	[ "ar2" ] =
	{
		[ ACT_MP_STAND_IDLE ] = ACT_HL2MP_IDLE_AR2,
		[ ACT_MP_WALK ] = ACT_HL2MP_WALK_AR2,
		[ ACT_MP_RUN ] = ACT_HL2MP_RUN_AR2,
		[ ACT_MP_CROUCH_IDLE ] = ACT_HL2MP_IDLE_CROUCH_AR2,
		[ ACT_MP_CROUCHWALK ] = ACT_HL2MP_WALK_CROUCH_AR2,
		[ ACT_MP_ATTACK_STAND_PRIMARYFIRE ] = ACT_HL2MP_GESTURE_RANGE_ATTACK_AR2,
		[ ACT_MP_ATTACK_CROUCH_PRIMARYFIRE ] = ACT_HL2MP_GESTURE_RANGE_ATTACK_AR2,
		[ ACT_MP_RELOAD_STAND ] = ACT_HL2MP_GESTURE_RELOAD_AR2,
		[ ACT_MP_RELOAD_CROUCH ] = ACT_HL2MP_GESTURE_RELOAD_AR2,
		[ ACT_MP_JUMP ] = ACT_HL2MP_JUMP_AR2,
		[ ACT_RANGE_ATTACK1 ] = ACT_HL2MP_GESTURE_RANGE_ATTACK_AR2,
		[ ACT_MP_SWIM ] = ACT_HL2MP_SWIM_AR2,
		[ ACT_MP_SWIM_IDLE ] = ACT_HL2MP_SWIM_IDLE_AR2
	}
}

function SWEP:SetWeaponHoldType(preset)
	self.ActTable = self.HoldTypes[ preset ] or self.ActTable
end

function SWEP:RegisterHoldType(preset, acttable)
	self.HoldTypes[ preset ] = acttable
end

function SWEP:GetActTable()
	return self.ActTable
end

function SWEP:SetActTable(acttable)
	self.ActTable = acttable
end

local ActToString = {
	[ ACT_MP_STAND_IDLE ] = "ACT_MP_STAND_IDLE",
	[ ACT_MP_WALK ] = "ACT_MP_WALK",
	[ ACT_MP_RUN ] = "ACT_MP_RUN",
	[ ACT_MP_CROUCH_IDLE ] = "ACT_MP_CROUCH_IDLE",
}

local DEBUG = false -- Fix

function SWEP:TranslateActivity(act)
	if (DEBUG) then
		if act == ACT_RANGE_ATTACK1 then print"BaseCombatWeapon: Range Attack called" end
	end

	if (act == ACT_MP_SWIM and not (self:GetOwner():KeyDown(KEY_W ) or self:GetOwner():KeyDown(KEY_A ) or self:GetOwner():KeyDown(KEY_S) or self:GetOwner():KeyDown(KEY_D))) then
		act = ACT_MP_SWIM_IDLE
	end

	if (DEBUG) then
		local test = self:GetOwner():GetSequenceActivityName(self:GetOwner():SelectWeightedSequence(act))
		-- Unregistered sequences
		if not self.ActTable[ act ] and (test ~= "Not Found!" and test ~= ACT_GMOD_NOCLIP_LAYER and test ~= ACT_LAND) then
			print("BaseCombatWeapon: Unregistered sequence - " .. test)
		end
	end
	--return 665
	if (DEBUG) then
		print("Quick: " .. QuickTranslation[ act ])
		print("Act: " .. self.ActTable[ QuickTranslation[ act ] ])
	end
	return self.ActTable[ act ] or -1
	--return self:GetOwner().ActivityList[ self.ActTable[ ActToString[ act ] ] ] or -1 -- Fix; return -1 or just re-return the activity?
end

function SWEP:DoFireEffects()
	self:_SendWeaponAnim(self:LookupActivity("primary"))
	self:PlaySound("primary")

	local pPlayer = self:GetOwner()

	if (pPlayer ~= NULL) then
		pPlayer:MuzzleFlash()
		pPlayer:SetAnimation(pPlayer:LookupAnimation("attack"))
	end
end




PLAYER.Animations = {
	[ "attack" ] = PLAYER_ATTACK1,
	[ "reload" ] = PLAYER_RELOAD
}

PLAYER.AnimEvents = {
	[ "primary" ] = PLAYERANIMEVENT_ATTACK_PRIMARY,
	[ "secondary" ] = PLAYERANIMEVENT_ATTACK_SECONDARY,
}

function PLAYER:LookupAnimation(sAnim)
	return self.Animations[ sAnim:lower() ] or -1
end

function PLAYER:LookupAnimEvent(sAnimEvent)
	return self.AnimEvents[ sAnimEvent:lower() ] or -1
end

function PLAYER:MouseLifted()
	return not (self:KeyDown(IN_ATTACK ) and self:KeyDown(IN_ATTACK2))
end