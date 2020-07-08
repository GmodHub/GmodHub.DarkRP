TOOL.Category = "Staff"
TOOL.Name		= '#tool.playercolorizer.name'

TOOL.ClientConVar['usemat'] = 1
TOOL.ClientConVar['mat'] = ''
TOOL.ClientConVar['r'] = 255
TOOL.ClientConVar['g'] = 255
TOOL.ClientConVar['b'] = 255
TOOL.ClientConVar['a'] = 255

local col_white = Color(255, 255, 255)
local editedPlayers = {}

local function editPlayer(pl, col, mat)
	editedPlayers[pl] = {col, mat}
	pl:SetColor(col)
	pl:SetMaterial(mat)
end

local function unEditPlayer(pl)
	editedPlayers[pl] = nil
	pl:SetColor(col_white)
	pl:SetMaterial()
end

function TOOL:LeftClick(tr)
	if (SERVER) then
		local r = self:GetClientNumber('r', 0)
		local g = self:GetClientNumber('g', 0)
		local b = self:GetClientNumber('b', 0)
		local a = self:GetClientNumber('a', 0)
		local col = Color(r, g, b, a)
		local mat = self:GetClientNumber('usemat') == 1 and self:GetClientInfo('mat') or nil

		if (IsValid(tr.Entity) and tr.Entity:IsPlayer()) then
			if (!ba.ranks.CanTarget(self:GetOwner(), tr.Entity)) then return true end

			editPlayer(tr.Entity, col, mat)
			rp.Notify(self:GetOwner(), NOTIFY_SUCCESS, term.Get('ColorizedPlayer'), tr.Entity)

			return true
		else
			editPlayer(self:GetOwner(), col, mat)

			rp.Notify(self:GetOwner(), NOTIFY_SUCCESS, term.Get('ColorizedYou'))
		end
	end

	return false
end

function TOOL:RightClick(tr)
	if (SERVER) then
		if (IsValid(tr.Entity) and tr.Entity:IsPlayer()) then
			if (!ba.ranks.CanTarget(self:GetOwner(), tr.Entity)) then return true end

			local pl = tr.Entity

			if (editedPlayers[pl]) then
				unEditPlayer(pl)
				rp.Notify(self:GetOwner(), NOTIFY_SUCCESS, term.Get('DecolorizedPlayer'), pl)
			end

			return true
		else
			local pl = self:GetOwner()

			if (editedPlayers[pl]) then
				unEditPlayer(pl)
				rp.Notify(self:GetOwner(), NOTIFY_SUCCESS, term.Get('DecolorizedYou'))
			end
		end
	end

	return false
end

local fr
function TOOL:Reload(tr)
	local pl = self:GetOwner()

	if (SERVER) then
		for k, v in pairs(editedPlayers) do
			if (!IsValid(k)) then editedPlayers[k] = nil end
		end

		net.Start('rp.ColorizedPlayers')
			net.WriteUInt(table.Count(editedPlayers), 7)
			for k, v in pairs(editedPlayers) do
				net.WritePlayer(k)
			end
		net.Send(pl)

	elseif (IsFirstTimePredicted()) then
		if (IsValid(fr)) then fr:Close() end

		fr = ui.Create('ui_frame', function(self)
			self:SetTitle("Colorized Players")
			self:SetSize(205, 300)
			self:Center()
			self:MakePopup()
		end)

		fr.lbl = ui.Create('DLabel', function(self)
			self:SetText("Loading")
			self:SizeToContents()
			self:Center()
		end, fr)
	end

	return false
end

if (CLIENT) then
	language.Add('tool.playercolorizer.name', 'Player Colorizer')
	language.Add('tool.playercolorizer.desc', 'Colorize and materialize players')
	language.Add('tool.playercolorizer.0', 'Left click to apply settings. Right click to remove settings. Reload to open edited players menu')

	net.Receive('rp.ColorizedPlayers', function(len)
		if (!IsValid(fr)) then return end

		local count = net.ReadUInt(7)

		if (count == 0) then
			fr.lbl:SetText("No colorized players!")
			fr.lbl:SizeToContents()
			fr.lbl:Center()

			return
		end

		fr.lbl:Remove()
		fr.list = ui.Create('ui_listview', function(self)
			self:DockMargin(0, 3, 0, 0)
			self:Dock(FILL)
		end, fr)
		fr.btn = ui.Create('DButton', function(self)
			self:SetText("Reset All")
			self:Dock(BOTTOM)

			self.DoClick = function()
				net.Start('rp.DecolorizePlayer')
					net.WriteBit(1)
				net.SendToServer()

				fr:Close()
			end
		end, fr)

		for i=1, count do
			local pl = net.ReadPlayer()

			if (IsValid(pl)) then
				local btn = fr.list:AddPlayer(pl)
				btn.DoClick = function()
					net.Start('rp.DecolorizePlayer')
						net.WriteBit(0)
						net.WritePlayer(pl)
					net.SendToServer()

					btn:Remove()
				end
			end
		end
	end)
else
	util.AddNetworkString('rp.ColorizedPlayers')
	util.AddNetworkString('rp.DecolorizePlayer')

	net.Receive('rp.DecolorizePlayer', function(len, pl)
		if (pl:IsSA()) then
			local all = net.ReadBit() == 1

			if (!all) then
				local targ = net.ReadPlayer()

				if (IsValid(targ) and ba.ranks.CanTarget(pl, targ)) then
					unEditPlayer(targ)
					rp.Notify(pl, NOTIFY_SUCCESS, term.Get('DecolorizedPlayer'), targ)
				end
			else
				for k, v in pairs(editedPlayers) do
					if (IsValid(k) and (k == pl or ba.ranks.CanTarget(pl, k))) then
						unEditPlayer(k)
					end
				end
				rp.Notify(pl, NOTIFY_SUCCESS, term.Get('DecolorizedAll'))
				table.Empty(editedPlayers)
			end
		end
	end)

	hook('PlayerSpawn', 'rp.colorizer.PlayerSpawn', function(pl)
		local dat = editedPlayers[pl]
		if dat then
			pl:SetColor(dat[1])
			pl:SetMaterial(dat[2])
		end
	end)
end

function TOOL.BuildCPanel(CPanel)
	CPanel:AddControl('Header', {Description = '#tool.playercolorizer.desc'})
	CPanel:AddControl('Color', {Label = 'Color', Red = 'playercolorizer_r', Green = 'playercolorizer_g', Blue = 'playercolorizer_b', Alpha = 'playercolorizer_a'})
	CPanel:AddControl('checkbox', {Label = 'Set Material', Command = 'playercolorizer_usemat'})
	CPanel:MatSelect('playercolorizer_mat', list.Get('OverrideMaterials'), true, 64, 64)
end