dash.IncludeSH 'shared.lua'

function ENT:PlayerUse()
	self.IsEnabled		= (not self.IsEnabled)
	self.PressKeyText	= self.IsEnabled and 'To Disable' or 'To Enable'
end

function ENT:Think()
	self.CameraEnt = IsValid(self:GetCamera()) and self:GetCamera() or nil

	self.ShouldRender = self:InSight(125000)

	self.InRange = self.CameraEnt and (self.CameraEnt:GetPos():DistToSqr(self:GetPos()) < 400000)

	if (not self.HookAdded) then
		self.LastRender = os.clock()
		self.HookAdded = true

		hook.Add('RenderScene', self, function()
			if self.ShouldRender and self.InRange and self.IsEnabled and ((os.clock() - self.LastRender) > 0.033) then --Render @ roughly 30fps
				self.LastRender = os.clock()

				if (not self.TVMaterial) or (not self.TVRT) then
					self.TVRT = GetRenderTarget('TVMatrender' .. self:EntIndex(), ScrW(), ScrH())

					self.TVMaterial = CreateMaterial('TVMaterial' .. self:EntIndex(),'UnlitGeneric',
					{
						['$basetexture'] = self.TVRT,
						['$model'] = '1',
						['$translucent'] = '0',
						['$ignorez'] = '0',
						['$alphatest'] = '0',
						['$additive'] = '0'
					})
				end

				if self.CameraEnt then
					local view = {}
					view.x = 0
					view.y = 0
					view.w = ScrW()
					view.h = ScrH()
					view.origin = self.CameraEnt:EyePos()
					view.angles = self.CameraEnt:GetAngles()
					view.drawhud = false
					view.drawviewmodel = false

					local ort = render.GetRenderTarget()

					render.SetRenderTarget(self.TVRT)
						render.Clear(0, 0, 0, 255)
						render.ClearDepth()
						render.ClearStencil()
						self.CameraEnt:SetNoDraw(true)
						render.RenderView(view)
						self.CameraEnt:SetNoDraw(false)
						render.UpdateScreenEffectTexture()
					render.SetRenderTarget(ort)
				end
			end
		end)
	end
end

local vec = Vector(6, 0, 19)
local ang = Angle(0, 90, 90)
local mat_server = Material 'sup/entities/security_tv/server.png'
local mat_static = Material 'sup/entities/security_tv/static.png'
function ENT:Draw()
	self:DrawModel()

	if (not self.ShouldRender) then return end

	cam.Start3D2D(self:LocalToWorld(vec), self:LocalToWorldAngles(ang), 0.065)
		if self.InRange and (not self.IsEnabled) then
			draw.Box(-430, -256, 860, 512, ui.col.FlatBlack)

			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(mat_server)
			surface.DrawTexturedRect(-32, -115, 64, 64)

			draw.Box(-430, -32, 860, 64, ui.col.Black)
			draw.SimpleText('Press E to activate your supServ subscription!', 'ui.38', 0, 0, ui.col.White, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		elseif self.InRange and self.TVMaterial and self.TVRT then
			self.TVMaterial:SetTexture('$basetexture', self.TVRT)

			surface.SetDrawColor(255,255,255,255)
			surface.SetMaterial(self.TVMaterial)
			surface.DrawTexturedRect(-430, -256, 860, 512)
		else
			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(mat_static)
			surface.DrawTexturedRect(-430, -256, 860, 512)

			draw.Box(-430, -32, 860, 64, ui.col.Black)
			draw.SimpleText(self.CameraEnt and 'No Signal!' or 'No Camera!', 'ui.38', 0, 0, ui.col.White, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	cam.End3D2D()
end