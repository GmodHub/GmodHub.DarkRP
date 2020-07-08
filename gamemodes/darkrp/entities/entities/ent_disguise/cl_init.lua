dash.IncludeSH 'shared.lua'

function ENT:Draw()
	self:DrawModel()
end

function ENT:PlayerUse()
	rp.DisguiseMenu(self)
end

function rp.DisguiseMenu(ent)
	local fr = ui.Create('ui_frame', function(self, p)
		self:SetSize(ScrW() * 0.65, ScrH() * 0.6)
		self:SetTitle('Disguise')
		self:Center()
		self:MakePopup()
	end)

	ui.Create('rp_jobslist', function(self, p)
		local x, y = fr:GetDockPos()
		x, y = x - 5, y - 5
		self:SetPos(x, y)
		self:SetSize(p:GetWide() - x, p:GetTall() - y)
		self.DoClick = function()
			if IsValid(ent) then
				net.Start('rp.disguise.Use')
					net.WriteEntity(ent)
					net.WriteInt(self.job.team, 8)
				net.SendToServer()
			else
				net.Start('rp.disguise.Enable')
					net.WriteInt(self.job.team, 8)
				net.SendToServer()
			end

			fr:Close()
		end
	end, fr)
end
