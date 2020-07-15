-- Generated on
-- Saturday, May 2, 2020 10:48:46 AM

AddCSLuaFile'gpakr/rpbase-data.lua'
AddCSLuaFile'gpakr/tnttemp-data.lua'
AddCSLuaFile'gpakr/textures-data.lua'
AddCSLuaFile'gpakr/playermodels-data.lua'
AddCSLuaFile'gpakr/drugs-data.lua'
AddCSLuaFile'gpakr/cosmetics-data.lua'
AddCSLuaFile'gpakr/knives-data.lua'
AddCSLuaFile'gpakr/weapons-data.lua'

local files = {include'gpakr/rpbase-data.lua',include'gpakr/tnttemp-data.lua',include'gpakr/textures-data.lua',include'gpakr/playermodels-data.lua',include'gpakr/drugs-data.lua',include'gpakr/cosmetics-data.lua',include'gpakr/knives-data.lua',include'gpakr/weapons-data.lua',}
local parent = (SERVER) and 'addons/gpakr_out/data/' or 'download/data/'

file.CreateDir('gmh/rp')

local color_red = {r=255, g=0, b=0, a=255}
local color_green = {r=0, g=255, b=0, a=255}
local color_white = {r=255, g=255, b=255, a=255}
local color_highlight = {r=150, g=200, b=175, a=255}
local function print(...)
	MsgC(color_green, '[gPakr] ', color_white, unpack{...})
	MsgN()
end

local function error(...)
	print(color_red, '[ERROR] ', color_white, ...)
end

local function round(num, idp)
	local mult = 10 ^ (idp or 2)
	return math.floor(num * mult + 0.5)/mult
end

print 'Init'

local compressedSize = 0
local decompressedSize = 0
local totalTime = 0
local function prepare(outFile, inf)
	local start = SysTime()

	local fh = file.Open(parent .. inf.File, 'rb', 'GAME')
	if (not fh) then
		error('Unable to open datapack: ', color_highlight, inf.FileName, color_whit)
		return false
	end

	local size = fh:Size()

	--[[if (size ~= inf.Len) then
		error('File size mismatch expected ', color_highlight, inf.Len, color_white, ' got ', color_highlight, size, color_white, ' for datapack: ', color_highlight, inf.FileName, color_white)
		fh:Close()
		return false
	end]]

	compressedSize = compressedSize + size

	local compressedData = fh:Read(size)
	fh:Close()

	if (not compressedData) then
		error('Unable to read datapack: ', color_highlight, inf.FileName, color_white)
		return false
	end

	local rawData = util.Decompress(compressedData)

	compressedData = nil
	collectgarbage()

	if (not rawData) then
		error('Unable to decompress datapack: ', color_highlight, inf.FileName, color_white)
		return false
	end

	local fh2 = file.Open(outFile, 'wb', 'DATA')
	if (not fh2) then
		error('Unable to open outfile for datapack: ', color_highlight, inf.FileName, color_white)
		return false
	end

	decompressedSize = decompressedSize + rawData:len()

	fh2:Write(rawData)
	fh2:Close()

	rawData = nil
	collectgarbage()

	local time = (SysTime() - start)

	totalTime = totalTime + time

	print('Cached datapack: ', color_highlight, inf.FileName, color_white,' in ', color_highlight, round(time, 4), color_white, ' seconds')

	return true
end

local totalFiles = 0
local function mount(inf)
	local outFile =  inf.File .. '.dat'
	local isCached = file.Exists(outFile, 'DATA')

	if (not isCached) and (not file.Exists(parent .. inf.File, 'GAME')) then
		error('Missing datapack: ', color_highlight, inf.FileName)
		return 0
	end

	if (not isCached) and (not prepare(outFile, inf)) then
		return 0
	end

	local start = SysTime()

	local succ, files = game.MountGMA('data/' .. outFile)

	if (not succ) then
		print('Failing to mount datapack: ', color_highlight, inf.FileName)
		return 0
	end

	totalFiles = totalFiles + #files

	local time = (SysTime() - start)

	print('Mounted datapack: ', color_highlight, inf.FileName, color_white, ' in ', color_highlight, round(time, 4), color_white,' seconds')

	return time
end

for k, v in ipairs(files) do
	if (not v.ShouldLoad) then
		print('Ignored datapack: ', color_highlight, v.FileName)
		continue
	end

	if (SERVER) then
		resource.AddSingleFile('data/' .. v.File)
	end

	totalTime = totalTime + mount(v)
end

if (compressedSize > 0) then
	print('Decompressed ', color_highlight, round(compressedSize/1048576) .. 'MB')
end

if (decompressedSize > 0) then
	print('Cached ', color_highlight, round(decompressedSize/1048576) .. 'MB')
end

print('Loaded ', color_highlight, totalFiles, color_white, ' files')
print('Finished in ', color_highlight, round(totalTime, 4), color_white, ' seconds')
