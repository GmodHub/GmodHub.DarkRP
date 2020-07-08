AddCSLuaFile()

local _DRAWPLY
if CLIENT then
	hook.Add('ShouldDrawLocalPlayer','SelfieCam',function()
		if _DRAWPLY then
			return true
		end
	end)

	SWEP.overlays = {
		function()
			--Black&white
			RunConsoleCommand('pp_colormod_addr', 0)
			RunConsoleCommand('pp_colormod_addg', 0)
			RunConsoleCommand('pp_colormod_addb', 0)

			RunConsoleCommand('pp_colormod_mulr', 0)
			RunConsoleCommand('pp_colormod_mulg', 0)
			RunConsoleCommand('pp_colormod_mulb', 0)

			RunConsoleCommand('pp_colormod_color', 0)
			RunConsoleCommand('pp_colormod_contrast', 1)

			RunConsoleCommand('pp_colormod', '1')
		end,
		function()
			RunConsoleCommand('pp_colormod_color', 1)
			RunConsoleCommand('pp_colormod_mulr', -255)
			RunConsoleCommand('pp_colormod_mulg', -255)
			RunConsoleCommand('pp_colormod_mulb', -255)
		end,
		function()
			RunConsoleCommand('pp_bokeh', 0)
			RunConsoleCommand('pp_colormod_mulr', 0)
			RunConsoleCommand('pp_colormod_mulg', 0)
			RunConsoleCommand('pp_colormod_mulb', 0)
			RunConsoleCommand('pp_colormod_color', 2.5)
		end,
	}
end

local function disable()
	RunConsoleCommand('pp_colormod','0')
	RunConsoleCommand('pp_sharpen', '0')
	RunConsoleCommand('pp_bokeh', '0')
	RunConsoleCommand('pp_colormod_color', '1')
end

SWEP.ViewModel = Model('models/weapons/c_arms_animations.mdl')
SWEP.WorldModel = Model('models/MaxOfS2D/camera.mdl')

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= 'none'

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo			= 'none'

SWEP.PrintName	= '#GMOD_Camera'

SWEP.Slot		= 2
SWEP.DrawAmmo		= false
SWEP.DrawCrosshair	= false
SWEP.Spawnable		= true

SWEP.ShootSound = Sound('NPC_CScanner.TakePhoto')

if (SERVER) then

	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false

	--
	-- A concommand to quickly switch to the camera
	--
	concommand.Add('gmod_camera', function(player, command, arguments)

		player:SelectWeapon('gmod_camera')

	end )

end

function SWEP:SetupDataTables()
	self:NetworkVar('Bool',0,'selfie')
end

--
-- Initialize Stuff
--
function SWEP:Initialize()
	self.selfie = false
	self:Setselfie(false)

	self:SetHoldType('camera')

	if SERVER then return end

end

SWEP.CurOverlay = 0

function SWEP:SecondaryAttack()
	if SERVER then return end
	if self.scool then return end
	if self.overlays[self.CurOverlay + 1] then
		self.CurOverlay = self.CurOverlay + 1
		self.overlays[self.CurOverlay]()
	else
		self.CurOverlay = 0
		disable()
	end

	self.scool = true
	timer.Simple(0.2,function()
		self.scool = false
	end)

end

function SWEP:Reload()
	if CLIENT then
		self:CreateWeaponWorldModel()
		if IsValid(self.world_model) then
			self.world_model:SetPos(self.Owner:GetPos())
		end
	end
	if self.cool then return end
	if self.selfie then
		self:SetHoldType('camera')
		self.selfie = false
		self:Setselfie(false)
	else
		self:SetHoldType('pistol')
		self.selfie = true
		self:Setselfie(true)
	end

	self.cool = true
	timer.Simple(0.25,function()
		self.cool = false
	end)

end

function SWEP:CreateWeaponWorldModel()
	if not CLIENT then return end
	if (not IsValid(self.world_model)) then
		self.world_model = ClientsideModel(self.WorldModel, RENDERGROUP_TRANSLUCENT)
		self.world_model:SetNoDraw(true)
		self.world_model:SetPos(self.Owner:GetPos())
	end
end

function SWEP:PreDrawViewModel()
	self:CreateWeaponWorldModel()
	self.world_model:SetNoDraw(true)
end

function SWEP:DrawWorldModel()
	self:CreateWeaponWorldModel()
	local wm = self.world_model
	local o = self.Owner
	if o == LocalPlayer() then return end
	local b = o:LookupAttachment('anim_attachment_RH')
	local bt = o:GetAttachment(b)

	if (!bt) then return end

	local ba,bp = bt.Ang,bt.Pos
	wm:SetNoDraw(false)
	if self.selfie or self:Getselfie() then
		wm:SetPos(bp + (ba:Forward() * 0.5) + (ba:Up() * -1) + (ba:Right() * -3))
		ba:RotateAroundAxis(ba:Up(),160)
	else
		wm:SetPos(bp + (ba:Forward() * 2.5) + (ba:Right() * -3))
	end
	wm:SetAngles(ba)
	wm:SetNoDraw(false)
end

--
-- PrimaryAttack - make a screenshot
--
function SWEP:PrimaryAttack()

	self:DoShootEffect()

	-- If we're multiplayer this can be done totally clientside
	if (!game.SinglePlayer() && SERVER) then return end
	if (CLIENT && !IsFirstTimePredicted()) then return end

	self.Owner:ConCommand('jpeg')

end
--
-- Mouse 2 action
--
function SWEP:Tick()
end

--
-- Deploy - Allow lastinv
--
function SWEP:Deploy()
	self.selfie = false
	self:Setselfie(false)
	self:SetHoldType('camera')
	self.CurOverlay = 0
	return true

end

function SWEP:Holster()
	if CLIENT then
		if IsValid(self.world_model) then
			self.world_model:SetNoDraw(true)
		end
		self.selfie = false
		self:Setselfie(false)
		if self.Owner == LocalPlayer() then
			disable()
			_DRAWPLY = false
		end
	end
	return true
end

--
-- Set FOV to players desired FOV
--
function SWEP:Equip()
end

function SWEP:ShouldDropOnDie() return false end

--
-- The effect when a weapon is fired successfully
--
function SWEP:DoShootEffect()
	self:EmitSound(self.ShootSound)
end

if (SERVER) then return end -- Only clientside lua after this line

SWEP.WepSelectIcon = surface.GetTextureID('vgui/gmod_camera')

-- Don't draw the weapon info on the weapon selection thing
function SWEP:DrawHUD() end
function SWEP:PrintWeaponInfo(x, y, alpha) end

function SWEP:HUDShouldDraw(name)
	-- So we can change weapons
	--if (name == 'CHudWeaponSelection') then return true end
	--return false
end

function SWEP:FreezeMovement()
	return false
end

function SWEP:OnRemove()
	if IsValid(self.world_model) then
		self.world_model:Remove()
	end
	_DRAWPLY = false
end

function SWEP:CalcView(ply, origin, angles, fov)
	if self.selfie then
		local wm = self.world_model
		local o = self.Owner
		local b = o:LookupAttachment('anim_attachment_RH')
		local bt = o:GetAttachment(b)

		if (not bt) then return end

		local ba,bp = bt.Ang,bt.Pos
		wm:SetNoDraw(false)
		if self.selfie or self:Getselfie() then
			wm:SetPos(bp + (ba:Forward() * 0.5) + (ba:Up() * -1) + (ba:Right() * -3))
			ba:RotateAroundAxis(ba:Up(),160)
		else
			wm:SetPos(bp + (ba:Forward() * 2.5) + (ba:Right() * -3))
		end
		wm:SetAngles(ba)
		wm:SetNoDraw(false)
		origin = self.world_model:GetPos()
		local ang = self.world_model:GetAngles()
		ang:RotateAroundAxis(ang:Forward(),20)
		angles = ang
		self.world_model:SetNoDraw(true)
		_DRAWPLY = true
	else
		_DRAWPLY = false
	end

	return origin, angles, fov
end