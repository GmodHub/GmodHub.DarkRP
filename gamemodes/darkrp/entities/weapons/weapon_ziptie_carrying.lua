AddCSLuaFile()

SWEP.WorldModel = ""
SWEP.ViewModel = ""
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ''

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ''

local badpoints = {
	[CONTENTS_SOLID] 		= true,
	[CONTENTS_MOVEABLE] 	= true,
	[CONTENTS_LADDER]		= true,
	[CONTENTS_PLAYERCLIP] 	= true,
	[CONTENTS_MONSTERCLIP] 	= true,
}
local ents_FindInSphere = ents.FindInSphere
local util_PointContents = util.PointContents
local function isEmpty(vector, ignore)
    ignore = ignore or {}

    local point = util_PointContents(vector)
    local a = point ~= CONTENTS_SOLID
        and point ~= CONTENTS_MOVEABLE
        and point ~= CONTENTS_LADDER
        and point ~= CONTENTS_PLAYERCLIP
        and point ~= CONTENTS_MONSTERCLIP
    if not a then return false end

    local b = true

    for k,v in ipairs(ents_FindInSphere(vector, 35)) do
        if (v:IsNPC() or v:IsPlayer() or v:GetClass() == "prop_physics" or v.NotEmptyPos) and not table.HasValue(ignore, v) then
            b = false
            break
        end
    end

    return a and b
end


function SWEP:Initialize()
	self:SetHoldType('melee2')
	self.DropWait = CurTime() + 1.5
end

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire(CurTime() + 0.5)

	if (CurTime() < self.DropWait) then return end

	if (SERVER) then
		local start = self.Owner:GetPos() + Vector(0, 0, 45)
		local ang = Angle(0, self.Owner:GetAngles().y, 0)
		local hulltr = util.TraceHull({
			start = start + ang:Forward() * 36,
			endpos = start + ang:Forward() * 70,
			filter = {self.Owner.ZiptieTarget, self.Owner.ZiptieTarget:GetVehicle()},
			mask = MASK_SHOT_HULL,
			mins = Vector(-16, -16, -45),
			maxs = Vector(16, 16, 45)
		})

		if (!hulltr.Hit) then
			self.Owner:StopCarrying(nil, start + ang:Forward() * 54)
		else
			rp.Notify(self.Owner, NOTIFY_GENERIC, term.Get('CantDropCarrierNoRoom'))
		end
	end
end

function SWEP:SecondaryAttack()
	if (self:GetNextPrimaryFire() <= CurTime()) then
		self:PrimaryAttack()
	end
end

function SWEP:Reload()
	if (self:GetNextPrimaryFire() <= CurTime()) then
		self:PrimaryAttack()
	end
end