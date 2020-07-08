local SKIN 	= {
	PrintName 	= 'SUP',
	Author 	 	= 'aStonedPenguin'
}

local color_sup 			= ui.col.SUP
local color_gradient 		= ui.col.Gradient
local color_header 			= ui.col.Header
local color_background 		= ui.col.Background
local color_outline 		= ui.col.Outline
local color_hover 			= ui.col.Hover
local color_button 			= ui.col.Button
local color_button_hover	= ui.col.ButtonHover
local color_close 			= ui.col.Close
local color_close_bg 		= ui.col.CloseBackground
local color_close_hover 	= ui.col.CloseHovered

local color_offwhite 		= ui.col.OffWhite
local color_flat_black 		= ui.col.FlatBlack
local color_black 			= ui.col.Black
local color_white 			= ui.col.White
local color_red 			= ui.col.Red
local color_green 			= ui.col.Green

local mat_grad = Material 'gui/gradient_down'
local mat_cecked = Material 'sup/ui/check.png'
local mat_uncecked = Material 'sup/ui/x.png'

-- Frames
function SKIN:PaintFrame(self, w, h)
	if (self.Blur ~= false) then
		draw.Blur(self)
	end

	draw.OutlinedBox(0, 0, w, 30, color_header, color_outline)

	if (self.Accent) then
		draw.Box(1, 1, 3, 28, color_sup)
	end

	draw.OutlinedBox(0, 29, w, h - 29, color_background, color_outline)
end

function SKIN:PaintFrameLoading(self, w, h)
	if self.ShowIsLoadingAnim then
		draw.OutlinedBox(0, 27, w, h - 27, color_background, color_outline)

		local t = SysTime() * 5
		draw.NoTexture()
		surface.SetDrawColor(255, 255, 255)
		surface.DrawArc(w * 0.5, h * 0.5, 41, 46, t * 80, t * 80 + 180, 20)
	end
end

function SKIN:PaintFrameTitleAnim(self, w, h)
	local perc = self.TitleAnimDelta

	local pa = color_sup.a
	color_sup.a = perc * 255
	draw.Box(1, 1, 3, 28, color_sup)
	color_sup.a = pa

	if (perc == 1) then
		self.Accent = true
	end
end

function SKIN:PaintPanel(self, w, h)
	draw.OutlinedBox(0, 0, w, h, color_background, color_outline)
end

function SKIN:PaintShadow() end


-- Buttons
function SKIN:PaintButton(self, w, h)
	if (not self.m_bBackground) then return end

	if self:GetDisabled() then
		draw.OutlinedBox(0, 0, w, h, color_flat_black, color_outline)
	elseif (self.Active == true) then
		draw.OutlinedBox(0, 0, w, h, self.BackgroundColor or color_sup, color_outline)
	else
		draw.OutlinedBox(0, 0, w, h, (self.Hovered and (self.BackgroundColorHover or color_button_hover) or (self.BackgroundColor or color_button)), (self.OutlineColor or color_outline))
	end

	self:SetTextColor(((self.Hovered and (not self:GetDisabled()) and (not self.Active)) and (self.TextColorHover or color_black) or (self.TextColor or color_white)))

	if (not self.fontset) then
		self:SetFont('ui.20')
		self.fontset = true
	end
end

function SKIN:PaintAvatarImage(self, w, h)
	if self.AvatarMaterial then
		surface.SetDrawColor(255, 255, 255)
		surface.SetMaterial(self.AvatarMaterial)
		surface.DrawTexturedRect(0, 0, w, h)
	end

	if self.Hovered then
		draw.Box(0, 0, w, h, color_hover)
	end
end

function SKIN:PaintPlayerButton(self, w, h)
	if self.Active then
		draw.OutlinedBox(0, 0, w, h, color_flat_black, color_outline)
		return
	else
		draw.OutlinedBox(0, 0, w, h, self.PlayerColor or color_background, color_outline)
	end

	if self:IsHovered() then
		draw.Box(0, 0, w, h, color_hover)
	end
end


-- Close Button
function SKIN:PaintWindowCloseButton(panel, w, h)
	if (not panel.m_bBackground) then return end

	draw.Box(1, 1, w - 2, h - 2, panel.Hovered and color_close_hover or color_close_bg, color_outline)

	surface.SetDrawColor(color_close)

	local xX = math.floor((w / 2) - 5)
	local xY = math.floor((h / 2) - 5)

	render.PushFilterMin(3)
		render.PushFilterMag(3)
			surface.DrawLine(xX, xY, xX + 10, xY + 10)
			surface.DrawLine(xX, xY + 10, xX + 10, xY)
		render.PopFilterMag()
	render.PopFilterMin()
end


-- Scrollbar
function SKIN:PaintVScrollBar(self, w, h) end
function SKIN:PaintButtonUp(self, w, h) end
function SKIN:PaintButtonDown(self, w, h) end
function SKIN:PaintButtonLeft(self, w, h) end
function SKIN:PaintButtonRight(self, w, h) end

function SKIN:PaintScrollBarGrip(self, w, h)
	draw.Box(0, 0, w, h, color_sup)
end

function SKIN:PaintScrollPanel(self, w, h)
	draw.OutlinedBox(0, 0, w, h, color_background, color_outline)
end

function SKIN:PaintUIScrollBar(self, w, h)
	local x = self.scrollButton.x

	draw.Box(x, 0, w - x - x, h, color_outline)
	draw.Box(x, self.scrollButton.y, w - x - x, self.height, color_sup)
end


-- Slider
function SKIN:PaintUISlider(self, w, h)
	SKIN:PaintPanel(self, w, h)

	draw.Box(1, 1, w -2, h - 2, color_flat_black)

	if self.Vertical then
		draw.Box(1, self:GetValue() * h, w - 2, h - (self:GetValue() * h), color_sup)
	else
		draw.Box(41, 1, self:GetValue() * (w - 40) - self:GetValue() * 16, h - 2, color_sup)

		draw.SimpleText(math.ceil(self:GetValue() * 100) .. '%', 'ui.18', 20, h * 0.5 , color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end

function SKIN:PaintSliderButton(self, w, h)
	draw.OutlinedBox(0, 0, w, h, self:IsHovered() and color_button_hover or color_offwhite, color_outline)
end

-- Text Entry
function SKIN:PaintTextEntry(self, w, h)
	draw.OutlinedBox(0, 0, w, h, color_offwhite, color_outline)

	-- Hack on a hack, but this produces the most close appearance to what it will actually look if text was actually there
	if ( self.GetPlaceholderText && self.GetPlaceholderColor && self:GetPlaceholderText() && self:GetPlaceholderText():Trim() != "" && self:GetPlaceholderColor() && ( !self:GetText() || self:GetText() == "" ) ) then

		local oldText = self:GetText()

		local str = self:GetPlaceholderText()
		if ( str:StartWith( "#" ) ) then str = str:sub( 2 ) end
		str = language.GetPhrase( str )

		self:SetText( str )
		self:DrawTextEntryText( self:GetPlaceholderColor(), self:GetHighlightColor(), self:GetCursorColor() )
		self:SetText( oldText )

		return
	end

	self:DrawTextEntryText(color_black, color_sup, color_black)
end


-- List View
function SKIN:PaintUIListView(self, w, h)
	draw.OutlinedBox(0, 0, w, h, color_offwhite, color_outline)
end


function SKIN:PaintListView(self, w, h)
	--draw.OutlinedBox(0, 0, w, h, color_offwhite, color_outline)
end

function SKIN:PaintListViewLine(self, w, h) -- todo, just make a new control and never use this
	if self.m_bAlt then
		draw.Box(0, 0, w, h, (self:IsSelected() or self:IsHovered()) and color_sup or color_hover)
	else
		draw.Box(0, 0, w, h, (self:IsSelected() or self:IsHovered()) and color_sup or color_background)
	end

	for k, v in ipairs(self.Columns) do
		if (self:IsSelected() or self:IsHovered()) then
			v:SetTextColor(color_black)
			v:SetFont('ui.20')
		else
			v:SetTextColor(color_white)
			v:SetFont('ui.17')
		end
	end
end


-- Checkbox
function SKIN:PaintCheckBox(self, w, h)
	local checked = self:GetChecked() -- check urself before u rek urself

	draw.OutlinedBox(0, 0, w, h, self:IsHovered() and color_button_hover or color_offwhite, color_outline)

	draw.Box(checked and 1 or (w * 0.5), 1, (w * 0.5) - 1, h - 2, checked and color_sup or color_flat_black)
end


-- Tabs
local color_tab = color_sup:Copy()
color_tab.a = 75
function SKIN:PaintTabButton(self, w, h)
	self:SetTextColor(self.TextColor or color_white)

	if IsValid(self.m_Image) then
		draw.OutlinedBox(0, 0, h, h, color_header, color_outline)
		draw.OutlinedBox(h - 1, 0, (w - h) + 1, h, color_background, color_outline)


		if self.Hovered or self.Active then
		--	draw.Box(1, 1, 38, h - 2, color_tab)

			if self.Hovered then
				draw.Box(w - 6, 1, 6, h - 2, color_tab)
			elseif self.Active then
				draw.Box(w - 3, 1, 6, h - 2, color_tab)
			end
		end
	else
		draw.OutlinedBox(0, 0, w, h, color_background, color_outline)

		if self.Hovered then
			draw.Box(1, 1, 6, h - 2, color_tab)
			draw.Box(w - 6, 1, 6, h - 2, color_tab)
		elseif self.Active then
			draw.Box(1, 1, 3, h - 2, color_tab)
			draw.Box(w - 3, 1, 6, h - 2, color_tab)
		end
	end


end

function SKIN:PaintTabListPanel(self, w, h)
	draw.OutlinedBox(159, 0, w - 159, h, color_background, color_outline)
end


-- ComboBox
function SKIN:PaintComboBox(self, w, h)
	if IsValid(self.Menu) and (not self.Menu.SkinSet) then
		self.Menu:SetSkin('SUP')
		self.Menu.SkinSet = true
	end

	self:SetTextColor(((self.Hovered or self.Depressed or self:IsMenuOpen()) and color_black or color_white))

	draw.OutlinedBox(0, 0, w, h, ((self.Hovered or self.Depressed or self:IsMenuOpen()) and color_button_hover or color_background), color_outline)
end

function SKIN:PaintComboDownArrow(self, w, h)
	surface.SetDrawColor(color_sup)
	draw.NoTexture()
	surface.DrawPoly({
		{x = 0, y = w * .5},
		{x = h, y = 0},
		{x = h, y = w}
	})
end


-- DMenu
function SKIN:PaintMenu(self, w, h)
end

function SKIN:PaintMenuOption(self, w, h)
	if (not self.FontSet) then
		self:SetFont('ui.22')
		self.FontSet = true
	end

	self:SetTextColor(color_white)

	draw.OutlinedBox(0, 0, w, h + 1, color_black, color_outline)

	if self.m_bBackground and (self.Hovered or self.Highlight) then
		draw.OutlinedBox(0, 0, w, h + 1, color_button_hover, color_outline)
		self:SetTextColor(color_black)
	end
end


-- DPropertySheet
local propbackground = Color(200, 200, 200)
local prophovered = ui.col.ButtonHover
local propactive = Color(color_sup.r, color_sup.g, color_sup.b - 20)

function SKIN:PaintPropertySheet(self, w, h)
	local tab = self:GetActiveTab()

	if (IsValid(tab)) then
		if (!self.Dark) then
			draw.Box(0, tab:GetTall(), w, h - tab:GetTall(), propbackground)
		end
	end
end

function SKIN:PaintTab(self, w, h)
	local active = self:GetPropertySheet():GetActiveTab() == self

	if (active) then
		self:SetTextColor(propactive)
		if (!self:GetPropertySheet().Dark) then
			draw.Box(0, 0, w, h, propbackground)
		else
			draw.Box(0, 0, w, h, color_background)
			surface.SetDrawColor(color_outline)
			surface.DrawOutlinedRect(0, 0, w, h+1)
			//draw.Box(0, 0, w, h, color_background)
		end
	elseif (self:IsHovered()) then
		self:SetTextColor(prophovered)
	else
		self:SetTextColor(propbackground)
	end
end

derma.DefineSkin('SUP', 'SUP\'s derma skin', SKIN)