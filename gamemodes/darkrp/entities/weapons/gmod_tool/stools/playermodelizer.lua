TOOL.Category 	= 'Staff'
TOOL.Name		= '#tool.playermodelizer.name'

TOOL.ClientConVar['model'] = ''

if (CLIENT) then
	language.Add('tool.playermodelizer.name', 'Player Modelizer')
	language.Add('tool.playermodelizer.desc', 'Change the model of players')
	language.Add('tool.playermodelizer.0', 'Left click to set the model of a player, Right click to remove the model.')
end

function TOOL:LeftClick(trace)
	 if SERVER then
		  local model = self:GetClientInfo('model')
		  
		  if model == '' then return false end
		  if (!util.IsValidModel(model)) then return false end

		  if IsValid(trace.Entity) and trace.Entity:IsPlayer() then
			   trace.Entity:SetModel(model)
			   return true
		  else
			   self:GetOwner():SetModel(model)
			   self:GetOwner():ChatPrint('Set your own model.')
		  end
	 end
	 return false
end

function TOOL:RightClick(trace)
	if SERVER then
		if IsValid(trace.Entity) and trace.Entity:IsPlayer() then
			trace.Entity:SetModel(team.GetModel(trace.Entity:GetJob()))
		else
			self:GetOwner():SetModel(team.GetModel(self:GetOwner():GetJob()))
			self:GetOwner():ChatPrint('Reset your own model.')
		end
	 end
	 return false
end

function TOOL.BuildCPanel(CPanel)
	CPanel:AddControl('Header', {Description = '#tool.playermodelizer.desc'})
	CPanel:AddControl('PropSelect', {
		Label = 'Choose Model',
		ConVar = 'playermodelizer_model',
		Height = 3,
		Models = list.Get('PlayerModels')
	})
end

for k, v in ipairs(rp.teams) do
	if istable(v.model) then
		for k, v in ipairs(v.model) do
			list.Set('PlayerModels', v, {})
		end
	else
		list.Set('PlayerModels', v.model, {})
	end
end