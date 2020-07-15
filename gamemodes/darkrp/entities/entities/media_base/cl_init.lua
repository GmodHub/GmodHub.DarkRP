dash.IncludeSH 'shared.lua'

cvar.Register 'media_enable'
	:SetDefault(true, true)
	:AddMetadata('Catagory', 'Медиа')
	:AddMetadata('Menu', 'Включить медиа проигрыватели')

cvar.Register 'media_mute_when_unfocused'
	:SetDefault(true, true)
	:AddMetadata('Catagory', 'Медиа')
	:AddMetadata('Menu', 'Отключать звук проигрывателей при alt-tab')

cvar.Register 'media_volume'
	:SetDefault(0.75, true)
	:AddMetadata('Catagory', 'Медиа')
	:AddMetadata('Menu', 'Громкость медиа проигрывателей')
	:AddMetadata('Type', 'number')

cvar.Register 'media_quality'
	:SetDefault('low')
	:SetType(function()
		return (v == 'low') or (v == 'medium') or (v == 'high') or (v == 'veryhigh')
	end)

local defaultPlaylist = 'Сохранённые Видео'
cvar.Register 'media_saved_videos'
	:SetDefault({[defaultPlaylist] = {}}, true)
	:SetEncrypted()

local mediaservice = medialib.load 'media'

local currentVideoList = defaultPlaylist

function ENT:OnPlay(media)

end

function ENT:GetSoundOrigin()
	return self
end

function ENT:Think()
	local link = self:GetURL()
	local lp = LocalPlayer()
	local shouldplay = cvar.GetValue('media_enable') and (lp:EyePos():Distance(self:GetPos()) < 1024) and (not self:IsPaused()) and ((not lp.AfkTime) or lp.AfkTime < 300)
	local shouldBeMuted = !(system.HasFocus() or (not cvar.GetValue('media_mute_when_unfocused')))
	local targetVolume = !shouldBeMuted and (cvar.GetValue('media_volume') or 0.75) or 0

	if IsValid(self.Media) and (not link or not shouldplay) then
		self.Media:stop()
		self.Media = nil
	elseif shouldplay and (not IsValid(self.Media) or self.Media:getUrl() ~= link) then
		if IsValid(self.Media) then
			self.Media:stop()
			self.Media = nil
		end

		if (link ~= '') then
			local service = mediaservice.guessService(link)
			if service then
				local mediaclip = service:load(link, {use3D = true, ent3D = self:GetSoundOrigin()})
				self:OnPlay(mediaclip)
				mediaclip:setVolume(cvar.GetValue('media_volume') or 0.75)
				mediaclip:setQuality(cvar.GetValue('media_quality'))
				if (self:GetTime() ~= 0) then
					local progress = (CurTime() - self:GetStart()) % self:GetTime()
					mediaclip:seek(progress)
					mediaclip.LastStart = CurTime() - progress
				end
				mediaclip:play()

				self.Media = mediaclip
			end
		end
	elseif (IsValid(self.Media) and self.Media:getVolume() != targetVolume) then
		self.Media:setVolume(targetVolume)
	elseif (IsValid(self.Media) and shouldplay) then
		if (self:IsLooping()) then
			local inCurrentPlay = (CurTime() - self.Media.LastStart) < self:GetTime()
			if (!inCurrentPlay) then

				local progress = (CurTime() - self:GetStart()) % self:GetTime()
				self.Media:seek(progress)
				self.Media.LastStart = CurTime() - progress
			end
		end
	end
end

local color_bg = ui.col.Black
local color_text = ui.col.White
local color_red = ui.col.Red
function ENT:DrawScreen(x, y, w, h)
	if IsValid(self.Media) and cvar.GetValue('media_enable') then
		self.Media:draw(x, y, w, h)
	elseif (cvar.GetValue('media_enable') == false) then
		draw.Box(x, y, w, h, color_bg)
		draw.SimpleText('Медиа проигрыватели выключены.', 'DermaLarge', x + (w * .5),  y + (h * .5), color_red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	elseif (!self:IsFrozen()) then
		draw.Box(x, y, w, h, color_bg)
		draw.SimpleText('Медиа отключено так как проигрыватель не заморожен.', 'DermaLarge', x + (w * .5),  y + (h * .5), color_red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	elseif (self:IsPaused()) then
		draw.Box(x, y, w, h, color_bg)
		draw.SimpleText('Медиа на паузе.', 'DermaLarge', x + (w * .5),  y + (h * .5), color_red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	else
		draw.Box(x, y, w, h, color_bg)
		self:DrawRules(x, y, w, h)
	end
end

function ENT:DrawRules(x, y, w, h)
	draw.Box(x, y, w, h, color_bg)
	draw.SimpleText('Медиа не выбрано', 'DermaLarge', x + (w * .5),  y + (h * .45), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.SimpleText('Соблюдайте правила при проигрывании медиа', 'DermaLarge', x + (w * .5),  y + (h * .55), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.SimpleText('Нарушение правил ведёт к серьёзному наказанию', 'DermaLarge', x + (w * .5),  y + (h * .60), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

-- UI
local PANEL = {}

function PANEL:Init()
	self:SetText('')
	self:SetTall(50)
end


function PANEL:GetTitle()
	return self.TrackTitle
end

function PANEL:GetLink()
	return self.TrackLink
end

function PANEL:GetID()
	return self.TrackID
end


function PANEL:GetMaterial()
	return self.TrackMaterial
end

function PANEL:GetLength()
	return self.TrackLength
end


function PANEL:PerformLayout()

end

function PANEL:SetMedia(link, data)
	self.TrackLink = link

	if istable(data) then
		self.TrackTitle = data.Title
		self.TrackLength = data.Length
		self.TrackID = data.ID

		self:LoadMaterial()
	else

		local service = mediaservice.guessService(link)

		service:query(link, function(err, data)
			if IsValid(self) and (not err) and (data ~= nil) then
				self.TrackTitle = data.title
				self.TrackLength = data.duration or 0
				self.TrackID = data.id

				self:LoadMaterial()

				local favs = cvar.GetValue('media_saved_videos')
				favs[currentVideoList] = favs[currentVideoList] or {}
				favs[currentVideoList][link] = {
					Title = data.title,
					Length = data.duration or 0,
					ID = data.id
				}

				cvar.SetValue('media_saved_videos', favs)
			end
		end)
	end
end

function PANEL:LoadMaterial()
	local id = self:GetID()

	if (id == nil) then return end

	texture.Create('Media.Image.' .. id)
		:EnableProxy(false)
		:EnableCache(true)
		:Download('https://img.youtube.com/vi/' .. id .. '/sddefault.jpg', function(mat, material)
			if IsValid(self) then
				self.TrackMaterial = material
			end
		end)
end

function PANEL:DoClick()
	local m = ui.DermaMenu(self)
	m:AddOption('Проиграть', function()
		cmd.Run('playsong', self:GetLink())
	end)
	m:AddOption('Зациклить', function()
		cmd.Run('loopsong', self:GetLink())
	end)
	m:AddOption('Переименовать', function()
		ui.StringRequest('Установить Название', 'Как вы хотите назвать этот трек?', self:GetTitle(), function(title)
			if IsValid(self) then
				local favs = cvar.GetValue('media_saved_videos')
				favs[currentVideoList][self:GetLink()].Title = title
				cvar.SetValue('media_saved_videos', favs)

				self.TrackTitle = title
			end
		end)
	end)
	m:AddOption('Скопировать Ссылку', function()
		SetClipboardText(self:GetLink())
	end)
	m:AddOption('Удалить', function()
		local favs = cvar.GetValue('media_saved_videos')
		favs[currentVideoList][self:GetLink()] = nil
		cvar.SetValue('media_saved_videos', favs)

		self:Remove()
	end)
	m:Open()
end

function PANEL:Paint(w, h)
	self.BaseClass.Paint(self, w, h)

	local imw = 0
	local material = self:GetMaterial()
	if material then
		imw = h * 1.33
		surface.SetDrawColor(255, 255, 255)
		surface.SetMaterial(material)
		surface.DrawTexturedRect(5, 5, imw, h - 10)
	end

	local x = imw + 10
	draw.SimpleText(self:GetTitle(), 'ui.18', x, h * 0.3, ui.col.White, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	draw.SimpleText(string.FormattedTime(self:GetLength(), '%02i:%02i'), 'ui.18', x, h * 0.7, ui.col.White, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

vgui.Register('ui_mediabutton', PANEL, 'DButton')


local fr
function ENT:PlayerUse()
	-- Upgrade media_saved_videos to new format if not already
	local favs = cvar.GetValue('media_saved_videos')
	if (not favs[defaultPlaylist] or not istable(favs[defaultPlaylist])) then
		cvar.SetValue('media_saved_videos', {[defaultPlaylist] = favs})
	end

	if IsValid(fr) then fr:Close() end

	local ent = self
	local w, h = ScrW() * .45, ScrH() * .6

	fr = ui.Create('ui_frame', function(self)
		self:SetTitle('Медиа Проигрыватель')
		self:SetSize(w, h)
		self:MakePopup()
		self:Center()
		function self:Think()
			if (not IsValid(ent)) then
				self:Close()
			end
		end
	end)

	local x, y = fr:GetDockPos()

	local videoList
	local playlistList
	local query

	local function listMedia()
		local query = query:GetValue()
		if (string.Trim(query) == '') then query = nil end

		videoList:Reset()

		local favs = cvar.GetValue('media_saved_videos')[currentVideoList] or {}

		local count = 0
		for k, v in pairs(favs) do
			if (not query) or (istable(v) and string.find(v.Title:lower(), query:lower(), 1, true)) then
				videoList:AddItem(ui.Create('ui_mediabutton', function(self, p)
					self:SetMedia(k, v)
				end))

				count = count + 1
			end
		end

		if (count <= 0) then
			videoList:AddSpacer('Результатов не найдено!'):SetTall(30)
		end
	end

	query = ui.Create('DTextEntry', function(self, p)
		self:SetPos(x, y)
		self:SetSize((p:GetWide() * 0.75) - 10, 25)
		self:RequestFocus()
		self.OnChange = function(s)
			listMedia(s:GetValue())
		end
		self:SetPlaceholderText('Поиск..')
	end, fr)

	videoList = ui.Create('ui_listview', function(self, p)
		self:SetPos(5, y + 30)
		self:SetSize((p:GetWide() * 0.75) - 10, p:GetTall() - 100)

		self.Paint = function(self, w, h)
			derma.SkinHook('Paint', 'UIListView', self, w, h)
		end
	end, fr)

	local playlistButtons = {}
	playlistList = ui.Create('ui_listview', function(self, p)
		self:SetPos((p:GetWide() * 0.75), y)
		self:SetSize((p:GetWide() * 0.25) - 5, (videoList.y + videoList:GetTall()) - self.y - 23)

		self.Paint = function(self, w, h)
			derma.SkinHook('Paint', 'UIListView', self, w, h)
		end

		local playlists = {}

		local sp = self:AddSpacer('Плейлисты')
		sp:SetTall(25)
		local addBtn = ui.Create('DButton', function(self, p)
			self:Dock(RIGHT)
			self:SetWide(25)
			self:SetText('')
			self.PaintOver = function(self, w, h)
				surface.SetDrawColor(255, 255, 255)
				surface.DrawRect(7, 12, 11, 1)
				surface.DrawRect(12, 7, 1, 11)
				end

			self.DoClick = function(self)
				ui.StringRequest('Новый Плейлитс', 'Как вы хотите назвать этот плейлист?', 'Новый Плейлист', function(name)
					local favs = cvar.GetValue('media_saved_videos')
					if (favs[name]) then
						for k, v in pairs(playlistButtons) do
							if (k == name) then
								v:DoClick()
								return
							end
						end
					end

					favs[name] = {}
					cvar.SetValue('media_saved_videos', favs)

					playlistButtons[name] = playlistList:AddRow(name)
					playlistButtons[name]:DoClick()
				end)
			end
		end, sp)

		playlistButtons[defaultPlaylist] = self:AddRow(defaultPlaylist)
		playlistButtons[defaultPlaylist]:DoClick()

		for k, v in pairs(cvar.GetValue('media_saved_videos')) do
			if (k ~= defaultPlaylist) then
				playlistButtons[k] = self:AddRow(k)
			end
		end
	end, fr)

	local delPlaylist = ui.Create('DButton', function(self, p)
		self:SetSize(playlistList:GetWide(), 24)
		self:SetPos(playlistList.x, playlistList.y + playlistList:GetTall() - 1)
		self:SetText('Удалить Плейлист')
		self.Think = function(self)
			self:SetDisabled(currentVideoList == defaultPlaylist)
		end
		self.DoClick = function(self)
			if (self.clicked) then
				if (currentVideoList == defaultPlaylist) then return end

				local favs = cvar.GetValue('media_saved_videos')
				favs[currentVideoList] = nil
				cvar.SetValue('media_saved_videos', favs)

				playlistButtons[currentVideoList]:Remove()
				playlistList:PerformLayout()
				playlistButtons[defaultPlaylist]:DoClick()
				currentVideoList = defaultPlaylist

				listMedia()

				self.clicked = nil
				self:SetText('Удалить Плейлист')
			else
				self.clicked = true
				self:SetText('Нажмите ещё раз')

				timer.Simple(3, function()
					if (IsValid(self) and self.clicked) then
						self.clicked = nil
						self:SetText('Удалить Плейлист')
					end
				end)
			end
		end
	end, fr)

	fr.Think = function(self)
		if (currentVideoList ~= playlistList.Selected:GetText()) then
			currentVideoList = playlistList.Selected:GetText()
			listMedia()
		end
	end

	listMedia()

	ui.Create('DButton', function(self, p)
		self:SetText('Пауза')
		self:SetSize(75, 25)
		self:SetPos(5, p:GetTall() - 30)
		self.DoClick = function()
			cmd.Run('pausesong')
		end
		self.Think = function(self)
			self:SetDisabled(false)
			if ent:IsPaused() then
				self:SetText('Играть')
			else
				self:SetText('Пауза')
			end
		end
	end, fr)

	local text = ui.Create('DTextEntry', function(self, p)
		self:SetSize(p:GetWide() - 255, 25)
		self:SetPos(85, p:GetTall() - 30)
	end, fr)

	ui.Create('DButton', function(self, p)
		self:SetText('Play')
		self:SetSize(50, 25)
		self:SetPos(p:GetWide() - 165, p:GetTall() - 30)
		self.DoClick = function()
			cmd.Run('playsong', text:GetValue())
		end
		self.Think = function(self)
			if (not medialib.load('media').guessService(text:GetValue())) then
				self:SetDisabled(true)
			else
				self:SetDisabled(false)
			end
		end
	end, fr)

	ui.Create('DButton', function(self, p)
		self:SetText('Loop')
		self:SetSize(50, 25)
		self:SetPos(p:GetWide() - 110, p:GetTall() - 30)
		self.DoClick = function()
			cmd.Run('loopsong', text:GetValue())
		end
		self.Think = function(self)
			if (not medialib.load('media').guessService(text:GetValue())) then
				self:SetDisabled(true)
			else
				self:SetDisabled(false)
			end
		end
	end, fr)

	ui.Create('DButton', function(self, p)
		self:SetText('Save')
		self:SetSize(50, 25)
		self:SetPos(p:GetWide() - 55, p:GetTall() - 30)
		self.DoClick = function()
			local link = text:GetValue()
			local service = medialib.load('media').guessService(link)
			if service then
				service:query(link, function(err, data)
					if (not data) then return end
					if not videoList then return end

					local favs = cvar.GetValue('media_saved_videos')
					favs[currentVideoList] = favs[currentVideoList] or {}
					favs[currentVideoList][link] = {
						Title = data.title,
						Length = data.duration or 0,
						ID = data.id
					}

					cvar.SetValue('media_saved_videos', favs)
					listMedia()

					text:SetValue('')
				end)
			end
		end
		self.Think = function(self)
			local favs = cvar.GetValue('media_saved_videos')[currentVideoList] or {}
			if favs[text:GetValue()] or (not mediaservice.guessService(text:GetValue())) then
				self:SetDisabled(true)
			else
				self:SetDisabled(false)
			end
		end
	end, fr)
end
