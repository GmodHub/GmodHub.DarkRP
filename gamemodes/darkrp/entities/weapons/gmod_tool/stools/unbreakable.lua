TOOL.Category	= 'Constraints'
TOOL.Name		= '#tool.unbreakable.name'

TOOL.Information = {
	{ name = "left" },
	{ name = "right" }
}

if (CLIENT) then
	language.Add('tool.unbreakable.name', 'Unbreakable')
	language.Add('tool.unbreakable.desc', 'Makes props unbreakable')
	language.Add('tool.unbreakable.left', 'Make a prop unbreakable')
	language.Add('tool.unbreakable.right', 'Restore props original settings')
else
	hook('InitPostEntity', 'unbreakable.InitPostEntity', function()
		local ent = ents.Create 'filter_activator_name'
		ent:SetKeyValue('TargetName', 'FilterDamage')
		ent:SetKeyValue('negated', '1')
		ent:Spawn()
	end)
end

local function ToogleUnbreakable(Player, Entity, Data)
	if Data.Unbreakable then
		Entity:Fire('SetDamageFilter', 'FilterDamage', 0)
	else
		Entity:Fire('SetDamageFilter', '', 0)
	end

	Entity.Unbreakable = Data.Unbreakable

	if (SERVER) then
		duplicator.StoreEntityModifier(Entity, 'unbreakable', Data)
	end
end
duplicator.RegisterEntityModifier('unbreakable', ToogleUnbreakable)

function TOOL:LeftClick(tr)
	if IsValid(tr.Entity) and (not tr.Entity.Unbreakable) then
		if (SERVER) then
			ToogleUnbreakable(self:GetOwner(), tr.Entity, {
				Unbreakable = true
			})
			self:GetOwner():Notify(NOTIFY_GENERIC, term.Get('UnBreakable'))
		end
		return true
	end
	return false
end

function TOOL:RightClick(tr)
	if IsValid(tr.Entity) and tr.Entity.Unbreakable then
		if (SERVER) then
			ToogleUnbreakable(self:GetOwner(), tr.Entity, {
				Unbreakable = false
			})
			self:GetOwner():Notify(NOTIFY_GENERIC, term.Get('Breakable'))
		end
		return true
	end
	return false
end

TOOL.Reload = TOOL.RightClick

function TOOL.BuildCPanel(Panel)
	Panel:AddControl('Header', {Text = '#tool.unbreakable.name', Description = '#tool.unbreakable.desc'})
end