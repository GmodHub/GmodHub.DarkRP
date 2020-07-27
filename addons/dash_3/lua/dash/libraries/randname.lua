randName 				= {}

local randName 		= randName
local http_fetch 	= http.Fetch
local json_to_table = util.JSONToTable

local failures		 = 0

function randName.Get(cback, failure)
	http_fetch('https://api.namefake.com/', function(b)
		if (b == '404 page not found') then
			error('RandName: Failed to lookup ip: ' .. ip)
		else
			local res = json_to_table(b)
			failures = 0
			cback(res.name)
		end
	end, function()
		if (failures <= 5) then
			timer.Simple(5, function()
				failures = failures + 1
				randName.Get(ip, cback, failure)
			end)
		else
			failure()
		end
	end)
end
