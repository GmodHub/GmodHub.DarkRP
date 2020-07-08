local id = 1
local fr
function rp.ToggleF4Menu(openCs)
	if IsValid(fr) then fr:Close() return end

	local w, h = ScrW() * 0.75, ScrH() * 0.7

	fr = ui.Create('ui_frame', function(self)
		self:SetTitle('Меню Сервера')
		self:SetSize(w, h)
		self:MakePopup()
		self:Center()
		local keydown = false
		function self:Think()
			if input.IsKeyDown(KEY_F4) and keydown then
			self:Close()
			elseif (not input.IsKeyDown(KEY_F4)) then
				keydown = true
			end
		end
		function self:OnClose()
			id = self.tabs:GetActiveTabID()
		end
	end)

	fr.tabs = ui.Create('ui_tablist', fr)
	fr.tabs:DockToFrame()

	fr.tabs:AddTab('Действия', function(self)
		return ui.Create 'rp_commandlist'
	end):SetIcon 'sup/gui/f4/f4_actions.png'

	fr.tabs:AddTab('Профессии', function(self)
		return ui.Create 'rp_jobslist'
	end):SetIcon 'sup/hud/job.png'

	fr.tabs:AddTab('Магазин', function(self)
		return ui.Create 'rp_shoplist'
	end):SetIcon 'sup/hud/money.png'

	fr.tabs:AddTab('Навыки', function(self)
		return ui.Create 'rp_skillslist'
	end):SetIcon 'sup/hud/karma.png'

//	local hatTab
	//fr.tabs:AddTab('Apparel', function(self)
	//	hatTab = ui.Create 'rp_hatspanel'
	//	return hatTab
	//end):SetIcon 'sup/gui/f4/f4_hats.png'

	hook.Call('PopulateF4Tabs', GAMEMODE, fr.tabs, fr) -- todo, remove

	fr.tabs:AddTab('Настройки', function(self)
		return ui.Create 'rp_settings'
	end):SetIcon 'sup/gui/f4/f4_settings.png'

	local csTab
	local cs = fr.tabs:AddTab('Донат', function(self)
		csTab = ui.Create 'rp_creditshop_panel'
		return csTab
	end)
	cs:SetIcon 'sup/hud/superior.png'
	cs.TextColor = ui.col.Gold

	if (not openCs) then -- hack
		fr.tabs:SetActiveTab(id)
	else
		fr.tabs:SetActiveTab(8)
	end

	if IsValid(csTab) then
		csTab:AddControls(fr)
	end

	//if IsValid(hatTab) then
	//	hatTab:AddControls(fr)
	//end

	function fr.tabs:TabChanged(tab)
		if IsValid(fr) then
			if IsValid(csTab) then
				if (tab ~= csTab) then
					csTab:HideControls()
				else
					csTab:AddControls(fr)
				end
			end

		//	if IsValid(hatTab) then
			//	if (tab ~= hatTab) then
			//		hatTab:HideControls()
			//	else
			//		hatTab:AddControls(fr)
			//	end
			//end

			hook.Call('F4TabChanged', nil, tab)
		end
	end
end

function GM:ShowSpare2()
	rp.ToggleF4Menu()
end
