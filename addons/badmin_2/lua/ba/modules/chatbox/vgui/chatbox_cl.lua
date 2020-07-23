local chatfont = 'ba.chat.Font'

surface.CreateFont(chatfont, {
	font = "Roboto Lt",
	size = 20,
	weight = 600,
	antialias = true,
	outline = false,
	extended = true
})

local surface_SetMaterial = surface.SetMaterial
local surface_DrawTexturedRect = surface.DrawTexturedRect
local surface_DrawText = surface.DrawText
local surface_SetDrawColor = surface.SetDrawColor
local surface_DrawRect = surface.DrawRect
local surface_DrawOutlinedRect = surface.DrawOutlinedRect
local surface_SetFont = surface.SetFont
local surface_GetTextSize = surface.GetTextSize
local surface_SetAlphaMultiplier = surface.SetAlphaMultiplier
local surface_SetAlphaMultiplier = surface.SetAlphaMultiplier
local surface_SetTextColor = surface.SetTextColor
local surface_SetTextPos = surface.SetTextPos
local draw_TextShadow = draw.TextShadow
local draw_SimpleText = draw.SimpleText
local draw_SimpleTextOutlined = draw.SimpleTextOutlined
local draw_BlurBox = draw.BlurBox
local draw_Blur = draw.Blur

function ba.LoadSingleEmote(em)
	if (not istable(em)) then return end

	em.matloading = true

	texture.Create('Chat_Emote_' .. em.name)
		:EnableProxy(false)
		:Download(em.loadUrl, function(self, mat)
			em.mat = mat
			em.matloading = false
		end)
end

local function ParseForEmotes(...)
	local data = {...}

	if (ba.chatEmotes) then
		local k = 0
		for k, v in ipairs(data) do
			if istable(v) then
				local first = true
				local shouldgoto
				for m, n in pairs(v) do
					if (shouldgoto and m < shouldgoto) then
						continue
					elseif (shouldgoto) then
						shouldgoto = nil
					end
					if (isstring(n) and (!first or n[1] == ":")) then
						first = nil

						local earliest = math.huge
						local emote
						for i, l in pairs(ba.chatEmotes) do
							local pos = string.find(n, i, 1, true)
							if (pos and pos < earliest) then
								earliest = pos
								emote = i
							end
						end

						if (emote) then
							local repwith = utf8_sub(n, 1, earliest-1)
							local add = utf8_sub(n, earliest+utf8.len(emote))
							local em = ba.chatEmotes[emote]

							if (!em.mat and !em.matloading) then
								ba.LoadSingleEmote(em)
							end

							data[k][m] = repwith
							table.insert(data[k], m+1,add)
							table.insert(data[k], m+1, em)

							shouldgoto = m + 2
						end
					end
				end
			end
		end
	end

	return data
end

function ba.CreateChatBox()
	if not IsValid(LocalPlayer()) then return end
	local frame = vgui.Create('ba_chatbox')

	hook.Call('BadminChatboxLoaded')

	return frame
end

local LABEL = {}
function LABEL:Init()
	self._Colors = {}
	self._Emotes = {}
	self._Text = ''
	self._SelStart = 0
	self._SelEnd = 0
	self._SelText = ''
	self._Bits = {}

	self.Expire = SysTime() + 15
	self.Created = SysTime()

	self:SetText('')
end

function LABEL:SizeToContents(w)
	surface_SetFont(chatfont)

	local w, h = 0, 0
	for i=1, utf8.len(self._Text) do
		if (self._Emotes[i]) then
			if (h < 16) then h = 16 end
			table.insert(self._Chars, {'', w, 16})
			w = w + 16
		else
			local t = utf8_sub(self._Text, i, i)
			local wid, th = surface_GetTextSize(t)

			if (h < th) then h = th end

			if (self._Text[i] == '&') then wid = 12 end
			table.insert(self._Chars, {self._Text[i], w, wid})
			w = w + wid
		end
	end
	self:SetSize(w, h)
end

function LABEL:SetText(val)
	self._Text = val
	self._Bits = {}

	self._Chars = {}

	surface_SetFont(chatfont)

	self:SizeToContents()
end

function LABEL:AddColor(Pos, Col)
	self._Colors[Pos] = Col
	self._Bits = {}
end

function LABEL:AddEmote(Pos, Emote)
	self._Emotes[Pos] = Emote
	self._Bits = {}
end

function LABEL:GetSelectedText()
	return self._SelText
end

function LABEL:Think()
	self._SelText = ''

	local x1 = nil
	local x2 = nil

	if (self._SelStart != 0 or self._SelEnd != 0) then
		local endx
		for k, v in ipairs(self._Chars) do
			if (self._SelStart <= v[2] + v[3] and self._SelEnd >= v[2] + v[3]) then
				self._SelText = self._SelText .. v[1] .. ((k == self._Chars) and '\n' or '')
				v.Sel = true

				if (!x1) then x1 = v[2] end
			else
				v.Sel = false

				if (x1 and !x2) then x2 = v[2] - x1 end
			end
			endx = v[2] + v[3]
		end
		if (x1 and !x2) then x2 = endx - x1 end
	end

	self._HighX1 = x1
	self._HighX2 = x2

	if (!self._Bits[1]) then
		local lastcol = Color(0, 0, 0)
		local lastpos = 1
		local lastx = 0
		local str = ''

		for k, v in ipairs(self._Chars) do
			if (self._Colors[k]) then
				str = utf8_sub(self._Text, lastpos, k - 1)

				table.insert(self._Bits, {str, self._Chars[lastpos][2], lastcol})

				lastpos = k

				lastcol = self._Colors[k]
			end

			if (self._Emotes[k]) then
				str = utf8_sub(self._Text, lastpos, k - 1)

				table.insert(self._Bits, {str, self._Chars[lastpos][2], lastcol})

				if (self._Chars[k-1]) then
					table.insert(self._Bits, {'', self._Chars[k-1][2] + self._Chars[k-1][3], lastCol, Emote = self._Emotes[k]})
				else
					table.insert(self._Bits, {'', 0, lastCol, Emote = self._Emotes[k]})
				end

				lastpos = k+1

				//lastx = lastx
			end
		end

		if (self._Text[lastpos] and self._Chars[lastpos]) then
			str = utf8_sub(self._Text, lastpos)

			table.insert(self._Bits, {str, self._Chars[lastpos][2], lastcol})
		end

	end
end

function LABEL:GetSelText()
	return self._SelText or ''
end

local blk = Color(0, 0, 0)
function LABEL:Paint(w, h)
	if (CHATBOX and CHATBOX.ShouldDraw == false) then return true end
	if (SysTime() > self.Expire) and (CHATBOX and !CHATBOX._Open) then return true end

	local fin = math.Clamp((SysTime() - (self.Expire - 15)) / .25, 0, 1)
	if (!CHATBOX._Open and fin == 1) then
		-- calc alpha and override mul
		local a = 1 - (math.Clamp((SysTime() - self.Expire) + 2, 0, 2) / 2)
		surface_SetAlphaMultiplier(a)
	else
		surface_SetAlphaMultiplier(fin)
	end

	local h = self:GetTall()
	local outcol = Color(0, 0, 0)
	local emoteswide = 0

	if (self._HighX1 and self._HighX2) then
		surface_SetDrawColor(200, 200, 200, 100)
		surface_DrawRect(self._HighX1, 0, self._HighX2, h)
	end

	for k, v in ipairs(self._Bits) do
		if (v.Emote) then
			if (v.Emote.mat) then
				surface_SetDrawColor(255, 255, 255)
				surface_SetMaterial(v.Emote.mat)
				--surface_DrawTexturedRect(v[2], (h - 16) * 0.5, 16, 16)
				surface_DrawTexturedRect(v[2], 0, h, h)
			end
		else
			v[3].a = math.Clamp((SysTime() - self.Created) * 2, 0, 1) * 255
			draw_SimpleTextOutlined(v[1], chatfont, v[2]+1, ((self:GetTall() == 16 and 1) or 0), v[3], 0, 0, 0.5, blk)
		end
	end

	return true
end
derma.DefineControl('ba_chatlabel', 'Badmin Chatbox Label', LABEL, 'DLabel')

local PANEL = {}

function PANEL:OnMouseReleased(b)
	self.Selecting = nil
end

function PANEL:GetSheet(name)
	if (self.Sheets[name]) then
		return self.Sheets[name].Frame
	else
		local sheet, msgFrame = self:CreateTab(name)

		return msgFrame
	end
end

local numTabs = 0
function PANEL:CreateTab(name)
	numTabs = numTabs + 1
	local msgFrame = vgui.Create('ui_scrollpanel', self)
	msgFrame:SetScrollSize(2)
	msgFrame:SetSkin('SUP')
	msgFrame:SetPadding(0)
	msgFrame:SetSpacing(0)
	msgFrame._Messages = {}

	local sheet = self.propSheet:AddSheet(name, msgFrame)
	sheet.Tab:SetFont(chatfont)
	sheet.Tab:SetTextColor(Color(5, 5, 5))
	sheet.Tab.OldOnMP = sheet.Tab.OnMousePressed
	sheet.Tab.OnMousePressed = function(s, m)
		if (m == MOUSE_MIDDLE and name != "All") then
			if (self.activeMessageFrame and msgFrame == self.activeMessageFrame) then
				self.propSheet:SetActiveTab(self.Sheets["All"].Tab)
			end

			self.propSheet:CloseTab(s, true)
			self.Sheets[name] = nil
			return
		end

		s:OldOnMP(m)
	end
	sheet.Tab.Paint = function(s, w, h, x, y)
		if (numTabs == 1 or !x) then
			return true
		end

		local sel = false
		if (self.activeMessageFrame and msgFrame == self.activeMessageFrame) then
			surface_SetDrawColor(0, 0, 0, 200)
			sel = true
			msgFrame.Attention = false
		else
			if (msgFrame.Attention) then
				local diff = SysTime() - msgFrame.Attention
				if (diff >= 15) then
					msgFrame.Attention = SysTime()
				end

				local a
				if (self._OpenTime) then
					a = 0
					msgFrame.Attention = SysTime()
				else
					a = math.min(diff, 2) / 2
					if (a == 1) then return end
				end

				surface_SetDrawColor(255 - 255 * a, 150 - 150 * a, 0, 200 - 100 * a)
			else
				surface_SetDrawColor(0, 0, 0, 100)
			end
		end

		surface_DrawRect(x + 1, y, w - 5, 28)

		surface_SetDrawColor(ui.col.Outline.r, ui.col.Outline.g, ui.col.Outline.b, 255)
		surface_DrawOutlinedRect(x, y, w - 4, 29)

		draw_SimpleText(name, chatfont, x + w * 0.5 - 2, y + 4, sel and ui.col.SUP or ui.col.White, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

		return true
	end
	msgFrame:SetSize(self.propSheet:GetWide())

	self.Sheets[name] = {Tab = sheet.Tab, Frame = msgFrame}
	msgFrame.Tab = sheet.Tab

	return sheet, msgFrame
end

function PANEL:Init()
	self:SetSize(chat.GetChatBoxSize(true))
	self:SetPos(chat.GetChatBoxPos())

	self.Sheets = {}

	self.ShouldDraw = true

	self._Open = false
	self._Team = false

	self.History = {}
	self.AutoNames = {}
	self.CurrentAutoName = 0

	self.btnResize = vgui.Create('Panel', self)
	self.btnResize:SetCursor('sizenesw')
	self.btnResize.OnMousePressed = function(s, mb)
		if (mb == MOUSE_LEFT) then
			self.Resizing = true
		end
	end

	self.propSheet = vgui.Create('DPropertySheet', self)
	self.propSheet:SetFadeTime(0)
	self.propSheet.Paint = function() end
	self.propSheet.OnActiveTabChanged = function(s, o, n)
		self.activeMessageFrame = n:GetPanel()
	end

	self.OvermsgFrame = vgui.Create('Panel', self)

	local checkVisibility = 0
	local mp = {}
	self.OvermsgFrame.Think = function(s)
		checkVisibility = checkVisibility + 1
		if (checkVisibility >= 5) then
			checkVisibility = 0
		end

		local y = 0
		local off = self.activeMessageFrame.yOffset
		mp[1] = gui.MouseX() - s.x - self.x
		mp[2] = gui.MouseY() - s.y - self.y + self.activeMessageFrame.yOffset
		local firstx, firsty, lastx, lasty

		if (self.Selecting) then
			if (self.MouseDown[2] > mp[2]) then firstx = mp[1] firsty = mp[2] lastx = self.MouseDown[1] lasty = self.MouseDown[2] else firstx = self.MouseDown[1] firsty = self.MouseDown[2] lastx = mp[1] lasty = mp[2] end
		end

		self.SelectedText = ''

		if (checkVisibility == 0 or self.Selecting) then
			for k, v in ipairs(self.activeMessageFrame._Messages) do
				if (checkVisibility == 0) then
					if (y >= off - s:GetTall() * 2 and y <= off + s:GetTall() * 2) then
						if (v.invisible) then
							v:SetVisible(true)
							v.invisible = false
						end
					elseif (!v.invisible) then
						v.invisible = true
						v:SetVisible(false)
					end
				end

				if (!v.invisible and self.Selecting) then
					if (firsty <= v.y and lasty > v.y + v:GetTall()) then
						v._SelStart = 0
						v._SelEnd = v:GetWide()
					elseif (firsty >= v.y and firsty <= v.y + v:GetTall() - 1) then
						if (lasty > v.y + v:GetTall()) then
							v._SelStart = firstx
							v._SelEnd = v:GetWide()
						else
							if (firstx < lastx) then
								v._SelStart = firstx
								v._SelEnd = lastx
							else
								v._SelStart = lastx
								v._SelEnd = firstx
							end
						end
					elseif (lasty >= v.y and lasty <= v.y + v:GetTall()) then
						if (firsty <= v.y + 10) then
							v._SelStart = 0
							v._SelEnd = lastx
						else
							if (firstx < lastx) then
								v._SelStart = firstx
								v._SelEnd = lastx
							else
								v._SelStart = lastx
								v._SelEnd = firstx
							end
						end
					else
						v._SelStart = 0
						v._SelEnd = 0
					end

					self.SelectedText = self.SelectedText .. v:GetSelText()
				end

				y = y + v:GetTall()
			end
		end
	end

	self.OvermsgFrame.OnMouseWheeled = function(s, ...)
		return self.activeMessageFrame:OnMouseWheeled(...)
	end

	self.OvermsgFrame.OnMousePressed = function(s, b)
		local sb = self.activeMessageFrame.scrollBar.scrollButton
		local sbx, sby = sb:CursorPos()

		if (sbx >= 0 and sbx <= sb:GetWide() and sby >= 0 and sby <= sb:GetTall()) then
			sb:OnMousePressed(b)
		else
			self.MouseDown = {gui.MouseX() - self.x - s.x, gui.MouseY() - self.y - s.y + self.activeMessageFrame.yOffset}
			self.Selecting = true
		end
	end

	self.OvermsgFrame.OnMouseReleased = function(s, b)
		self.Selecting = false
	end

	self.txtEntry = vgui.Create('DTextEntry', self)
	self.txtEntry:SetDrawBackground(false)
	self.txtEntry:SetVisible(false)

	self.txtEntry.PaintOver = function(s, w, h)
		if (CHATBOX and CHATBOX.ShouldDraw == false) then return true end

		if (!s.AutoFillText) then return end

		surface_SetFont(chatfont)

		local x = surface_GetTextSize(s:GetValue())
		local w, h = surface_GetTextSize(s.AutoFillText)

		surface_SetDrawColor(s:GetHighlightColor() or ui.col.SUP)
		surface_DrawRect(x+3, 0, w, h+1)
		surface_SetTextColor(ui.col.White)
		surface_SetTextPos(x+3, 0)
		surface_DrawText(s.AutoFillText)
	end

	self.txtEntry.OnKeyCodeTyped = function(s, c)
		if (c == KEY_TAB) or ((c == KEY_RIGHT) and (s:GetCaretPos() == utf8.len(s:GetValue()))) then
			self:DoAutoFill()
			s:OnTextChanged()
			s:SetCaretPos(utf8.len(s:GetValue()))
		elseif (c == KEY_UP) then
			if (#self.AutoNames > 0) then
				local auto = self:GetAutoFill(1)
				s.AutoFillText = auto and auto.CompleteString or nil
			else
				if (self.History[s.historyPos + 1]) then
					s.historyPos = s.historyPos + 1
					self._Team = self.History[s.historyPos].Team
					s:SetText(self.History[s.historyPos].Text)
					s:SetCaretPos(utf8.len(s:GetValue()))
				end
			end
		elseif (c == KEY_DOWN) then
			if (#self.AutoNames > 0) then
				local auto = self:GetAutoFill(1)
				s.AutoFillText = auto and auto.CompleteString or nil
			else
				if (self.History[s.historyPos - 1] or s.historyPos - 1 == 0) then
					s.historyPos = s.historyPos - 1
					if (self.History[s.historyPos]) then
						s:SetText(self.History[s.historyPos].Text)
						self._Team = self.History[s.historyPos].Team
					else
						s:SetText('')
						self._Team = self._OpenedWithTeam
					end
					s:SetCaretPos(utf8.len(s:GetValue()))
				end
			end
		elseif (c == KEY_ENTER) then
			RunConsoleCommand("say" .. ((self._Team and "_team") or ""), s:GetValue())
			if (string.Trim(s:GetValue()) != "") then
				table.insert(self.History, 1, {Team = self._Team, Text = s:GetValue()})
			end
			self:Close()
		elseif (c == KEY_ESCAPE) then
			self:Close()

			RunConsoleCommand("cancelselect")
		end
	end

	self.txtEntry.OnLoseFocus = function(s)
		if (input.IsKeyDown(KEY_TAB)) then
			s:RequestFocus()
			s:SetCaretPos(utf8.len(s:GetText()))
		end
	end

	self.txtEntry.OnTextChanged = function(s)
		self:CalculateAutoFill()

		local auto = self:GetAutoFill()
		s.AutoFillText = auto and auto.CompleteString or nil

		if (s:AllowInput()) then
			s:SetValue(utf8_sub(s:GetValue(), 1, 126))
			s:SetCaretPos(126)
		end

		gamemode.Call('ChatTextChanged', s:GetValue())
	end

	self.txtEntry.AllowInput = function(s)
		if (utf8.len(s:GetValue()) >= 126) then
			surface.PlaySound('Resource/warning.wav')
			return true
		end
	end

	self.emotes = ui.Create('DButton', self)
	self.emotes:SetText('')
	self.emotes:SetVisible(false)

	self.emotes.PaintOver = function(s, w, h)
		draw_SimpleText('☺', 'ui.29', 10, 7, ui.col.White, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) -- gettextsize doesnt work here
	end
	self.emotes.DoClick = function()
		if IsValid(self.emotesList) then
			self.emotesList:AddRecents()
			self.emotesList:SetVisible(not self.emotesList:IsVisible())
		else
			self.emotesList = ui.Create('ba_emotes_list', self)
		end
	end

	self:PerformLayout(self:GetWide(), self:GetTall())
end

function PANEL:OnKeyCodePressed(k)
	if (k == KEY_C) and (input.IsKeyDown(KEY_LCONTROL)) then
		if (self.SelectedText and self.SelectedText != '') then
			SetClipboardText(self.SelectedText)
		end
	end
end

function PANEL:PerformLayout(w, h)
	self.txtEntry:SetFont(chatfont)

	local ts = self.txtEntry:GetTall()

	self.txtEntry:SetPos(5, h - ts - 5)
	self.txtEntry:SetWide(w - ts - 15)

	self.emotes:SetSize(ts, ts)
	self.emotes:SetPos(w - ts - 5, h - ts - 5)

	if IsValid(self.emotesList) then
		self.emotesList:SetSize(185, 220)
		self.emotesList:SetPos(w - self.emotesList:GetWide() - 5, h - self.emotesList:GetTall() - ts - 10)
	end

	self.btnResize:SetSize(5, 5)
	self.btnResize:SetPos(w - 5, 0)
	self.propSheet:SetPos(5, 5)
	self.propSheet:SetSize(w - 10, self.txtEntry.y - 10)

	if (!self.activeMessageFrame) then
		self.activeMessageFrame = self:GetSheet("All")
		self:AddMessage({Color(255, 100, 0), '| ', Color(255, 255, 255), 'Добро пожаловать на ', Color(51, 128, 255), 'GmodHub!'})
		self:AddMessage({Color(255, 100, 0), '| ', Color(255, 255, 255), 'Лучшие сервера во всём', Color(51, 128, 255), 'Garry\'s mod!'})
	end

	for k, v in pairs(self.Sheets) do
		v.Frame:Dock(FILL)
	end

	self.OvermsgFrame:SetPos(5 + self.activeMessageFrame.x, 5 + self.activeMessageFrame.y)
	self.OvermsgFrame:SetSize(w - (self.OvermsgFrame.x * 2), self.txtEntry.y - (self.OvermsgFrame.y * 2))
end

function PANEL:Think()
	if (!self.Resizing) then return end
	if (!input.IsMouseDown(MOUSE_LEFT)) then
		cvar.SetValue('ChatboxSize', {self:GetWide(), self:GetTall()})
		self.Resizing = false
		return
	end

	local w = math.Clamp(gui.MouseX() - chat.GetChatBoxLeftBound(), 265, ScrW() - 23) + 3
	local h = math.Clamp(chat.GetChatBoxBottomBound() - gui.MouseY(), 155, ScrH() - 23) + 3

	if (x != self:GetWide() or h != self:GetTall()) then
		for _, msgFrame in pairs(self.Sheets) do
			local newOff = msgFrame.yOffset
			if (h < self:GetTall()) then
				newOff = newOff + (self:GetTall() - h)
			end

			msgFrame:SetOffset(newOff)
		end

		self:SetSize(w, h)
		self:SetPos(chat.GetChatBoxPos(w, h))
		self:InvalidateLayout(true)
	end
end

local colblack = Color(0, 0, 0)
local coloutline = Color(ui.col.Outline.r, ui.col.Outline.g, ui.col.Outline.b)
local colteamchat = Color(100, 200, 100)
local colglobalchat = Color(255, 255, 255)
function PANEL:Paint(w, h)
	self.ShouldDraw = hook.Call('HUDShouldDraw', GAMEMODE, 'Chatbox')
	if (!self.ShouldDraw) then return true end

	local a = 0
	if (self._OpenTime) then
		a = math.Clamp((SysTime() - self._OpenTime) / .25, 0, 1)
	elseif (self._CloseTime) then
		a = 1 - math.Clamp((SysTime() - self._CloseTime) / .25, 0, 1)
	end

	self.activeMessageFrame.scrollBar:SetAlpha(a * 255)
	for k, v in pairs(self.Sheets) do
		v.Tab:SetAlpha(a * 255)

		local bx, by = v.Tab:LocalToScreen(0, 0)
		bx = bx - self.x - 5
		by = by - self.y - 5

		surface.SetAlphaMultiplier(v.Frame.Attention and 1 or a)
		v.Tab:Paint(v.Tab:GetWide(), v.Tab:GetTall(), bx, by)
		surface.SetAlphaMultiplier(1)
	end

	if (a == 0) then
		return
	end

	local bx, by, bw, bh = self:GetBounds()
	local fy = self.activeMessageFrame.y
	h = h - fy
	draw_BlurBox(bx, by + fy, bw, bh - fy)

	surface_SetDrawColor(0, 0, 0, 150 * a)
	surface_DrawRect(0, fy, w, h)

	coloutline.a = a * 255
	surface_SetDrawColor(coloutline)
	surface_DrawOutlinedRect(0, fy, w, h)

	local x, y, w, h = self.txtEntry.x - 2, self.txtEntry.y - 2, self.txtEntry:GetWide() + 4, self.txtEntry:GetTall() + 4

	colblack.a = a * 255
	surface_SetDrawColor(colblack)
	surface_DrawRect(x + 1, y + 1, w - 2, h - 2)

	colteamchat.a = a * 255
	colglobalchat.a = a * 255
	surface_SetDrawColor((self._Team and colteamchat) or colglobalchat)
	surface_DrawRect(x+2, y+2, w-4, h-4)
end

function PANEL:PaintOver(w, h)
end

function PANEL:AddTabbedMessage(tab, ...)
	self.activeMessageTab = self:GetSheet(tab)
	self:AddMessage(...)
	self.activeMessageTab = nil

	if (self.SkipMessageInAll) then self.SkipMessageInAll = nil return end

	if (tab != "All") then
		self:AddTabbedMessage("All", ...)
	end
end

function PANEL:AddMessage(...)
	if (self.PendingChatTab) then
		local tab = self.PendingChatTab
		self.PendingChatTab = nil
		self:AddTabbedMessage(tab, ...)
		return
	end

	local strings = ''
	local colors = {}
	local emotes = {}
	local emotesww = {}

	local msgFrame = self.activeMessageTab or self:GetSheet('All')
	if (msgFrame != self.activeMessageFrame) then
		msgFrame.Attention = SysTime()
	end

	self.LastMaxOffset = math.Clamp(msgFrame:GetCanvas():GetTall() - msgFrame:GetTall(), 0, math.huge)

	table.insert(colors, {Col=Color(200, 200, 200), Pos=1})

	local data = ((not cvar.GetValue('DisableEmotes')) and self.DoEmotes) and ParseForEmotes(...) or {...}
	self.DoEmotes = false

	for k, v in ipairs(data[1]) do
		if istable(v) and v.mat != nil then
			strings = strings .. '*'

			emotesww[emotes[table.insert(emotes, {Emote = v, Pos=utf8.len(strings)})].Pos] = true
		elseif (isstring(v) or isnumber(v)) then
			if (v[1] == '>') then
				table.insert(colors, {Col=Color(140, 200, 100), Pos=utf8.len(strings)})
			end
			strings = strings .. v
		elseif isplayer(v) then
			if (utf8.len(strings) == 0) then table.remove(colors, 1) end

			table.insert(colors, {Col=team.GetColor(v:Team()), Pos=utf8.len(strings) + 1})

			strings = strings .. v:Name()
		else
			if (utf8.len(strings) == 0) then table.remove(colors, 1) end
			table.insert(colors, {Col=v:Copy(), Pos=utf8.len(strings) + 1})
		end
	end

	local texts = ba.ui.WordWrap(chatfont, strings, msgFrame:GetWide() - 25, emotesww)

	local shouldPopDown
	if (msgFrame:IsAtMaxOffset()) then
		shouldPopDown = true
	end

	local cursnip = 1
	for k, v in ipairs(texts) do
		if (v == '') then continue end

		if (msgFrame._Messages[500]) then
			msgFrame._Messages[1]:Remove()
			table.remove(msgFrame._Messages, 1)

			if (!shouldPopDown) then -- Comment this out mayb?
				--self.yOffset = self.yOffset - msgFrame._Messages[1]:GetTall()
			end
		end

		local lbl = vgui.Create('ba_chatlabel', msgFrame:GetCanvas())
		lbl:SetFont(chatfont)
		lbl:SetCursor("beam")

		table.insert(msgFrame._Messages, lbl)

		for i, l in ipairs(colors) do
			if (l.Pos <= cursnip and (!colors[i+1] or colors[i+1].Pos > cursnip)) then
				lbl:AddColor(1, l.Col)
			elseif (l.Pos >= cursnip and l.Pos < cursnip + #v) then
				lbl:AddColor(l.Pos - cursnip + 1, l.Col)
			end
		end

		for i, l in ipairs(emotes) do
			if (l.Pos >= cursnip and l.Pos < cursnip + #v) then
				lbl:AddEmote(l.Pos - cursnip + 1, l.Emote)
			end
		end

		lbl:SetText(v)
		msgFrame:AddItem(lbl)

		cursnip = cursnip + #v
	end

	chat.PlaySound()

	if (shouldPopDown) then
		msgFrame.yOffset = math.Clamp(msgFrame:GetCanvas():GetTall() - msgFrame:GetTall(), 0, math.huge)
	end

	self:InvalidateLayout()
end

function PANEL:CalculateAutoFill()
	local curSel = self.AutoNames[self.CurrentAutoName]

	table.Empty(self.AutoNames)

	local words = string.Explode(' ', self.txtEntry:GetValue())
	match = words[#words]

	if (!match or match == '') then
		self.CurrentAutoName = 0
		return
	end

	local isEmote = LocalPlayer():IsVIP() and string.StartWith(match, ':')

	if (not isEmote) then
		for k, v in ipairs(player.GetAll()) do
			if ((string.find(utf8.lower(v:Name()), utf8.lower(match), 1, true) or -1) == 1) then
				if (curSel and curSel.SteamID == v:SteamID()) then
					self.CurrentAutoName = #self.AutoNames + 1
				end

				self.AutoNames[#self.AutoNames + 1] = {
					Name = v:Name(),
					SteamID = v:SteamID()
				}
			end
		end
	end

	if isEmote then
		for k, v in pairs(ba.chatEmotes) do // do the hack
			if ((string.find(utf8.lower(k), utf8.lower(match), 1, true) or -1) == 1)  then
				self.AutoNames[#self.AutoNames + 1] = {
					Name = k,
					SteamID = k
				}
			end
		end
	end
end

function PANEL:GetAutoFill(step)
	step = step or 0

	local words = string.Explode(' ', self.txtEntry:GetValue())
	match = words[#words]
	if (!match or match == '') then return end

	self.CurrentAutoName = self.CurrentAutoName + step
	if (!self.AutoNames[self.CurrentAutoName]) then
		self.CurrentAutoName = (self.CurrentAutoName <= 0 and #self.AutoNames) or 1
	end

	local fillData = self.AutoNames[self.CurrentAutoName]

	if (fillData) then
		fillData.CompleteString = utf8_sub(fillData.Name, utf8.len(match) + 1)
	end

	return fillData
end

function PANEL:DoAutoFill()
	local pl = self:GetAutoFill()
	if (!pl) then return end

	local words = string.Explode(' ', self.txtEntry:GetValue())
	match = words[#words]
	if (!match or match == '') then return end

	local pref = utf8_sub(self.txtEntry:GetValue(), 1, 1)
	local fillVal

	local firstarg = utf8_sub(self.txtEntry:GetValue(), 1, (string.find(self.txtEntry:GetValue(), ' ')  or (utf8.len(self.txtEntry:GetValue()) + 1)) - 1)

	if (pref == '/' or pref == '!') and (firstarg != '//' and firstarg != '/ooc' and firstarg != '/ad' and firstarg != '/advert') and (!ret) then
		fillVal = pl.SteamID
	else
		fillVal = pl.Name
	end

	self.txtEntry:SetText(utf8_sub(self.txtEntry:GetValue(), 1, -(utf8.len(match) + 1)) .. fillVal .. ' ')
end

/*function PANEL:DoAutoFill(ret, cont) -- TODO, replace with command autocomplete
	local pl = self.AutoNames[self.CurrentAutoName]

	table.Empty(self.AutoNames)

	local match

	local words = string.Explode(' ', self.txtEntry:GetValue())
	match = words[#words]

	if (!match or match == '') then return end

	for k, v in ipairs(player.GetAll()) do
		if ((string.find(v:Name():lower(), match:lower(), 1, true) or -1) == 1) then
			if (pl and pl == v) then
				self.CurrentAutoName = #self.AutoNames + 1
			end

			self.AutoNames[#self.AutoNames + 1] = v
		end
	end

	if (cont != nil) then
		self.CurrentAutoName = self.CurrentAutoName + cont
	end

	if (!pl or !self.AutoNames[self.CurrentAutoName] or self.AutoNames[self.CurrentAutoName] != pl) then
		self.CurrentAutoName = self.AutoNames[self.CurrentAutoName + 1] and (self.CurrentAutoName + 1) or 0
	end

	pl = self.AutoNames[self.CurrentAutoName]

	if (pl) then
		local pref = string.sub(self.txtEntry:GetValue(), 1, 1)
		local add

		local firstarg = string.sub(self.txtEntry:GetValue(), 1, (string.find(self.txtEntry:GetValue(), ' ')  or (#self.txtEntry:GetValue() + 1)) - 1)

		if (pref == '/' or pref == '!') and (firstarg != '//' and firstarg != '/ooc' and firstarg != '/ad' and firstarg != '/advert') and (!ret) then
			add = pl:SteamID()
		else
			add = pl:Name()
		end

		if (!ret) then
			self.txtEntry:SetText(string.sub(self.txtEntry:GetValue(), 1, -(#match + 1)) .. add .. ' ')
		else
			return string.sub(add, #match+1)
		end

		return
	end
end*/

function PANEL:Open(tm)
	if (CHATBOX and CHATBOX.ShouldDraw == false) then return end -- Don't open if we can't draw!

	self._Open = true
	self._OpenTime = SysTime()
	self._CloseTime = nil

	self._Team = tm
	self._OpenedWithTeam = tm
	gamemode.Call('StartChat')

	self:MakePopup()
	self:MoveToFront()

	self.txtEntry:SetVisible(true)
	self.txtEntry:RequestFocus()
	self.txtEntry.historyPos = 0

	self.emotes:SetVisible(true)
end

function PANEL:Close()
	if (!self._Open) then return end

	if (self.ForceOpen) then
		gamemode.Call('FinishChat')
		gamemode.Call('ChatTextChanged', '')
		self.txtEntry:SetText('')

		return
	end

	self._Open = false
	self._OpenTime = nil
	self._CloseTime = SysTime()

	for k, v in pairs(self.Sheets) do
		v.Frame.yOffset = math.Clamp((v.Frame:GetCanvas():GetTall() - v.Frame:GetTall()), 0, math.huge)
		v.Frame:InvalidateLayout()

		v.Frame.Attention = false
	end

	gamemode.Call('FinishChat')

	self:SetMouseInputEnabled(false)
	self:SetKeyboardInputEnabled(false)

	gamemode.Call('ChatTextChanged', '')

	self.txtEntry:SetVisible(false)
	self.txtEntry:SetText('')
	self.txtEntry:OnTextChanged()

	if IsValid(self.emotesList) then
		self.emotesList:SetVisible(false)
	end
	self.emotes:SetVisible(false)

	self:MoveToBack()
end


derma.DefineControl('ba_chatbox', 'Badmin Chatbox', PANEL, 'EditablePanel')

if (CHATBOX) then CHATBOX:Remove() CHATBOX = ba.CreateChatBox() end

concommand.Add("spamchatbox", function()
	for i=1, 1250 do
		chat.AddText("[" .. i .. "] AYYYYYY!")
	end
end)
