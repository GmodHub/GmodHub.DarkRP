TOOL.Category = 'Easy Fading Doors'
TOOL.Name = '#tool.pad_toll.name'

if CLIENT then
	language.Add('tool.pad_toll.name', 'Toll')
	language.Add('tool.pad_toll.desc', 'Create a toll that fades prop/s')
	language.Add('tool.pad_toll.right', 'Select prop/s to link')
	language.Add('tool.pad_toll.left_1', 'Place toll')
	language.Add('tool.pad_toll.reload', 'Clear selected props')
end

TOOL.Information = {
	{ name = "left_1", stage = 1 },
	{ name = "right" },
	{ name = "reload" }
}


TOOL.ClientConVar['price'] 		= 100
TOOL.ClientConVar['onetimeuse'] = 0
TOOL.ClientConVar['holdlen'] 	= 4

cleanup.Register('tolls')

local function makeToll(pl, price, onetimeuse, holdlen, pos, ang)
	if (not IsValid(pl)) or (not pl:CheckLimit('tolls')) then return false end

	local toll = ents.Create 'pad_toll'

	if (not IsValid(toll)) then return false end

	toll:CPPISetOwner(pl)
	toll.ItemOwner = pl

	toll:SetAngles(pos)
	toll:SetPos(ang)
	toll:Spawn()
	for k, v in ipairs(rp.fadingdoor.GetProps(pl)) do
		if IsValid(v) then
			toll:AddProp(v)
		end
	end
	toll:Setprice(price)
	toll:SetOneTimeUse(onetimeuse)
	toll:SetHoldLength(holdlen)

	rp.fadingdoor.ClearProps(pl)
	pl:AddCount('tolls', toll)

	return toll
end
--duplicator.RegisterEntityClass('gmod_button', MakeButton, 'Model', 'Ang', 'Pos', 'key', 'description', 'toggle', 'Vel', 'aVel', 'frozen')

function TOOL:ResetProps()
	self:SetStage(0)

	if SERVER then
		rp.fadingdoor.ClearProps(self:GetOwner())
	end

	if IsValid(self.GhostEntity) then
		self.GhostEntity:Remove()
	end
end

TOOL.Holster = TOOL.ResetProps
TOOL.Reload = TOOL.ResetProps

function TOOL:LeftClick(trace)
	if (IsValid(trace.Entity) and trace.Entity:IsPlayer()) or CLIENT then return false end

	local pl = self:GetOwner()

	if (#rp.fadingdoor.GetProps(pl) == 0) then
		pl:Notify(NOTIFY_ERROR, term.Get('FadingDoorNoProps'))
		return
	end

	self:SetStage(0)

	local ang = trace.HitNormal:Angle()
	ang.pitch = ang.pitch + 90

	local toll = makeToll(pl, math.Clamp(math.floor(tonumber(self:GetClientInfo('price'))), 100, 100000), tobool(self:GetClientInfo('onetimeuse')), math.Clamp(tonumber(self:GetClientInfo('holdlen')), 4, 10), ang, trace.HitPos)

	if (not IsValid(toll)) then return end

	constraint.Weld(toll, trace.Entity, 0, 0, 0, true, false)

	undo.Create('Tolls')
		undo.AddEntity(toll)
		undo.SetPlayer(pl)
	undo.Finish()

	pl:AddCleanup('tolls', toll)

	rp.Notify(pl, NOTIFY_HINT, term.Get('SboxSpawned'), pl:GetCount('tolls'), pl:GetLimit('tolls'), 'tolls')

	return true
end

function TOOL:RightClick(trace)
	local prop = trace.Entity
	local pl = self:GetOwner()

	if CLIENT then return false end

	if (not IsValid(pl)) or (not pl:CheckLimit('tolls')) then return false end

	if (not IsValid(prop)) or (not prop:IsProp()) then
		pl:Notify(NOTIFY_ERROR, term.Get('FadingDoorOnlyProps'))
		return false
	end

	local linkedProps = #rp.fadingdoor.GetProps(pl)

	if rp.fadingdoor.HasProp(pl, prop) then
		rp.fadingdoor.RemoveProp(self:GetOwner(), prop)

		linkedProps = linkedProps - 1
	else
		if (linkedProps >= 2) then
			pl:Notify(NOTIFY_ERROR, term.Get('FadingDoorMaxProps'), 2)
			return false
		end

		rp.fadingdoor.AddProp(self:GetOwner(), prop)

		linkedProps = linkedProps + 1
	end

	self:SetStage((linkedProps > 0) and 1 or 0)

	return true
end

function TOOL:UpdateGhostButton(ent, player)
	if (!IsValid(ent)) then return end

	local tr = util.GetPlayerTrace(player)
	local trace = util.TraceLine(tr)
	if (!trace.Hit) then return end

	if (trace.Entity && trace.Entity:GetClass() == 'pad_toll' || trace.Entity:IsPlayer()) then
		ent:SetNoDraw(true)
		return
	end

	local Ang = trace.HitNormal:Angle()
	Ang.pitch = Ang.pitch + 90

	local min = ent:OBBMins()
	ent:SetPos(trace.HitPos - trace.HitNormal * min.z)
	ent:SetAngles(Ang)

	ent:SetNoDraw(false)
end

function TOOL:Think()
	if (!IsValid(self.GhostEntity )) then
		self:MakeGhostEntity('models/maxofs2d/button_04.mdl', Vector(0, 0, 0), Angle(0, 0, 0))
	end

	self:UpdateGhostButton(self.GhostEntity, self:GetOwner())
end

function TOOL.BuildCPanel(CPanel)
	CPanel:AddControl('Header', { Description = '#tool.pad_toll.desc' })

	CPanel:NumSlider('Price', 'pad_toll_price', 100, 100000)
	CPanel:CheckBox('One Time Use', 'pad_toll_onetimeuse')
	CPanel:ControlHelp('Should people pay every time they use the pad or just once.')

	CPanel:NumSlider('Hold Length', 'pad_toll_holdlen', 4, 10)
	CPanel:ControlHelp('Time the door stays open')
end