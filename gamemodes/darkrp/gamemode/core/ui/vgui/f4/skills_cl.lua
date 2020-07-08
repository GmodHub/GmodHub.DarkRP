local PANEL = {}

function PANEL:Init()
	self:SetText('')
end

local color_canafford = ui.col.DarkGreen:Copy()
color_canafford.a = 100
local color_cannotafford = ui.col.Red:Copy()
color_cannotafford.a = 100
local color_maxed = ui.col.SUP:Copy()
color_maxed.a = 100


function PANEL:Paint(w, h)
	draw.OutlinedBox(0, 0, w, h, ui.col.Background, ui.col.Outline)

	local totalLevels = #self.Prices
	local nextLevel = LocalPlayer():GetSkillLevel(self.ID) + 1
	local nextDesc = (self.Descriptions[nextLevel] and ('Level ' .. nextLevel .. '/' .. totalLevels .. ' - ' .. self.Descriptions[nextLevel]) or ('Level ' .. totalLevels .. ' - ' .. self.Descriptions[nextLevel - 1]))
	local nextPrice = self.Prices[nextLevel]

	local tTH = 0
	local tW, tH = draw.SimpleText(self.Name .. ' - ' .. self.Description, 'ui.22', w * 0.5, 5, ui.col.White, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	tTH = tTH + tH

	tW, tH = draw.SimpleText(nextDesc, 'ui.20', w * 0.5, 5 + tH, ui.col.White, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	tTH = tTH + tH

	local barColor = nextPrice and (LocalPlayer():CanAffordKarma(nextPrice) and color_canafford or color_cannotafford) or color_maxed

	draw.Box(0, 0, w, tTH + 10, barColor)

	tW, tH = draw.SimpleText(nextPrice and (string.Comma(nextPrice) .. ' Karma') or 'Skill Mastered', 'ui.22', w * 0.5, h - 5, ui.col.White, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
	tTH = tTH + tH

	draw.Box(0, (h - tH) - 10, w, tH + 10, barColor)

	if self.Icon then
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(self.Icon)

		local s = h - 35 - tTH
		surface.DrawTexturedRect((w - s) * 0.5, (h - s) * 0.5 + 10, s, s)
	end
end

function PANEL:PaintOver(w, h)
	local nextPrice = self.Prices[LocalPlayer():GetSkillLevel(self.ID) + 1]
	if self:IsHovered() and nextPrice then
		draw.Box(1, 1, w - 2, h - 2, ui.col.Background)
		draw.SimpleText(LocalPlayer():CanAffordKarma(nextPrice) and (self.Confirm and 'Click again to confirm' or 'Purchase') or 'Cannot afford!', 'ui.22', w * 0.5, h * 0.5, ui.col.White, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	if (not self:IsHovered()) and self.Confirm then
		self.Confirm = nil
	end
end

function PANEL:DoClick()
	if (not self.Prices[LocalPlayer():GetSkillLevel(self.ID) + 1]) then return end

	if self.Confirm then
		cmd.Run('buyskill', self.Name)
	end

	self.Confirm = (not self.Confirm)
end

function PANEL:SetSkill(skill)
	self.ID = skill.ID
	self.Name = skill.Name
	self.Description = skill.Description
	self.Descriptions = skill.Descriptions
	self.Prices = skill.Prices
	self.Icon = skill.Icon
end

vgui.Register('rp_skillbutton', PANEL, 'DButton')

PANEL = {}

function PANEL:Init()
	self.List = ui.Create('ui_listview', self)
	self.List.Paint = function() end
	self.List:SetPadding(5)

	self.Buttons = {}

	for k, v in ipairs(rp.karma.Skills) do
		self.Buttons[#self.Buttons + 1] = ui.Create('rp_skillbutton', function(s)
			s:SetSkill(v)
		end, self)
	end

	local cont
	local i = 0
	for k, v in ipairs(self.Buttons) do
		if (i == 0) then
			cont = ui.Create('DPanel', function(s)
				s.Paint = function() end
			end)

			self.List:AddCustomRow(cont)
		end

		v:SetParent(cont)

		i = (i == 2) and 0 or (i + 1)
	end

end

function PANEL:PerformLayout(w, h)
	self.List:SetPos(0, 5)
	self.List:SetSize(w, h - 10)

	for k, v in ipairs(self.List.Rows) do
		v:SetSize(self.List:GetWide(), (self.List:GetTall() * 0.33) - 1)

		for i, child in ipairs(v:GetChildren()) do
			child:SetSize(v:GetWide() * 0.33, v:GetTall())
			child:SetPos((i - 1) * (v:GetWide() * 0.33) + (5 * (i - 1)), 0)
		end
	end
end

vgui.Register('rp_skillslist', PANEL, 'Panel')
