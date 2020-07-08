TOOL.Category = 'Appearance'
TOOL.Name = '#tool.colour.name'

TOOL.ClientConVar[ 'r' ] = 255
TOOL.ClientConVar[ 'g' ] = 0
TOOL.ClientConVar[ 'b' ] = 255
TOOL.ClientConVar[ 'a' ] = 255

TOOL.Information = {
	{ name = "left" },
	{ name = "right" },
	{ name = "reload" }
}

local function SetColour(Player, Entity, Data)
	if (Data.Color ) then Entity:SetColor(Color(Data.Color.r, Data.Color.g, Data.Color.b, math.Clamp(Data.Color.a, 25, 255))) end

	if (SERVER) then
		duplicator.StoreEntityModifier(Entity, 'colour', Data)
	end
end
duplicator.RegisterEntityModifier('colour', SetColour)

function TOOL:LeftClick(trace)
	local ent = trace.Entity
	if (IsValid(ent.AttachedEntity)) then ent = ent.AttachedEntity end

	if IsValid(ent) then

		if (CLIENT) then return true end

		local r = self:GetClientNumber('r', 0)
		local g = self:GetClientNumber('g', 0)
		local b = self:GetClientNumber('b', 0)
		local a = self:GetClientNumber('a', 0)

		if (r < 20) and (g < 20) and (b < 20) then
			r, g, b = 20, 20, 20
		end

		SetColour(self:GetOwner(), ent, { Color = Color(r, g, b, a)})

		return true

	end
end

function TOOL:RightClick( trace )

	local ent = trace.Entity
	if ( IsValid( ent.AttachedEntity ) ) then ent = ent.AttachedEntity end
	if ( !IsValid( ent ) ) then return false end -- The entity is valid and isn't worldspawn

	if ( CLIENT ) then return true end

	local clr = ent:GetColor()
	self:GetOwner():ConCommand( "colour_r " .. clr.r )
	self:GetOwner():ConCommand( "colour_g " .. clr.g )
	self:GetOwner():ConCommand( "colour_b " .. clr.b )
	self:GetOwner():ConCommand( "colour_a " .. clr.a )
	self:GetOwner():ConCommand( "colour_fx " .. ent:GetRenderFX() )
	self:GetOwner():ConCommand( "colour_mode " .. ent:GetRenderMode() )

	return true

end

function TOOL:Reload(trace)
	local ent = trace.Entity
	if IsValid(ent.AttachedEntity) then ent = ent.AttachedEntity end

	if IsValid(ent) then

		if (CLIENT) then return true end

		SetColour(self:GetOwner(), ent, { Color = Color(255, 255, 255, 255), RenderMode = 0, RenderFX = 0 })
		return true

	end
end

local ConVarsDefault = TOOL:BuildConVarList()

function TOOL.BuildCPanel(CPanel)
	CPanel:AddControl('Header', {Description	= '#tool.colour.desc'})
	CPanel:AddControl('ComboBox', {MenuButton = 1, Folder = 'colour', Options = {['#preset.default'] = ConVarsDefault }, CVars = table.GetKeys(ConVarsDefault)})
	CPanel:AddControl('Color', {Label = '#tool.colour.color', Red = 'colour_r', Green = 'colour_g', Blue = 'colour_b', Alpha = 'colour_a'})
end