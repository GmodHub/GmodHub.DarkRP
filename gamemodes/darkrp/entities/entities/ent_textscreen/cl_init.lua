local createdFonts = {}

local function getFont(name)
	if (not createdFonts[name]) then
		local fd = {
			font = name,
			size = 100,
			weight = 1500,
			shadow = true,
			antialias = true,
			symbol = (name == 'Webdings')
		}

		surface.CreateFont('textscreen.' .. name, fd)

		createdFonts[name] = true
	end

	return 'textscreen.' .. name
end

include('shared.lua')

function ENT:Initialize()
	self:SetMaterial('models/effects/vol_light001')
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	self:SetColor(255, 255, 255, 0)
end

function ENT:GetTextureID()
	return 'textscreen.' .. self:GetText() .. getFont(self:GetFont()) .. self:GetTextColor() .. (self:GetBackground() and '1' or '0') .. self:GetBackgroundColor()
end

function ENT:RenderTexture()
	self.Rendering = true

	local font = getFont(rp.cfg.TextSrceenFonts[self:GetFont() or 1])
	local lines = string.Wrap(font, self:GetText(), 1990)

	local color_text = Color()
	color_text:SetEncodedRGB(self:GetTextColor())
	local color_background = Color()
	color_background:SetEncodedRGB(self:GetBackgroundColor())
	local draw_background = self:GetBackground()

	self.TextureHeight = #lines * 100
	texture.Create(self:GetTextureID())
		:SetSize(2000, self.TextureHeight)
		:SetFormat('png')
		:Render(function(_, w, h)
			local x, y = 0, 0
			local maxW = 0

			if draw_background then
				for k, v in ipairs(lines) do
					surface.SetFont(font)
					local w, h = surface.GetTextSize(v)
					y = y + h

					if (w > maxW) then
						maxW = w
					end
				end

				maxW = maxW + 10

				draw.Box(1000 - (maxW * 0.5), 0, maxW, y, color_background)
			end

			x, y = 0, 0
			for k, v in ipairs(lines) do
				local w, h = draw.SimpleTextOutlined(v, font, 1000, y, color_text, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, ui.col.Black)
				y = y + h
			end

			if IsValid(self) then
				self.Rendering = false
			end
		end, function()
			if IsValid(self) then
				self.Rendering = false
			end
		end)
end

function ENT:Draw()
	local inView, dist = self:InDistance(562500)

	if (not inView) or self.Rendering then return end

	local textureCache = texture.Get(self:GetTextureID())

	if (not textureCache) then
		self:RenderTexture()
		return
	end

	if (not self.TextureHeight) then
		local font = getFont(rp.cfg.TextSrceenFonts[self:GetFont() or 1])
		local lines = string.Wrap(font, self:GetText(), 2000)

		self.TextureHeight = #lines * 100
	end

	local pos = self:GetPos()
	local ang = self:GetAngles()
	pos = pos + ang:Up()

	local x, y = -1000, -(self.TextureHeight * 0.5)
	local w, h = 2000, self.TextureHeight
	local scale = self:GetSize()/750

	surface.SetDrawColor(255, 255, 255, 255)
	surface.SetMaterial(textureCache)

	cam.Start3D2D(pos, ang, scale)
		surface.DrawTexturedRect(x, y, w, h)
	cam.End3D2D()

	ang:RotateAroundAxis(ang:Right(), 180)

	cam.Start3D2D(pos, ang, scale)
		surface.DrawTexturedRect(x, y, w, h)
	cam.End3D2D()
end

function ENT:DrawTranslucent()
	self:Draw()
end
