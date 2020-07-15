local filters = {}

--[[
	Default
	['$pp_colour_addr']         = 0,
	['$pp_colour_addg']         = 0,
	['$pp_colour_addb']         = 0,
	['$pp_colour_brightness']   = 0,
	['$pp_colour_contrast']     = 1,
	['$pp_colour_colour']       = 1,
	['$pp_colour_mulr']         = 0,
	['$pp_colour_mulg']         = 0,
	['$pp_colour_mulb']         = 0
]]
filters['None'] = 0
filters['Vibrant'] = {
	['$pp_colour_addr']         = 0,
	['$pp_colour_addg']         = 0,
	['$pp_colour_addb']         = 0,
	['$pp_colour_brightness']   = 0,
	['$pp_colour_contrast']     = 1,
	['$pp_colour_colour']       = 1.5,
	['$pp_colour_mulr']         = 0,
	['$pp_colour_mulg']         = 0,
	['$pp_colour_mulb']         = 0
}
filters['Super Vibrant'] = {
	['$pp_colour_addr']         = 0,
	['$pp_colour_addg']         = 0,
	['$pp_colour_addb']         = 0,
	['$pp_colour_brightness']   = 0,
	['$pp_colour_contrast']     = 1,
	['$pp_colour_colour']       = 2.5,
	['$pp_colour_mulr']         = 0,
	['$pp_colour_mulg']         = 0,
	['$pp_colour_mulb']         = 0
}
filters['Washed Out'] = {
	['$pp_colour_addr']         = 0,
	['$pp_colour_addg']         = 0,
	['$pp_colour_addb']         = 0,
	['$pp_colour_brightness']   = 0,
	['$pp_colour_contrast']     = 1,
	['$pp_colour_colour']       = 0.5,
	['$pp_colour_mulr']         = 0,
	['$pp_colour_mulg']         = 0,
	['$pp_colour_mulb']         = 0
}
filters['Black & White'] = {
	['$pp_colour_addr']         = 0,
	['$pp_colour_addg']         = 0,
	['$pp_colour_addb']         = 0,
	['$pp_colour_brightness']   = 0,
	['$pp_colour_contrast']     = 1,
	['$pp_colour_colour']       = 0,
	['$pp_colour_mulr']         = 0,
	['$pp_colour_mulg']         = 0,
	['$pp_colour_mulb']         = 0
}

local DrawColorModify = DrawColorModify

cvar.Register('ColorFilter')
	:SetType(TYPE_STRING)
	:SetDefault('Vibrant')
	:SetCustomElement('ui_filter_picker')
	.Validate = function(self, name)
		return filters[name] != nil
	end

hook('RenderScreenspaceEffects', function()
	local filter = cvar.GetValue('ColorFilter') or 'None'

	if (filter == 'None' or !filters[filter]) then return end

	DrawColorModify(filters[filter])
end)

local PANEL = {}

function PANEL:SetCvar(cvar)
	self.Cvar = cvar
end

function PANEL:Init()
	self.lblFilter = ui.Create('DLabel', function(lbl)
		lbl:SetText('Цветовая Палитра: ')
	end, self)

	self.filterPicker = ui.Create('DComboBox', function(cmb)
		cmb:SetValue(cvar.GetValue('ColorFilter') or 'None')

		for k, v in pairs(filters) do
			cmb:AddChoice(k)
		end

		cmb.OnSelect = function(cmb, idx, filter)
			self.Cvar:SetValue(filter)
		end
	end, self)
end

function PANEL:ApplySchemeSettings()
	self.lblFilter:SetFont('ui.18')
end

function PANEL:PerformLayout()
	local tw = 0
	surface.SetFont('ui.22')
	for k, v in pairs(filters) do
		local _tw = surface.GetTextSize(k)
		tw = math.max(tw, _tw)
	end

	self.lblFilter:SizeToContents()
	self.lblFilter:SetPos(5, 3)
	self.filterPicker:SetSize(tw + 36, self.lblFilter:GetTall() + 6)
	self.filterPicker:SetPos(self.lblFilter:GetWide() + 5, 0)
	self:SetHeight(self.filterPicker:GetTall())
end

vgui.Register('ui_filter_picker', PANEL, 'Panel')
