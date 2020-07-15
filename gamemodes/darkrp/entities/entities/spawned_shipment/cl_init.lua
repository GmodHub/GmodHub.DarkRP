include 'shared.lua'

if (not file.Exists('gmh/shipments', 'DATA')) then
	file.CreateDir('gmh/shipments')
end

function ENT:Draw()
	self:DrawModel()

	if (self:Getcount() == 0) then return end

	local inView, dist = self:InDistance(150000)

	if (not inView) then return end

	local ang = self:GetAngles()
	ang:RotateAroundAxis(ang:Up(), 180)

	cam.Start3D2D(self:GetPos() + ang:Up() * 14.01, ang, 0.023)
		self:DrawTexture(255 - dist/590)
	cam.End3D2D()
end

local text_col 	= ui.col.White:Copy()
text_col.a 		= 200

local mat_white = Material 'models/debug/debugwhite'
local clmodel 	= ClientsideModel 'models/weapons/3_rif_ak47.mdl'
clmodel:SetNoDraw(true)

surface.CreateFont('rp.ShipmentTitle', {font = 'Tahoma', size = 100, weight = 1700, antialias = true})
surface.CreateFont('rp.ShipmentCount', {font = 'Tahoma', size = 75, weight = 1700, antialias = true})

local salt = '1' --.. os.time() -- Change this any time how these are rendered gets changed for caching reasons
function ENT:GetTextureID()
	local tab = self:GetShipmentTable()

	if (not tab) then return end

	return self:Getcount() .. '-' .. util.CRC(tab.name .. tab.entity .. tab.model .. salt)
end

function ENT:RenderTexture()
	self.LastCount = self:Getcount()

	local tab = self:GetShipmentTable()

	if (not tab) then return end

	local rf = rp.cfg.RenderInfo[tab.model] or {}

	clmodel:SetAngles(rf and rf.Angle or Angle(30,90,0))
	clmodel:SetModel(tab.model)
	clmodel:SetModelScale(rf.Scale or 1, 0)

	local id = self:GetTextureID()

	local rt = GetRenderTargetEx(id..1, 1024, 522, RT_SIZE_NO_CHANGE, 8, MATERIAL_RT_DEPTH_SHARED, CREATERENDERTARGETFLAGS_AUTOMIPMAP, IMAGE_FORMAT_RGBA8888)
	local mat = CreateMaterial(id..1, 'UnlitGeneric', {
		['$basetexture']	= rt:GetName(),
		['$ignorez']		= 1,
		['$vertexcolor']	= 1,
		['$vertexalpha']	= 1,
		['$nolod']			= 1,
		['$transparent']	= 1
	})

	render.PushRenderTarget(rt)
		render.SetStencilEnable(true)
		render.SuppressEngineLighting(true)
		render.Clear(0, 0, 0, 255, true, true)
		render.PushFilterMag(3)
		render.PushFilterMin(3)
		render.ResetModelLighting(1, 1, 1)
		render.SetColorModulation(1, 1, 1)
		render.MaterialOverride(mat_white)
		render.SetBlend(.99)
		render.SetStencilReferenceValue(1)
		render.SetStencilFailOperation(STENCILOPERATION_KEEP)
		render.SetStencilZFailOperation(STENCILOPERATION_KEEP)
		render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
		render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)

			local x, y, w, h = (rf.X and (rf.X > 0)) and rf.X or 10, (rf.Y and (rf.Y > 0)) and rf.Y or 10, 1004, 492
			cam.Start3D(Angle(-96,0,0), Vector(0, 0, -15), 30, x, y, w, h)
					clmodel:DrawModel()
			cam.End3D()

		render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NOTEQUAL)
		render.ClearBuffersObeyStencil(255, 255, 255, 0)
		render.SetStencilEnable(false)
		render.PopFilterMag()
		render.PopFilterMin()
		render.MaterialOverride()
		render.SuppressEngineLighting(false)
	render.PopRenderTarget()

	local rt = GetRenderTargetEx(id..2, 1024, 522, RT_SIZE_NO_CHANGE, 8, MATERIAL_RT_DEPTH_SHARED, CREATERENDERTARGETFLAGS_AUTOMIPMAP, IMAGE_FORMAT_RGBA8888)
	render.PushRenderTarget(rt)
		render.Clear(50,50,50,0,true)
		cam.Start2D()
			surface.SetDrawColor(text_col:Unpack())
			local x, y, str, chars = 20, 512 - 90, '', 0
			for i = 1, 20 do
				local w = math.random(1,5)
				x = x + w + w
				surface.DrawRect(x, y, w, 50)
				if (chars < 9) then
						str = str .. ((math.random(0, 3) == 1) and string.Random(1):upper() or math.random(0,9))
					chars = chars + 1
				end
			end

			surface.SetMaterial(mat)
			surface.DrawTexturedRect((rf.X and (rf.X < 0)) and rf.X or 0,(rf.Y and (rf.Y < 0)) and rf.Y or 0,1024,512)

			draw.SimpleText(tab.name, 'rp.ShipmentTitle', 512, 10, text_col, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			draw.SimpleText(str, 'ui.18', x/2 - 20, y + 50, text_col, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			draw.SimpleText(self:Getcount() .. '/10', 'rp.ShipmentCount', 994, y - 10, text_col, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
		cam.End2D()

		local path = 'gmh/shipments/' .. id .. '.png'
		file.Write(path, render.Capture({
			format = 'png',
			quality = 100,
			x = 0,
			y = 0,
			h = 512,
			w = 1024
		}))
	render.PopRenderTarget()

	self.Texture = Material('../data/' .. path)
end

function ENT:DrawTexture(alpha)
	if self.Texture and self.LastCount and (self:Getcount() == self.LastCount) then
		surface.SetDrawColor(255, 255, 255, alpha)
		surface.SetMaterial(self.Texture)
		--surface.SetMaterial(matshipment)
		surface.DrawTexturedRect(-264, -256, 1024, 522)
	else
		local id = self:GetTextureID()

		if (not id) then return end

		local path = 'gmh/shipments/' .. id .. '.png'
		if file.Exists(path, 'DATA') then
			self.Texture = Material('../data/' .. path)
			self.LastCount = self:Getcount()
		else
			self:RenderTexture()
		end
	end
end

/*
-- lua refresh
for k, v in ipairs(ents.FindByClass'spawned_shipment') do
	v.Texture = nil
end
*/