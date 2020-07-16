rp.question = rp.question or {
	Queue = {}
}

if IsValid(rp.question.Container) then rp.question.Container:Remove() rp.question.Container = nil end

function rp.question.Destroy(uid)
	local ques = rp.question.Queue[uid]

	if IsValid(ques.Panel) then
		ques.Panel:Remove()
	end

	rp.question.Queue[uid] = nil
end

net('rp.question.Ask', function()
	if (not IsValid(LocalPlayer())) then return end

	local ques = {
		Question 	= net.ReadString(),
		Time 		= net.ReadUInt(16),
		Uid 		= net.ReadString()
	}

	ques.End = ques.Time + CurTime()

	if (not IsValid(rp.question.Container)) then
		rp.question.Container = ui.Create('ui_scrollpanel', function(self)
			self.Think = function(self)
				local count = table.Count(rp.question.Queue)

				if (count == 0) then
					self:Remove()
					return
				end

				local chatX, chatY = chat.GetChatBoxPos()
				local chatW, chatH = chat.GetChatBoxSize()

				local x, y = chatX + chatW + 10, ScrH() - 10

				self:SetSize(chatW * 0.5, math.min((105 * table.Count(rp.question.Queue)), 210))
				self:SetPos(x, y - self:GetTall())
			end
		end)
	end

	rp.question.Container:AddItem(ui.Create('rp_question_panel', function(self)
		self:SetQuestion(ques)
	end))

	rp.question.Queue[ques.Uid] = ques
end)

net('rp.question.Destroy', function()
	local uid = net.ReadString()

	if rp.question.Exists(uid) then
		rp.question.Destroy(uid)
	end
end)


local PANEL = {}

local material_key = Material 'gmh/hud/button.png'
function PANEL:Init()
	self.Label = ui.Label('QUESTION?', 'ui.18', 0, 0, self)

	self.BtnYes = ui.Create('DButton', self)
	self.BtnYes:SetText('Да')
	self.BtnYes.DoClick = function() self:Answer(true) end

	self.BtnNo = ui.Create('DButton', self)
	self.BtnNo:SetText('Нет')
	self.BtnNo.DoClick = function() self:Answer(false) end

	self:SetTall(105)
	self:ShowCloseButton(false)

	self.Blur = false

	LocalPlayer():EmitSound('Town.d1_town_02_elevbell1', 100, 100)
end

function PANEL:PerformLayout()
	self.BaseClass.PerformLayout(self)

	local x, y = self:GetDockPos()
	local w, h = self:GetWide(), self:GetTall()

	self.Label:SetSize(w - 10, h - y - 30)
	self.Label:SetPos(x, y)

	self.BtnYes:SetSize((w * 0.5) - 7.5, 25)
	self.BtnYes:SetPos(x, h - self.BtnYes:GetTall() - 5)

	self.BtnNo:SetSize((w * 0.5) - 7.5, 25)
	self.BtnNo:SetPos(x + self.BtnNo:GetWide() + 5, h - self.BtnNo:GetTall() - 5)
end

local bar_color = ui.col.SUP:Copy()
bar_color.a = 25
function PANEL:Paint(w, h)
	self.BaseClass.Paint(self, w, h)

	draw.Box(0, 0, w * ((self.Question.End - CurTime())/self.Question.Time), self:GetTitleHeight() - 5, bar_color)
end

function PANEL:OnClose()
	rp.question.Queue[self.Question.Uid] = nil
end

function PANEL:Answer(ans)
	net.Start 'rp.question.Answer'
		net.WriteString(self.Question.Uid)
		net.WriteBool(ans)
	net.SendToServer()

	self:Close()
end

local hasReleased = false
function PANEL:Think()
	self.BaseClass.Think(self)

	local time = self.Question.End - CurTime()

	if (time <= 0) then
		self:Remove()
		return
	end

	self:SetTitle('Время: ' .. math.ceil(time))
	self.lblTitle:SizeToContents()

	local isFirst, lastEnd = false, math.huge
	for k, v in pairs(rp.question.Queue) do
		if (v.End < lastEnd) then
			lastEnd = v.End
			isFirst = (v.Uid == self.Question.Uid)
		end
	end

	if isFirst then
		if (not self.HasUpdatedText) then
			self.BtnYes:SetText('Да (F1)')
			self.BtnNo:SetText('Нет (F2)')
			self.HasUpdatedText = true
		end

		if input.IsKeyDown(KEY_F1) then
			if hasReleased then
				self:Answer(true)
			end
			hasReleased = false
		elseif input.IsKeyDown(KEY_F2) then
			local ent = LocalPlayer():GetEyeTrace().Entity

			if hasReleased and ((not IsValid(ent)) or (not ent:IsDoor())) then
				self:Answer(false)
			end
			hasReleased = false
		else
			hasReleased = true
		end
	end
end

function PANEL:SetQuestion(ques)
	self.Question = ques

	self.Label:SetText(ques.Question)
	ques.Panel = self
end

vgui.Register('rp_question_panel', PANEL, 'ui_frame')
