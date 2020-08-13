/*
local fh = file.Open("gmh/in/cosmetics.gma", 'rb', 'DATA')
local size = fh:Size()
local compressedData = fh:Read(size)
local rawData = util.Compress(compressedData)
fh:Close()
file.Write("gmh/in/cosmetics.txt", rawData)

local SteamIDS = '["76561198972640651","76561198987456088","76561198262928689","76561198947042529","76561199003309192","76561198348830833","76561198970668959","76561198273537495","76561197999918685","76561199027971923","76561198168266683","76561198355550953","76561198804220084","76561198196745303","76561198233765124","76561198061760026","76561198995555199","76561198236978314","76561199050306892","76561198319634213","76561198873409093","76561198833036495","76561199028157886","76561198419586041","76561198967180011","76561198243172588","76561198419263915","76561198957400376","76561198808946887","76561197981489666","76561198885910287","76561198830497524","76561198334838497","76561198798858832","76561198358925640","76561198894693716","76561198370798197","76561198876874170","76561199004425821","76561198887235906","76561198156876086","76561199018229689","76561198886253098","76561198253951830","76561199012844741","76561198193058857","76561198998468746","76561198259027966","76561198324318473","76561199025833041","76561198281855833","76561198932056853","76561198416480623","76561198997027239","76561198843275367","76561198112426393","76561198173837354","76561198194404141","76561198356963824","76561198407792202","76561199055490386","76561198838167924","76561199008821948","76561198258157353","76561198822533959","76561198813638594","76561198950981057","76561198979969370","76561198254531690","76561198784802671","76561198974102789","76561198996257831","76561198903773644","76561198357038480","76561198264636892","76561198347271791","76561199029643581","76561198417189097","76561198887517550","76561198801908327","76561198941257852","76561198314968288","76561198915572715","76561198986161369","76561198380991439","76561198342922336","76561198817687887","76561198901798115","76561198995337584","76561198917628158","76561198995794505","76561198987126369","76561198398969310","76561198799705880","76561198208438505","76561198373065301","76561198988893626","76561198335294059","76561198812849661","76561198231735676","76561198846964996","76561198400596634","76561198253732795","76561198802352245"]'
SteamIDS = util.JSONToTable(SteamIDS)
for k,v in pairs(SteamIDS) do
	timer.Simple(math.random(1, 15), function()
		RunConsoleCommand("ba", "perma", v, "Использование багов")
	end)
end

ids = {}

local data = file.Read("result.txt", "DATA")

local t = string.Explode('\n', data)

for k,v in pairs(t) do
	local f = string.Left(v, 43)
	local b = string.Right(f, 18)
	local steamid = string.Left(b, 17)

	if !table.HasValue(ids, steamid) and steamid != "" then
		table.insert(ids, steamid)
		print(steamid)
	end
end
file.Write("resultend.txt", util.TableToJSON(ids))


timer.Simple( 1, function()
	require('query')

	query.EnableInfoDetour(true)
	//for i=1,3 do RunConsoleCommand('bot') end

	print('Detour enabled')
	hook.Add("A2S_INFO", "reply", function(ip, port, info)
	    print("A2S_INFO from", ip, port)
		
	    info.players = 100
	    info.map = 'newbie'
		
	    return info
	end)

	local playersTable={}
	local talbeName = util.JSONToTable(file.Read('names.txt', 'DATA'))
	for i=1,91 do
		local time = math.Round(math.random(100, 5000))
		table.insert(playersTable, {name = table.Random(talbeName), score = 0, time = time})
	end
	PrintTable(playersTable)

	hook.Add('A2S_PLAYER', 'HackPlayers', function(ip, port, info)
		return playersTable
	end)
end)


timer.Simple(1,function()
require("query")
query.EnableInfoDetour(true)
for i=1,3 do RunConsoleCommand("bot") end

print("Detour enabled")
hook.Add("A2S_INFO", "reply", function(ip, port, info)
	info.name="GALAXY RP "
    info.players = 71
	info.tags="gm:darkrp"
	info.maxplayers = 70
    return info
end)

local shit={
	{name = "Караван", score = 1, time = 123},
	{name = "GaySSHA", score = 1, time = 425},
	{name = "Kayfar4", score = 1, time = 413},
	{name = "KEK", score = 1, time = 12312},
	{name = "-=MAFIOZNIK=-", score = 1, time = 123},
	{name = "Единорог", score = 27, time = 233},
	{name = "Rastaman", score = 1, time = 4123},
	{name = "pes()", score = 1, time = 1231},
	{name = "FrimonGordan", score = 1, time = 312},
	{name = "Lemos", score = 1, time = 0},
	{name = "MARIO", score = 1, time = 13212},
	{name = "NoobKiller", score = 1, time = 133},
	{name = "картошка", score = 1, time = 0},
	{name = ":3", score = 1, time = 0},
	{name = "KotePodNarkote", score = 1, time = 121},
	{name = "Foxs", score = 1, time = 0},
	{name = "Artur", score = 1, time = 0},
	{name = "Джесси", score = 1, time = 0},
	{name = "PENISDETROV", score = 1, time = 1233},
	{name = "Goga", score = 1, time = 0},
	{name = "ТупоРОФЛ", score = 1, time = 0},
	{name = "MemBoi", score = 1, time = 123},
	{name = "peasd", score = 1, time = 123},
	{name = "MrTrololoshka", score = 1, time = 0},
	{name = "DeusEx", score = 1, time = 0},
}
hook.Add("A2S_PLAYER", "reply", function(ip, port, info)
	return shit
end)
end)