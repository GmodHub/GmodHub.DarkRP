local PANEL = {}

surface.CreateFont("PwdFont", {font="Courier New", size=30, weight=700, antialias=true, extended = true})

function PANEL:Init()
	self:SetFont("PwdFont")
	self:SetMouseInputEnabled(false)
	self:SetKeyBoardInputEnabled(false)

	self.Under = vgui.Create("DTextEntry")
	self.Under:SetFont("PwdFont")
	self.Under:SetTextColor(Color(0, 0, 0, 0))

	self.Under.OnTextChanged = function(s)
		self.HiddenText = string.rep('*', utf8.len(s:GetText()))
		self.LastRand = nil
	end

	self.Under.Paint = function() return false end
end

function PANEL:GetRealText()
	return self.Under:GetText()
end

function PANEL:Think()
	self.Under:SetParent(self:GetParent())
	self.Under:SetPos(self:GetPos())
	self.Under:SetSize(self:GetSize())
end

local trans = Color(0, 0, 0, 0)
function PANEL:PaintOver(w, h)
	local caretpos = self.Under:GetCaretPos()
	local realtxt = self.Under:GetText()
	self.Under:SetText(self.HiddenText or "")
	self.Under:SetCaretPos(caretpos)
	self.Under:DrawTextEntryText(self:GetTextColor(), self:GetHighlightColor(), self:GetCursorColor())
	self.Under:SetText(realtxt)
	self.Under:SetCaretPos(caretpos)
end

vgui.Register("ba_passwordentry", PANEL, "DTextEntry")

local fr
net.Receive("ba.PasswordRequest", function(len)
	if (IsValid(fr)) then fr:Close() end

	local isReset = net.ReadBool()
	local hasResetKey = isReset and net.ReadBool()

	fr = ui.Create("ui_frame", function(self)
		self:SetTitle("Авторизация")
		self:SetSize(300, 1)
		self:MakePopup()
	end)

	local password
	local new1
	local new2
	local submit

	if (!isReset) then
		local x, y = fr:GetDockPos()
		password = ui.Create("ba_passwordentry", function(self)
			self:SetSize(290, 28)
			self:SetPos(x, y + 17)
		end, fr)

		submit = ui.Create("DButton", function(self)
			self:SetSize(290, 29)
			self:SetPos(x, y + 50)
			self:SetText("Готово")
		end, fr)

		local lbl = ui.Create("DLabel", function(self)
			self:SetText("Введите пароль:")
			self:SizeToContents()
			self:SetPos(x, y - 5)
		end, fr)

		password.Under.OnEnter = function() submit:DoClick() end

		fr:SetTall(118)
	else
		if (hasResetKey) then
			password = ui.Create("ba_passwordentry", function(self)
				self:SetSize(290, 28)
				self:SetPos(5, 51)
			end, fr)

			new1 = ui.Create("ba_passwordentry", function(self)
				self:SetSize(290, 28)
				self:SetPos(5, 102)
			end, fr)

			new2 = ui.Create("ba_passwordentry", function(self)
				self:SetSize(290, 28)
				self:SetPos(5, 153)
			end, fr)

			submit = ui.Create("DButton", function(self)
				self:SetSize(290, 29)
				self:SetPos(5, 186)
				self:SetText("Готово")
			end, fr)

			local lbl = ui.Create("DLabel", function(self)
				self:SetText("Введите код:")
				self:SizeToContents()
				self:SetPos(5, 29)
			end, fr)

			local lbl2 = ui.Create("DLabel", function(self)
				self:SetText("Введите новый пароль:")
				self:SizeToContents()
				self:SetPos(5, 80)
			end, fr)

			local lbl3= ui.Create("DLabel", function(self)
				self:SetText("Подтвердите:")
				self:SizeToContents()
				self:SetPos(5, 131)
			end, fr)

			fr:SetTall(220)
		else
			new1 = ui.Create("ba_passwordentry", function(self)
				self:SetSize(290, 28)
				self:SetPos(5, 51)
			end, fr)

			new2 = ui.Create("ba_passwordentry", function(self)
				self:SetSize(290, 28)
				self:SetPos(5, 102)
			end, fr)

			submit = ui.Create("DButton", function(self)
				self:SetSize(290, 29)
				self:SetPos(5, 135)
				self:SetText("Готово")
			end, fr)

			local lbl = ui.Create("DLabel", function(self)
				self:SetText("Введите новый пароль:")
				self:SizeToContents()
				self:SetPos(5, 29)
			end, fr)

			local lbl2 = ui.Create("DLabel", function(self)
				self:SetText("Подтвердите:")
				self:SizeToContents()
				self:SetPos(5, 80)
			end, fr)

			fr:SetTall(169)
		end

		new2.Under.OnEnter = function() submit:DoClick() end
	end

	fr:Center()

	submit.DoClick = function(self)
		if (self:GetDisabled()) then return end

		net.Start("ba.PasswordAuth")
			net.WriteBool(isReset)
			if (isReset) then
				if (hasResetKey) then
					net.WriteString(new1:GetRealText())
					net.WriteBool(true)
					net.WriteString(password:GetRealText())
				else
					net.WriteString(new1:GetRealText())
					net.WriteBool(false)
				end
			else
				net.WriteString(password:GetRealText())
			end
		net.SendToServer()

		fr:Close()
	end

	local created = SysTime()
	submit.Think = function(self)
		if (isReset) then
			if (hasResetKey) then
				local code = password:GetRealText()
				if (#code == 0) then
					self:SetText("Введите код")
					self:SetDisabled(true)
					return
				end
			end

			local pass = new1:GetRealText()
			if (#pass < 4) then
				self:SetText("Минимальная длинна 4 символа!")
				self:SetDisabled(true)
			elseif (new2:GetRealText() != pass) then
				self:SetText("Пароли не совпадают")
				self:SetDisabled(true)
			else
				self:SetText("Готово")
				self:SetDisabled(false)
			end
		else
			if (SysTime() < created + 1) then
				self:SetDisabled(true)
			else
				self:SetDisabled(false)
			end
		end
	end

	if (password) then
		password.OnKeyCode = function(k) if (k == KEY_TAB and new1) then new1.Under:RequestFocus() end end
	end

	if (new1) then
		new1.OnKeyCode = function(k) if (k == KEY_TAB) then new2.Under:RequestFocus() end end
	end
end)
