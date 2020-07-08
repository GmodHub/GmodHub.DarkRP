rp.orgs = rp.orgs or {}

local sdr = surface.DrawRect
local ssdc = surface.SetDrawColor
local sdor = surface.DrawOutlinedRect
local sdtr = surface.DrawTexturedRect
local sdl = surface.DrawLine
local mf = math.floor
local iimd = input.IsMouseDown

local colg = Color(150, 150, 150, 200)
local coldg = Color(100, 100, 100, 200)
local colTrans = Color(0, 0, 0, 0)
local colMeta = FindMetaTable("Color")

local padding = 0
local dim = 64
local outline = 512 / dim
local cursorSize = 1
local cursorShape = "Square"

local delMat = Material("sup/gui/orgs/trash.png", "smooth")
local renMat = Material("sup/gui/orgs/rename.png", "smooth")

local fr

function rp.orgs.SaveOrgBanner(name, data)
	if (!file.IsDir("sup", "DATA")) then
		file.CreateDir("sup")
	end

	if (!file.IsDir("sup/banners", "DATA")) then
		file.CreateDir("sup/banners")
	end

	local data = table.Copy(data)

	for i=0, dim-1 do
		for k=0, dim-1 do
			local v = data[i][k]
			if (v.trans) then
				data[i][k] = -1
			else
				PrintTable(v.col)
				data[i][k] = v.col:ToEncodedRGBA()
			end
		end
	end

	file.Write("sup/banners/" .. name .. ".txt", util.TableToJSON(data, true))
end

function rp.orgs.LoadOrgBanner(name)
	if (fr and fr:IsValid()) then
		local data = util.JSONToTable(file.Read('sup/banners/' .. name .. '.txt'))
		local modTime = file.Time('sup/banners/' .. name .. '.txt', 'DATA')

		local transVal = modTime > 1484503888 and -1 or 0

		for i=0, dim-1 do
			for k=0, dim-1 do
				local px = data[i][k]

				if (px == transVal) then
					data[i][k] = {trans = true}
				else
					local col = Color()
					col:SetEncodedRGBA(px)
					data[i][k] = {col=col}
				end
			end
		end

		return data
	end
end

local pnlFlag, perms, upgraded
function rp.orgs.OpenOrgBannerEditor(_pnlFlag, _perms, _upgraded)
	if (_pnlFlag.DrawLoading) then return end

	pnlFlag, perms, upgraded = _pnlFlag, _perms, _upgraded
	pnlFlag.DrawLoading = true

	net.Ping('rp.OrgBannerRaw')
end

net('rp.OrgBannerRaw', function(len)
	if (IsValid(pnlFlag)) then
		pnlFlag.DrawLoading = false
	end

	print("Packet was " .. len .. " bits")

	local hasFlag = net.ReadBool()
	local data
	if (hasFlag) then
		data = {}
		local dim = net.ReadUInt(7)
		for i=0, dim do
			data[i] = {}

			for k=0, dim do
				local px = net.ReadBool() and -1 or nil
				if (!px) then
					px = net.ReadUInt(24)
				end

				data[i][k] = px
			end
		end
	end

	rp.orgs.OpenOrgBannerEditorStage2(perms, upgraded, data)
end)

local all_patterns = {
	"^https?://.*%.jpg",
	"^https?://.*%.png",
}

local function isValidUrl(url)
	for _, pattern in ipairs(all_patterns) do
		if string.match(url, pattern) then
			return true
		end
	end
end

function rp.orgs.OpenBannerImporter()
	local importFr = ui.Create('ui_frame', function(self)
		self:SetSize(520, 120)
		self:SetTitle('Import Image')
		self:MakePopup()
		self:Center()
		self:RequestFocus()
	end)

	local set
	local text = ui.Create('DTextEntry', function(self, p)
		self:SetPos(5, 60)
		self:SetSize(p:GetWide() - 10, 25)
		self:SetPlaceholderText('URL...')
		self.OnEnter = function(s)
			set:DoClick()
		end
	end, importFr)

	ui.Create('DLabel', function(self, p)
		self:SetText('.jpg and .png images only! No porn, gore, ect or ban.')
		self:SetFont('ui.24')
		self:SetTextColor(ui.col.White)
		self:SizeToContents()
		self:SetPos((p:GetWide() - self:GetWide()) / 2, 32)
	end, importFr)

	set = ui.Create('DButton', function(self, p)
		self:SetText('Import')
		self:SetPos(5, 90)
		self:SetSize(p:GetWide() - 10, 25)
		function self:Think()
			if (not IsValid(fr)) and IsValid(p) then
				p:Close()
			end

			if isValidUrl(text:GetValue()) then
				self:SetDisabled(false)
			else
				self:SetDisabled(true)
			end
		end
		function self:DoClick()
			self:SetText('Importing...')
			self.Think = function() end
			self:SetDisabled(true)
			p:ShowCloseButton(false)

			local hasFailed = false
			timer.Simple(5, function()
				if IsValid(p) then
					p:ShowCloseButton(true)
					self:SetText('Import timed out...')
				end
			end)

			local url = string.Trim(text:GetValue())

			local logo = texture.Create(url)
				:SetSize(64, 64)
				:SetFormat('png')
				:Download(url, function(self)
					self:EnableCache(false)
					self:Render(function(self, w, h)
						surface.SetDrawColor(255, 255, 255)
						surface.SetMaterial(self:GetMaterial())
						surface.DrawTexturedRect(0, 0, w, h)
					end, function(texture, material)
						if hasFailed then return end

						local dat = {}
						for x = 0, dim-1 do
							dat[x] = {}
							for y = 0, dim-1 do
								local col = material:GetColor(x, y)
								local trans = col.a==0
								dat[x][y] = trans and {trans=trans} or {col=setmetatable(col, _R.Color)}
							end
						end

						if IsValid(fr) then
							fr.pnlPaintArea.pixels = dat
							fr.pnlPaintArea.invalidated = true
						end

						if IsValid(p) then
							p:Close()
						end
					end)
				end, function()
					if IsValid(p) then
						p:ShowCloseButton(true)
					end
					if IsValid(self) then
						self:SetText('Import failed...')
					end
				end)
		end
	end, importFr)
end

function rp.orgs.OpenOrgBannerEditorStage2(perms, upgraded, startData)
	if (fr and fr:IsValid()) then
		fr:Remove()
	end

	cursorSize = 1
	cursorShape = "Square"

	local parent = ui.Create('ui_frame')
	parent:Focus()

	parent.pnlPaintArea = ui.Create("Panel", parent)
	parent.clrCombo = ui.Create("DColorMixer", parent)
	parent.numCursorSize = ui.Create("DComboBox", parent)
	function parent.numCursorSize:OpenMenu(pControlOpener) -- We must have an ordered list
		if (pControlOpener) then
			if (pControlOpener == self.TextEntry) then
				return
			end
		end

		if (#self.Choices == 0) then return end

		if (IsValid(self.Menu)) then
			self.Menu:Remove()
			self.Menu = nil
		end

		self.Menu = ui.DermaMenu()

		for k, v in pairs(self.Choices) do
			self.Menu:AddOption(v, function() self:ChooseOption(v, k) end)
		end

		local x, y = self:LocalToScreen(0, self:GetTall())

		self.Menu:SetMinimumWidth(self:GetWide())
		self.Menu:Open(x, y, false, self)
	end

	parent.comboCursorShape = ui.Create("DComboBox", parent)
	parent.lblCursorSize = ui.Create("DLabel", parent)
	parent.lblCursorShape = ui.Create("DLabel", parent)
	parent.lblSubdivision = ui.Create("DLabel", parent)
	parent.btnSubdivisionUp = ui.Create("DButton", parent)
	parent.btnSubdivisionDown = ui.Create("DButton", parent)
	parent.pnlPreview = ui.Create("Panel", parent)
	parent.btnSubmit = ui.Create("DButton", parent)
	parent.btnLoad = ui.Create("DButton", parent)
	parent.btnSave = ui.Create("DButton", parent)
	parent.btnReset = ui.Create("DButton", parent)
	parent.btnImport = ui.Create("DButton", parent)

	parent.iSubdivide = 1

	local x, y = parent:GetDockPos()
	parent.pnlPaintArea:SetPos(x, y)
	parent.pnlPaintArea:SetSize(512 + padding * 2, 512 + padding * 2)

	parent:SetSize(768, y + parent.pnlPaintArea:GetTall() + 5)
	parent:SetTitle("Organization Flag")

	parent.clrCombo:SetPalette(false)
	parent.clrCombo:SetAlphaBar(false)
	parent.clrCombo:SetWangs(true)
	parent.clrCombo:SetPos(5 + parent.pnlPaintArea:GetWide() + 5, y)
	parent.clrCombo:SetSize(parent:GetWide() - parent.pnlPaintArea:GetWide() - 15, 160)
	parent.clrCombo:SetColor(Color(255, 255, 255))

	local halfrem = (parent:GetWide() - parent.pnlPaintArea:GetWide() - 20) / 2

	parent.lblCursorSize:SetText("Cursor Size")
	parent.lblCursorSize:SetPos(parent.clrCombo.x, parent.clrCombo:GetTall() + 35)
	parent.lblCursorSize:SizeToContents()

	parent.numCursorSize:SetPos(parent.clrCombo.x - 1, parent.lblCursorSize.y + parent.lblCursorSize:GetTall() + 3)
	parent.numCursorSize:SetWide(halfrem)
	parent.numCursorSize:SetValue("1 px")
	for i =1, 15 do
		parent.numCursorSize:AddChoice(i .. " px")
	end
	parent.numCursorSize.OnSelect = function(self, idx, val)
		cursorSize = idx
	end

	parent.lblCursorShape:SetText("Cursor Shape")
	parent.lblCursorShape:SetPos(parent.numCursorSize.x + parent.numCursorSize:GetWide() + 6, parent.lblCursorSize.y)
	parent.lblCursorShape:SizeToContents()

	parent.comboCursorShape:SetPos(parent.numCursorSize.x + parent.numCursorSize:GetWide() + 6, parent.lblCursorSize.y + parent.lblCursorSize:GetTall() + 3)
	parent.comboCursorShape:SetWide(halfrem)
	parent.comboCursorShape:SetValue("Square")
	parent.comboCursorShape:AddChoice("Square")
	parent.comboCursorShape:AddChoice("Circle")
	parent.comboCursorShape:AddChoice("Horizontal")
	parent.comboCursorShape:AddChoice("Vertical")
	parent.comboCursorShape:AddChoice("Diagonal Up")
	parent.comboCursorShape:AddChoice("Diagonal Down")
	parent.comboCursorShape:AddChoice("Outlined Square")
	parent.comboCursorShape:AddChoice("Eyedropper")
	parent.comboCursorShape.OnSelect = function(self, idx, val)
		cursorShape = val
	end

	parent.lblSubdivision:SetText("Guidelines")
	parent.lblSubdivision:SetPos(parent.clrCombo.x, parent.comboCursorShape.y + parent.comboCursorShape:GetTall() + 2)
	parent.lblSubdivision:SizeToContents()

	parent.btnSubdivisionDown:SetPos(parent.lblSubdivision.x, parent.lblSubdivision.y + parent.lblSubdivision:GetTall() + 3)
	parent.btnSubdivisionDown:SetText("-")
	parent.btnSubdivisionDown:SetSize(halfrem, 15)
	parent.btnSubdivisionDown.DoClick = function(self)
		self:GetParent().iSubdivide = math.Clamp(self:GetParent().iSubdivide - 1, 1, 10)
	end

	parent.btnSubdivisionUp:SetPos(parent.lblSubdivision.x + halfrem + 5, parent.lblSubdivision.y + parent.lblSubdivision:GetTall() + 3)
	parent.btnSubdivisionUp:SetText("+")
	parent.btnSubdivisionUp:SetSize(halfrem, 15)
	parent.btnSubdivisionUp.DoClick = function(self)
		self:GetParent().iSubdivide = math.Clamp(self:GetParent().iSubdivide + 1, 1, 10)
	end

	parent.pnlPreview:SetPos(parent.clrCombo.x, parent.btnSubdivisionDown.y + parent.btnSubdivisionDown:GetTall() + 5)
	parent.pnlPreview:SetSize(94, 94)

	parent.btnSubmit:SetFont("ui.22")
	parent.btnSubmit:SetText("Submit")
	parent.btnSubmit:SetPos(parent.clrCombo.x, parent:GetTall() - 50)
	parent.btnSubmit:SetSize(halfrem * 2 + 5, 45)
	if (!perms.Owner and (!upgraded or !perms.Banner)) then
		parent.btnSubmit:SetDisabled(true)
	end

	local str

	if (!upgraded) then
		str = "This Organization is not upgraded, and cannot have a flag!"
	elseif (!perms.Banner) then
		str = "Your rank cannot edit this Organization's flag!"
	else
		str = "Your Organization's flag can be used in picture frames as well as our website!"
	end

	local lines = string.Wrap('ui.22', str, parent.btnSubmit:GetWide())
	local msgy = parent.pnlPreview.y + parent.pnlPreview:GetTall() + ((parent.btnSubmit.x - (parent.pnlPreview.y + parent.pnlPreview:GetTall())) - (#lines * 22)) / 2
	for k, v in ipairs(lines) do
		local lbl = ui.Create('DLabel')
		lbl:SetParent(parent)
		lbl:SetFont('ui.22')
		lbl:SetText(v)
		lbl:SizeToContents()
		lbl:SetPos(parent.btnSubmit.x + (parent.btnSubmit:GetWide() - lbl:GetWide()) / 2, msgy)
		msgy = msgy + 22
	end

	parent.btnLoad:SetText("Load..")
	parent.btnLoad:SetFont("ui.22")
	parent.btnLoad:SetPos(parent.pnlPreview.x + parent.pnlPreview:GetWide() + 5, parent.pnlPreview.y)
	parent.btnLoad:SetSize((halfrem * 2) - parent.pnlPreview:GetWide(), math.floor((parent.pnlPreview:GetTall() - 10) / 3))
	parent.btnLoad.DoClick = function(self)
		local designs, _ = file.Find("sup/banners/*.txt", "DATA")
		if (#designs == 0) then
			local menu = ui.DermaMenu()
			menu:AddOption("No designs saved yet", function() end)
			menu:Open()
			menu:SetPos(parent.x + parent:GetWide(), parent.y + parent.btnLoad.y)
			return
		end

		print("Open new loading interface")

		local previewRendered = false
		local previewRT = GetRenderTarget("SUPLoadBannerPreview", 512, 512, true)

		local previewMat = CreateMaterial("SUPLoadBannerPreview","UnlitGeneric",{
			["$ignorez"] = 1,
			["$vertexcolor"] = 1,
			["$vertexalpha"] = 1,
			["$nolod"] = 1,
			["$basetexture"] = previewRT:GetName()
		})

		parent.over_loadPreview = ui.Create('Panel', function(pnl)
			pnl:SetPos(parent.pnlPaintArea:GetPos())
			pnl:SetSize(parent.pnlPaintArea:GetSize())
			pnl.Paint = function(self, w, h)
				if (!previewRendered) then
					return false
				end

				if (IsValid(self.current)) then
					local mx, my = self.current:CursorPos()
					if not (mx >= 0 and my >= 0 and mx <= self.current:GetWide() and my <= self.current:GetTall()) then
						return false
					end
				end

				surface.SetMaterial(previewMat)
				ssdc(255, 255, 255, 255)
				surface.DrawTexturedRect(1, 1, w-2, h-2)
			end
		end, parent)

		parent.over_loadList = ui.Create('Panel', function(pnl)
			local _, y = parent:GetDockPos()
			pnl:SetPos(parent.over_loadPreview:GetWide() + 9, y)
			pnl:SetSize(parent:GetWide() - pnl.x - 5 , parent:GetTall() - y - 55)
			pnl.Paint = function(s, w, h)
				ssdc(0, 0, 0, 255)
				sdr(0, 0, w, h)

				ssdc(ui.col.Outline)
				sdor(0, 0, w, h)
			end

			pnl.scroll = ui.Create("ui_scrollpanel", function(s)
				s:SetPos(0, 0)
				s:SetSize(pnl:GetWide(), pnl:GetTall())
			end, pnl)

			for k, v in ipairs(designs) do
				local item = ui.Create("DButton")
				item:SetText("")

				item:SetTall(40)

				local name = string.sub(v, 1, -5)
				local lblName = ui.Create("DLabel", item)
				lblName:SetText(name)
				lblName:SizeToContents()
				lblName:SetPos(5, 20 - (lblName:GetTall() * 0.5))

				local btnDel = ui.Create("DButton", item)
				btnDel:SetText("")
				btnDel:SetSize(40, 40)
				btnDel:Dock(RIGHT)
				btnDel.PaintOver = function(s)
					surface.SetMaterial(delMat)
					if (s.Clicked) then
						ssdc(255, 50, 50)
					else
						ssdc(255, 255, 255)
					end
					sdtr(8, 8, 24, 24)
				end
				btnDel.DoClick = function(s)
					if (s.Clicked) then
						file.Delete("sup/banners/" .. v)
						item:Remove()
						pnl.scroll:PerformLayout()
					else
						s.Clicked = true
						timer.Simple(2, function() if (IsValid(s)) then s.Clicked = false end end)
					end
				end

				local btnRen = ui.Create("DButton", item)
				btnRen:SetText("")
				btnRen:SetSize(40, 40)
				btnRen:Dock(RIGHT)
				btnRen.PaintOver = function(s)
					surface.SetMaterial(renMat)
					ssdc(255, 255, 255)
					sdtr(8, 8, 24, 24)
				end
				btnRen.DoClick = function(s, str)
					local str = str or "What would you like to name this design?"
					ui.StringRequest("Rename Design", str, name, function(val)
						if (name:lower() == val:lower()) then return end
						for k, v in ipairs(designs) do
							if (v:lower() == val:lower() .. ".txt") then
								s:DoClick("You already have a design with that name. Please enter another.")
								return
							end
						end
						file.Rename("sup/banners/" .. v, "sup/banners/" .. val .. ".txt")
						name = val
						lblName:SetText(val)
						lblName:SizeToContents()
					end)
				end

				pnl.scroll:AddItem(item)

				item.Think = function(s)
					local mx, my = s:CursorPos()
					if (mx >= 0 and my >= 0 and mx <= s:GetWide() and my <= s:GetTall()) then
						if (parent.over_loadPreview.current != s) then
							parent.over_loadPreview.current = s
							item.pixels = rp.orgs.LoadOrgBanner(name)
							parent.pnlPaintArea:RenderBanner(parent.over_loadPreview:GetWide(), parent.over_loadPreview:GetTall(), previewRT, item.pixels)
							previewRendered = true
						end
					end
				end

				item.DoClick = function(s)
					if (!item.pixels) then return end

					parent.pnlPaintArea.pixels = item.pixels
					parent.pnlPaintArea.invalidated = true

					parent.over_btnCancel:DoClick()
				end
			end

		end, parent)

		parent.over_btnCancel = ui.Create("DButton", parent)
		parent.over_btnCancel:SetPos(parent.btnSubmit.x, parent.btnSubmit.y)
		parent.over_btnCancel:SetSize(parent.btnSubmit:GetSize())
		parent.over_btnCancel:SetText("Cancel")
		parent.over_btnCancel.DoClick = function()
			parent.over_loadList:Remove()
			parent.over_loadPreview:Remove()
			parent.over_btnCancel:Remove()
			parent.btnSubmit:SetVisible(true)
		end

		parent.btnSubmit:SetVisible(false)
	end

	parent.btnSave:SetText("Save..")
	parent.btnSave:SetFont("ui.22")
	parent.btnSave:SetPos(parent.pnlPreview.x + parent.pnlPreview:GetWide() + 5, parent.btnLoad.y + parent.btnLoad:GetTall() + 5)
	parent.btnSave:SetSize(parent.btnLoad:GetWide(), parent.btnLoad:GetTall())
	parent.btnSave.DoClick = function(self)
		local designs, dirs = file.Find("sup/banners/*.txt", "DATA")

		local menu = ui.DermaMenu()

		menu:AddOption("New..", function()
			local function askForName(taken)
				ui.StringRequest("New Design", ((taken and "That save already exists.\n\n") or "") .. "Please enter a name for your design.", "Untitled 1", function(resp)
					if (file.Exists("sup/banners/" .. resp .. ".txt", "DATA")) then
						askForName(true)
						return
					end

					rp.orgs.SaveOrgBanner(resp, fr.pnlPaintArea.pixels)
				end)
			end

			askForName()
		end)

		for k, v in pairs(designs) do
			menu:AddOption(string.sub(v, 1, -5), function()
				rp.orgs.SaveOrgBanner(string.sub(v, 1, -5), fr.pnlPaintArea.pixels)
			end)
		end

		menu:Open()
		menu:SetPos(parent.x + parent:GetWide(), parent.y + parent.btnSave.y)
	end

	parent.btnReset:SetText("Reset Canvas")
	parent.btnReset:SetFont("ui.22")
	parent.btnReset:SetPos(parent.pnlPreview.x + parent.pnlPreview:GetWide() + 5, parent.btnSave.y + parent.btnSave:GetTall() + 5)
	parent.btnReset:SetSize(parent.btnLoad:GetWide(), parent.btnLoad:GetTall())
	parent.btnReset.DoClick = function(self)
		self:GetParent().pnlPaintArea:Reset(true)
	end

	parent.btnImport:SetText("Import From URL")
	parent.btnImport:SetFont("ui.22")
	parent.btnImport:SetPos(parent.pnlPreview.x + parent.pnlPreview:GetWide() + 5, parent.pnlPreview.y + parent.pnlPreview:GetTall() + 5)
	parent.btnImport:SetSize((halfrem * 2) - parent.pnlPreview:GetWide(), math.floor((parent.pnlPreview:GetTall() - 10) / 3))
	parent.btnImport.DoClick = rp.orgs.OpenBannerImporter

	parent.pnlPaintArea.cursors = {}

	parent.pnlPaintArea.Reset = function(self, force)
		if (force or !startData) then
			self.pixels = {}
		else
			self.pixels = table.Copy(startData)
			for k = 0, dim-1 do
				for i = 0, dim-1 do
					if (self.pixels[k][i] == -1) then -- trans
						self.pixels[k][i] = {trans = true}
					else
						local col = Color()
						col:SetEncodedRGBA(self.pixels[k][i])
						col.a = 255
						self.pixels[k][i] = {col = col}
					end
				end
			end
		end

		if (!self.pixels[1]) then
			for x=1, dim do
				self.pixels[x - 1] = {}

				for y=1, dim do
					self.pixels[x - 1][y - 1] = {
						col = colg,
						trans = true
					}
				end
			end
		end

		self:RenderBanner(w, h)
	end

	parent.SendImage = function(self)
		self.btnSubmit:SetMouseInputEnabled(false)
		self.btnSubmit:SetText("Sending..")

		net("rp.OrgBannerReceived", function(len)
			if (self:IsValid() and self.btnSubmit:IsValid()) then
				self.btnSubmit:SetMouseInputEnabled(true)
				self.btnSubmit:SetText("Submit")
			end
		end)

		net.Start('rp.SetOrgBanner')
			net.WriteUInt(dim-1, 7)

			for i=0, dim-1 do
				for k=0, dim-1 do
					local px = self.pnlPaintArea.pixels[i][k]

					net.WriteBool(px.trans)
					if (!px.trans) then
						net.WriteUInt(setmetatable(px.col, _R.Color):ToEncodedRGBA(), 24)
					end
				end
			end
		net.SendToServer()
	end

	parent.btnSubmit.DoClick = function(self)
		if (!upgraded) then
			if (perms.Owner) then
				ui.BoolRequest('Premium Org', 'You need the Premium Org upgrade to make org banners. Would you like to buy it?', function(ans)
					if (ans == true) then
						cmd.Run('upgrades')
					end
				end)
			end

			return
		end
		self:GetParent():SendImage()
		cvar.SetValue('OrgBanner', self:GetParent().pnlPaintArea.pixels)
	end

	local drawRT = GetRenderTarget("SUPBannerPreview2", 512, 512, true)

	local drawMaterial = CreateMaterial("SUPBannerPreview2","UnlitGeneric",{
		["$ignorez"] = 1,
		["$vertexcolor"] = 1,
		["$vertexalpha"] = 1,
		["$nolod"] = 1,
		["$basetexture"] = drawRT:GetName()
	})

	parent.pnlPaintArea.Paint = function(self, w, h)
		if (self.invalidated) then
			self:RenderBanner(w, h)
			self.invalidated = false
		end

		surface.SetMaterial(drawMaterial)
		ssdc(255, 255, 255, 255)
		surface.DrawTexturedRect(1, 1, w-2, h-2)
	end

	parent.pnlPaintArea.RenderBanner = function(self, w, h, rt, pixels)
		rt = rt or drawRT
		pixels = pixels or self.pixels
		local oldRT = render.GetRenderTarget()
		local scrw = ScrW()
		local scrh = ScrH()

		render.SetRenderTarget(rt)
			render.Clear(0, 0, 0, 0)
			render.ClearDepth()

			render.SetViewPort(0, 0, 512, 512)
				cam.Start2D()
					for x, v in pairs(pixels) do
						for y, data in pairs(v) do
							local boxX = (x * outline)
							local boxY = (y * outline)
							if (!data.trans) then
								ssdc(data.col)
								sdr(boxX, boxY, outline, outline)
							else
								local col1 = colg
								local col2 = coldg

								local half = outline / 2

								ssdc(col1)
								sdr(boxX, boxY, half, half)
								sdr(boxX + half, boxY + half, half, half)

								ssdc(col2)
								sdr(boxX + half, boxY, half, half)
								sdr(boxX, boxY + half, half, half)
							end
						end
					end
				cam.End2D()
			render.SetViewPort(0, 0, scrw, scrh)
		render.SetRenderTarget(oldRT)
	end

	parent.pnlPaintArea.cursors["Square"] = function(self, x, y)
		local activePx = {}

		local toMinus = mf(cursorSize / 2)
		local altMinus = 0

		if (toMinus < 1) then
			toMinus = 0
		end

		if (cursorSize == 2) then
			toMinus = 0
			altMinus = outline / 2
		end

		local boxX = mf((x - padding - altMinus) / outline) - toMinus
		local boxY = mf((y - padding - altMinus) / outline) - toMinus

		for x=0, cursorSize - 1 do
			if (self.pixels[boxX + x] and self.pixels[boxX + x][boxY]) then
				table.insert(activePx, {boxX + x, boxY})
			end

			for y=0, cursorSize - 1 do
				if (self.pixels[boxX + x] and self.pixels[boxX + x][boxY + y]) then
					table.insert(activePx, {boxX + x, boxY + y})
				end
			end
		end

		return activePx
	end

	parent.pnlPaintArea.cursors["Circle"] = function(self, x, y)
		local activePx = {}

		local boxX = mf((x - padding) / outline)
		local boxY = mf((y - padding) / outline)

		local startX = boxX - mf(cursorSize / 2)
		local startY = boxY - mf(cursorSize / 2)

		for x=startX, (startX + cursorSize) do
			for y=startY, (startY + cursorSize) do
				if (self.pixels[x] and self.pixels[x][y]) then
					if ((x - boxX)^2 + (y - boxY)^2 <= (cursorSize / 2)^2) then
						table.insert(activePx, {x, y})
					end
				end
			end
		end

		return activePx
	end

	parent.pnlPaintArea.cursors["Horizontal"] = function(self, x, y)
		local activePx = {}

		local toMinus = mf(cursorSize / 2)
		local altMinus = 0

		if (toMinus < 1) then
			toMinus = 0
		end

		if (cursorSize == 2) then
			toMinus = 0
			altMinus = outline / 2
		end

		local boxX = mf((x - padding - altMinus) / outline) - toMinus
		local boxY = mf((y - padding - altMinus) / outline)

		for x=0, cursorSize - 1 do
			if (self.pixels[boxX + x] and self.pixels[boxX + x][boxY]) then
				table.insert(activePx, {boxX + x, boxY})
			end
		end

		return activePx
	end

	parent.pnlPaintArea.cursors["Vertical"] = function(self, x, y)
		local activePx = {}

		local toMinus = mf(cursorSize / 2)
		local altMinus = 0

		if (toMinus < 1) then
			toMinus = 0
		end

		if (cursorSize == 2) then
			toMinus = 0
			altMinus = outline / 2
		end

		local boxX = mf((x - padding - altMinus) / outline)
		local boxY = mf((y - padding - altMinus) / outline) - toMinus

		for y=0, cursorSize - 1 do
			if (self.pixels[boxX] and self.pixels[boxX][boxY + y]) then
				table.insert(activePx, {boxX, boxY + y})
			end
		end

		return activePx
	end

	parent.pnlPaintArea.cursors["Diagonal Down"] = function(self, x, y)
		local activePx = {}

		local toMinus = mf(cursorSize / 2)
		local altMinus = 0

		if (toMinus < 1) then
			toMinus = 0
		end

		if (cursorSize == 2) then
			toMinus = 0
			altMinus = outline / 2
		end

		local boxX = mf((x - padding - altMinus) / outline) - toMinus
		local boxY = mf((y - padding - altMinus) / outline) - toMinus

		for i=0, cursorSize - 1 do
			if (self.pixels[boxX + i] and self.pixels[boxX + i][boxY + i]) then
				table.insert(activePx, {boxX + i, boxY + i})
			end
		end

		return activePx
	end

	parent.pnlPaintArea.cursors["Diagonal Up"] = function(self, x, y)
		local activePx = {}

		local toMinus = mf(cursorSize / 2)
		local altMinus = 0

		if (toMinus < 1) then
			toMinus = 0
		end

		if (cursorSize == 2) then
			toMinus = 0
			altMinus = outline / 2
		end

		local boxX = mf((x - padding - altMinus) / outline) - toMinus
		local boxY = mf((y - padding - altMinus) / outline) + toMinus

		for i=0, cursorSize - 1 do
			if (self.pixels[boxX + i] and self.pixels[boxX + i][boxY - i]) then
				table.insert(activePx, {boxX + i, boxY - i})
			end
		end

		return activePx
	end

	parent.pnlPaintArea.cursors["Outlined Square"] = function(self, x, y)
		local activePx = {}

		local toMinus = mf(cursorSize / 2)
		local altMinus = 0

		if (toMinus < 1) then
			toMinus = 0
		end

		if (cursorSize == 2) then
			toMinus = 0
			altMinus = outline / 2
		end

		local boxX = mf((x - padding - altMinus) / outline) - toMinus
		local boxY = mf((y - padding - altMinus) / outline) - toMinus

		for x=0, cursorSize - 1 do
			if (self.pixels[boxX + x] and self.pixels[boxX + x][boxY]) then
				table.insert(activePx, {boxX + x, boxY})
			end

			if (self.pixels[boxX + x] and self.pixels[boxX + x][boxY + (cursorSize - 1)]) then
				table.insert(activePx, {boxX + x, boxY + (cursorSize - 1)})
			end
		end

		for y=0, cursorSize - 1 do
			if (self.pixels[boxX] and self.pixels[boxX][boxY + y]) then
				table.insert(activePx, {boxX, boxY + y})
			end

			if (self.pixels[boxX + (cursorSize - 1)] and self.pixels[boxX + (cursorSize - 1)][boxY + y]) then
				table.insert(activePx, {boxX + (cursorSize - 1), boxY + y})
			end
		end

		return activePx
	end

	parent.pnlPaintArea.cursors["Eyedropper"] = function(self, x, y)
		local activePx = {}
		local cursorSize = 1

		local boxX = mf((x - padding) / outline)
		local boxY = mf((y - padding) / outline)

		do
			if (self.pixels[boxX] and self.pixels[boxX][boxY]) then
				table.insert(activePx, {boxX, boxY})
			end

			do
				if (self.pixels[boxX] and self.pixels[boxX][boxY]) then
					table.insert(activePx, {boxX, boxY})
				end
			end
		end

		return activePx
	end

	parent.pnlPaintArea.GetActivePixels = function(self)
		local x, y = self:CursorPos()

		if ((x < padding or x >= 512 + padding) or (y < padding or y >= 512 + padding)) then
			return {}
		end

		return self.cursors[cursorShape](self, x, y)
	end

	parent.pnlPaintArea.PaintOver = function(self, w, h)
		-- Draw active pixels
		for k, v in pairs(self:GetActivePixels()) do
			local x = v[1] * outline + padding
			local y = v[2] * outline + padding

			--if (!self.pixels[x][y]) then break end
			local px = self.pixels[v[1]][v[2]]
			if (px.trans) then
				ssdc(255, 50, 50)
			else
				local c = px.col
				local y = (299 * c.r + 587 * c.g + 1144 * c.b) / 1000
				if (y >= 128) then
					ssdc(0, 0, 0)
				else
					ssdc(255, 255, 255)
				end
			end

			sdor(x, y, outline, outline)
		end

		-- Draw picture outline
		ssdc(ui.col.Outline)
		sdor(0, 0, w, h)

		-- Alignment
		local subdivide = self:GetParent().iSubdivide
		if (subdivide > 1) then
			ssdc(50, 50, 50)

			for i=1, subdivide - 1 do
				sdl(i * (w / subdivide), 0, i * (w / subdivide), h)
				sdl(0, i * (h / subdivide), w, i * (h / subdivide))
			end
		end
	end

	parent.pnlPaintArea.OnMousePressed = function(self, mb)
		if (mb == MOUSE_LEFT) then
			self.isClicked = true
		end

		if (mb == MOUSE_RIGHT) then
			self.isRightClicked = true
		end
	end

	parent.pnlPaintArea.OnMouseReleased = function(self, mb)
		if (mb == MOUSE_LEFT) then
			self.isClicked = false
		end

		if (mb == MOUSE_RIGHT) then
			self.isRightClicked = false
		end
	end

	parent.pnlPaintArea.OnCursorEntered = function(self)
		if (!system.IsOSX()) then
			self:SetCursor("blank")
		end
	end

	parent.pnlPaintArea.OnCursorExited = function(self)
		if (!system.IsOSX()) then
			self:SetCursor("arrow")
		end
	end

	parent.pnlPaintArea.Think = function(self)
		if (!self.isClicked and !self.isRightClicked) then
			return
		end

		local x, y = self:CursorPos()

		if ((x < padding or x >= 512 + padding) or (y < padding or y >= 512 + padding)) then
			if (self.isClicked and !iimd(MOUSE_LEFT)) then
				self.isClicked = false
			end

			if (self.isRightClicked and !iimd(MOUSE_RIGHT)) then
				self.isRightClicked = false
			end
		end

		local shouldInvalidate = false

		local newCol = self:GetParent().clrCombo:GetColor()

		-- Modify active pixels
		if (cursorShape == "Eyedropper") then
			local selPx = self:GetActivePixels()[1]
			local px = self.pixels[selPx[1]][selPx[2]]

			if (px.trans) then return end

			self:GetParent().clrCombo:SetColor(px.col)
		else
			for k, v in pairs(self:GetActivePixels()) do
				local px = self.pixels[v[1]][v[2]]

				if (self.isClicked) then
					if (!px.col or px.col.r != newCol.r or px.col.g != newCol.g or px.col.b != newCol.b or px.trans) then
						px.col = setmetatable(table.Copy(newCol), colMeta)
						px.trans = false
						shouldInvalidate = true
					end
				elseif (self.isRightClicked) then
					if (!px.trans) then
						px.trans = true
						shouldInvalidate = true
					end
				end
			end
		end

		if (shouldInvalidate) then
			self.invalidated = true
		end
	end

	parent.pnlPreview.Paint = function(self, w, h)
		surface.SetMaterial(drawMaterial)
		ssdc(255, 255, 255)
		surface.DrawTexturedRect(0, 0, w, h)
	end
	parent:Center()
	parent:SetVisible(true)
	parent:MakePopup()

	parent.pnlPaintArea:Reset()

	fr = parent
end
