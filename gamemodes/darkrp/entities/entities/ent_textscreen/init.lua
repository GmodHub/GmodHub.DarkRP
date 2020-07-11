dash.IncludeCL 'cl_init.lua'
dash.IncludeSH 'shared.lua'

function ENT:Initialize()
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	self:DrawShadow( false )
	self:SetModel("models/hunter/plates/plate1x1.mdl")
	self:SetMaterial("models/effects/vol_light001")
	self:SetSolid( SOLID_VPHYSICS )
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)

	self:SetText("")
	self:SetBackground(false)
	self:SetFont(1)
	self:SetSize(14)
	self:SetTextColor(14)
	self:SetBackgroundColor(255)

	self.heldby = 0
	self:SetMoveType(MOVETYPE_NONE)
end

function ENT:PhysicsUpdate(phys)
	if self.heldby <= 0 then
		phys:Sleep()
	end
end

local function textscreenpickup(ply, ent)
	if IsValid(ent) and ent:GetClass() == "ent_textscreen" then
		ent.heldby = ent.heldby+1
	end
end
hook.Add("PhysgunPickup", "textscreenpreventtravelpickup", textscreenpickup)

local function textscreendrop(ply, ent)
	if IsValid(ent) and ent:GetClass() == "ent_textscreen" then
		ent.heldby = ent.heldby-1
	end
end
hook.Add("PhysgunDrop", "textscreenpreventtraveldrop", textscreendrop)

function ENT:UpdateInfo(text, font, size, backgorund, color, colorbg)

	self:SetText(text)
	self:SetBackground(backgorund)
	self:SetFont(font)
	self:SetSize(size)
	self:SetTextColor(color)
	self:SetBackgroundColor(colorbg)

end

local function textscreencantool(ply, trace, tool)
	if IsValid(trace.Entity) and trace.Entity:GetClass() == "textscreen" then
		if !(tool == "ent_textscreen" or tool == "remover") then
			return false
		end
	end
end
hook.Add("CanTool", "textscreenpreventtools", textscreencantool)
