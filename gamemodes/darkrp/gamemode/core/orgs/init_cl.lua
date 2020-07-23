include('painter_cl.lua')

rp.orgs = rp.orgs or {}
rp.orgs.Banners = rp.orgs.Banners or {}

local head
local cont
local fr
net('rp.OrgsMenu', function()
	if (not IsValid(cont)) then return end
	cont:Clear()
	local hasOrg = net.ReadBool() // Control variable. True for org menu, false for create org/list invites

	if (!hasOrg) then
		cont.IsLoaded = true

		local invScale = math.Clamp(ScrW() / 3840, 0.5, 1)
		local invFont = 'ui.' .. math.floor(invScale * 40)
		cont.InviteSection = ui.Create('ui_scrollpanel', cont)
		cont.InviteSection:SetPadding(-1)
		cont.InviteSection.Paint = function(s, w, h)
			draw.Outline(0, 0, w, h, ui.col.Outline)
		end
		cont.InviteSection:SetPos(0, 0)
		cont.InviteSection:SetSize(invScale * 516, cont:GetTall())
		cont.InviteSection:AddItem(ui.Create('DButton', function(s)
			s:SetText('Приглашения в банду')
			s:SetTall(30)
			s:SetDisabled(true)
		end))

		for i = 1, net.ReadUInt(4) do
			local id = net.ReadUInt(14)
			local name = net.ReadString()
			cont.InviteSection:AddItem(ui.Create('ui_panel', function(s)
				s:SetTall(invScale * 138)

				local nm = ui.Create('DLabel', function(lbl)
					lbl:SetText(name)
					lbl:SetFont(invFont)
					lbl:SizeToContents()
					lbl:SetPos(invScale * 128 + 5, 5)
				end, s)

				local banner = ui.Create('ui_panel', function(b)
					b:SetSize(s:GetTall() - 10, s:GetTall() - 10)
					b:SetPos(5, 5)
					b.Paint = function(b, w, h)
						local mat = rp.orgs.GetBanner(name)
						if (mat) then
							surface.SetMaterial(mat)
							surface.SetDrawColor(255, 255, 255)
							surface.DrawTexturedRect(0, 0, w, h)
						end
					end
				end, s)

				local btnWidth = (cont.InviteSection:GetWide() - banner:GetWide() - 20) * 0.5
				local rej = ui.Create('DButton', function(btn)
					btn.fontset = true
					btn:SetFont(invFont)
					btn:SetText("Отклонить")
					btn:SetSize(btnWidth, s:GetTall() - 15 - nm:GetTall())
					btn:SetPos(cont.InviteSection:GetWide() - btn:GetWide() - 5, s:GetTall() - btn:GetTall() - 5)
					btn.DoClick = function()
						s:Remove()
						net.Start('rp.OrgInviteResponse')
							net.WriteUInt(id, 14)
							net.WriteBool(false)
						net.SendToServer()
					end
				end, s)

				local acc = ui.Create('DButton', function(btn)
					btn.fontset = true
					btn:SetFont(invFont)
					btn:SetText("Принять")
					btn:SetSize(rej:GetSize())
					btn:SetPos(cont.InviteSection:GetWide() - btn:GetWide() - rej:GetWide() - 10, s:GetTall() - btn:GetTall() - 5)
					btn.DoClick = function()
						cont.InviteSection:Reset()
						net.Start('rp.OrgInviteResponse')
							net.WriteUInt(id, 14)
							net.WriteBool(true)
						net.SendToServer()
					end
				end, s)
			end))
		end

		cont.CreateSection = ui.Create('ui_scrollpanel', cont)
		cont.CreateSection:SetPadding(-1)
		cont.CreateSection.Paint = function(s, w, h)
			draw.Outline(0, 0, w, h, ui.col.Outline)
		end
		cont.CreateSection:SetPos(cont.InviteSection:GetWide() - 1, 0)
		cont.CreateSection:SetSize(cont:GetWide() - cont.InviteSection:GetWide() + 1, cont:GetTall())

		cont.CreateSection:AddItem(ui.Create('DButton', function(s)
			s:SetText('Создать новую банду')
			s:SetTall(30)
			s:SetDisabled(true)
		end))
		cont.CreateSection:AddItem(ui.Create('Panel', function(p) p:SetTall(3) end))


		local lines = string.Wrap('ui.24', [[За ]] .. rp.FormatMoney(rp.cfg.OrgCost) .. [[, вы можете создать свою банду, которая будер развиваться на нашем сервере.

Нахождение в банде даёт вам ряд преимуществ. Развивайтесь вместе со своей РП бандой, покажите другим, насколько вы круты, используя своё лого банды, помогайте друг другу используя общий банк, или же рейдите базы других банд.

Используйте красочное MoTD и проработанную систему рангов чтобы обозначить значимость участников банды. С лёгкостью приглашайте, повышайте, или выгоняйте игроков. Логи действий помогут вам отслеживать каждое действие в банде.

После создания, банда может быть улучшена за специальное улучшение, которое повысит её возможности.

Выбирайте имя с умом, переименование стоит ]] .. rp.FormatMoney(rp.cfg.OrgRenameCost) .. [[!]], cont.CreateSection:GetWide() * 0.85)

		for k, v in ipairs(lines) do
			cont.CreateSection:AddItem(ui.Create('DLabel', function(l)
				l:SetText(v)
				l:SetFont('ui.24')
				l:SetContentAlignment(5)
				l:SetTall(27)
			end))
		end

		local create = ui.Create('DButton', function(s)
			s:SetText('Create!')
			s:SetSize(cont.CreateSection:GetWide() - 10, 30)
			s:SetPos(5, cont.CreateSection:GetTall() - 35)
			s.DoClick = function()
				ui.StringRequest('Создать Банду', 'Вы не состоите в банде. Желаете создать свою за ' .. rp.FormatMoney(rp.cfg.OrgCost) .. '?\n Введите название банды для продолжения.', '', function(resp)
					cmd.Run('createorg', resp)
					head:Close()
				end)
			end
		end, cont.CreateSection)

		return
	end

	local w, h = ScrW() * 0.55, ScrH() * 0.525

	local orgdata   = LocalPlayer():GetOrgData()
	if (!orgdata) then
		rp.Notify(NOTIFY_ERROR, 'Неизвестная ошибка.')
	end

	local rank      = orgdata.Rank
	local motd      = orgdata.MoTD
	local perms     = orgdata.Perms

	fr = ui.Create('DPanel', function(s)
		s:SetPos(5, 5)
		s:SetSize(cont:GetWide() - 10, cont:GetTall() - 10)
		s.Paint = function() end
	end, cont)

	local orgmembers = {}
	local orgranks = {}
	local orgrankref = {}
	local onlinecount = 0

	local upgraded = net.ReadBool()

	for i = 1, net.ReadUInt(5) do
		local rankname  = net.ReadString()
		local weight    = net.ReadUInt(7)
		local invite    = net.ReadBool()
		local kick		= net.ReadBool()
		local rank		= net.ReadBool()
		local motd		= net.ReadBool()
		local banner    = net.ReadBool()
		local withdraw  = net.ReadBool()
		orgranks[#orgranks + 1] = {
			Name     = rankname,
			Weight   = weight,
			Invite   = invite,
			Kick     = kick,
			Rank     = rank,
			MoTD     = motd,
			Banner   = banner,
			Withdraw = withdraw
		}
		orgrankref[rankname] = orgranks[#orgranks]
	end
	table.SortByMember(orgranks, 'Weight')

	for i = 1, net.ReadUInt(8) do
		local steamid   = net.ReadString()
		local name      = net.ReadString()
		local rank      = net.ReadString()
		local isOnline	= net.ReadBool()
		local lastConnect = (!isOnline and net.ReadUInt(32) or os.time())
		if (lastConnect == os.time()) then lastConnect = 0 end

		if (!orgrankref[rank]) then
			print("Забаганный участник: " .. steamid .. " ранг " .. rank .. " не существует! Ранг был изменён на самый низкий")
			rank = orgranks[#orgranks].Name
		end

		if isOnline then
			onlinecount = onlinecount + 1
		end

		local weight = orgrankref[rank].Weight
		orgmembers[#orgmembers + 1] = {
			SteamID 	= steamid,
			Name    	= name,
			Rank    	= rank,
			Weight		= weight,
			IsOnline	= isOnline,
			LastConnect = lastConnect
		}
	end

	local funds = net.ReadUInt(32)

	cont.IsLoaded = true

	--------------------------------------------
	-- Patented quit button
	--------------------------------------------
	fr.AddControls = function()
		if IsValid(fr.btnQuit) then
			fr.btnQuit:Show()
			fr.lblTitle:Show()
			fr.btnLog:Show()
			fr.btnBank:Show()
			fr.btnUpgraded:Show()
			return
		end

		fr.btnQuit = ui.Create('DButton', function(self)
			self:SetText(perms.Owner and 'Распустить' or 'Покинуть')
			self:SizeToContents()
			self:SetSize(self:GetWide() + 10, head.btnClose:GetTall())
			self:SetPos(head.btnClose.x - self:GetWide() + 1, 0)

			self.DoClick = function(s)
				local str = perms.Owner and 'Распустить Банду?' or 'Выйти из Банды?'
				local str2 = perms.Owner and 'Вы уверены, что хотите распустить ' .. LocalPlayer():GetOrg() .. '?\nВведите РАСПУСТИТЬ чтобы продолжить.' or 'Вы уверены, что хотите покинуть организацию ' .. LocalPlayer():GetOrg() .. '?\nВведите ВЫХОД для продолжения.'

				ui.StringRequest(str, str2, '', function(resp)
					local ismatch = (perms.Owner and resp:lower() == 'распустить') or (!perms.Owner and resp:lower() == 'выход')

					if (ismatch) then
						head:Close()
						net.Ping('rp.QuitOrg')
					end
				end)
			end
		end, head)

		fr.lblTitle = (not perms.Owner) and fr.btnQuit or ui.Create('DButton', function(self)
			self:SetPos(0, 0)
			self:SetText('Переименовать')
			self:SizeToContents()
			self:SetSize(self:GetWide() + 10, head.btnClose:GetTall())
			self:SetPos(fr.btnQuit.x - self:GetWide() + 1, 0)
		end, head)

		fr.btnLog = ui.Create("DButton", function(self)
			self:SetText("Логи")
			self:SizeToContents()
			self:SetSize(self:GetWide() + 10, head.btnClose:GetTall())
			self:SetPos(fr.lblTitle.x - self:GetWide() + 1, 0)

			self.DoClick = function(s)
				cmd.Run('orglog')
			end
		end, head)

		/*fr.btnDupes = ui.Create("DButton", function(self)
			self:SetText("Saved Dupes")
			self:SizeToContents()
			self:SetSize(self:GetWide() + 10, head.btnClose:GetTall())
			self:SetPos(fr.btnLog.x - self:GetWide() + 1, 0)

			self.DoClick = function(s)
				cmd.Run('orgdupes')
			end
		end, head)*/

		fr.btnBank = ui.Create('DButton', function(self)
			self:SetText("Банк: " .. rp.FormatMoney(funds))
			self:SizeToContents()
			self:SetSize(self:GetWide() + 10, head.btnClose:GetTall())
			self:SetPos(fr.btnLog.x - self:GetWide() + 1, 0)

			self.DoClick = function(s)
				local canWithdraw = LocalPlayer():GetNetVar('OrgData').Perms.Withdraw

				fr.CreateBankWindow(canWithdraw)
			end
		end, head)

		fr.btnUpgraded = ui.Create('DButton', function(self)
			self:SetText(upgraded and "★ Премиум" or "Стандартная Банда")
			if (upgraded) then
				self.TextColor = rp.col.Yellow
			end
			self:SizeToContents()
			self:SetSize(self:GetWide() + 10, head.btnClose:GetTall())
			self:SetPos(fr.btnBank.x - self:GetWide() + 1, 0)
			self:SetDisabled(true)
		end, head)
	end

	function fr.HideControls()
		fr.btnQuit:Hide()
		fr.lblTitle:Hide()
		fr.btnLog:Hide()
		fr.btnBank:Hide()
		fr.btnUpgraded:Hide()
	end

	fr.AddControls()

	fr.CreateBankWindow = function(canWithdraw)
		fr:SetMouseInputEnabled(false)

		local overFrame = ui.Create('Panel', function(self)
			self.Paint = function(s, w, h) surface.SetDrawColor(0, 0, 0, 240) surface.DrawRect(0, 0, w, h) end
			self:SetSize(fr:GetWide(), fr:GetTall())
		end, fr)

		local overOver = ui.Create('ui_frame', function(self)
			self:SetTitle('Bank: ' .. rp.FormatMoney(funds))
			self:SetSize(300, 139)
			self:Center()
			self:SetDraggable(false)

			local numLbl = ui.Create('DLabel', function(numLbl)
				numLbl:SetText('Amount')
				numLbl:SetFont('ui.24')
				numLbl:SizeToContents()
				numLbl:SetPos(5, 29)
			end, self)

			local numIn = ui.Create('DTextEntry', function(numIn)
				numIn:DockMargin(0, 2, 0, 0)
				numIn:SetFont('ui.22')
				numIn:SetSize(self:GetWide() - 10, 26)
				numIn:SetPos(5, 56)
			end, self)

			local warnLbl = ui.Create('DLabel', function(warnLbl)
				warnLbl:SetText('Налог на пополнений ' .. rp.cfg.OrgBankTax * 100 .. '%' .. (upgraded and '' or (', Ваш лимит ' .. rp.FormatMoney(rp.cfg.OrgBasicBankMax) .. '')))
				warnLbl:SetFont('ui.17')
				warnLbl:SizeToContents()
				warnLbl:SetPos(5, 84)
				warnLbl:SetTextColor(rp.col.Red)
			end, self)

			local amt
			local btnD = ui.Create('DButton', function(btnD)
				btnD:SetText('Пополнить')
				btnD:SetSize(143, 30)
				btnD:SetPos(5, 104)
				btnD.DoClick = function(btnD)
					funds = math.floor(funds + amt * (1 - rp.cfg.OrgBankTax))
					self.btnClose:DoClick()

					net.Start("rp.OrgBankDeposit")
						net.WriteUInt(amt, 32)
					net.SendToServer()
				end
			end, self)

			local btnW = ui.Create('DButton', function(btnW)
				btnW:SetText('Снять')
				btnW:SetSize(143, 30)
				btnW:SetPos(152, 104)
				btnW.DoClick = function(btnW)
					funds = funds - amt
					self.btnClose:DoClick()

					net.Start("rp.OrgBankWithdraw")
						net.WriteUInt(amt, 32)
					net.SendToServer()
				end
			end, self)

			self.btnClose.DoClick = function()
				fr.btnBank:SetText("Банк: " .. rp.FormatMoney(funds))
				overFrame:Remove()
				fr:SetMouseInputEnabled(true)
				self:Remove()
			end

			local onThink = function()
				if (not IsValid(overFrame)) then
					self:Close()
				end

				if (!tonumber(numIn:GetValue())) then
					btnW:SetDisabled(true)
					btnD:SetDisabled(true)
				else
					amt = tonumber(numIn:GetValue())
					if (amt <= 0) then
						btnW:SetDisabled(true)
						btnD:SetDisabled(true)
						return
					end

					if (!canWithdraw) then
						btnW:SetDisabled(true)
					else
						if (amt > funds) then
							btnW:SetDisabled(true)
						else
							btnW:SetDisabled(false)
						end
					end

					if (amt > LocalPlayer():GetMoney()) then
						btnD:SetDisabled(true)
					elseif (!upgraded and amt + funds > rp.cfg.OrgBasicBankMax) then
						btnD:SetDisabled(true)
					else
						btnD:SetDisabled(false)
					end
				end
			end

			self.Think = onThink

			self:MakePopup()
			self:MoveToFront()
			numIn:RequestFocus()
		end)
	end

	--------------------------------------------
	-- Left Column: Members
	--------------------------------------------
	fr.colLeft = ui.Create('Panel', function(self)
		self:SetWide(w / 3)
		self:Dock(LEFT)
	end, fr)

	fr.lblMem = ui.Create('DButton', function(self)
		self:SetText('Участники Онлайн: ' .. onlinecount .. '/' .. #orgmembers)
		self:SetTall(30)
		self:SetDisabled(true)
		self:DockMargin(0, 0, 0, -1)
		self:Dock(TOP)
	end, fr.colLeft)

	fr.listMem = ui.Create('ui_listview', function(self)
		self:Dock(FILL)
	end, fr.colLeft)

	--------------------------------------------
	-- Middle Column: Flag, Ranks
	--------------------------------------------
	fr.colMid = ui.Create('Panel', function(self)
		self:SetWide(128)
		self:DockMargin(5, 0, 5, 0)
		self:Dock(LEFT)
	end, fr)

	fr.lblFlag = ui.Create('DButton', function(self)
		self:SetText("Лого")
		self:SetTall(30)
		self:SetDisabled(true)
		self:Dock(TOP)
	end, fr.colMid)

	fr.pnlFlag = ui.Create('Button', function(self)
		self:SetText('')
		self:SetTall(128)
		self:Dock(TOP)

		self.Paint = function(s, w, h)
			surface.SetDrawColor(rp.col.Outline)
			surface.DrawOutlinedRect(0, 0, w, h)

			if (!LocalPlayer():GetOrg()) then return true end

			local mat = rp.orgs.GetBanner(LocalPlayer():GetOrg())
			if (mat) then
				surface.SetMaterial(mat)
				surface.SetDrawColor(255, 255, 255)
				surface.DrawTexturedRect(0, 0, w, h)
			end

			if (self.DrawLoading) then
				surface.SetDrawColor(0, 0, 0, 200)
				surface.DrawRect(0, 0, w, h)
				local t = SysTime() * 5
				draw.NoTexture()
				surface.SetDrawColor(255, 255, 255)
				surface.DrawArc(w*0.5, h*0.5, 20, 25, t*80, t*80+180, 20)
			end

			return true
		end

		self.DoClick = function(s)
			rp.orgs.OpenOrgBannerEditor(self, perms, upgraded)
		end
	end, fr.colMid)

	fr.lblRanks = ui.Create('DButton', function(self)
		self:SetText("Ранги")
		self:SetTall(30)
		self:SetDisabled(true)
		self:DockMargin(0, 5, 0, -1)
		self:Dock(TOP)

	end, fr.colMid)

	fr.listRank = ui.Create('ui_listview', function(self)
		self:Dock(FILL)
		self:SetSpacing(-1)
		self:SetPadding(0)
	end, fr.colMid)

	--------------------------------------------
	-- Right Column: MOTD, Color
	--------------------------------------------
	fr.colRight = ui.Create('Panel', function(self)
		self:Dock(FILL)
	end, fr)

	fr.lblMoTD = ui.Create('DButton', function(self)
		self:SetText('MOTD')
		self:SetTall(30)
		self:SetDisabled(true)
		self:Dock(TOP)
	end, fr.colRight)

	if (!upgraded) then
		fr.txtMoTD = ui.Create('ui_scrollpanel', function(self)
			self:Dock(FILL)
			self:SetPadding(3)

			self.Paint = function(s, w, h)
				surface.SetDrawColor(200, 200, 200)
				surface.DrawRect(0, 0, w, h)
			end
		end, fr.colRight)
	else
		fr.txtMoTD = ui.Create('HTML', function(self)
			self:Dock(FILL)
		end, fr.colRight)
	end

	--------------------------------------------
	-- Begin Data Population
	--------------------------------------------
	local function timeAgo(time)
		if (time == 0) then
			return 'очень давно'
		elseif (time < 3600) then
			return 'меньше часа назад'
		elseif (time < 172800) then
			return math.floor(time / 3600) .. ' ч. назад'
		else
			return math.floor(time / 86400) .. ' д. назад'
		end
	end

	fr.PopulateMembers = function(tosel)
		table.SortByMember(orgmembers, 'Weight')
		fr.listMem:Reset(true)

		local lastRank = ''
		local cats = {}
		for k, v in ipairs(orgmembers) do
			if (v.Rank != lastRank) then
				cats[#cats+1] = {Name = v.Rank, Members = {}}
				lastRank = v.Rank
			end

			table.insert(cats[#cats].Members, v)
		end

		for k, v in ipairs(cats) do
			fr.listMem:AddSpacer(v.Name):SetTall(30)
			table.SortByMember(v.Members, 'Name', true)

			for k, v in ipairs(v.Members) do
				local btn = fr.listMem:AddPlayer(v.Name, v.SteamID)
				btn:SetContentAlignment(4)
				btn:SetTextInset(32, 0)

				btn.Player = v

				if (v.IsOnline) then
					btn.PaintOver = function(self, w, h)
						draw.OutlinedBox(w - 30, 0, 30, h, LocalPlayer():GetOrgColor(), ui.col.Outline)
					end
				else
					btn.lblLastSeen1 = ui.Create("DLabel", function(self)
						self:SetFont('ui.12')
						self:SetText('Последний Онлайн:')
						self:SizeToContents()
						self.Think = function(s)
							s:SetPos(btn:GetWide() - s:GetWide() - 4, 2)
						end
					end, btn)
					btn.lblLastSeen2 = ui.Create("DLabel", function(self)
						self:SetFont('ui.12')
						self:SetText(timeAgo(v.LastConnect))
						self:SizeToContents()
						self.Think = function(s)
							s:SetPos(btn:GetWide() - s:GetWide() - 4, btn:GetTall() - s:GetTall() - 2)
						end
					end, btn)
				end

				if (tosel == v.SteamID) then
					btn:DoClick()
				end
			end
		end
	end
	fr.PopulateMembers()

	fr.ReorderRanks = function()
		local sel = fr.listRank:GetSelected()
		local rank = sel and sel.Rank and sel.Rank.Name or nil

		table.SortByMember(orgranks, 'Weight')

		for k, v in ipairs(orgranks) do
			local k = #orgranks - (k - 1)
			local newWeight = 1 + math.floor(((k - 1) / (#orgranks - 1)) * 99)
			v.Weight = newWeight
		end

		fr.PopulateRanks(rank)
	end

	fr.PopulateRanks = function(tosel)
		fr.listRank:Reset(true)

		for k, v in ipairs(orgranks) do
			local btn = fr.listRank:AddRow(v.Name)
			btn.Rank = v
			v.Btn = btn
			v.Number = k

			if (v.Name == tosel) then
				btn:DoClick()
			end
		end

		for k, v in ipairs(fr.listRank:GetChildren()) do
			local x, y = v.x, v.y
			local w, h = v:GetSize()

			v:Dock(NODOCK)
			v:SetPos(x, y)
			v:SetSize(w, h)
		end
	end
	fr.PopulateRanks()

	fr.PopulateMoTD = function(m)
		m = m or motd

		if (!upgraded) then
			fr.txtMoTD:Reset(true)

			local motdRows = string.Wrap('ui.22', motd.Text, w - 30 - fr.colLeft:GetWide() - fr.colMid:GetWide())
			for k, v in pairs(motdRows) do
				local lbl = ui.Create('DLabel', function(self)
					self:SetText(v)
					self:SizeToContents()
					self:SetWide(w - 15 - fr.colLeft:GetWide() - fr.colMid:GetWide())
					self:SetTextColor(rp.col.Black)
					fr.txtMoTD:AddItem(self)
				end)
			end
		else
			md = '<head><style type="text/css">'.. (m.Dark and rp.orgs.MDStyleDark or rp.orgs.MDStyleLight) ..'</style></head><body class="markdown-body">' .. rp.orgs.ParseMarkdown(m.Text) .. "</body>"
			fr.txtMoTD:SetHTML(md)
		end
	end
	fr.PopulateMoTD()

	--------------------------------------------
	-- Admin stuff!
	--------------------------------------------
	if (perms.Owner) then
		fr.lblTitle.DoClick = function(self, mb)
			if (!LocalPlayer():CanAfford(rp.cfg.OrgRenameCost)) then
				rp.Notify(NOTIFY_ERROR, term.GetString(term.Get("CannotAfford")))
				return
			end

			local askWindow, attemptRename, lastRequestedName

			askWindow = function(err)
				err = err and err .. "\n\n" or ""

				ui.StringRequest('Переименовать ' .. LocalPlayer():GetOrg(), err .. 'Хотите сменить имя вашей банды?\nЭто будет стоить ' .. rp.FormatMoney(rp.cfg.OrgRenameCost) .. ".", LocalPlayer():GetOrg(), function(resp)
					attemptRename(resp)
				end)
			end

			attemptRename = function(name)
				name = string.Trim(name)
				lastRequestedName = name

				if (name == LocalPlayer():GetOrg()) then
					askWindow("Это текущее имя вашей банды.")
					return
				end

				net.Start("rp.SetOrgName")
					net.WriteString(name)
				net.SendToServer()
			end

			askWindow()

			net("rp.SetOrgNameResponse", function(len)
				if (!IsValid(fr)) then return end

				local success = net.ReadBool()
				local msg = net.ReadTerm()

				if (!success) then
					askWindow(msg)
				else
					fr.lblTitle:SetText(lastRequestedName)
				end

				rp.Notify(NOTIFY_GENERIC, msg)
			end)
		end


		fr.btnCol = ui.Create('DButton', function(self)
			self:SetText("Изменить Цвет")
			self:SetTall(25)
			self:DockMargin(0, 5, 0, 0)
			self:Dock(BOTTOM)

			self.Think = function(s)
				s:SetDisabled(IsValid(fr.overMoTD))
			end

			self.DoClick = function(s)
				if (IsValid(fr.colPicker)) then
					local color = fr.colPicker:GetColor()
					if (color != LocalPlayer():GetOrgColor()) then
						net.Start('rp.SetOrgColor')
							net.WriteRGB(color.r, color.g, color.b)
						net.SendToServer()
					end

					fr.colPicker:Remove()
					fr.lblMoTD:SetText('MOTD')
					s:SetText('Изменить Цвет')
				else
					fr.colPicker = ui.Create('DColorMixer', function(col)
						col:SetPos(fr.txtMoTD.x, fr.lblMoTD:GetTall())
						col:SetSize(fr.txtMoTD:GetSize())
						col:SetColor(LocalPlayer():GetOrgColor())
						col:SetAlphaBar(false)

						col.OP = col.Paint
						col.Paint = function(s, w, h)
							surface.SetDrawColor(rp.col.Black)
							surface.DrawRect(0, 0, w, h)
							s:OP(w, h)
						end

					end, fr.colRight)

					fr.lblMoTD:SetText('Выберите новый цвет')
					s:SetText("Подтвердить Цвет")
				end
			end
		end, fr.colRight)

		fr.btnNewRank = ui.Create('DButton', function(self)
			self:SetText("Новый Ранг")
			self:SetTall(25)
			self:DockMargin(0, 5, 0, 0)
			self:Dock(BOTTOM)

			self.Think = function(s)
				s:SetDisabled(IsValid(fr.overRankEdit) or (#orgranks >= (upgraded and rp.cfg.OrgMaxRanksPremium or rp.cfg.OrgMaxRanks)))
			end

			self.DoClick = function(s)
				if (IsValid(fr.overRankNew)) then
					fr.overRankNew:Remove()
					s:SetText("Новый Ранг")
				else
					fr.overRankNew = ui.Create('ui_scrollpanel', function(scr)
						scr:SetPos(fr.listRank.x, fr.lblFlag:GetTall() + fr.pnlFlag:GetTall() + fr.lblRanks:GetTall())
						scr:SetSize(fr.listRank:GetSize())
						scr.Paint = function(s, w, h)
							surface.SetDrawColor(200, 200, 200)
							surface.DrawRect(0, 0, w, h)
						end
					end, fr.colMid)

					local txtName = ui.Create('DButton', function(txt)
						txt:SetTall(25)
						txt:SetFont('ui.22')
						txt:SetText('Введите Имя')
						txt:Dock(TOP)

						txt.DoClick = function(s, err)
							ui.StringRequest('Rank Name', (err or '') .. ' What would you like to name this rank?', '', function(resp)
								resp = string.Trim(resp or '')
								if (utf8.len(resp) == 0) then
									s:DoClick(term.GetString(term.Get('OrgRankNameLength')))
								elseif (orgrankref[resp] != nil) then
									s:DoClick(term.GetString(term.Get('OrgRankNameTaken')))
								else
									s:SetText(resp)
								end
							end)
						end

						fr.overRankNew:AddItem(txt)
					end)

					local chkInvite = ui.Create('DCheckBoxLabel', function(chk)
						chk:SetText("Может Приглашать")
						chk:SetTextColor(rp.col.Black)
						chk:Dock(TOP)

						fr.overRankNew:AddItem(chk)
					end)

					local chkKick = ui.Create('DCheckBoxLabel', function(chk)
						chk:SetText("Может Кикать")
						chk:SetTextColor(rp.col.Black)
						chk:Dock(TOP)

						fr.overRankNew:AddItem(chk)
					end)

					local chkRank = ui.Create('DCheckBoxLabel', function(chk)
						chk:SetText("Может Изменять Ранг")
						chk:SetTextColor(rp.col.Black)
						chk:Dock(TOP)

						fr.overRankNew:AddItem(chk)
					end)

					local chkMOTD = ui.Create('DCheckBoxLabel', function(chk)
						chk:SetText("Может Менять MOTD")
						chk:SetTextColor(rp.col.Black)
						chk:Dock(TOP)

						fr.overRankNew:AddItem(chk)
					end)

					local chkBanner = ui.Create('DCheckBoxLabel', function(chk)
						chk:SetText("Может Менять Лого")
						chk:SetTextColor(rp.col.Black)
						chk:Dock(TOP)

						if (upgraded) then
							fr.overRankNew:AddItem(chk)
						end
					end)

					local chkWithdraw = ui.Create('DCheckBoxLabel', function(chk)
						chk:SetText("Может Снимать Деньги")
						chk:SetTextColor(rp.col.Black)
						chk:Dock(TOP)

						fr.overRankNew:AddItem(chk)
					end)

					local btnSubmit = ui.Create('DButton', function(btn)
						btn:SetTall(25)
						btn:SetText("Подтвердить")
						btn.TextColor = rp.col.Green
						btn:Dock(TOP)

						btn.DoClick = function(s)
							local name = txtName:GetText()
							local weight = 2
							local invite = chkInvite:GetChecked()
							local kick = chkKick:GetChecked()
							local canrank = chkRank:GetChecked()
							local motd = chkMOTD:GetChecked()
							local banner = chkBanner and chkBanner:GetChecked() or false
							local withdraw = chkWithdraw:GetChecked()

							net.Start("rp.AddEditOrgRank")
								net.WriteBool(true)
								net.WriteString(name)
								net.WriteUInt(weight, 7)
								net.WriteBit(invite)
								net.WriteBit(kick)
								net.WriteBit(canrank)
								net.WriteBit(motd)
								net.WriteBit(banner)
								net.WriteBit(withdraw)
							net.SendToServer()

							if (#orgranks < (upgraded and rp.cfg.OrgMaxRanksPremium or rp.cfg.OrgMaxRanks)) then
								orgrankref[name] = orgranks[table.insert(orgranks, {Name = name, Weight = weight, Invite = invite, Kick = kick, Rank = canrank, MoTD = motd, Banner = banner, Withdraw = withdraw})]
							end

							fr.btnNewRank:DoClick()
							fr.ReorderRanks()
						end

						fr.overRankNew:AddItem(btn)
					end)

					txtName:DoClick()
					s:SetText("Отмена")
				end
			end
		end, fr.colMid)

		fr.btnEditRank = ui.Create('DButton', function(self)
			self:SetText("Изменить Ранг")
			self:SetTall(25)
			self:DockMargin(0, 5, 0, 0)
			self:Dock(BOTTOM)

			self.Think = function(s)
				s:SetDisabled(IsValid(fr.overRankNew) or !fr.listRank:GetSelected() or (IsValid(fr.overRankEdit) and fr.overRankEdit:GetAlpha() != 255))
			end

			self.DoClick = function(s, ignore)
				if (IsValid(fr.overRankEdit)) then
					if (!ignore) then
						local rank = fr.listRank:GetSelected().Rank

						local invite = fr.overRankEdit.chkInvite:GetChecked()
						local kick = fr.overRankEdit.chkKick:GetChecked()
						local canrank = fr.overRankEdit.chkRank:GetChecked()
						local motd = fr.overRankEdit.chkMOTD:GetChecked()
						local banner = fr.overRankEdit.chkBanner and fr.overRankEdit.chkBanner:GetChecked() or false
						local withdraw = fr.overRankEdit.chkWithdraw:GetChecked()

						if (invite != rank.Invite or kick != rank.Kick or canrank != rank.Kick or motd != rank.MoTD or banner != rank.Banner or withdraw != rank.Withdraw) then
							rank.Invite = invite
							rank.Kick = kick
							rank.Rank = canrank
							rank.MoTD = motd
							rank.Banner = banner
							rank.Withdraw = withdraw

							net.Start("rp.AddEditOrgRank")
								net.WriteBool(false)
								net.WriteString(rank.Name)
								net.WriteUInt(rank.Weight, 7)
								net.WriteBit(rank.Invite)
								net.WriteBit(rank.Kick)
								net.WriteBit(rank.Rank)
								net.WriteBit(rank.MoTD)
								net.WriteBit(rank.Banner)
								net.WriteBit(rank.Withdraw)
							net.SendToServer()
						end
					end

					fr.overRankEdit:Remove()
					s:SetText("Изменить Ранг")
					fr.lblRanks:SetText('Ранги')
				else
					local rank = fr.listRank:GetSelected().Rank

					fr.overRankEdit = ui.Create('ui_scrollpanel', function(scr)
						scr:SetPos(fr.listRank.x, fr.listRank.y)
						scr:SetSize(fr.listRank:GetSize())
						scr.Paint = function(s, w, h)
							surface.SetDrawColor(200, 200, 200)
							surface.DrawRect(0, 0, w, h)
						end
						scr.FadeTo = 255
						scr.Think = function(s)
							if (s:GetAlpha() != s.FadeTo) then
								local a = s:GetAlpha()
								local mul = a > s.FadeTo and -1 or 1
								s:SetAlpha(math.Clamp(a + (FrameTime() * mul * 1000), mul == 1 and 0 or s.FadeTo, 255))
							end
						end
					end, fr.colMid)

					local btnName = ui.Create('DButton', function(btn)
						btn:SetText('Переименовать')
						btn:SetTall(25)
						btn:Dock(TOP)

						btn.DoClick = function(s)
							ui.StringRequest('Переименовать Ранг', 'Как вы хотите назвать ' .. rank.Name .. '?', '', function(resp)
								if (!orgrankref[resp]) then
									net.Start("rp.RenameOrgRank")
										net.WriteString(rank.Name)
										net.WriteString(resp)
									net.SendToServer()

									fr.listRank:GetSelected():SetText(resp)
									fr.lblRanks:SetText('Изменение ' .. resp)

									for k, v in ipairs(orgmembers) do if (v.Rank == rank.Name) then v.Rank = resp end end
									rank.Name = resp
									fr.PopulateMembers()
									fr.PopulateRanks(resp)
								end
							end)
						end

						fr.overRankEdit:AddItem(btn)
					end)

					local pnlMoveBtns = ui.Create('Panel', function(pnl)
						pnl:SetTall(25)
						pnl:Dock(TOP)
						fr.overRankEdit:AddItem(pnl)
					end)

					local moveRank

					local btnMoveUp = ui.Create('DButton', function(btn)
						btn:SetSize(pnlMoveBtns:GetWide() * 0.5, 25)
						btn:SetText('▲')
						btn.DoClick = function(s)
							moveRank(-1)
						end
						if (rank.Number <= 2) then
							btn:SetDisabled(true)
						end
					end, pnlMoveBtns)

					local btnMoveDown = ui.Create('DButton', function(btn)
						btn:SetSize(pnlMoveBtns:GetWide() * 0.5, 25)
						btn:SetPos(btnMoveUp:GetWide(), 0)
						btn:SetText('▼')
						btn.DoClick = function(s)
							moveRank(1)
						end
						if (rank.Number >= #orgranks - 1) then
							btn:SetDisabled(true)
						end
					end, pnlMoveBtns)

					moveRank = function(dir)
						if (rank.Number == 1 or rank.Number == #orgranks) then return end

						local targRank = rank.Number + dir
						if (targRank == 1 or targRank == #orgranks) then return end

						if (targRank >= #orgranks - 1) then
							btnMoveDown:SetDisabled(true)
						else
							btnMoveDown:SetDisabled(false)
						end

						if (targRank <= 2) then
							btnMoveUp:SetDisabled(true)
						else
							btnMoveUp:SetDisabled(false)
						end

						local swap1 = rank.Btn
						local swap2 = orgranks[targRank].Btn

						rank.Weight = orgranks[targRank].Weight + (dir * -1)
						for k, v in pairs(orgmembers) do
							if (v.Rank == rank.Name) then
								v.Weight = rank.Weight
							end
						end

						net.Start("rp.AddEditOrgRank")
							net.WriteBool(false)
							net.WriteString(rank.Name)
							net.WriteUInt(rank.Weight, 7)
							net.WriteBit(rank.Invite)
							net.WriteBit(rank.Kick)
							net.WriteBit(rank.Rank)
							net.WriteBit(rank.MoTD)
							net.WriteBit(rank.Banner)
							net.WriteBit(rank.Withdraw)
						net.SendToServer()

						fr.listRank:SetMouseInputEnabled(false)
						fr.overRankEdit:SetMouseInputEnabled(false)
						fr.overRankEdit.FadeTo = 0
						timer.Simple(0.4, function()
							local x1, y1 = swap1.x, swap1.y
							local x2, y2 = swap2.x, swap2.y

							swap1:MoveTo(x2, y2, 0.5, 0, -1)
							swap2:MoveTo(x1, y1, 0.5, 0, -1, function()
								timer.Simple(0.25, function()
									fr.ReorderRanks()
									fr.PopulateMembers()
									fr.overRankEdit.FadeTo = 255
									fr.overRankEdit:SetMouseInputEnabled(true)
									fr.listRank:SetMouseInputEnabled(true)
								end)
							end)
						end)
					end

					if (rank.Weight == 1 or rank.Weight == 100) then
						btnMoveUp:SetDisabled(true)
						btnMoveDown:SetDisabled(true)
					end

					local btnMove = ui.Create('DButton', function(btn)
						btn:SetText('Set Below')
						btn:SetTall(25)
						btn:Dock(TOP)

						btn.DoClick = function(s)
							local m = ui.DermaMenu()

							for k, v in ipairs(orgranks) do
								if (v.Weight == 1 or v.Name == rank.Name) then continue end

								m:AddOption(v.Name, function()
									rank.Weight = v.Weight-1

									net.Start("rp.AddEditOrgRank")
										net.WriteBool(false)
										net.WriteString(rank.Name)
										net.WriteUInt(rank.Weight, 7)
										net.WriteBit(rank.Invite)
										net.WriteBit(rank.Kick)
										net.WriteBit(rank.Rank)
										net.WriteBit(rank.MoTD)
										net.WriteBit(rank.Banner)
										net.WriteBit(rank.Withdraw)
									net.SendToServer()

									fr.ReorderRanks()
								end)
							end

							m:Open()
						end

						fr.overRankEdit:AddItem(btn)
						if (rank.Weight == 1 or rank.Weight == 100) then
							btn:SetMouseInputEnabled(false)
						end
					end)

					fr.overRankEdit.chkInvite = ui.Create('DCheckBoxLabel', function(chk)
						chk:SetText("Может Приглашать")
						chk:SetTextColor(rp.col.Black)
						chk:SetChecked(rank.Invite)

						fr.overRankEdit:AddItem(chk)
						if (rank.Weight == 100) then chk:SetMouseInputEnabled(false) end
					end)

					fr.overRankEdit.chkKick = ui.Create('DCheckBoxLabel', function(chk)
						chk:SetText("Может Кикать")
						chk:SetTextColor(rp.col.Black)
						chk:SetChecked(rank.Kick)

						fr.overRankEdit:AddItem(chk)
						if (rank.Weight == 100) then chk:SetMouseInputEnabled(false) end
					end)

					fr.overRankEdit.chkRank = ui.Create('DCheckBoxLabel', function(chk)
						chk:SetText("Может Менять Ранг")
						chk:SetTextColor(rp.col.Black)
						chk:SetChecked(rank.Rank)

						fr.overRankEdit:AddItem(chk)
						if (rank.Weight == 100) then chk:SetMouseInputEnabled(false) end
					end)

					fr.overRankEdit.chkMOTD = ui.Create('DCheckBoxLabel', function(chk)
						chk:SetText("Может Менять MOTD")
						chk:SetTextColor(rp.col.Black)
						chk:SetChecked(rank.MoTD)

						fr.overRankEdit:AddItem(chk)
						if (rank.Weight == 100) then chk:SetMouseInputEnabled(false) end
					end)

					if (upgraded) then
						fr.overRankEdit.chkBanner = ui.Create('DCheckBoxLabel', function(chk)
							chk:SetText("Может Менять Лого")
							chk:SetTextColor(rp.col.Black)
							chk:SetChecked(rank.Banner)

							fr.overRankEdit:AddItem(chk)
							if (rank.Weight == 100) then chk:SetMouseInputEnabled(false) end
						end)
					end

					fr.overRankEdit.chkWithdraw = ui.Create('DCheckBoxLabel', function(chk)
						chk:SetText("Может Снимать Деньги")
						chk:SetTextColor(rp.col.Black)
						chk:SetChecked(rank.Withdraw)

						fr.overRankEdit:AddItem(chk)
						if (rank.Weight == 100) then chk:SetMouseInputEnabled(false) end
					end)

					ui.Create('DButton', function(btn)
						btn:SetText('Удалить')
						btn:SetTall(25)

						btn.Think = function(s)
							if (s.CoolDown and SysTime() > s.CoolDown + 2) then
								s:SetText("Удалить")
								s.CoolDown = nil;
							end
						end

						btn.DoClick = function(s)
							if (!s.CoolDown) then
								s.CoolDown = SysTime()
								s:SetText("Нажмите Ещё Раз")
							else
								net.Start('rp.RemoveOrgRank')
									net.WriteString(rank.Name)
								net.SendToServer()
								fr.listRank:GetSelected():Remove()
								fr.btnEditRank:DoClick(true)

								orgrankref[rank.Name] = nil
								local nextRank
								local rn = rank.Name
								for k, v in ipairs(orgranks) do
									if (v.Name == rank.Name) then
										nextRank = orgranks[k+1]
										table.remove(orgranks, k)
										break
									end
								end
								for k, v in ipairs(orgmembers) do
									if (v.Rank == rn) then
										v.Rank = nextRank.Name
									end
								end
								local sel = fr.listMem:GetSelected()
								fr.PopulateMembers(sel and sel.Player.SteamID or nil)
							end
						end

						btn.TextColor = rp.col.Red

						fr.overRankEdit:AddItem(btn)
						if (rank.Weight == 1 or rank.Weight == 100) then
							btn:SetMouseInputEnabled(false)
						end
					end)

					fr.lblRanks:SetText('Editing ' .. rank.Name)
					fr.lblRanks:SizeToContents()
					s:SetText("Сохранить")
				end
			end
		end, fr.colMid)

	end

	if (perms.MoTD) then
		fr.btnMoTD = ui.Create('DButton', function(self)
			self:SetText("Изменить MOTD")
			self:SetTall(25)
			self:DockMargin(0, 5, 0, 0)
			self:Dock(BOTTOM)

			self.Think = function(s)
				s:SetDisabled(IsValid(fr.colPicker))
			end

			local oldMoTD
			self.DoClick = function(s)
				if (upgraded) then
					if (IsValid(fr.overMoTD)) then
						fr.overMoTD:Remove()
						s:SetText("Изменить MOTD")

						if (motd.Text == oldMoTD.Text and (!upgraded or (upgraded and motd.Dark == oldMoTD.Dark))) then
							return
						end

						net.Start('rp.SetOrgMoTD')
							net.WriteString(motd.Text)
							net.WriteBit(motd.Dark == true)
						net.SendToServer()
					else
						oldMoTD = { Text = motd.Text, Dark = motd.Dark }

						fr.overMoTD = ui.Create('Panel', function(pnl)
							pnl:SetPos(fr.colLeft:GetPos())
							pnl:SetSize(fr.colMid.x + fr.colMid:GetWide(), fr.colLeft:GetTall())
							pnl.Paint = function(s, w, h)
								surface.SetDrawColor(0, 0, 0, 255)
								surface.DrawRect(0, 0, w, h)
							end

							pnl.lblEditing = ui.Create('DButton', function(lbl)
								lbl:SetText('Изменение MoTD')
								lbl:SetTall(30)
								lbl:SetDisabled(true)
								lbl:DockMargin(0, 0, 0, -1)
								lbl:Dock(TOP)
							end, pnl)

							pnl.TextEntry = ui.Create('DTextEntry', function(txt)
								txt:Dock(FILL)
								txt:SetMultiline(true)
								txt:SetValue(motd.Text)
								txt:SetFont('ui.22')
								txt:RequestFocus()
								txt.OnChange = function(s)
									motd.Text = s:GetValue()
									fr.PopulateMoTD()
								end
							end, pnl)

							if (upgraded) then
								local settingsBG = ui.Create('DButton', function(lbl)
									lbl:SetText('')
									lbl:SetTall(30)
									lbl:SetDisabled(true)
									lbl:DockMargin(0, 0, 0, -1)
									lbl:Dock(TOP)
								end, pnl)

								pnl.btnDarkTheme = ui.Create('DCheckBoxLabel', function(chk)
									chk:DockMargin(5, 5, 5, 5)
									chk:SetTall(35)
									chk:Dock(LEFT)
									chk:SetText("Тёмная Тема")
									chk:SetFont('ui.22')
									chk:SetChecked(motd.Dark and true or false)
									chk.OnChange = function(s)
										motd.Dark = s:GetChecked()
										fr.PopulateMoTD()
									end
								end, settingsBG)

								pnl.helpBtn = ui.Create('DButton', function(lbl)
									//lbl:SetTextColor(ui.col.White)
									lbl:SetText("Помощь в Форматировании")
									lbl:SetFont('ui.22')
									lbl:SizeToContents()
									lbl:SetTall(25)
									lbl:Dock(RIGHT)
									lbl.DoClick = function(s)
										gui.OpenURL("https://guides.github.com/features/mastering-markdown/")
									end
								end, settingsBG)
							end
						end, fr)

						s:SetText("Готово")
					end
				else
					if (IsValid(fr.overMoTD)) then
						local newmotd = fr.overMoTD:GetValue()
						fr.overMoTD:Remove()
						s:SetText("Изменить MOTD")

						if (motd.Text == newmotd) then
							return
						end

						net.Start('rp.SetOrgMoTD')
							net.WriteString(newmotd)
							net.WriteBit(0)
						net.SendToServer()

						motd.Text = newmotd
						fr.PopulateMoTD()
					else
						fr.overMoTD = ui.Create('DTextEntry', function(txt)
							txt:SetPos(fr.txtMoTD.x, fr.lblMoTD:GetTall())
							txt:SetSize(fr.txtMoTD:GetSize())
							txt:SetMultiline(true)
							txt:SetValue(motd.Text)
							txt:SetFont('ui.22')
							txt:RequestFocus()
						end, fr.colRight)

						s:SetText("Готово")
					end
				end
			end
		end, fr.colRight)
	end

	if (perms.Invite) then
		fr.btnInv = ui.Create('DButton', function(self)
			self:SetText("Пригласить Игроков ($" .. rp.cfg.OrgInviteCost .. " каждый)")
			self:SetTall(25)
			self:DockMargin(0, 5, 0, 0)
			self:Dock(BOTTOM)

			self.Think = function(s)
				s:SetDisabled(IsValid(fr.overMem))
			end

			self.DoClick = function(s)
				if (IsValid(fr.overMemInv)) then
					fr.overMemInv:Remove()
					s:SetText("Пригласить Игроков")
				else
					fr.overMemInv = ui.Create('ui_playerrequest', function(scr)
						scr:SetPos(fr.listMem.x, fr.lblMem:GetTall())
						scr:SetSize(fr.listMem:GetSize())

						scr:SetPlayers(table.Filter(player.GetAll(), function(v)
							return (not v:GetOrg())
						end))

						scr.OnSelection = function(self, row, pl)
							if (LocalPlayer():CanAfford(rp.cfg.OrgInviteCost)) then
								net.Start('rp.OrgInvite')
									net.WritePlayer(pl)
								net.SendToServer()

								row:Remove()
							else
								rp.Notify(NOTIFY_ERROR, term.GetString(term.Get('CannotAfford')))
							end
						end

						scr.Paint = function(scr, w, h)
							surface.SetDrawColor(0, 0, 0)
							surface.DrawRect(0, 0, w, h)
							derma.SkinHook('Paint', 'Frame', self, w, h)
						end
					end, fr.colLeft)

					s:SetText("Назад")
				end
			end
		end, fr.colLeft)
	end

		if (perms.Rank) then
			fr.btnEdit = ui.Create('DButton', function(self)
				self:SetText("Изменить Игрока")
				self:SetTall(25)
				self:DockMargin(0, 5, 0, 0)
				self:Dock(BOTTOM)

				self.Think = function(s)
					local sel = fr.listMem:GetSelected()

					if (IsValid(fr.overMemInv) or !IsValid(sel) or !sel.Player or sel.Player.SteamID == LocalPlayer():SteamID64() or sel.Player.Weight >= perms.Weight) then
						s:SetDisabled(true)
					else
						s:SetDisabled(false)
					end
				end

				self.DoClick = function(s)
					if (IsValid(fr.overMem)) then
						fr.overMem:Remove()
						s:SetText("Изменить Игрока")
					else
						local sel = fr.listMem:GetSelected()

						fr.overMem = ui.Create('ui_listview', function(scr)
							scr:SetPadding(-1)
							scr:SetPos(fr.listMem.x, fr.lblMem:GetTall())
							scr:SetSize(fr.listMem:GetSize())

							scr.Paint = function(s, w, h)
								surface.SetDrawColor(200, 200, 200)
								surface.DrawRect(0, 0, w, h)
							end

							scr:AddSpacer(sel.Player.Name)

							if (!sel.Player) then return end

							if (perms.Kick) then
								scr.btnKick = ui.Create('DButton', function(btn)
									btn:SetText("Кикнуть Игрока")
									btn.TextColor = rp.col.Red
									btn:SetTall(25)
									scr:AddItem(btn)

									btn.Think = function(s)
										if (s.CoolDown) then
											if (SysTime() > s.CoolDown + 2) then
												s:SetText("Кикнуть Игрока")
												s.CoolDown = nil
											end
										end
									end

									btn.DoClick = function(s)
										if (!s.CoolDown) then
											s.CoolDown = SysTime()
											s:SetText("Нажмите ещё раз для подтверждения")
										else
											net.Start('rp.OrgKick')
												net.WriteString(sel.Player.SteamID)
											net.SendToServer()

											fr.btnEdit:DoClick()

											sel:Remove()
										end
									end
								end)
							end

							scr.btnRank = ui.Create('DButton', function(btn)
								btn:SetText("Изменить Ранг")
								btn:SetTall(25)
								scr:AddItem(btn)

								btn.DoClick = function(s)
									local m = ui.DermaMenu()

									local num = 0
									for k, v in ipairs(orgranks) do
										if (v.Weight < perms.Weight and v.Name != sel.Player.Rank) then
											num = num + 1
											m:AddOption(v.Name, function()
												net.Start('rp.OrgSetRank')
													net.WriteString(sel.Player.SteamID)
													net.WriteString(v.Name)
												net.SendToServer()

												sel.Player.Rank = v.Name
												sel.Player.Weight = v.Weight
												fr.PopulateMembers(sel.Player.SteamID)
												sel = fr.listMem:GetSelected()
											end)
										end
									end

									if (num >= 1) then
										m:Open()
									else
										m:Remove()
									end
								end
							end)

							if (perms.Owner) then
								scr.btnMakeOwner = ui.Create('DButton', function(btn)
									btn:SetText('Сделать Владельцем')
									btn:SetTall(25)
									scr:AddItem(btn)

									btn.DoClick = function(s)
										ui.StringRequest('Передать Владение Бандой', 'Вы уверены что хотите сделать ' .. sel.Player.Name .. ' новым владельцем ' .. LocalPlayer():GetOrg() .. '? Введите ДА для продолжения.', '', function(resp)
											if (resp:lower() == 'да') then
												head:Close()

												net.Start('rp.PromoteOrgLeader')
													net.WriteString(sel.Player.SteamID)
												net.SendToServer()
											end
										end)
									end
								end)
							end
						end, fr.colLeft)

						s:SetText("Назад")
					end
				end
			end, fr.colLeft)
		elseif (perms.Kick) then
			fr.btnKick = ui.Create('DButton', function(self)
				self:SetText("Кикнуть Игрока")
				self:SetTall(25)
				self:DockMargin(0, 5, 0, 0)
				self:Dock(BOTTOM)
				self.TextColor = rp.col.Red

				self.Think = function(s)
					local sel = fr.listMem:GetSelected()

					if (IsValid(fr.overMemInv) or !IsValid(sel) or !sel.Player or sel.Player.SteamID == LocalPlayer():SteamID64() or sel.Player.Weight >= perms.Weight) then
						s:SetDisabled(true)
					else
						s:SetDisabled(false)
					end

					if (s.CoolDown) then
						if (SysTime() > s.CoolDown + 2) then
							s:SetText("Кикнуть Игрока")
							s.CoolDown = nil
						end
					end
				end

				self.DoClick = function(s)
					if (!s.CoolDown) then
						s.CoolDown = SysTime()
						s:SetText("Нажмите ещё раз для подтверждения")
					else
						local sel = fr.listMem:GetSelected()
						net.Start('rp.OrgKick')
							net.WriteString(sel.Player.SteamID)
						net.SendToServer()

						sel:Remove()
						s.CoolDown = 0
					end
				end
			end, fr.colLeft)
		end
end)

net("rp.OrgLog", function()
	if (not IsValid(cont)) then return end

	local data = {}

	for i = 1, net.ReadUInt(8) do
		data[#data + 1] = {
			Time = net.ReadUInt(32),
			Log = net.ReadString()
		}
	end

	local w, h = cont:GetWide(), cont:GetTall()

	local logFr = ui.Create("ui_frame", function(self)
		self:SetSize(w, h)
		self:SetTitle(LocalPlayer():GetOrg() .. ': Логи')
	end, cont)

	ui.Create('ui_listview', function(self, p)
		self:DockToFrame()

		for k, v in ipairs(data) do

			local b = self:AddRow(os.date("[%H:%M:%S - %d/%m/%Y] ", v.Time) .. v.Log)
			b:SetContentAlignment(4)
			b:SetTextInset(5, 0)
			b.DoClick = function(s)
				local m = ui.DermaMenu(s)
				m:AddOption('Скопировать Лог', function()
					SetClipboardText(b:GetText())
				end)
				m:AddOption('Скопировать Дату', function()
					SetClipboardText()
				end)
				m:Open()
			end
		end
	end, logFr)
end)

hook('F4TabChanged', function(tab)
	if (tab == cont) and IsValid(fr) then
		fr.AddControls()
	elseif IsValid(fr) then
		fr.HideControls()
	end
end)

hook('PopulateF4Tabs', function(frs, f4fr)
	frs:AddTab('Банды', function(self)
		head = f4fr

		cont = ui.Create 'DPanel'

		cont.PaintOver = function(self, w, h)
			if (not self.IsLoaded) then
				local t = SysTime() * 5
				draw.NoTexture()
				surface.SetDrawColor(255, 255, 255)
				surface.DrawArc(w * 0.5, h * 0.5, 41, 46, t * 80, t * 80 + 180, 20)
			end
		end

		net.Ping("rp.OrgsMenu")

		return cont
	end):SetIcon 'gmh/gui/f4/f4_orgs.png'
end)

function rp.orgs.GetBanner(orgName)
	if (rp.orgs.Banners[orgName]) then
		if (rp.orgs.Banners[orgName] == 2) then
			return texture.Get('OrgBanner.' .. orgName)
		end
	else
		rp.orgs.LoadBanner(orgName)
	end
end

function rp.orgs.LoadBanner(orgName)
	rp.orgs.Banners[orgName] = 1
	texture.Delete('OrgBanner.' .. orgName)
	texture.Create('OrgBanner.' .. orgName)
		:EnableProxy(false)
		:EnableCache(false)
		:Download('https://gmodhub.com/api/org/banners/' .. orgName:URLEncode(), function(self, material)
			rp.orgs.Banners[orgName] = 2
		end, function(self, error)
			rp.orgs.Banners[orgName] = 3
			timer.Simple(5, function() rp.orgs.Banners[orgName] = nil end)
		end)
end

net('rp.OrgBannerInvalidate', function(len)
	rp.orgs.Banners[net.ReadString()] = nil
end)
