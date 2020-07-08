SWEP.Base = "weapon_rp_base"

if CLIENT then
	SWEP.PrintName		= "Taser"
	SWEP.Purpose		= "Fires a stunning projectile"
	SWEP.Instructions	= "Left click to launch the taser"
	SWEP.Category 		= 'RP'
	SWEP.Slot			= 2
	SWEP.DrawCrosshair	= true
end

SWEP.Spawnable = true

SWEP.ViewModel			= Model("models/weapons/c_pistol.mdl")
SWEP.WorldModel			= Model("models/weapons/w_pistol.mdl")

SWEP.ViewModelFOV = 55
SWEP.HoldType = "revolver"
SWEP.UseHands = true

SWEP.Primary.Sound			= Sound("weapons/mortar/mortar_fire1.wav")
SWEP.Secondary.Sound		= Sound("ambient/energy/spark5.wav")

SWEP.HitDistance			= 750
SWEP.NextThinkTime = 0
local Rate = 0.05

local HookCable = Material("sprites/physbeama")

function SWEP:Deploy()
	if SERVER and (not self.HasDeployed) then
		self:SetCharge(self.Owner.TaserCharge or 100)
	end

	self.HasDeployed = true

	self.NextThinkTime = CurTime()
end

if CLIENT then
	function SWEP:GetSwitcherSlot()
		return IsValid(self.Owner) and self.Owner:IsCP() and 2 or 3
	end

	local color_bg 		= Color(0,0,0)
	local color_outline = Color(245,245,245)

	local math_clamp	= math.Clamp
	local Color 		= Color
	local cam 			= cam

	function SWEP:DrawHUD()
		if (not LocalPlayer():Alive()) then return end

		local w, h = 150, 25
		local x, y = ScrW() - w - 30, ScrH() - h - 30

		rp.ui.DrawProgress(x, y, w, h, self:GetCharge()/100)

		local vm = self.Owner:GetViewModel()

		if (not IsValid(vm)) then return end

		render.SetMaterial(HookCable)
		--render.DrawSprite(self.StartPos, self.size or 60, self.size or 60, Color(180,180,255))

		att = vm:GetAttachment(1)

		cam.Start3D()
			if IsValid(self:GetBolt()) then
				--render.DrawBeam(self:GetBolt():GetPos(), vm:GetPos() + Vector(-1, 0, -1), 1, 0, 2, Color(255,255,255,255)) -- Find bone pos
				render.DrawBeam(att and att.Pos + Vector(2.5, 0, 3 ) or self.Owner:GetShootPos(), self:GetBolt():GetPos(), 3, 0, 2, Color(0, 255, 255, 255))
			else
				render.DrawBeam(self:GetPos(), self:GetPos(), 1, 0, 2, Color(255,255,255,255))
			end
		cam.End3D()
	end
end

function SWEP:Reload() end

function SWEP:SetupDataTables()
	self:NetworkVar("Entity", 0, "Bolt")
	self:NetworkVar("Int", 0, "Charge")
end

local off_ang = Angle(0, 90, 0)
function SWEP:FireTaser(DoDmg)
	local tsr = ents.Create("ent_taser_hook")

	if IsValid(tsr) then
		local trace = self:GetOwner():GetEyeTrace()

		/*local sparkfx = EffectData() sparkfx:SetOrigin(trace.HitPos)
		util.Effect("Sparks", sparkfx)*/

		--tsr:SetParent(self, 1)
		tsr:SetPos(self.Owner:GetShootPos() - self.Owner:GetAimVector() * 10)
		tsr:SetAngles(self.Owner:EyeAngles() + off_ang)
		tsr:SetOwner(self.Owner)
		tsr:Spawn()

		tsr:SetDamage(0)

		tsr.Weapon = self
		tsr.Shooter = self.Owner

		self:SetBolt(tsr)

		tsr.FireVelocity = self.Owner:GetAimVector() * self.HitDistance + self.Owner:GetVelocity()

		local phys = tsr:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetVelocity(tsr.FireVelocity)
			tsr.Fired = true
		end
	end
end

function SWEP:PrimaryAttack()
	if (not IsValid(self.Owner ) or self:GetCharge() < 100 or IsValid(self:GetBolt())) then return end

	self.Weapon:EmitSound(self.Primary.Sound)

	if SERVER then
		self:SetCharge(0)
		self.Owner.TaserCharge = 0
		self.Owner:SetAnimation(PLAYER_ATTACK1)
		self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)

		self:FireTaser()
	end
end

function SWEP:Think()
	self.Slot = self.Owner:IsCP() and 2 or 3

	if CurTime() < self.NextThinkTime then return end

	local charge = self:GetCharge()

	if charge < 100 then
		local newCharge = charge + 1
		self:SetCharge(newCharge)
		self.Owner.TaserCharge = newCharge
	end

	self.NextThinkTime = CurTime() + Rate
end

	function SWEP:Holster()
		local bolt = self:GetBolt()
		if SERVER and IsValid(bolt ) and IsValid(self.Owner) then
			bolt:Remove()
		end

		return true
	end

if CLIENT then
	function SWEP:DrawWorldModel()
		self:DrawModel()
		local att = self:GetAttachment(1)
		if IsValid(self:GetBolt() ) and IsValid(self.Owner) then
			render.SetMaterial(HookCable)
			render.DrawBeam(self:GetBolt():GetPos(), att and att.Pos or self.Owner:GetShootPos(), 3, 0, 2, Color(0, 255, 255, 255))
		end
	end
end