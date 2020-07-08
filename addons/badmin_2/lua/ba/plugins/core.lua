-------------------------------------------------
-- Setid
-------------------------------------------------
term.Add('SerevrIDSet', 'Server ID set to #')

ba.AddCommand('SetID', function(pl, id)
	ba.svar.Set('sv_id', id)
	return ba.NOTIFY_NORM, term.Get('SerevrIDSet'), id
end)
:AddParam(cmd.STRING)
:SetFlag '*'
:SetHelp 'Sets the server ID | Don\'t fuck with this one.'

-------------------------------------------------
-- Set Group
-------------------------------------------------
term.Add('SetRank', '# has set #\'s rank to # #')

ba.AddCommand('SetGroup', function(pl, targ, rank, time, expirerank)
	if time and (not expirerank) then
		return ba.NOTIFY_ERROR, term.Get('MissingArg'), 'Expire Rank'
	end
	ba.data.SetRank(targ, rank, (expirerank or rank) , (time and os.time() + time or 0), function(data)
		ba.notify_all(term.Get('SetRank'), pl, targ, rank, (expirerank and ('expiring to ' .. expirerank .. ' in ' .. string.FormatTime(time)) or ' '))
	end)
end)
:AddParam(cmd.PLAYER_STEAMID32)
:AddParam(cmd.RANK)
:AddParam(cmd.TIME, cmd.OPT_OPTIONAL)
:AddParam(cmd.RANK, cmd.OPT_OPTIONAL)
:SetFlag 'S'
:SetHelp 'Sets a players rank'

-------------------------------------------------
-- Set Group
-------------------------------------------------
ba.AddCommand('ResetPassword', function(pl, targ, resetkey)
	if (#resetkey < 4) then
		return ba.NOTIFY_ERROR, term.Get('AdminPasswordTooShort'), 4
	end
	ba.ResetPassword(targ, resetkey, true, function()
		ba.notify_staff(term.Get('AdminPasswordReset'), pl, targ)
	end)
end)
:AddParam(cmd.PLAYER_ENTITY)
:AddParam(cmd.STRING)
:SetFlag 'G'
:SetHelp 'Resets a staff member\'s administrative password'

-------------------------------------------------
-- Adminmode
-------------------------------------------------
term.Add('EnterAdminmode', '# is now administrating.')
term.Add('ExitAdminmode', '# is no longer administrating.')

ba.AddCommand('AdminMode', function(pl)
	if pl:HasFlag('M') then
		if (not ba.IsAuthed(pl)) then
			ba.RequestAuth(pl, function() pl:RunCommand('adminmode') end)
			return
		end

		if pl:HasFlag('A') then
			pl:SetBVar('adminmode',  (not pl:GetBVar('adminmode')))
			if pl:GetBVar('adminmode') then
				ba.notify_staff(term.Get('EnterAdminmode'), pl)
			else
				ba.notify_staff(term.Get('ExitAdminmode'), pl)
			end
		end
	end
end)
:SetHelp 'Enables you to noclip and manipulate props'

-------------------------------------------------
-- Help
-------------------------------------------------
if (CLIENT) then
	local opts = {
		[cmd.OPT_OPTIONAL] = 'Optional'
	}

	local params = {
		[cmd.RANK] 					= 'Rank',
		[cmd.STRING] 				= 'String',
		[cmd.NUMBER]				= 'Number',
		[cmd.TIME]					= 'Time',
		[cmd.PLAYER_ENTITY]			= 'Player',
		[cmd.PLAYER_STEAMID32]		= 'Player/SteamID32',
		[cmd.PLAYER_STEAMID64]		= 'Player/SteamID64',
		[cmd.PLAYER_ENTITY_MULTI] 	= 'Player/s OR SteamID'
	}

	local function buildOpts(o)
		local str = ''

		for k, v in pairs(o) do
			str = str .. '(' .. (opts[k] or '???') .. ')'
		end
		return str
	end

	local function buildParams(n, p)
		local str = '\n/' .. n
		for k, v in ipairs(p) do
			str = str .. ' ' .. (params[v.Enum] or 'Param') .. buildOpts(v.Opts) .. ((k == #p) and '' or ',')
		end
		return str
	end

	local PANEL = {}

	function PANEL:Init()
		self.SearchBar = ui.Create('DTextEntry', self)
		self.SearchBar:RequestFocus()
		self.SearchBar.OnChange = function(s)
			self.PlayerList:AddCommands(s:GetValue())
		end

		self.PlayerList = ui.Create('ui_listview', self)
		self.PlayerList.AddCommands = function(s, inf)
			inf = inf and inf:Trim()

			s:Reset()

			local count = 0
			for k, v in pairs(cmd.GetTable()) do
				if (k ~= v:GetName()) and (not inf) then continue end --Alias

				if ((not v:GetFlag()) or LocalPlayer():HasFlag(v:GetFlag())) and (v:GetConCommand() == 'ba') and ((not inf) or (inf and string.find(k, inf:lower(), 1, true)) or (inf and v:GetHelp() and string.find(v:GetHelp():lower(), inf:lower(), 1, true))) then

					local row = s:AddRow(
						((k ~= v:GetName()) and '(Alias)' or '') .. v:GetNiceName() ..
						buildParams(k, v:GetParams()) ..
						(v:GetHelp() and ('\n' .. v:GetHelp()) or '')
					)
					local h = 45
					h = v:GetHelp() and (h + 20) or h

					row:SetTall(h)
					row:SetContentAlignment(4)
					row:SetTextInset(5, 0)

					count = count + 1
				end
			end

			if (count <= 0) then
				s:AddSpacer('No commands found!')
			end
		end

		self.PlayerList:AddCommands()
	end

	function PANEL:PerformLayout()
		self.SearchBar:SetPos(0, 0)
		self.SearchBar:SetSize(self:GetWide(), 25)

		self.PlayerList:SetPos(0, 30)
		self.PlayerList:SetSize(self:GetWide(), self:GetTall() - 30)
	end

	function PANEL:OnSelection(row, pl)

	end

	function PANEL:DockToFrame()
		local p = self:GetParent()
		local x, y = p:GetDockPos()
		self:SetPos(x, y)
		self:SetSize(p:GetWide() - 10, p:GetTall() - (y + 5))
	end

	vgui.Register('ba_help_panel', PANEL, 'Panel')
end

ba.AddCommand 'Help'
:RunOnClient(function()
	local fr = ui.Create('ui_frame', function(self)
		self:SetSize(600, ScrH() * 0.5)
		self:SetTitle('Command help')
		self:Center()
		self:MakePopup()
	end)
	ui.Create('ba_help_panel', function(self, p)
		self:SetPos(5, 32)
		self:SetSize(p:GetWide() - 10, p:GetTall() - 37)
	end, fr)
end)
:SetHelp 'Tells you helpful info about itself and other commands'
