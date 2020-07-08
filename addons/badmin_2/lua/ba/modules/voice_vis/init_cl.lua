-- Inspired by IJWTB
PLAYER.GetJobColor = PLAYER.GetJobColor or function(self) return team.GetColor(self:Team()) end -- rp fix

local math 				= math
local table 			= table
local draw 				= draw
local team 				= team
local IsValid 			= IsValid
local CurTime 			= CurTime

local PANEL 			= {}
local PlayerVoicePanels = {}

local color_white 		= Color(255,255,255)
local color_bg 			= Color(0,0,0)
local color_outline 	= Color(20,20,20)
local color_vis_outline	= Color(200,200,200)
local color_vis_bg 		= Color(40,40,40)

function PANEL:Init()
	self.LabelName = ui.Create('DLabel', self)
	self.LabelName:SetFont('ui.17')
	self.LabelName:Dock(FILL)
	self.LabelName:DockMargin(8, 0, 0, 0)
	self.LabelName:SetTextColor(color_white)

	self.Avatar = ui.Create('AvatarImage', self)
	self.Avatar:Dock(LEFT)
	self.Avatar:SetSize(40, 40)

	self.Color = color_transparent
	self.LastThink = CurTime()

	self:SetSize(300, 45)
	self:DockPadding(4, 4, 4, 4)
	self:DockMargin(2, 2, 2, 2)
	self:Dock(BOTTOM)
end

function PANEL:Setup(pl)
	self.pl = pl
	self.LabelName:SetText(pl:Nick())
	self.Avatar:SetPlayer(pl)

	self.Color = pl:GetJobColor()

	self:InvalidateLayout()
end


function PANEL:Paint(w, h)
	if not IsValid(self.pl) or (hook.Call('HUDShouldDraw', nil, 'VoiceBox') == false) then return end

	local pl 		= self.pl
	local volume   	= pl:VoiceVolume()

	pl.VoiceBars 	= pl.VoiceBars or {}

	self.Color 		 = pl:GetJobColor()

	if (pl.VoiceBars[40] ~= nil) and (self.LastThink < CurTime() - 0.033) then
		table.remove(pl.VoiceBars, 1)
		pl.VoiceBars[40] = (((volume == 0) and (pl == LocalPlayer())) and math.Rand(0, 1) or math.Clamp(volume, 0.05, 1))
		self.LastThink = CurTime()
	end

	draw.Outline(0, 0, w, h, color_outline)
	draw.Outline(1, 1, w - 2, h - 2, self.Color, 3)

	draw.Box(3, 3, w - 6, h - 6, color_bg)

	draw.OutlinedBox(w - 86, 6, 80, h - 12, color_vis_bg, color_vis_outline)

	for i = 1, 40 do
		if (pl.VoiceBars[i] == nil) then
			pl.VoiceBars[i] = (((volume == 0) and (pl == LocalPlayer())) and math.Rand(0, 0.8) or math.Clamp(volume, 0.025, 1))
		end
		local barH = pl.VoiceBars[i] * 26
		draw.Box((w - 74) + (2 * (i - 1)) - 12, (h - barH) * .5, 1, barH, color_white)
	end
end

function PANEL:Think()
	if IsValid(self.pl) then
		self.LabelName:SetText(self.pl:Name())
	end
	if self.fadeAnim then
		self.fadeAnim:Run()
	end
end

function PANEL:FadeOut(anim, delta, data)
	if anim.Finished then
		if IsValid(PlayerVoicePanels[self.pl]) then
			PlayerVoicePanels[self.pl]:Remove()
			PlayerVoicePanels[self.pl] = nil
			return
		end
		return
	end
	self:SetAlpha(255 - (255 * delta))
end

derma.DefineControl('ba_VoiceNotify', '', PANEL, 'DPanel')

hook.Add('InitPostEntity', 'ba.vv.InitPostEntity', function() -- it doesn't play nice if we load before GAMEMODE is a table :(
	function GAMEMODE:PlayerStartVoice(pl)
		if not IsValid(ba.VoiceVis) then return end

		GAMEMODE:PlayerEndVoice(pl)

		if IsValid(PlayerVoicePanels[pl]) then
			if PlayerVoicePanels[pl].fadeAnim then
				PlayerVoicePanels[pl].fadeAnim:Stop()
				PlayerVoicePanels[pl].fadeAnim = nil
			end
			PlayerVoicePanels[pl]:SetAlpha(255)
			return
		end

		if not IsValid(pl) then return end

		local pnl = ba.VoiceVis:Add('ba_VoiceNotify')
		pnl:Setup(pl)

		PlayerVoicePanels[pl] = pnl
	end

	function GAMEMODE:PlayerEndVoice(pl)
		if IsValid(PlayerVoicePanels[pl]) then
			if (PlayerVoicePanels[pl].fadeAnim) then return end

			PlayerVoicePanels[pl].fadeAnim = Derma_Anim('FadeOut', PlayerVoicePanels[pl], PlayerVoicePanels[pl].FadeOut)
			PlayerVoicePanels[pl].fadeAnim:Start(1)
		end
	end

	timer.Create('VoiceClean', 10, 0, function()
		for k, v in pairs(PlayerVoicePanels) do
			if not IsValid(k) then
				GAMEMODE:PlayerEndVoice(k)
			end
		end
	end)

	timer.Simple(0, function()
		if IsValid(g_VoicePanelList) then g_VoicePanelList:Remove() end
		if IsValid(ba.VoiceVis) then ba.VoiceVis:Remove() end

		ba.VoiceVis = ui.Create('DPanel')
		ba.VoiceVis:ParentToHUD()
		ba.VoiceVis:SetPos(ScrW() - 325, 100)
		ba.VoiceVis:SetSize(300, ScrH() - 200)
		ba.VoiceVis.Paint = function() end
	end)
end)
