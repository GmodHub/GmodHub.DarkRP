/*local function loadmat(name, cback, fail)
	local inf = rp.Clothes[name]
	if file.Exists('materials/sup/clothes/' .. name .. '.vtf', 'GAME') then
		rp.Clothes[name].Material = 'sup/clothes/' .. name
		print('using local content ' .. name)
		cback()
	elseif (not rp.Clothes[name].Material) then
		wmat.Create(name, {
			URL 	= 'http://gmodhub.com/rp/sub_materials/' .. inf.File .. '.png',
			W 		= inf.W or 1024,
			H 		= inf.H or 1024,
			Cache 	= true,
			UseHTTP = true,
			Shader = 'VertexLitGeneric',
			MaterialData = {
				['$translucent'] 	= 0,
				['$model'] 			= 1,
				['$smooth'] 		= 1
			},
		}, function(mat)
			print(name, mat)
			rp.Clothes[name].Material = '!' .. mat:GetName()
			cback()
		end, function()
			print(name, 'FAILED')
			fail()
		end)
		print('fetching content ' .. name)
	else
		print('using local fetched content ' .. name)
		cback()
	end
end

local function findsheet(self)
	for k, v in ipairs(self:GetMaterials()) do
		if string.find(v, 'players_sheet') then
			return (k - 1)
		end
	end
	return 0
end

local function setmaterial(self, outfit)
	local id = findsheet(self)
	local mat = outfit and rp.Clothes[outfit].Material
	self:SetSubMaterial(id, mat)
	self.LastOutfit = self:GetOutfit()

	-- Handle our clientside legs also :)
	if (self == LocalPlayer() and IsValid(self.Legs) and IsValid(self.Legs.Entity)) then
		self.Legs.Entity:SetSubMaterial(findsheet(self.Legs.Entity), mat)
	end
end

function ENTITY:SetOutfit(outfit)
	if (outfit == nil) or rp.Clothes[outfit].Material then
		setmaterial(self, outfit)
	else
		loadmat(outfit, function()
			if IsValid(self) then
				self.LoadingOutfit = false
				setmaterial(self, outfit)
			end
		end, function()
			if IsValid(self) then
				self.LoadingOutfit = false
			end
		end)
	end
end

timer.Create('rp.ClothingThink', 1, 0, function()
	if IsValid(LocalPlayer()) then
		for k, v in ipairs(player.GetAll()) do
			local outfit = v:GetOutfit()
			if IsValid(v) and (not v.LoadingOutfit) and (((not v.LastOutfit) and (outfit ~= nil)) or (outfit ~= v.LastOutfit)) and ((outfit == nil) or v:GetJobTable().Outfits[outfit]) then
				v:SetOutfit(v:GetOutfit())
				print('setting ' , v)
			end
		end
	end
end)



concommand.Add('clothes_test', function(p,c,a)
	local id = 0
	local mat = rp.Clothes[a[1] or 'Misfits'].Material

	for k, v in ipairs(p:GetMaterials()) do
		if string.find(v, 'players_sheet') then
			id = (k - 1)
			break
		end
	end

	PrintTable(p:GetMaterials())

	print(id, mat)

	p:SetSubMaterial(id, mat)

	PrintTable(p:GetMaterials())
end)






-- Menu
hook('PopulateF4Tabs', 'clothes.PopulateF4Tabs', function(tabs)
    local cont = ui.Create('ui_panel')
	cont:SetSize(tabs:GetParent():GetWide() - 165, tabs:GetParent():GetTall() - 35)
	tabs:AddTab('Clothes (Beta)', cont)

	ui.Create('ui_panel', function(self, p)
		self:SetPos(5, 5)
		self:SetSize(p:GetWide() *.65 - 2.5, 50)
		self.Paint = function(s, w, h)
			draw.OutlinedBox(0, 0, w, 50, LocalPlayer():GetJobColor(), ui.col.Outline)
			draw.SimpleTextOutlined('Outfits for: ' .. LocalPlayer():GetJobName(), 'ui.24', w * 0.5, 25, ui.col.White, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, ui.col.Black)
		end
	end, cont)

    local tab = ui.Create('ui_scrollpanel', function(self, p)
        self:SetPos(5, 55)
        self:SetSize(p:GetWide() *.65 - 2.5, p:GetTall() - 55)
        self:SetSpacing(2)
    end, cont)

	local prev = ui.Create('rp_playerpreview', function(self, p)
		self:SetPos(p:GetWide() * .65 + 2.5, 5)
		self:SetSize(p:GetWide() *.35 - 7.5, p:GetTall() - 40)
	end, cont)

    for k, v in SortedPairsByMemberValue(rp.Clothes, 'Price', false) do
    	if (not LocalPlayer():CanUseOutfit(v.File)) then continue end
    	local pnl = ui.Create('ui_panel', function(self, p)
    		self:SetTall(65)
    	end)
    	tab:AddItem(pnl)

		ui.Create('DLabel', function(self, p)
			self:SetText(v.Name)
			self:SetFont('ui.22')
			self:SetPos(5, p:GetTall()/2 - self:GetTall()/2)
			self:SizeToContents()
		end, pnl)

		ui.Create('DLabel', function(self, p)
			self:SetText(rp.FormatMoney(v.Price))
			self:SetFont('ui.22')
			self:SetPos(p:GetWide()/2 - self:GetWide() - 2, 5)
			self:SizeToContents()
		end, pnl)

		ui.Create('DLabel', function(self, p)
			self:SetText('-OR-')
			self:SetFont('ui.17')
			self:SetPos(p:GetWide()/2 - self:GetWide() - 2, p:GetTall()/2 - self:GetTall()/2 + 3)
			self:SizeToContents()
		end, pnl)

		ui.Create('DLabel', function(self, p)
			self:SetText(v.Credits .. ' credits')
			self:SetFont('ui.22')
			self:SetPos(p:GetWide()/2 - self:GetWide() - 2, p:GetTall() - self:GetTall() - 5)
			self:SizeToContents()
		end, pnl)


		local hasoutfit = LocalPlayer():HasOutfit(v.File)
		ui.Create('DButton', function(self, p)
			self:SetText('View')
			self:SetSize(hasoutfit and 135 or 50, 25)
			self:SetPos(p:GetWide() - (hasoutfit and 140 or 195), 5)
			self.DoClick = function()
				prev:SetOutfit(v.File)
			end
		end, pnl)

		if hasoutfit then
			ui.Create('DButton', function(self, p)
				self:SetText('Equip')
				self:SetSize(135, 25)
				self:SetPos(p:GetWide() - 140, 35)
				self.DoClick = function()
					cmd.Run('setoutfit', v.File)
					prev:SetOutfit(v.File)
				end
			end, pnl)
		else
			local buycash
			local buycred
			buycash = ui.Create('DButton', function(self, p)
				self:SetText('Buy with Cash')
				self:SetSize(135, 25)
				self:SetPos(p:GetWide() - 140, 5)
				self.Confirm = hasoutfit
				self.DoClick = function()
					if self.Confirm then
						cmd.Run('buyoutfit', v.File)
						prev:SetOutfit(v.File)
						self:SetText('Equip')
						self.DoClick = function()
							cmd.Run('setoutfit', v.File)
							prev:SetOutfit(v.File)
						end
					else
						self.Confirm = true
						self:SetText('Click Again')
					end
				end
			end, pnl)

			buycred = ui.Create('DButton', function(self, p)
				self:SetText('Buy With Credits')
				self:SetSize(135, 25)
				self:SetPos(p:GetWide() - 140, 35)
				self.Confirm = hasoutfit
				self.DoClick = function()
					if (not LocalPlayer():CanAffordCredits(v.UpgradeObj:GetPrice())) then
						ui.BoolRequest('Cannot afford', 'You need more credits to buy this. Would you like to buy credits?', function(ans)
							if (ans == true) then
								gui.OpenURL(rp.cfg.CreditsURL .. LocalPlayer():SteamID())
							end
						end)
					end

					if self.Confirm then
						cmd.Run('buyupgrade', tostring(v.UpgradeObj:GetID()))
						prev:SetOutfit(v.File)
						self:SetText('Equip')
						self.DoClick = function()
							cmd.Run('setoutfit', v.File)
							prev:SetOutfit(v.File)
						end
					else
						self.Confirm = true
						self:SetText('Click Again')
					end
				end
			end, pnl)
		end
    end
end)
