include 'shared.lua'

cvar.Register 'enable_pictureframes'
	:SetDefault(true, true)
	:AddMetadata('State', 'RPMenu')
	:AddMetadata('Menu', 'Включить картины')

function ENT:RenderTexture()
	self.Rendering = true

	if (string.sub(self:GetURL(), 1, 4) == 'ORG:') then
		self.IsOrg = true
		self.OrgName = string.sub(self:GetURL(), 5)
		self.LastURL = self:GetURL()
	else
		self.IsOrg = false

		texture.Create(self:GetURL())
			:SetSize(1014, 1014)
			:SetFormat(self:GetURL():sub(-3) == 'jpg' and 'jpg' or 'png')
			:EnableCache(false)
			:Download(self:GetURL(), function()
				if IsValid(self) then
					self.Rendering 	= false
					self.LastURL 	= self:GetURL()
				end
			end, function()
				if IsValid(self) then
					self.Rendering = false
				end
			end)
	end
end

function ENT:GetTexture()
	if (not self.IsOrg) then
		return texture.Get(self:GetURL())
	else
		local mat = rp.orgs.GetBanner(self.OrgName)

		if (mat and self.Rendering) then
			self.Rendering = false
		end

		return mat
	end
end

local vec1, vec2 = Vector(-10, -20, -20), Vector(0, 20, 20)
function ENT:Think()
	self.IsPeepShow = false
	for k, v in ipairs(ents.FindAlongRay(self:GetPos() + self:GetRight(), self:GetPos(), vec1, vec2)) do
		if v:IsProp() then
			self.IsPeepShow = true
			break
		end
	end

	self:NextThink(CurTime() + 0.5)

	return true
end

function ENT:Draw()
	self:DrawModel()

	/*

	local tr = util.TraceHull {
		mask = MASK_ALL,
		start = LocalPlayer():EyePos(),
		endpos = self:GetPos(),
		mins = Vector(-3, -20, -20),
		maxs = Vector(0, 20, 20),
		filter = function(ent)
			--print(ent, ent:GetPos():DistToSqr(self:GetPos()))

			return ent:IsProp() and (ent:GetPos():DistToSqr(self:GetPos()) < 1000)
		end
	}*/

--PrintTable(ents.FindAlongRay( self:GetPos() + self:GetRight(), self:GetPos(), Vector(-3, -20, -20), Vector(0, 20, 20)) )
	--PrintTable(tr)

	if self.IsPeepShow then return end

--	print(util.PointContents( tr.HitPos ), bit.band( util.PointContents( tr.HitPos ), CONTENTS_EMPTY ) )

	if (cvar.GetValue('enable_pictureframes') == false) or (not self:InSight()) then return end

	if ((not self:GetTexture()) or (self:GetURL() ~= self.LastURL)) and (not self.Rendering) then
		self:RenderTexture()
	end

	local ang = self:GetAngles()
	ang:RotateAroundAxis(ang:Up(), 180)
	ang:RotateAroundAxis(ang:Forward(), 90)

	local scale = self:GetModelScale()
	local s = 1024 * scale
	local off = -(s * 0.5)

	cam.Start3D2D(self:GetPos() + (self:GetRight() * -(0.5 * scale)), ang, 0.022)
		surface.SetDrawColor(25,25,25,255)
		surface.DrawRect(off, off, s, s)

		if self.Rendering or self:GetIsLoading() then
			local t = SysTime() * 5
			draw.NoTexture()
			surface.SetDrawColor(255, 255, 255, 255)
			surface.DrawArc(off + (s * 0.5), off + (s * 0.5), 111, 116, t * 180, t * 180 + 180, 10)
		elseif self:GetTexture() then
			surface.SetDrawColor(255,255,255,255)
			surface.SetMaterial(self:GetTexture())
			surface.DrawTexturedRect(off, off, s, s)
		end

	cam.End3D2D()
end


local all_patterns = {
	"^https?://.*%.jpg",
	"^https?://.*%.png",
}

local function IsValidURL(url)
	for _, pattern in ipairs(all_patterns) do
		if string.match(url, pattern) then
			return true
		end
	end
end

local sizes = {
	'Small - 1024x1024',
	'Medium - 2048x2048',
	'Large - 3072x3072'
}

local fr
net.Receive('rp.OpenImageWindow', function()
	local set, text

	if IsValid(fr) then fr:Close() end

	fr = ui.Create('ui_frame', function(self)
		self:SetSize(700, 120)
		self:SetTitle('Изменить Картинку')
		self:MakePopup()
		self:Center()
		function self:Think()
			if IsValid(set) and IsValid(text) and IsValidURL(text:GetValue()) then
				set:SetDisabled(false)
			else
				set:SetDisabled(true)
			end
		end
	end)

	text = ui.Create('DTextEntry', function(self, p)
		self:SetPos(5, 60)
		self:SetPlaceholderText('URL...')
		self:SetSize(p:GetWide() - 10, 25)
		self.OnEnter = function(s)
			set:DoClick()
		end
	end, fr)

	ui.Create('DLabel', function(self, p)
		self:SetText('Только .jpg и .png картинки! Никакого порно, насилия, и прочего или бан.')
		self:SetFont('ui.24')
		self:SetTextColor(ui.col.White)
		self:SizeToContents()
		self:SetPos((p:GetWide() - self:GetWide()) / 2, 32)
	end, fr)

	local bwidth = (fr:GetWide() * 0.25) - 6
	set = ui.Create('DButton', function(self, p)
		self:SetText('Сохранить')
		self:SetPos(5, 90)
		self:SetSize(bwidth, 25)
		function self:DoClick()
			p:Close()
			cmd.Run('setimage', text:GetValue())
		end
	end, fr)

	ui.Create('DButton', function(self, p)
		self:SetText('Изменить Размер')
		self:SetPos(10 + bwidth, 90)
		self:SetSize(bwidth, 25)
		function self:DoClick()
			local m = ui.DermaMenu()
			for k, v in pairs(sizes) do
				m:AddOption(v, function()
					cmd.Run('setimagescale', k)
				end)
			end
			m:Open()
		end
	end, fr)

	ui.Create('DButton', function(self, p)
		self:SetText('Аватар Steam')
		self:SetPos(15 + (bwidth * 2), 90)
		self:SetSize(bwidth, 25)
		function self:DoClick()
			p:Close()
			cmd.Run('setimageavatar')
		end
	end, fr)

	ui.Create('DButton', function(self, p)
		self:SetText('Лого Банды')
		self:SetPos(20 + (bwidth * 3), 90)
		self:SetSize(bwidth, 25)
		function self:DoClick()
			p:Close()
			cmd.Run('setimageorg')
		end
		if (not LocalPlayer():GetOrg()) then
			self:SetDisabled(true)
		end
	end, fr)
end)
