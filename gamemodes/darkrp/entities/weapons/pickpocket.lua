if SERVER then
	AddCSLuaFile()
end

if CLIENT then
	SWEP.PrintName = "Руки Воришки"
	SWEP.Slot = 3
	SWEP.SlotPos = 1
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
end

SWEP.Instructions = "Left click to pick a pocket"
SWEP.ViewModelFOV = 60
SWEP.ViewModelFlip = false
SWEP.UseHands = true
SWEP.ViewModel = Model("models/weapons/c_lockpick.mdl")
SWEP.WorldModel = Model('models/sup/weapons/lockpick/lockpick.mdl')

SWEP.Spawnable = true
SWEP.Category = "RP"

SWEP.Sound = Sound("physics/wood/wood_box_impact_hard3.wav")

SWEP.Primary.ClipSize = -1      -- Size of a clip
SWEP.Primary.DefaultClip = 0        -- Default number of bullets in a clip
SWEP.Primary.Automatic = false      -- Automatic/Semi Auto
SWEP.Primary.Ammo = ""

SWEP.Secondary.ClipSize = -1        -- Size of a clip
SWEP.Secondary.DefaultClip = -1     -- Default number of bullets in a clip
SWEP.Secondary.Automatic = false        -- Automatic/Semi Auto
SWEP.Secondary.Ammo = ""
SWEP.PickPocketCooldown = 180

function SWEP:Initialize()
	self:SetHoldType("pistol")
end

function SWEP:Deploy()
	if (CLIENT) then return end

	self:SetNextFire(self:GetOwner().PickPocketCooldown or CurTime())
end

function SWEP:PrimaryAttack()
	if (CLIENT) then return end

	local pl = self:GetOwner()
	local target = pl:GetEyeTrace().Entity

	if (self:GetNextFire() > CurTime()) then
		rp.Notify(pl, NOTIFY_ERROR, term.Get('NeedToWait'), math.ceil(self:GetNextFire() - CurTime()))
		return
	end

	if (not IsValid(target)) or (not target:IsPlayer()) or (pl:EyePos():DistToSqr(target:GetPos()) > 28900) then
		rp.Notify(pl, NOTIFY_ERROR, term.Get('GetCloser'))
		return
	end

	if pl:InSpawn() or target:InSpawn() then
		rp.Notify(pl, NOTIFY_ERROR, term.Get('NotAllowedInSpawn'), 'Кража')
		return
	end

	target:TakeDamage(0, pl, self)

	pl:TakeKarma(2)
	pl:Notify(NOTIFY_ERROR, term.Get('LostKarma'), 2, 'кражу')

	hook.Call('PlayerPickPocket', nil, pl, target)

	pl.PickPocketCooldown = CurTime() + self.PickPocketCooldown
	self:SetNextFire(pl.PickPocketCooldown)

	local rand = math.random(0, 10)
	local fail = (rand >= 6) or (not target:CanAfford(rp.cfg.StartMoney)) or target:IsAFK() or (target.NextPickPocket and (target.NextPickPocket > CurTime()))

	target.NextPickPocket = CurTime() + 900

	pl:EmitSound("npc/combine_soldier/gear5.wav", 50, 100)

	if (not pl:IsWanted()) and pl:CloseToCPs() then
		pl:Wanted(nil, "Pick Pocket")
	end

	if fail then
		if target:GetTeamTable().hobo and (math.random(1, 2) ~= 2) then
			rp.Notify(pl, NOTIFY_ERROR, term.Get('YouGotHIV'))
			pl:GiveSTD('HIV')
		else
			rp.Notify(pl, NOTIFY_GENERIC, term.Get('FoundNothing'))
		end

		rp.Notify(target, NOTIFY_ERROR, term.Get('RobberyAttempt'))
		return
	end

	local stealMoney = (rand > 1) or (table.Count(target:GetInv()) < 2) or (not target:CanAfford(rp.cfg.StartMoney * 2))

	if stealMoney then
		local amount = math.random(50, 1000)

		target:TakeMoney(amount, function()
			if IsValid(self) and IsValid(pl) then
				pl:AddMoney(amount)
			end
		end)

		rp.Notify(pl, NOTIFY_SUCCESS, term.Get('YouRobbed'), amount)
		rp.Notify(target, NOTIFY_ERROR, term.Get('YouAreRobbed'))
	else
		local tInv = target:GetInv()
		local v, k = table.Random(tInv)

		if tInv[k] then
			local item = tInv[k]

			local trace = {}
				trace.start = target:EyePos()
				trace.endpos = trace.start + target:GetAimVector() * 85
				trace.filter = target
			local tr = util.TraceLine(trace)

			local ent
			local remove = false
			if (item.Class == "spawned_shipment") then
				item.count = item.count - 1

				if (item.count <= 0) then
					remove = true
				else
					net.Start('Pocket.AddItem')
						net.WriteUInt(k, rp.inv.Bits)
						net.WriteString(rp.shipments[item.contents].name)
						net.WriteString("Count: " .. item.count)
						net.WriteString(item.Model)
					net.Send(target)
				end

				local class = rp.shipments[item.contents].entity
				if (not weapons.Get(class)) then
					ent = ents.Create(class)
				else
					ent = ents.Create('spawned_weapon')
					ent:SetModel(rp.shipments[item.contents].model)
					ent.weaponclass = rp.shipments[item.contents].entity
				end

				ent:SetPos(tr.HitPos + Vector(0, 0, 10))
				ent:Spawn()
			else
				remove = true
				ent = ents.Create(item.Class)
				ent:SetPos(tr.HitPos + Vector(0, 0, 10))
				rp.inv.Finalize(ent, item, target)
			end

			if (remove) then
				net.Start("Pocket.RemoveItem")
					net.WriteUInt(k, rp.inv.Bits)
				net.Send(target)

				target:GetInv()[k] = nil
			end

			target:SaveInv()

			rp.Notify(pl, NOTIFY_SUCCESS, term.Get('YouRobbedItem'))
			rp.Notify(target, NOTIFY_ERROR, term.Get('YouAreRobbedItem'))
		end
	end

end

function SWEP:SecondaryAttack()
	self:PrimaryAttack()
end

function SWEP:SetupDataTables()
	self:NetworkVar("Int", 0, "NextFire")
end

if CLIENT then
	function SWEP:DrawHUD()
		if (not LocalPlayer():Alive()) then return end

		local w, h = 150, 25
		local x, y = ScrW() - w - 30, ScrH() - h - 30

		rp.ui.DrawProgress(x, y, w, h, 1 - math.max(self:GetNextFire() - CurTime(), 0)/self.PickPocketCooldown)
	end
end

function SWEP:DrawWorldModel()
	if (!IsValid(self.Owner)) then return end -- ?

	if (not self.Hand) then
		self.Hand = self.Owner:LookupAttachment("anim_attachment_rh")
	end

	if (not self.Hand) then
		self:DrawModel()
		return
	end

	local hand = self.Owner:GetAttachment(self.Hand)

	if hand then
		self:SetRenderOrigin(hand.Pos + (hand.Ang:Right() * 5.5) + (hand.Ang:Up() * -1.5))

		hand.Ang:RotateAroundAxis(hand.Ang:Right(), 90)
		hand.Ang:RotateAroundAxis(hand.Ang:Up(), 180)

		self:SetRenderAngles(hand.Ang)
	end

	self:DrawModel()
end
