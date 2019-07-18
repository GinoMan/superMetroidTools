-- stats vars
local positionX = 0
local positionY = 835
local lineSpacing = 15
local color = 0xAA00FF0F
local bgcolor = 0xAA000000
local sessionFrames = 0
local lastTime = 0

local function showStats()
	igtMin = mainmemory.readbyte(0x09DE) -- Current Minutes. For hours, divide by 60 and modulo by 60
	igtSec = mainmemory.readbyte(0x09DC) -- Current Seconds
	igtFrame = mainmemory.readbyte(0x09DA) -- Current Frame in each second.
	gameState = mainmemory.readbyte(0x0998) -- game state. 
	totalFrames = (igtMin * 60 * 60) + (igtSec * 60) + (igtFrame)
	if totalFrames > lastTime then
		sessionFrames = sessionFrames + 1
	end
	if gameState <= 4 or (gameState <= 42 and gameState >= 30) then
		sessionFrames = 0; 
		igtMin = 0
		igtSec = 0
		igtFrame = 0
	end
	
		-- 1 = intro
		-- 4 = Data Select Screen
		-- 2 = Option Mode
		-- 5 = world map
		-- 6 = gameplay
		-- 3 = ?
		-- 30 = Last Metroid...
		-- 31 = brief period between intro and station
		-- 8 = Gameplay
		-- 11 = Room transition

	igtHour = igtMin / 60;
	igtMin = igtMin % 60;

	displayFrames = string.format("Total: %08u  Session: %08u", totalFrames, sessionFrames)
	displayTime = 	string.format("GTime: %02u:%02u:%02u:%02u", igtHour, igtMin, igtSec, igtFrame)
	displayState = 	string.format("State: %u", gameState)

	-- gui.opacity(opacity);
	gui.text(positionX, positionY, displayState, color, bgcolor); 
	gui.text(positionX, positionY + lineSpacing, displayFrames, color, bgcolor); 
	gui.text(positionX, positionY + (2 * lineSpacing), displayTime, color, bgcolor)
	lastTime = totalFrames
end

while true do
	showStats()
	emu.frameadvance()
end