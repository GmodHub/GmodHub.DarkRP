SWEP.Instructions = "LMB: Vape\n (Hold and release)"

SWEP.PrintName = "Вейп"

SWEP.IconLetter	= "V"
SWEP.Category = "RP"
SWEP.Slot = 2
SWEP.SlotPos = 0

SWEP.ViewModelFOV = 62 --default
SWEP.UseHands = true
SWEP.DrawCrosshair = false

SWEP.ViewModel = "models/swamponions/vape.mdl"
SWEP.WorldModel = "models/swamponions/vape.mdl"
SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.Clipsize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.Clipsize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.DrawAmmo = false
SWEP.HoldType = "slam"

if SERVER then
	function SWEP:VapeUpdate()
		local ply = self.Owner
		if not ply.vapeCount then ply.vapeCount = 0 end
		--if not ply.cantStartVape then ply.cantStartVape=false end
		if ply.vapeCount == 0 and ply.cantStartVape then return end

		ply.vapeCount = ply.vapeCount + 1
		if ply.vapeCount == 1 then
			ply.vapeArm = true
			net.Start("VapeArm")
			net.WriteEntity(ply)
			net.WriteBool(true)
			net.Broadcast()
		end
		if ply.vapeCount >= 50 /*and !ply:IsRoot()*/ then
			ply.cantStartVape = true
			self:ReleaseVape(ply)
		end
	end

	hook.Add("KeyRelease","DoVapeHook",function(ply, key)
		if key == IN_ATTACK then
			if IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() == "weapon_vape" then
				ply:GetActiveWeapon():ReleaseVape()
				ply.cantStartVape=false
			end
		end
	end)

	function SWEP:ReleaseVape()
		local ply = self.Owner
		if not ply.vapeCount then ply.vapeCount = 0 end
		if ply.vapeCount >= 5 then
			net.Start("Vape")
				net.WriteEntity(ply)
				net.WriteInt(ply.vapeCount, 8)
				net.WriteUInt(self.Color, 8)
			net.Send(table.Filter(player.GetAll(), function(v) return ply:GetPos():Distance(v:GetPos()) < 4000000 end))
		end
		if ply.vapeArm then
			ply.vapeArm = false
			net.Start("VapeArm")
				net.WriteEntity(ply)
				net.WriteBool(false)
			net.Broadcast()
		end
		ply.vapeCount=0
	end
end

function SWEP:Deploy()
	self:SetHoldType("slam")

	if (CLIENT or self.Color) then return end

	local flavor = self.Owner and self.Owner.PermaWeaponSettings and self.Owner.PermaWeaponSettings.Vape
	if (flavor) then
		local upg = rp.shop.Get(flavor)
		if (upg and self.Owner:HasUpgrade(upg:GetUID()) and upg:GetCat() == 'Permanent Vapes') then
			self.Color = flavor
		end
	end
	self.Color = self.Color or 0
end

function SWEP:SetupDataTables()
	self:NetworkVar("Bool", 0, "Amount");
end

function SWEP:PrimaryAttack()
	if SERVER then
		self:VapeUpdate()
	end
	self.Weapon:SetNextPrimaryFire(CurTime() + 0.1)
end

function SWEP:SecondaryAttack()
	return
end

function SWEP:Reload()
	return
end

function SWEP:Holster()
	if SERVER and IsValid(self.Owner) then
		self:ReleaseVape()
	end
	return true
end

SWEP.OnDrop = SWEP.Holster
SWEP.OnRemove = SWEP.Holster
