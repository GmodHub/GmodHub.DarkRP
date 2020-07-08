include('shared.lua')
local VapeParticleEmitter = ParticleEmitter(Vector(0,0,0))
local vapeScale = 1

function SWEP:DrawWorldModel()
	local ply = self:GetOwner()

	if IsValid(ply) then

		local bn = "ValveBiped.Bip01_R_Hand"
		if ply.vapeArmFullyUp then bn ="ValveBiped.Bip01_Head1" end
		local bon = ply:LookupBone(bn) or 0

		local opos = self:GetPos()
		local oang = self:GetAngles()
		local bp,ba = ply:GetBonePosition(bon)
		if bp then opos = bp end
		if ba then oang = ba end
		if ply.vapeArmFullyUp then
			--head position
			opos = opos + (oang:Forward()*0.74) + (oang:Right()*15) + (oang:Up()*2)
			oang:RotateAroundAxis(oang:Forward(),-100)
			oang:RotateAroundAxis(oang:Up(),100)
			opos = opos + (oang:Up()*(vapeScale-1)*-10.25)
		else
			--hand position
			oang:RotateAroundAxis(oang:Forward(),90)
			oang:RotateAroundAxis(oang:Right(),90)
			opos = opos + (oang:Forward()*2) + (oang:Up()*-4.5) + (oang:Right()*-2)
			oang:RotateAroundAxis(oang:Forward(),69)
			oang:RotateAroundAxis(oang:Up(),10)
			opos = opos + (oang:Up()*(vapeScale-1)*-10.25)
		end
		self:SetupBones()

		local mrt = self:GetBoneMatrix(0)
		if mrt then
		mrt:SetTranslation(opos)
		mrt:SetAngles(oang)

		self:SetBoneMatrix(0, mrt)
		end
	end

	self:DrawModel()
end

function SWEP:GetViewModelPosition(pos, ang)
	--mouth pos
	local vmpos1=self.VapeVMPos1 or Vector(18.5,-3.4,-3)
	local vmang1=self.VapeVMAng1 or Vector(170,-105,82)
	--hand pos
	local vmpos2=self.VapeVMPos2 or Vector(24,-8,-11.2)
	local vmang2=self.VapeVMAng2 or Vector(170,-108,132)

	if not LocalPlayer().vapeArmTime then LocalPlayer().vapeArmTime=0 end
	local lerp = math.Clamp((os.clock()-LocalPlayer().vapeArmTime)*3,0,1)
	if LocalPlayer().vapeArm then lerp = 1-lerp end
	local newpos = LerpVector(lerp,vmpos1,vmpos2)
	local newang = LerpVector(lerp,vmang1,vmang2)
	--I have a good reason for doing it like this
	newang = Angle(newang.x,newang.y,newang.z)

	pos,ang = LocalToWorld(newpos,newang,pos,ang)
	return pos, ang
end

sound.Add({
	name = "vape_inhale",
	channel = CHAN_WEAPON,
	volume = 0.24,
	level = 60,
	pitch = { 95 },
	sound = "vapeinhale.ogg"
})


local function vape_do_particle(particle, vel, col)
	col = isfunction(col) and col() or col
	particle:SetColor(col.r, col.g, col.b, 200)
	particle:SetVelocity(vel)
	particle:SetGravity(Vector(0,0,1.5))
	particle:SetLifeTime(0)
	particle:SetDieTime(math.Rand(80,100)*0.11)
	particle:SetStartSize(5)
	particle:SetEndSize(35)
	particle:SetStartAlpha(150)
	particle:SetEndAlpha(0)
	particle:SetCollide(true)
	particle:SetBounce(1)
	particle:SetRoll(math.Rand(0,360))
	particle:SetRollDelta(0.01*math.Rand(-40,40))
	particle:SetAirResistance(80)
end

local function vape_raisearm(ply,raise)
	if !IsValid(ply) then return end
	if raise then
		ply.vapeArmFullyUp = true
		mult = 1
	else
		mult = 0
		ply.vapeArmFullyUp = false
	end
	local b1 = ply:LookupBone("ValveBiped.Bip01_R_Upperarm")
	local b2 = ply:LookupBone("ValveBiped.Bip01_R_Forearm")
	if (not b1) or (not b2) then return end
	ply:ManipulateBoneAngles(b1,Angle(20*mult,-62*mult,10*mult))
	ply:ManipulateBoneAngles(b2,Angle(-5*mult,-10*mult,0))
end

local function vape_do_pulse(ply, amt, spreadadd, col)
	if !IsValid(ply) then return end

	if ply:WaterLevel()==3 then return end

	if not spreadadd then spreadadd=0 end

	local attachid = ply:LookupAttachment("eyes")
	VapeParticleEmitter:SetPos(LocalPlayer():GetPos())

	local angpos = ply:GetAttachment(attachid) or {Ang=Angle(0,0,0), Pos=Vector(0,0,0)}
	local fwd
	local pos

	if (ply != LocalPlayer()) then
		fwd = (angpos.Ang:Forward()-angpos.Ang:Up()):GetNormalized()
		pos = angpos.Pos + (fwd*3.5)
	else
		fwd = ply:GetAimVector():GetNormalized()
		pos = ply:GetShootPos() + fwd*1.5 + gui.ScreenToVector(ScrW()/2, ScrH())*5
	end

	fwd = ply:GetAimVector():GetNormalized()

	for i = 1,amt do
		if !IsValid(ply) then return end
		local particle = VapeParticleEmitter:Add(string.format("particle/smokesprites_00%02d",math.random(7,16)), pos)
		if particle then
			local dir = VectorRand():GetNormalized() * ((amt+5)/10)
			vape_do_particle(particle, (ply:GetVelocity()*0.25)+(((fwd*9)+dir):GetNormalized() * math.Rand(50,80) * (amt + 1) * 0.2), col)
		end
	end
end

net.Receive("Vape",function()
	local ply = net.ReadEntity()
	if not IsValid(ply) then return end
	if ply:GetPos():Distance(LocalPlayer():GetPos()) > 1000 then return end
	local amt = net.ReadInt(8)

	local flavor = net.ReadUInt(8)
	local col = rp.col.White
	if (flavor != 0) then
		local upg = rp.shop.Get(flavor)
		if (upg and upg.Color) then
			col = upg.Color
		end
	end
	//if (ply:IsRoot()) then amt = 1000 end
	if !IsValid(ply) then return end
	if amt>=50 /*and !ply:IsRoot()*/ then
		ply:EmitSound("vapecough1.ogg",90)

		for i=1,200 do
			local d=i+10
			if i>140 then d=d+150 end
			timer.Simple((d-1)*0.003,function() vape_do_pulse(ply, 1, 0, col) end)
		end

		return
	elseif amt>=35 then
		ply:EmitSound("vapebreath2.ogg",75,100,0.7)
	elseif amt>=10 then
		ply:EmitSound("vapebreath1.ogg",70,130-math.min(100,amt*2),0.4+(amt*0.005))
	end

	for i=1,amt*2 do
		timer.Simple((i-1)*0.02,function() vape_do_pulse(ply,math.floor(((amt*2)-i)/10), 0, col) end)
	end
end)

net.Receive("VapeArm",function()
	local ply = net.ReadEntity()
	if not IsValid(ply) then return end
	if ply:GetPos():Distance(LocalPlayer():GetPos()) > 2000 then return end
	local z = net.ReadBool()
	if !IsValid(ply) then return end
	if ply.VapeArm ~= z then
		if z then
			ply:EmitSound("vape_inhale")
		else
			ply:StopSound("vape_inhale")
		end
		ply.vapeArm = z
		ply.vapeArmTime = os.clock()
	end
	vape_raisearm(ply,z)
end)
