TOOL.Category 	= 'Construction'
TOOL.Name 		= '#tool.nocollider.name'

TOOL.Information = {
	{ name = 'left' },
	{ name = 'right' },
}

if CLIENT then
	language.Add('tool.nocollider.name', 'No Collide')
	language.Add('tool.nocollider.desc', 'Make an object not collide with other objects')
	language.Add('tool.nocollider.right', 'Make an object have collisions')
	language.Add('tool.nocollider.left', 'Make an object have no collisions with anything but the world')
end

function TOOL:LeftClick(trace)
	if (not IsValid(trace.Entity)) or (not trace.Entity:IsProp() and not trace.Entity:IsVehicle()) then return false end
	if CLIENT then return true end

	local succ = (trace.Entity:GetCollisionGroup() == (trace.Entity:IsVehicle() and COLLISION_GROUP_VEHICLE or COLLISION_GROUP_NONE))

	if succ then
		trace.Entity:SetCollisionGroup(COLLISION_GROUP_WORLD)
		self:GetOwner():Notify(NOTIFY_GENERIC, term.Get('NoCollided'))
	end

	return succ
end

function TOOL:RightClick(trace)
	if (not IsValid(trace.Entity)) or (not trace.Entity:IsProp() and not trace.Entity:IsVehicle()) then return false end
	if CLIENT then return true end

	local succ = (trace.Entity:GetCollisionGroup() == COLLISION_GROUP_WORLD)

	if succ then
		trace.Entity:SetCollisionGroup((trace.Entity:IsVehicle() and COLLISION_GROUP_VEHICLE or COLLISION_GROUP_NONE))
		self:GetOwner():Notify(NOTIFY_GENERIC, term.Get('Collided'))
	end

	return succ
end

function TOOL.BuildCPanel(CPanel)
	CPanel:AddControl('Header', {Description = '#tool.nocollider.desc'})
end

hook('EntityRemoved', 'nocollide_fix', function(ent) -- garry is dum
	if (ent:GetClass() == 'logic_collision_pair') then
		ent:Fire('EnableCollisions')
	end
end)