AddCSLuaFile()

SWEP.PrintName 					= 'Incendiary'
SWEP.Slot 						= 3
SWEP.SlotPos 					= 1
SWEP.DrawAmmo 					= false
SWEP.DrawCrosshair 				= false

SWEP.Instructions 				= 'Click to set shit on fire'
SWEP.Author 					= 'aStonedPenguin'

SWEP.WorldModel = Model( "models/weapons/w_tnt.mdl" )
SWEP.ViewModel = Model( "models/weapons/v_tnt.mdl" )


SWEP.ViewModelFOV 				= 62
SWEP.ViewModelFlip 				= false
SWEP.AnimPrefix	 				= 'rpg'

SWEP.Spawnable 					= true
SWEP.Category 					= 'RP'
SWEP.Sound 						= ''
SWEP.Primary.ClipSize 			= -1
SWEP.Primary.DefaultClip 		= 0
SWEP.Primary.Automatic 			= false
SWEP.Primary.Ammo 				= ''

SWEP.Secondary.ClipSize 		= -1
SWEP.Secondary.DefaultClip 		= 0
SWEP.Secondary.Automatic 		= false
SWEP.Secondary.Ammo 			= ''

function SWEP:Initialize()
	--self:SetHoldType('pistol')
end

function SWEP:Deploy()
	if (SERVER) then
	--	self.Owner:DrawWorldModel(false)
	end
end

function SWEP:PrimaryAttack()
	if (SERVER) then
		local tr = util.TraceLine({
			start = self.Owner:GetShootPos(),
			endpos = self.Owner:GetShootPos() + 100 * self.Owner:GetAimVector(),
			filter = {self.Owner},
		})

		local c4 = ents.Create('ent_incendiary')
		c4:SetPos(tr.HitPos)
		c4:SetAngles(tr.HitNormal:Angle() - Angle(90, 180, 0))
		c4:Spawn()

		c4.ItemOwner = self.Owner

		if tr.Entity and IsValid(tr.Entity) then
			if tr.Entity:GetPhysicsObject():IsValid() then
				c4:SetParent(tr.Entity)
			elseif not tr.Entity:IsNPC() and not tr.Entity:IsPlayer() and tr.Entity:GetPhysicsObject():IsValid() then
				constraint.Weld(c4, tr.Entity)
			end
		else
			c4:SetMoveType(MOVETYPE_NONE)
		end

		hook.Call('PlayerPlaceIncendiary', nil, self.Owner, tr.Entity)

		if not tr.Hit then
			c4:SetMoveType(MOVETYPE_VPHYSICS)
		end

		self.Owner:DoAnimationEvent(ACT_GMOD_GESTURE_ITEM_PLACE)
		self.Owner:EmitSound("c4.PlantSound")
		self.Owner:StripWeapon('weapon_incendiary')
	end
end

function SWEP:SecondaryAttack()
	self:PrimaryAttack()
end