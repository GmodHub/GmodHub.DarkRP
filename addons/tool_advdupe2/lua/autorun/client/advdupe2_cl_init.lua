AdvDupe2 = {
	Version = "1.1.0",
	Revision = 51,
	InfoText = {},
	DataFolder = "advdupe2",
	FileRenameTryLimit = 256
}

if(!file.Exists(AdvDupe2.DataFolder, "DATA"))then
	file.CreateDir(AdvDupe2.DataFolder)
end

include "advdupe2/cl_file.lua"
include "advdupe2/cl_networking.lua"
include "advdupe2/file_browser.lua"
include "advdupe2/sh_codec.lua"

function AdvDupe2.Notify(msg,typ,dur)
	GAMEMODE:AddNotify(msg, typ or NOTIFY_GENERIC, dur or 5)
end

usermessage.Hook("AdvDupe2Notify",function(um)
	AdvDupe2.Notify(um:ReadString(),um:ReadChar(),um:ReadChar())
end)

timer.Simple(0, function()
	AdvDupe2.ProgressBar={}
end)