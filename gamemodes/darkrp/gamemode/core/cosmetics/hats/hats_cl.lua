/*--cvar.Create('enable_hats', true)
rp.hats = rp.hats or {}
rp.hats.List = {}
rp.hats.stored = rp.hats.stored or {}

local vecneg = Vector(0, 0, -32000)

function rp.hats.Render(ent, cfg)
	if cfg and cfg.ShouldRender then
		local bonenum = ent:LookupBone('ValveBiped.Bip01_Head1')

		rp.hats.stored[ent] = rp.hats.stored[ent] or {}

		local hat = rp.hats.stored[ent][cfg.type] or ClientsideModel(cfg.model, RENDERGROUP_BOTH)
		hat.UID = cfg.UID

		if IsValid(hat) then
			rp.hats.stored[ent][cfg.type] = rp.hats.stored[ent][cfg.type] or hat

			if bonenum then
				local pos, ang = ent:GetBonePosition(bonenum)

				local offang = cfg.offang
				ang:RotateAroundAxis(ang:Forward(), offang.p + 270)
				ang:RotateAroundAxis(ang:Right(), offang.y + 270)
				ang:RotateAroundAxis(ang:Up(), offang.r - 5)

				local offpos = cfg.offpos
				pos = pos + (ang:Forward() * offpos.x) + (ang:Right() * offpos.y) + (ang:Up() * offpos.z)

				hat:SetModelScale(cfg.scale, 0)

				hat:SetPos(pos)
				hat:SetAngles(ang)

				if cfg.skin then
					hat:SetSkin(cfg.skin)
				end

				hat:SetRenderOrigin(pos)
				hat:SetRenderAngles(ang)
				hat:SetupBones()
				hat:DrawModel()

				hat:SetRenderOrigin()
				hat:SetRenderAngles()

				if (cfg.model ~= hat:GetModel()) then
					hat:SetModel(cfg.model)
				end
			else
				hat:SetRenderOrigin(vecneg)
			end

			local min, max = hat:GetModelBounds()
			local offset = cfg.usebounds and (max.z - min.z) or cfg.infooffset

			if (not ent.InfoOffset) or (offset > ent.InfoOffset) then
				ent.InfoOffset = offset
			end
		end
	end
end

hook('PostPlayerDraw', 'hats.PostPlayerDraw', function(pl)
	local apparel = pl:GetApparel()
	pl.InfoOffset = nil

	if apparel then
		local lp = LocalPlayer()

		if (pl ~= lp) and (not pl.IsCurrentlyVisible) then return end

		if (pl == lp) and (not rp.thirdPerson.isEnabled()) and (IsValid(lp:GetActiveWeapon()) and (lp:GetActiveWeapon():GetClass() ~= 'gmod_camera')) then return end

		for k, v in pairs(apparel) do
			rp.hats.Render(pl, rp.hats.List[v])
		end
	end
end)

hook('Think', 'hats.Think', function()
	local lp = LocalPlayer()

	for ent, hats in pairs(rp.hats.stored) do
		for slot, hat in pairs(hats) do
			if (not IsValid(hat)) then
				rp.hats.stored[ent][slot] = nil
			elseif (not IsValid(ent)) or (ent:IsPlayer() and ((not ent:Alive()) or (not ent:GetApparel()) or (ent:GetApparel()[slot] ~= hat.UID) or ((not rp.thirdPerson.isEnabled()) and (ent == lp)) or ((ent ~= lp) and (not ent.IsCurrentlyVisible)))) then
				hat:Remove()
				rp.hats.stored[ent][slot] = nil
			end

		end
	end
end)


local PANEL = {}

function PANEL:Init()
	self.List = ui.Create('ui_listview', self)
	self.List:SetPadding(-1)
	self.List.Paint = function() end

	self.Types = {
		[1] = 'Hats',
		[2] = 'Masks',
		[3] = 'Glasses',
		[4] = 'Scarves'
	}
	self.Previews = {}

	for i = 1, 4 do
		local name = self.Types[i]
		self.Types[i] = ui.Create('ui_collapsible_section')
		self.Types[i]:SetText(name)
		self.Types[i].OnCollapsing = function()
			self.List:InvalidateLayout()
		end
		self.List:AddItem(self.Types[i])

		self.Previews[i] = ui.Create('rp_modelicon', self)
		self.Previews[i]:SetToolTip('Slot #' .. i)
		self.Previews[i].DoClick = function(s)
			--self:SelectHat(s.Hat)
		end
		self.Previews[i].Paint = function(s, w, h)
			draw.OutlinedBox(0, 0, w, h, ui.col.Black, ui.col.Green)
		end
		self.Previews[i].PaintOver = function(s, w, h)
			if (not s.ShouldDraw) then
				draw.OutlinedBox(0, 0, w, h, ui.col.Black, ui.col.Outline)
				draw.SimpleText('Slot ' .. i, 'ui.18', w * 0.5, h * 0.5, ui.col.White, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
		end
	end

	self.Name = ui.Create('DButton', self)
	self.Name:SetDisabled(true)
	self.Name:SetText('Select an item')

	self.Preview = ui.Create('rp_playerpreview', self)
	self.Preview:Hide()

	self.BuyCash = ui.Create('DButton', self)
	self.BuyCash:Hide()
	self.BuyCash.Confirm = false
	self.BuyCash.DoClick = function(s)
		if (not s.Confirm) then
			s:SetText('Click again to confirm')
			s.Confirm = true
		else
			cmd.Run('buyapparel', self.Hat.UID)

			self.BuyCash:Hide()
			self.Spacer:Hide()
			self.BuyCredits:Hide()
			self.Equip:Show()
			self.Equip:SetText('Unequip')
		end
	end

	self.Spacer = ui.Create('DLabel', self)
	self.Spacer:SetText('-OR-')
	self.Spacer:Hide()

	self.BuyCredits = ui.Create('DButton', self)
	self.BuyCredits:Hide()
	self.BuyCredits.Confirm = false
	self.BuyCredits.BackgroundColor = ui.col.DarkGreen
	self.BuyCredits.OutlineColor = ui.col.OffWhite
	self.BuyCredits.DoClick = function(s)
		local price = self.Hat.upgradeobj:GetPrice()

		if (not s.Confirm) and LocalPlayer():CanAffordCredits(price) then
			s:SetText('Click again to confirm')
			s.Confirm = true
		else

			if (not LocalPlayer():CanAffordCredits(price)) then
				ui.BoolRequest('Cannot afford', 'You need more credits to buy this. Would you like to buy credits?', function(ans)
					if (ans == true) then
						gui.OpenURL(rp.cfg.CreditsURL .. LocalPlayer():SteamID() .. '/' .. price)
					end
				end)
			else
				cmd.Run('buyupgrade', tostring(self.Hat.upgradeobj:GetID()))

				self.BuyCash:Hide()
				self.Spacer:Hide()
				self.BuyCredits:Hide()
				self.Equip:Show()
				self.Equip:SetText('Unequip')
			end
		end
	end

	self.Equip = ui.Create('DButton', self)
	self.Equip:Hide()
	self.Equip.DoClick = function()
		if LocalPlayer():GetApparel() and (LocalPlayer():GetApparel()[self.Hat.type] == self.Hat.UID) then
			self.Equip:SetText('Equip')
			cmd.Run('removeapparel', self.Hat.type)
		else
			self.Equip:SetText('Unequip')
			cmd.Run('setapparel', self.Hat.UID)
		end
	end
end

function PANEL:Reset()
	self.Hat = nil
	self.Preview:SetApparel(LocalPlayer():GetApparel())
	self.BuyCash:Hide()
	self.BuyCredits:Hide()
	self.Equip:Hide()
end

function PANEL:SelectHat(hat)
	self.Hat = hat

	self.Name:SetText(hat.name)

	self.Preview:Show()

	local apparel = table.Copy(LocalPlayer():GetApparel())

	for k, v in pairs(apparel) do
		if hat.slots[k] then
			apparel[k] = nil
		end
	end

	apparel[hat.type] = hat.UID

	for k, v in ipairs(self.Previews) do
		v.ShouldDraw = false
	end

	for k, v in pairs(apparel) do
		local obj = rp.hats.List[v]
		for slot, _ in pairs(obj.slots) do
			self.Previews[slot]:SetModel(obj.model, obj.skin)
			self.Previews[slot].ShouldDraw = true
		end
	end

	self.Apparel = apparel
	self.Preview:SetApparel(apparel)

	local hasHat = LocalPlayer():HasApparel(hat.UID)

	if hasHat then
		self.Equip:Show()
		self.Equip:SetText((LocalPlayer():GetApparel() and (LocalPlayer():GetApparel()[hat.type] == hat.UID)) and 'Unequip' or 'Equip')

		self.BuyCash:Hide()
		self.Spacer:Hide()
		self.BuyCredits:Hide()
	else
		if (not LocalPlayer():CanAfford(hat.price)) then
			self.BuyCash:SetDisabled(true)
		else
			self.BuyCash:SetDisabled(false)
		end
		self.BuyCash:SetText(rp.FormatMoney(hat.price))
		self.BuyCash:Show()

		self.Spacer:Show()

		self.BuyCredits:SetText(string.Comma(hat.credits) .. ' Credits')
		self.BuyCredits:Show()

		self.Equip:Hide()
	end
end

function PANEL:AddControls(f4)
	if IsValid(self.BuyMoreCredits) then
		self.BuyMoreCredits:Show()
	elseif IsValid(f4) then
		self.BuyMoreCredits = ui.Create('DButton', f4)
		self.BuyMoreCredits:SetText('Purchase Credits' .. rp.cfg.CreditSale)
		self.BuyMoreCredits.BackgroundColor = ui.col.DarkGreen
		self.BuyMoreCredits:SizeToContents()
		self.BuyMoreCredits:SetSize(self.BuyMoreCredits:GetWide() + 10, f4.btnClose:GetTall())
		self.BuyMoreCredits:SetPos(f4.btnClose.x - self.BuyMoreCredits:GetWide() + 1, 0)
		self.BuyMoreCredits.DoClick = function(s)
			gui.OpenURL(rp.cfg.CreditsURL .. LocalPlayer():SteamID())
		end
	end

	if IsValid(self.CreditsBalance) then
		self.CreditsBalance:Show()
	elseif IsValid(f4) then
		self.CreditsBalance = ui.Create('DButton', f4)
		self.CreditsBalance:SetDisabled(true)
		self.CreditsBalance.TextColor = rp.col.Yellow
		self.CreditsBalance:SetText(string.Comma(LocalPlayer():GetCredits()) .. ' Credits')
		self.CreditsBalance:SizeToContents()
		self.CreditsBalance:SetSize(self.CreditsBalance:GetWide() + 10, f4.btnClose:GetTall())
		self.CreditsBalance:SetPos(self.BuyMoreCredits.x - self.CreditsBalance:GetWide() + 1, 0)
	end
end

function PANEL:HideControls()
	if IsValid(self.BuyCredits) then
		self.BuyMoreCredits:Hide()
	end

	if IsValid(self.CreditsBalance) then
		self.CreditsBalance:Hide()
	end
end

function PANEL:AddHats()
	local size = self.List:GetWide() * .125

	local sortedTypes = {
		[1] = {},
		[2] = {},
		[3] = {},
		[4] = {}
	}

	for k, v in pairs(rp.hats.Categories) do
		sortedTypes[1][v] = {}
		sortedTypes[2][v] = {}
		sortedTypes[3][v] = {}
		sortedTypes[4][v] = {}
	end

	for k, v in pairs(rp.hats.List) do
		local key = LocalPlayer():HasApparel(v.UID) and 1 or rp.hats.Categories[v.category]

		sortedTypes[v.type][key][v.UID] = v
	end

	for typeId, categories in ipairs(sortedTypes) do
		local i, y = 0, 0
		for categoryId, hats in ipairs(categories) do
			if table.IsEmpty(hats) then continue end

			for k, v in pairs(rp.hats.Categories) do
				if (v == categoryId) then
					self.Types[typeId]:AddItem(ui.Create('DButton', function(s)
						s:SetPos(0, y)
						s:SetText(k)
						s:SetSize(self.List:GetWide(), 30)
						s:SetDisabled(true)
					end))
				end
			end
			y = y + 29

			for uid, hat in SortedPairsByMemberValue(hats, 'price', false) do
				if (i == 8) then
					i = 0
					y = y + size
				end

				self.Types[typeId]:AddItem(ui.Create('rp_modelicon', function(m)
					m:SetSize(size, size)
					m:SetPos(i * size, y)
					m:SetModel(hat.model, hat.skin)
					m.DoClick = function()
						self:SelectHat(hat)
					end
					m.Paint = function(m, w, h)
						if self.Hat and (self.Hat.UID == hat.UID) then

							draw.Box(1, 1, w - 2, h - 2, ui.col.Hover)
							draw.OutlinedBox(1, 1, w - 2, h - 2, ui.col.Background, ui.col.White)

						elseif LocalPlayer():GetApparel() and (LocalPlayer():GetApparel()[hat.type] == hat.UID) then
							draw.OutlinedBox(1, 1, w - 2, h - 2, ui.col.Background, ui.col.Green)
						end
					end

					m:SetTooltip(hat.name .. '\n' .. rp.FormatMoney(hat.price) .. '\n -OR-\n' .. string.Comma(hat.credits) .. ' Credits')
				end))

				i = i + 1
			end

			i = 0
			y = (y + size) - 1
		end

		self.Types[typeId]:SetTall(y)
		self.Types[typeId]:Collapse(true, true)
	end


end

function PANEL:ApplySchemeSettings()
	self.Spacer:SetFont('ui.17')
end

function PANEL:PerformLayout()
	local w, h = self:GetWide(), self:GetTall()

	self.List:SetPos(5, 5)
	self.List:SetSize(w * .65 - 7.5, h - 10)

	local leftX, leftW = (w * .65) + 2.5, (w * .35) - 7.5

	self.Name:SetPos(leftX, 5)
	self.Name:SetSize(leftW, 30)

	local prevX, prevY = leftX, 40
	for k, v in ipairs(self.Previews) do
		v:SetPos(prevX, prevY)
		v:SetSize(50, 50)

		prevY = prevY + 55
	end

	self.Preview:SetPos(leftX, 35)
	self.Preview:SetSize(leftW, h - 125)

	self.BuyCash:SetPos(leftX, h - 80)
	self.BuyCash:SetSize(leftW, 30)

	self.Spacer:SizeToContents()
	self.Spacer:SetPos(leftX + (leftW * 0.5) - (self.Spacer:GetWide() * 0.5), h - 50)

	self.BuyCredits:SetPos(leftX, h - 35)
	self.BuyCredits:SetSize(leftW, 30)

	self.Equip:SetPos(leftX, h - 35)
	self.Equip:SetSize(leftW, 30)

	if (not self.HatsAdded) then
		self:AddHats()

		self.HatsAdded = true
	end
end

vgui.Register('rp_hatspanel', PANEL, 'Panel')
