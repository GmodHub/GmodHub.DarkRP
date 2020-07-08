ba.chatEmotes = {}

file.CreateDir 'badmin/emotes'

local function loadEmotesList(dat, imgurl)
	if (not dat or not imgurl) then return end
	for k, v in pairs(dat) do
		local url = string.Replace(imgurl, '{item_id}', tostring(v.id))
		local em = ':' .. k .. ':'

		ba.chatEmotes[em] = {
			name = em,
			loadUrl = url,
			mat = false
		}
	end
end

local function loadEmotesPayload(cachefile, url, imgurl, resolvePayload)
	if file.Exists(cachefile, 'DATA') and ((os.time() - file.Time(cachefile, 'DATA')) > 86400) then
		local dat = util.JSONToTable(file.Read(cachefile, 'DATA'))
		if (not dat) then
			file.Delete(cachefile)
		else
			loadEmotesList(dat, imgurl)
		end
	else
		http.Fetch(url, function(body)
			local dat = util.JSONToTable(body)
			if dat then
				file.Delete(cachefile)

				if resolvePayload then
					dat = resolvePayload(dat)
					file.Write(cachefile, util.TableToJSON(dat))
				else
					file.Write(cachefile, body)
				end

				loadEmotesList(dat, imgurl)
			end
		end, function()
			if file.Exists(cachefile, 'DATA') then
				local dat = util.JSONToTable(file.Read(cachefile, 'DATA'))
				loadEmotesList(dat, imgurl)
			end
		end)
	end
end

loadEmotesPayload('badmin/emotes/forum.dat', 'https://cdn.superiorservers.co/forum_ratings/list.json', 'https://cdn.superiorservers.co/forum_ratings/images/{item_id}.png')
loadEmotesPayload('badmin/emotes/custom.dat', 'https://gmod-api.superiorservers.co/api/emotes/custom', 'https://superiorservers.co/static/images/emotes/{item_id}.png')
loadEmotesPayload('badmin/emotes/twemoji_v2.dat', 'https://cdn.superiorservers.co/twemoji/list_v2.json', 'https://cdn.superiorservers.co/twemoji/36x36/{item_id}.png')
loadEmotesPayload('badmin/emotes/twitch_v41.dat', 'https://api.twitchemotes.com/api/v4/channels/0', 'https://static-cdn.jtvnw.net/emoticons/v1/{item_id}/4.0', function(data) 
	local emotes = {}
	for i = 1, #data.emotes do
		local e = data.emotes[i]
		if not e.code:find('\\', 1, true) then
			emotes[e.code] = {id = e.id}
		end
	end
	return emotes
end)