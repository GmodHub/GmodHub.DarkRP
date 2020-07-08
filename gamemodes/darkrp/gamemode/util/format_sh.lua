local string_comma = string.Comma

function rp.FormatMoney(n)
	return '$' .. string_comma(n)
end

function rp.FormatCredits(n)
	return string_comma(n) .. ' Credits'
end

function rp.formatNumber(n)
	return string_comma(n)
end
