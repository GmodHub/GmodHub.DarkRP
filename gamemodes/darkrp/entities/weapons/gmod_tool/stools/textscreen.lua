TOOL.Category		= 'Roleplay'
TOOL.Name			= '#Textscreen'
TOOL.Command		= nil
TOOL.ConfigName		= ''

TOOL.Information = {
	{ name = "left" },
	{ name = "right" }
}

local createdFonts = {}
local function getFont(name)
	if (not createdFonts[name]) then
		local fd = {
			font = name,
			size = 20,
			weight = 1500,
			shadow = true,
			antialias = true,
			symbol = (name == 'Webdings')
		}

		surface.CreateFont('textscreen.preview.' .. name, fd)

		createdFonts[name] = true
	end

	return 'textscreen.preview.' .. name
end

TOOL.ClientConVar['font'] = rp.cfg.TextSrceenFonts[1]
TOOL.ClientConVar['text'] = 'No text!'
TOOL.ClientConVar['background'] = 1
TOOL.ClientConVar['size'] = 20
TOOL.ClientConVar['r' ] = 255
TOOL.ClientConVar['g' ] = 255
TOOL.ClientConVar['b'] = 255
TOOL.ClientConVar['r2' ] = 25
TOOL.ClientConVar['g2' ] = 25
TOOL.ClientConVar['b2'] = 25

cleanup.Register('textscreens')

if (CLIENT) then
	language.Add('Tool.textscreen.name', 'Textscreen')
	language.Add('Tool.textscreen.desc', 'Create floating text')

	language.Add('Tool.textscreen.left', 'Spawn a textscreen')
	language.Add('Tool.textscreen.right', 'Update an existing textscreen')

	language.Add('Undone.textscreens', 'Undone textscreen')
	language.Add('Undone_textscreens', 'Undone textscreen')
	language.Add('Cleanup.textscreens', 'Textscreens')
	language.Add('Cleanup_textscreens', 'Textscreens')
	language.Add('Cleaned.textscreens', 'Cleaned up all textscreens')
	language.Add('Cleaned_textscreens', 'Cleaned up all textscreens')

	language.Add('SBoxLimit.textscreens', 'You\'ve hit the textscreen limit!')
	language.Add('SBoxLimit_textscreens', 'You\'ve hit the textscreen limit!')
end

function TOOL:GetFont()
	local font = 1
	for k, v in ipairs(rp.cfg.TextSrceenFonts) do
		if (v == self:GetClientInfo('font')) then
			font = k
			break
		end
	end
	return font
end

function TOOL:LeftClick(tr)
	if (CLIENT) then return true end

	local pl = self:GetOwner()

	if (not pl:CheckLimit('textscreens')) then return false end

	local pos = tr.HitPos
	local ang = tr.HitNormal:Angle()
	ang:RotateAroundAxis(tr.HitNormal:Angle():Right(), -90)
	ang:RotateAroundAxis(tr.HitNormal:Angle():Forward(), 90)

	local ent = ents.Create('ent_textscreen')
	ent:SetPos(pos)
	ent:SetAngles(ang)
	ent:Spawn()
	ent:Activate()
	ent:CPPISetOwner(self:GetOwner())

	local color_text = Color(math.Clamp(tonumber(self:GetClientInfo('r')) or 255, 0, 255), math.Clamp(tonumber(self:GetClientInfo('g')) or 255, 0, 255), math.Clamp(tonumber(self:GetClientInfo('b')) or 255, 0, 255)):ToEncodedRGB()
	local color_background = Color(math.Clamp(tonumber(self:GetClientInfo('r2')) or 255, 0, 255), math.Clamp(tonumber(self:GetClientInfo('g2')) or 255, 0, 255), math.Clamp(tonumber(self:GetClientInfo('b2')) or 255, 0, 255)):ToEncodedRGB()

	ent:UpdateInfo(self:GetClientInfo('text'), self:GetFont(), tonumber(self:GetClientInfo('size')), tobool(self:GetClientInfo('background')), color_text, color_background)

	undo.Create('textscreens')
		undo.AddEntity(ent)
		undo.SetPlayer(pl)
	undo.Finish()

	pl:AddCount('textscreens', ent)
	pl:AddCleanup('textscreens', ent)

	rp.Notify(pl, NOTIFY_HINT, term.Get('SboxSpawned'), pl:GetCount('textscreens'), pl:GetLimit('textscreens'), 'textscreens')

	return true
end

function TOOL:RightClick(tr)
	if (not IsValid(tr.Entity)) or (tr.Entity:GetClass() ~= 'ent_textscreen') then return false end
	if (CLIENT) then return true end

	local color_text = Color(math.Clamp(tonumber(self:GetClientInfo('r')) or 255, 0, 255), math.Clamp(tonumber(self:GetClientInfo('g')) or 255, 0, 255), math.Clamp(tonumber(self:GetClientInfo('b')) or 255, 0, 255)):ToEncodedRGB()
	local color_background = Color(math.Clamp(tonumber(self:GetClientInfo('r2')) or 255, 0, 255), math.Clamp(tonumber(self:GetClientInfo('g2')) or 255, 0, 255), math.Clamp(tonumber(self:GetClientInfo('b2')) or 255, 0, 255)):ToEncodedRGB()

	tr.Entity:UpdateInfo(self:GetClientInfo('text'), self:GetFont(), tonumber(self:GetClientInfo('size')), tobool(self:GetClientInfo('background')), color_text, color_background)

	return true
end

local ConVarsDefault = TOOL:BuildConVarList()
function TOOL.BuildCPanel(CPanel)
	CPanel:AddControl('Header', {
		Text = '#Tool.textscreen.name',
		Description = '#Tool.textscreen.desc'
	})

	CPanel:AddControl("ComboBox", {
		MenuButton = 1,
		Folder = "textscreen",
		Options = {
			["#preset.default"] = ConVarsDefault
		},
		CVars = table.GetKeys(ConVarsDefault)
	})

	local textPreview
	local colorPicker
	local colorPicker2
	local fontPicker
	local sizePicker
	local textInput

	local resetAll = vgui.Create('DButton', resetbuttons)
	resetAll:SetSize(100, 25)
	resetAll:SetText('Reset')
	resetAll.DoClick = function()
		local menu = DermaMenu()
		menu:AddOption('Font', function()
			RunConsoleCommand('textscreen_font', 'Tahoma')
		end)
		menu:AddOption('Text Color', function()
			RunConsoleCommand('textscreen_r', 255)
			RunConsoleCommand('textscreen_g', 255)
			RunConsoleCommand('textscreen_b', 255)
		end)
		menu:AddOption('Background Color', function()
			RunConsoleCommand('textscreen_r2', 25)
			RunConsoleCommand('textscreen_g2', 25)
			RunConsoleCommand('textscreen_b2', 25)
		end)
		menu:AddOption('Size', function()
			RunConsoleCommand('textscreen_size', 50)
			sizePicker:SetValue(50)
		end)
		menu:AddOption('Textbox', function()
			RunConsoleCommand('textscreen_text', '')
			textInput:SetValue('')
		end)
		menu:AddOption('Everything', function()
			RunConsoleCommand('textscreen_r', 255)
			RunConsoleCommand('textscreen_g', 255)
			RunConsoleCommand('textscreen_b', 255)

			RunConsoleCommand('textscreen_size', 50)
			sizePicker:SetValue(50)

			RunConsoleCommand('textscreen_text', '')
			textInput:SetValue('')
		end)
		menu:Open()
	end
	CPanel:AddItem(resetAll)

	local defaultFont = rp.cfg.TextSrceenFonts[1]

	textPreview = CPanel:AddControl('Label', {
		Text = 'Preview',
	})
	textPreview.Think = function()
		textPreview:SetColor(Color(GetConVarNumber('textscreen_r'), GetConVarNumber('textscreen_g'), GetConVarNumber('textscreen_b')))
	end
	textPreview:SetFont(getFont(defaultFont))

	colorPicker = CPanel:AddControl('Color', {
		Label = 'Text Color',
		Red = 'textscreen_r',
		Green = 'textscreen_g',
		Blue = 'textscreen_b',
		ShowHSV = 1,
		ShowRGB = 1,
		Multiplier = 255
	})

	colorPicker2 = CPanel:AddControl('Color', {
		Label = 'Background Color',
		Red = 'textscreen_r2',
		Green = 'textscreen_g2',
		Blue = 'textscreen_b2',
		ShowHSV = 1,
		ShowRGB = 1,
		Multiplier = 255
	})

	fontPicker = vgui.Create('DComboBox')
	fontPicker:ChooseOption(defaultFont)
	fontPicker.OnSelect = function(pnl, idx, value)
		RunConsoleCommand('textscreen_font', rp.cfg.TextSrceenFonts[idx] or defaultFont)
		textPreview:SetFont(getFont(rp.cfg.TextSrceenFonts[idx] or defaultFont))
	end
	for k, v in ipairs(rp.cfg.TextSrceenFonts) do
		fontPicker:AddChoice(rp.cfg.TextScreenPrettyFontNames[v] or v)
	end
	CPanel:AddItem(fontPicker)

	CPanel:AddControl("CheckBox", { Label = "Enable background", Command = "textscreen_background", Help = false })

	sizePicker = vgui.Create('DNumSlider')
	sizePicker:SetText('Size (doesn\'t show in preview)')
	sizePicker:SetMinMax(20, 100)
	sizePicker:SetDecimals(0)
	sizePicker:SetValue(50)
	sizePicker:SetConVar('textscreen_size')
	CPanel:AddItem(sizePicker)

	textInput = vgui.Create('DTextEntry')
	textInput:SetUpdateOnType(true)
	textInput:SetEnterAllowed(true)
	textInput:SetConVar('textscreen_text')
	textInput:SetValue(GetConVarString('textscreen_text'))
	textInput.OnTextChanged = function()
		local value = textInput:GetValue()
		textPreview:SetText(value)

		if (value:len() > 175) then
			textInput:SetValue(value:sub(1, 175))
		end
	end
	textInput:SetTall(100)
	textInput:SetMultiline(true)
	CPanel:AddItem(textInput)
end
