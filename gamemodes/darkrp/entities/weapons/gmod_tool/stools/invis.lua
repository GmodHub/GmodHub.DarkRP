TOOL.Category = 'Staff'
TOOL.Name = '#Tool.invis.name'

function TOOL:LeftClick(trace)
	if SERVER and IsValid(trace.Entity) then
		trace.Entity:SetRenderMode(RENDERMODE_NONE)
		trace.Entity:DrawShadow(false)
	end
end

function TOOL:RightClick(trace)
	if SERVER and IsValid(trace.Entity) then
		trace.Entity:SetRenderMode(RENDERMODE_NORMAL)
		trace.Entity:DrawShadow(true)
	end
end

if CLIENT then
	language.Add("Tool.invis.name", "Invisible")
	function TOOL.BuildCPanel(CPanel)
		CPanel:AddControl('Header', {Description = 'Sets a prop to invisible'})
	end
end
