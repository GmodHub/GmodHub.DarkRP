local function collideback(Particle, HitPos, Normal) -- stolen from poopee mod
	Particle:SetAngleVelocity(Angle(0, 0, 0))
	local Ang = Normal:Angle()
	Ang:RotateAroundAxis(Normal, Particle:GetAngles().y)
	Particle:SetAngles(Ang)

	Particle:SetBounce(1)
	Particle:SetVelocity(Vector(0, 0, -100))
	Particle:SetGravity(Vector(0, 0, -100))

	Particle:SetLifeTime(0)
	Particle:SetDieTime(30)

	Particle:SetStartSize(10)
	Particle:SetEndSize(0)

	Particle:SetStartAlpha(255)
	Particle:SetEndAlpha(0)
end

local grav = Vector(0, 0, -600)
net('rp.PooPeePiss', function()
	local pl = net.ReadPlayer()
	if (not IsValid(pl)) then return end
	local centr = pl:GetPos() + Vector(0,0,32)
	local em = ParticleEmitter(centr)
	for i = 1, (3 * 10) do
		timer.Simple(i/100, function()
			if (not IsValid(pl)) then return end
			local part = em:Add('sprites/orangecore2', centr)
			if part then
				part:SetVelocity(pl:GetAimVector() * 1000 + Vector(math.random(-50,50),math.random(-50,50),0))
				part:SetDieTime(30)
				part:SetLifeTime(1)
				part:SetStartSize(10)
				part:SetAirResistance(100)
				part:SetRoll(math.Rand(0, 360))
				part:SetRollDelta(math.Rand(-200, 200))
				part:SetGravity(grav)
				part:SetCollideCallback(collideback)
				part:SetCollide(true)
				part:SetEndSize(0)
			end
		end)
	end
	timer.Simple(3, function()
		em:Finish()
	end)
end)
