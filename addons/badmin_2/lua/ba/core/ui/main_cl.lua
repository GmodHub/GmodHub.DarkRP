ba.ui = ba.ui or {}

local utf8_len = utf8.len
local utf8_sub = utf8_sub

function ba.ui.OpenAuthLink(link)
	gui.OpenURL('https://superiorservers.co/api/auth/login?return=https://superiorservers.co' .. link)
end

function ba.ui.WordWrap(font, text, width, emotes)
	surface.SetFont(font)

	//if utf8.len(text) != string.len(text) then
	//	width = width * 2
	//end

	local ret = {}

	local strpos = 1
	local bitstart = 1
	local bits = string.Explode('\n', text, false)
	for k, v in ipairs(bits) do
		local w = 0
		local s = ''
		local lastsp = 0

		if isnumber(utf8_len(v)) then
			local i = 1
			while (i <= utf8_len(v)) do
				local char = utf8_sub(v, i, i)
				local charW

				if (emotes and emotes[strpos]) then
					charW = 16
				else
					charW = surface.GetTextSize(char)
				end

				if (w + charW > width) then
					if (lastsp != 0) then -- split to the last space
						s = utf8_sub(s, 1, utf8_len(s)-(i-lastsp)+1)
						ret[#ret+1] = s

						s = ''
						w = 0

						strpos = strpos - (i - lastsp)
						i = lastsp + 1
						lastsp = 0 -- reset the space
					else -- split right here
						ret[#ret + 1] = s
						w = charW
						s = char

						strpos = strpos + 1
						lastsp = 0

						i = i + 1
					end
				else
					if (char == ' ') then
						lastsp = i
					end

					s = s .. char
					w = w + charW
					strpos = strpos + 1

					i = i + 1
				end
			end
		end

		if (s != '' or bits[k+1]) then
			ret[#ret + 1] = s
		end

		strpos = strpos + 2
		bitstart = strpos
	end
	return ret
end
