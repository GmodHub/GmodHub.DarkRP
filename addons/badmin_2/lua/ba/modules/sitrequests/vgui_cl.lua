local PANEL = {}

function PANEL:Init()
	self:SetTitle('Жалобы')
	self:ShowCloseButton(false)
	self:SetDraggable(true)

	local w, h = chat.GetChatBoxSize()
	local x, y = chat.GetChatBoxPos()

	w = w * 0.5
	h = h * 0.75
	y = y - (h + x)

	self.W, self.H = w, h
	self.FullW = w * 2

	self:SetSize(w, h)
	self:SetPos(x, y)

	self.Requests = {}
	self.PlayerList = ui.Create('ui_scrollpanel', self)
	self.PlayerList:SetPadding(-1)
	self.PlayerList:SetPos(5, 32)
	self.PlayerList:SetSize(self.W - 10, self.H - 37)
end

function PANEL:SizeUp()
	self:SizeTo(self.FullW, self.H, 0.175, 0, 0.25)
end

function PANEL:SizeDown()
	self:SizeTo(self.W, self.H, 0.175, 0, 0.25)
end

function PANEL:AddRequest(eid)
	self:SetVisible(true)

	if (cvar.GetValue('AdminChatSound')) then
		surface.PlaySound('vo/ravenholm/monk_coverme05.wav')
	end

	local req = ba.sits.Pending[eid]
	if (!req) then return end

	local pnl = ui.Create('ba_menu_player', function(pnl)
		pnl.Request = req
		pnl:SetPlayer(req.Player)
		pnl:SetStartTime(req.Time)
		pnl.Checkbox.DoClick = function()
			if (self.Selected != pnl) then
				if (IsValid(self.Selected)) then
					self.Selected.Selected = false
				end

				self.Selected = pnl
				self:SizeUp()
				self:OpenRequest(req)
			else
				pnl.Selected = false

				self.Selected = nil
				self:SizeDown()
			end
		end
		pnl.OT = pnl.Think
		pnl.Think = function(pnl)
			if (!pnl.Request:StillValid()) then
				self:RemoveRequest(req)
				return
			end

			pnl:OT()
		end

		self.PlayerList:AddItem(pnl)
		self.Requests[eid] = pnl
	end)
end

function PANEL:RemoveRequest(req)
	local eid = req.ID

	if (IsValid(self.Selected) and self.Selected.Request == req) then
		self.Selected = nil
		self:SizeDown()
	end

	if (IsValid(self.Requests[eid])) then
		self.Requests[eid]:Remove()
	end
	self.Requests[eid] = nil

	if (table.Count(self.Requests) == 0) then
		self:SetVisible(false)
	end
end

function PANEL:OpenRequest(req)
	if (IsValid(self.PnlRequest)) then self.PnlRequest:Remove() end
	if (!req:StillValid()) then return end

	self.PnlRequest = ui.Create('ui_panel', function(pnl)
		pnl:SetPos(self.W, 32)
		pnl:SetSize(self.W - 5, self.H - 37)
	end, self)

	ui.Create('DButton', function(btn, p)
		btn:SetPos(5, 5)
		btn:SetSize(p:GetWide() * 0.5 - 7.5, 25)
		btn:SetText('Взять Жалобу')
		btn.DoClick = function(btn)
			if (req:StillValid()) then
				RunConsoleCommand('ba', 'Treq', req.Player:SteamID())
			end
		end
	end, self.PnlRequest)

	ui.Create('DButton', function(btn, p)
		btn:SetPos(p:GetWide() * 0.5 + 2.5, 5)
		btn:SetSize(p:GetWide() * 0.5 - 7.5, 25)
		btn:SetText('Закрыть Жалобу')
		btn.DoClick = function(btn)
			if (req:StillValid()) then
				RunConsoleCommand('ba', 'Rreq', req.Player:SteamID())
			end
		end
	end, self.PnlRequest)

	ui.Create('DButton', function(btn, p)
		btn:SetPos(5, 35)
		btn:SetSize(p:GetWide() - 10, 25)
		btn:SetText('Скопировать SteamID')
		btn.DoClick = function(btn)
			if (req:StillValid()) then
				SetClipboardText(req.Player:SteamID())
				btn:SetText('Скопировано!')
				timer.Simple(1, function()
					if (req:StillValid()) then
						btn:SetText('Скопировать SteamID ')
					end
				end)
			end
		end
	end, self.PnlRequest)

	ui.Create('DLabel', function(lbl, p)
		lbl:SetFont('ui.22')
		lbl:SetWrap(true)
		lbl:SetAutoStretchVertical(true)
		lbl:SetTextColor(ui.col.White)
		lbl:SetPos(5, 65)
		lbl:SetText(req.Text)
		lbl:SetSize(p:GetWide() - 10, p:GetTall() - 70)
	end, self.PnlRequest)
end

vgui.Register("ba_staffrequests", PANEL, "ui_frame")

if (IsValid(ba.sits.Menu)) then
	ba.sits.Menu:Remove()
end
ba.sits.Menu = ui.Create("ba_staffrequests")
for k, v in pairs(ba.sits.Pending) do
	if (v:StillValid()) then
		ba.sits.Menu:AddRequest(k)
	end
end
if (table.Count(ba.sits.Menu.Requests) == 0) then
	ba.sits.Menu:SetVisible(false)
end
