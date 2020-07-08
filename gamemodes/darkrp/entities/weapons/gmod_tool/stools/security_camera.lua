TOOL.Category = 'Roleplay'
TOOL.Name = '#tool.security_camera.name'

TOOL.Information = {
	{ name = 'left_0', stage = 0 },
	{ name = 'left_1', stage = 1 },
	{ name = 'reload_1', stage = 1 }
}

if CLIENT then
	language.Add('tool.security_camera.name', 'Security Camera')
	language.Add('tool.security_camera.desc', 'Creates a security camera and monitor')
	language.Add('tool.security_camera.left_0', 'Place a monitor or select monitor to link')
	language.Add('tool.security_camera.left_1', 'Place a camera')
	language.Add('tool.security_camera.reload_1', 'Undo monitor')
end

cleanup.Register 'Security Camera'
cleanup.Register 'Security Monitor'

local makeMonitor, makeCamera
if SERVER then
	function makeMonitor(pl, pos, ang)
		if (not IsValid(pl)) or (not pl:CheckLimit('security_monitors')) then return false end

		local monitor = ents.Create 'security_tv'

		if (not IsValid(monitor)) then return false end

		monitor:CPPISetOwner(pl)

		monitor:SetAngles(pos)
		monitor:SetPos(ang)
		monitor:Spawn()

		pl:AddCount('security_monitors', monitor)

		return monitor
	end

	function makeCamera(pl, monitor, pos, ang)
		if (not IsValid(pl)) or (not pl:CheckLimit('security_cameras')) then return false end

		local camera = ents.Create 'security_camera'

		if (not IsValid(camera)) then return false end

		camera:CPPISetOwner(pl)

		camera:SetAngles(pos)
		camera:SetPos(ang)
		camera:Spawn()

		monitor:SetCamera(camera)

		pl:AddCount('security_cameras', camera)

		return camera
	end
end

function TOOL:ResentEnts()
	if SERVER and (self:GetStage() == 1) then
		if IsValid(self.MonitorEnt) then
			self.MonitorEnt:Remove()
		end
	end

	if IsValid(self.GhostEntity) then
		self.GhostEntity:Remove()
	end

	self:SetStage(0)
end
TOOL.Holster = TOOL.ResentEnts
TOOL.Reload = TOOL.ResentEnts

function TOOL:LeftClick(trace)
	if CLIENT then return true end

	if (self:GetStage() == 0) then
		if IsValid(trace.Entity) and (trace.Entity:GetClass() == 'security_tv') and (not IsValid(trace.Entity:GetCamera())) then
			self.MonitorEnt = trace.Entity
		else
			local ang = trace.HitNormal:Angle()
			ang.pitch = 0

			local pl = self:GetOwner()
			local monitor = makeMonitor(pl, ang, trace.HitPos)

			if (not monitor) then return false end

			undo.Create('Security Monitor')
				undo.AddEntity(monitor)
				undo.SetPlayer(pl)
			undo.Finish()

			pl:AddCleanup('Security Monitor', monitor)

			self.MonitorEnt = monitor
		end

		self:SetStage(1)
	else
		local ang = trace.HitNormal:Angle()
		ang.pitch = ang.pitch + 90

		local pl = self:GetOwner()
		local camera = makeCamera(pl, self.MonitorEnt, ang, trace.HitPos)

		if (not camera) then return false end

		undo.Create('Security Camera')
			undo.AddEntity(camera)
			undo.SetPlayer(pl)
		undo.Finish()

		pl:AddCleanup('Security Camera', camera)

		self:SetStage(0)
	end
end
TOOL.RightClick = TOOL.LeftClick

function TOOL:UpdateGhost(ent, player)
	if (!IsValid(ent)) then return end

	local tr = util.GetPlayerTrace(player)
	local trace = util.TraceLine(tr)
	if (!trace.Hit) then return end

	local Ang = trace.HitNormal:Angle()
	Ang.pitch = ((self:GetStage() == 0) and 0 or (Ang.pitch + 90))

	local min = ent:OBBMins()
	ent:SetPos(trace.HitPos - trace.HitNormal * min.z)
	ent:SetAngles(Ang)

	ent:SetNoDraw(false)
end

function TOOL:Think()
	if SERVER and (not IsValid(self.MonitorEnt)) and (self:GetStage() == 1) then
		self:SetStage(0)
	end

	local model = (self:GetStage() == 0) and 'models/props/cs_office/TV_plasma.mdl' or 'models/dav0r/camera.mdl'

	if (!IsValid(self.GhostEntity) || self.GhostEntity:GetModel() != model) then
		self:MakeGhostEntity(model, Vector(0, 0, 0), Angle(0, 0, 0))
	end

	self:UpdateGhost(self.GhostEntity, self:GetOwner())
end

function TOOL.BuildCPanel(CPanel)
	CPanel:AddControl('Header', { Description = '#tool.security_camera.desc' })
end
