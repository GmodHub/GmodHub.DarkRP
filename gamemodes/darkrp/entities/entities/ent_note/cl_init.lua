include('shared.lua')

function ENT:Draw()
	self:DrawModel()
end

local fr
net.Receive('rp.Note.Text', function(len)
	if (IsValid(fr)) then fr:Remove() end

	local ent = net.ReadEntity()
	local text = net.ReadString()
	local ownername = net.ReadString()
	local isowner = net.ReadBool()

	fr = ui.Create('ui_frame', function(self)
		self:SetSize(ScrW() * 0.5, ScrH() * 0.7)
		self:SetTitle('Записка')
		self:Center()
		self:MakePopup()
	end)

	if (isowner) then
		local txt = ui.Create('DTextEntry', function(self)
			self:Dock(FILL)
			self:SetFont('ui.22')
			self:SetText(text)
			self:SetMultiline(true)
		end, fr)

		txt.OnTextChanged = function(self)
			if (#self:GetValue() > 2000) then
				self:SetText(string.sub(self:GetValue(), 1, 1000))
				chat.AddText('Текс записки не может быть длинее 1000 символов.')
			end
		end

		ui.Create('DButton', function(self)
			self:SetTall(30)
			self:DockMargin(0, 5, 0, 0)
			self:Dock(BOTTOM)
			self:SetText('Submit')
			self.DoClick = function(self)
				fr:Close()

				net.Start('rp.Note.Text')
					net.WriteEntity(ent)
					net.WriteString(txt:GetValue())
				net.SendToServer()
			end
		end, fr)
	else
		local lines = string.Wrap('ui.22', text .. '\n\nИскренне ваш,\n' .. ownername, fr:GetWide() - 10)

		ui.Create('ui_scrollpanel', function(scr)
			scr:Dock(FILL)

			for k, v in ipairs(lines) do
				ui.Create('DLabel', function(self)
					self:SetFont('ui.22')
					self:SetText(v)
					self:SizeToContents()
					scr:AddItem(self)
				end)
			end
		end, fr)
	end
end)
