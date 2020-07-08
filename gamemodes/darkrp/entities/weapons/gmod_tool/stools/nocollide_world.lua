TOOL.Category	= 'Construction'
TOOL.Name		= '#tool.nocollide_world.name'

TOOL.Information = {
	{ name = "left" },
	{ name = "right" }
}

if CLIENT then
	language.Add('tool.nocollide_world.name', 'No Collide - World')
	language.Add('tool.nocollide_world.desc', 'Make a prop not collide with the world')
	language.Add('tool.nocollide_world.left', 'Disable world collisions')
	language.Add('tool.nocollide_world.right', 'Enable world collisions')
end

cleanup.Register 'NoCollideWorld'

local freeze
local removeall
local nocollideworld
if SERVER then
	function freeze(self)
		local phys = self:GetPhysicsObject()
		if IsValid(phys) then
			phys:EnableMotion(false)
		end
	end

	function removeall(self, trace)
		if (not IsValid(trace.Entity)) or (not trace.Entity:IsProp()) then return false end
		if CLIENT then return true end

		trace.Entity.OnPhysgunDrop = nil

		self:GetOwner():Notify(NOTIFY_GENERIC, term.Get('CollidedWorld'))

		return constraint.RemoveConstraints(trace.Entity, 'NoCollideWorld')
	end

	function nocollideworld(ent)
		if (not IsValid(ent)) or ent:IsWorld() then
			return false
		end

		local phys1, phys2 = ent:GetPhysicsObject(), game.GetWorld():GetPhysicsObject()

		if (not IsValid(phys1)) or (not IsValid(phys2)) then
			return false
		end

		if ent.Constraints then
			for k, v in ipairs(ent.Constraints) do
				if IsValid(v) then
					local CTab = v:GetTable()
					if (CTab.Type == 'NoCollideWorld' or CTab.Type == 'NoCollide') then return false end
				end
			end
		end

		local const = ents.Create 'phys_ragdollconstraint'
		const:SetKeyValue('xmin', -180)
		const:SetKeyValue('xmax', 180)
		const:SetKeyValue('ymin', -180)
		const:SetKeyValue('ymax', 180)
		const:SetKeyValue('zmin', -180)
		const:SetKeyValue('zmax', 180)
		const:SetKeyValue('spawnflags', 3)
		const:SetPhysConstraintObjects(phys1, phys2)
		const:Spawn()
		const:Activate()

		constraint.AddConstraintTable(ent, const, game.GetWorld())

		const:SetTable({
			Type 	= 'NoCollideWorld',
			Ent1  	= ent,
			Ent2 	= game.GetWorld(),
			Bone1 	= 0,
			Bone2 	= 0
		})

		return const
	end
end

function TOOL:LeftClick(trace)
	if (not IsValid(trace.Entity)) or (not trace.Entity:IsProp()) then return false end
	if CLIENT then return true end

	local const = nocollideworld(trace.Entity)
	if const then
		self:GetOwner():Notify(NOTIFY_GENERIC, term.Get('NoCollidedWorld'))

		/*undo.Create 'NoCollideWorld'
			undo.AddEntity(const)
			undo.AddFunction(function(tab, ent)
				if IsValid(ent) then
					ent.OnPhysgunDrop = nil
					constraint.RemoveConstraints(ent, 'NoCollideWorld')
				end
			end, trace.Entity)
			undo.SetPlayer(self:GetOwner())
		undo.Finish()

		self:GetOwner():AddCleanup('NoCollideWorld', const)*/

		trace.Entity.OnPhysgunDrop = freeze
	end

	return (const ~= false)
end

TOOL.RightClick = removeall
TOOL.Reload 	= removeall

function TOOL.BuildCPanel(CPanel)
	CPanel:AddControl('Header', {Description = '#tool.nocollide_world.desc'})
end