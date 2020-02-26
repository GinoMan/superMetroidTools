--Author Pasky13, GinoMan2440

--Text scaler - Written by Pasky13
local xs
local ys

local function scaler()
	xs = client.screenwidth() / 256
	ys = client.screenwidth() / 224
end

-- stats vars
local positionX = 0
local positionY = 849 --vs 896 in windowed (4x) or 1080 in fullscreen
local color = 0xAA00FF0F
local bgcolor = 0xAA000000

-- Time to get object oriented. 
BottomPanel = {
	width = 0,
	height = 0,
	hOffset = 0,
	vOffset = 0,
	lHeight = 15,
	charWidth = 5,
	hasBorder = false,
	hasBackground = false,
	panelText = {}
}

function BottomPanel:new ()
	o = {} 
	o = setmetatable(o, BottomPanel)
	self.__index = self
	self.panelText = {}
	-- self.panelText = {}
	return o
end

function BottomPanel:addLine(LineString)
	table.insert(self.panelText, LineString)
end

function BottomPanel:calculateBottomRect()
	local screenHeight = client.screenheight()
	local screenWidth = client.screenwidth()
	local boxHeight = 0
	local gameWidth = 0
	local biggestWidth = 0
	local width = 0

	-- calculate the game window size based on height
	-- trying it with 8:7 
	gameWidth = (screenHeight * 8) / 7
	gameWidth = math.ceil(gameWidth)

	-- the renderer needs to account for this when rendering the panelText.
	if self.hasBorder then 
		boxHeight = boxHeight + 4 
		width = width + 4
	end

	boxHeight = boxHeight + (((table.maxn(self.panelText) + 1) * self.lHeight) + 2)
	self.height = boxHeight - 2

	for key,value in ipairs(self.panelText)
	do
		if string.len(value) > biggestWidth then biggestWidth = string.len(value) end
	end

	width = width + (biggestWidth * self.charWidth)

	self.width = width

	vOffset = screenHeight - boxHeight
	hOffset = (screenWidth - gameWidth) / 2
	hOffset = hOffset - 73
	-- positionY = vOffset
	-- positionY = hOffset

	self.vOffset = vOffset
	self.hOffset = hOffset
	return vOffset, hOffset
end

function BottomPanel:render()
	self:calculateBottomRect()
	if self.hasBackground then
		gui.drawBox(self.hOffset, self.vOffset, self.hOffset + self.width, self.vOffset + self.height, 0xFF000000, 0xFF000000)
	end
	if self.hasBorder then 
		gui.drawBox(self.hOffset, self.vOffset, self.hOffset + self.width, self.vOffset + self.height, color)
		self.width = self.width - 4
		self.height = self.height - 4
		self.hOffset = self.hOffset + 4
		self.vOffset = self.vOffset + 4
	end
	for key,value in ipairs(self.panelText)
	do
		gui.text(self.hOffset, self.vOffset + (key * self.lHeight), value, color, bgcolor)
	end
end

local function showStats()
	local totalFrames = mainmemory.read_u8(0x1842) -- Total frames in the whole run.
	local igtMin = mainmemory.readbyte(0x09DE) -- Current Minutes. For hours, divide by 60 and modulo by 60
	local igtSec = mainmemory.readbyte(0x09DC) -- Current Seconds
	local igtHour = mainmemory.readbyte(0x09E0) -- Current Hours
	local igtFrame = mainmemory.readbyte(0x09DA) -- Current Frame in each second.
	local gameState = mainmemory.readbyte(0x0998) -- game state. 
	-- 1 = intro
		-- 4 = Data Select Screen
		-- 2 = Option Mode
		-- 5 = world map
		-- 6 = gameplay
		-- 3 = ?
		-- 30 = Last Metroid...
		-- 31 = brief period between intro and station
		-- 8 = ceres station

	if totalFrames == 0 or gameState < 6 then
		igtMin = 0
		igtSec = 0
		igtFrame = 0
	end

	-- igtHour = igtMin / 60;
	-- igtMin = igtMin % 60;
	
	displayFrames = string.format("Total: %08u", totalFrames)
	displayTime = 	string.format("GTime: %02u:%02u:%02u:%02u", igtHour, igtMin, igtSec, igtFrame)
	displayState = 	string.format("State: %u", gameState)

	local Renderer = BottomPanel:new()
	Renderer:addLine(displayState)
	Renderer:addLine(displayFrames)
	Renderer:addLine(displayTime)
	Renderer:render()
	
	-- gui.opacity(opacity);
	-- gui.text(positionX, positionY, displayState, color, bgcolor); 
	-- gui.text(positionX, positionY + lineSpacing, displayFrames, color, bgcolor); 
	-- gui.text(positionX, positionY + (2 * lineSpacing), displayTime, color, bgcolor)
end



local Items = {
	maxEnergy = 0,
	curMissiles = 0,
	maxMissiles = 0,
	curSuperMissiles = 0,
	maxSuperMissiles = 0,
	curPowerBombs = 0,
	maxPowerBombs = 0,
	curReserveTank = 0,
	maxReserveTank = 0,
	
	itemsCollected = 0,
	
	beamByte = 0,
	itemByte = 0,
	chargeBeamByte = 0,
	
	chargeBeam = false,
	iceBeam = false,
	waveBeam = false,
	spazerBeam = false,
	plasmaBeam = false,
	
	variaSuit = false,
	gravitySuit = false,
	
	morphBall = false,
	bombs = false,
	springBall = false,
	screwAttack = false,
	
	highJumpBoots = false,
	spaceJumpBoots = false,
	speedBoosters = false,
	
	grappleBeam = false,
	xRayScope = false
}

local function updateQuantities()
	Items.maxEnergy = mainmemory.read_u16_le(0x09C4)
	Items.curMissiles = mainmemory.read_u16_le(0x09C6)
	Items.maxMissiles = mainmemory.read_u16_le(0x09C8)
	Items.curSuperMissiles = mainmemory.read_u16_le(0x09CA)
	Items.maxSuperMissiles = mainmemory.read_u16_le(0x09CC)
	Items.curPowerBombs = mainmemory.read_u16_le(0x09CE)
	Items.maxPowerBombs = mainmemory.read_u16_le(0x09D0)
	Items.curReserveTank = mainmemory.read_u16_le(0x09D6)
	Items.maxReserveTank = mainmemory.read_u16_le(0x09D4)
end

local function updateItems()
	Items.itemByte = mainmemory.read_u16_le(0x09A4) -- Collected Items
	Items.beamByte = mainmemory.readbyte(0x09A8) -- Collected Beams
	Items.chargeBeamByte = mainmemory.readbyte(0x09A9) -- Charge Beams
	
	local items = Items.itemByte
	local beams = Items.beamByte
	
	-- XY>*   %^   G  ZoNV
	-- 1111 0001 0010 0101	
	
	--    C           PSIW
	-- 0001 0000 0000 1111
	
	-- Item					Code			Mask
	-- Charge Beam:			C				& 0x10 - to charge byte
	-- Ice Beam:			I				& 0x02 - to beam byte
	-- Wave Beam:			W				& 0x01
	-- Spazer Beam:			S				& 0x04
	-- Plasma Beam:			P				& 0x08
	
	-- Varia Suit:			V				& 0x0001
	-- Gravity Suit:		G				& 0x0020
	
	-- Morph Ball:			o				& 0x0004
	-- Bombs:				*				& 0x1000
	-- Spring Ball:			N				& 0x0002
	-- Screw Attack:		Z				& 0x0008
	
	-- High Jump Boots:		^				& 0x0100
	-- Space Jump Boots:	%				& 0x0200
	-- Speed Boosters:		>				& 0x2000
	
	-- Grapple Beam:		Y				& 0x4000
	-- XRay Scope:			X				& 0x8000
	
	Items.chargeBeam = bit.check(Items.chargeBeamByte, 4)
	Items.iceBeam = bit.check(beams, 1)
	Items.waveBeam = bit.check(beams, 0)
	Items.spazerBeam = bit.check(beams, 2)
	Items.plasmaBeam = bit.check(beams, 3)
	
	Items.variaSuit = bit.check(items, 0)
	Items.gravitySuit = bit.check(items, 5)
	
	Items.morphBall = bit.check(items, 2)
	Items.bombs = bit.check(items, 12)
	Items.springBall = bit.check(items, 1)
	Items.screwAttack = bit.check(items, 3)
	
	Items.highJumpBoots = bit.check(items, 8)
	Items.spaceJumpBoots = bit.check(items, 9)
	Items.speedBoosters = bit.check(items, 13)
	
	Items.grappleBeam = bit.check(items, 14)
	Items.xRayScope = bit.check(items, 15)
end

local function showMax()	
	local missileLocationX = 78
	local iconBarY = 22
	local boxWidth = 75
	local boxHeight = 8
	local textColor = 0xFFFFFFFF
	local textBGColor = 0xAA293A8C
	local gameState = mainmemory.readbyte(0x0998) -- game state. 
	
	updateQuantities()
	
	missileString = string.format("%03u/%03u", Items.curMissiles, Items.maxMissiles)
	superString = string.format("%02u/%02u", Items.curSuperMissiles, Items.maxSuperMissiles)
	powerString = string.format("%02u/%02u", Items.curPowerBombs, Items.maxPowerBombs)
	reserveString = string.format("Reserve: %03u/%03u", Items.curReserveTank, Items.maxReserveTank)
	
	if (gameState >= 6) and (gameState ~= 30) and (gameState ~= 34) then
		gui.drawRectangle(missileLocationX, iconBarY, boxWidth, boxHeight, 0x00000000, 0xFF000000)
		if Items.maxMissiles > 0 then
			gui.pixelText(missileLocationX, iconBarY + 2, missileString, textColor, textBGColor) --
		end
		if Items.maxSuperMissiles > 0 then
			gui.pixelText(missileLocationX + 32, iconBarY + 2, superString, textColor, textBGColor)
		end
		if Items.maxPowerBombs > 0 then
			gui.pixelText(missileLocationX + 56, iconBarY + 2, powerString, textColor, textBGColor)
		end
		if Items.maxReserveTank > 0 then
			gui.pixelText(8, 31, reserveString, textColor)
		end
	end
end

local iIcons = {
	Collected = "",
	NotCollected = ""
}

local function calculateCollectionRate()
	updateItems()
	updateQuantities()
	local gameState = mainmemory.readbyte(0x0998) -- game state.
	
	missiles = Items.maxMissiles / 5
	superMissiles = Items.maxSuperMissiles / 5
	powerBombs = Items.maxPowerBombs / 5
	energy = (Items.maxEnergy - 99) / 100
	reserve = Items.maxReserveTank / 100
	
	items = 0
	items = items + (Items.chargeBeam and 1 or 0)
	items = items + (Items.iceBeam and 1 or 0)
	items = items + (Items.waveBeam and 1 or 0)
	items = items + (Items.spazerBeam and 1 or 0)
	items = items + (Items.plasmaBeam and 1 or 0)
	
	items = items + (Items.variaSuit and 1 or 0)
	items = items + (Items.gravitySuit and 1 or 0)
	
	items = items + (Items.morphBall and 1 or 0)
	items = items + (Items.bombs and 1 or 0)
	items = items + (Items.springBall and 1 or 0)
	items = items + (Items.screwAttack and 1 or 0)
	
	items = items + (Items.highJumpBoots and 1 or 0)
	items = items + (Items.spaceJumpBoots and 1 or 0)
	items = items + (Items.speedBoosters and 1 or 0)
	
	items = items + (Items.grappleBeam and 1 or 0)
	items = items + (Items.xRayScope and 1 or 0)
	
	Items.itemsCollected = missiles + superMissiles + powerBombs + energy + reserve + items
		-- debug start at 8 x 40, then go down 8 for each line

end

local function showCollectionRate()
	updateItems()
	local gameState = mainmemory.readbyte(0x0998) -- game state. 
	-- Put x/100 on the screen in the corner under Grapple Beam and XRay Scope
	if (gameState >= 6) and (gameState ~= 30) and (gameState ~= 34) then
		-- local itemsCollected = string.format("0x%04X", Items.itemsCollected)
		-- local beamsCollected = string.format("0x%02X%02X", Items.chargeBeam, Items.beamsCollected)
		-- the x and y are almost perfect for the string Items: 000%
		-- gui.pixelText(78 + 80, 24, itemsCollected, 0xFFFFFFFF, 0xAA293A8C)
		-- this y is perfect for the item icons, but the x should be the same as missile alignment
		-- gui.pixelText(78 + 80, 30, beamsCollected, 0xFFFFFFFF)
		calculateCollectionRate()
		local collectionString = string.format("items:%03u%%", Items.itemsCollected)
		gui.pixelText(78 + 82, 24, collectionString, 0xFFFFFFFF, 0xAA293A8C)
	end
end

local function showItems()
	updateItems()
	-- put item icons on screen right below top bar
	local gameState = mainmemory.readbyte(0x0998) -- game state. 
	
	if (gameState >= 6) and (gameState ~= 30) and (gameState ~= 34) then
		local itemsBarX = 85
		local itemsBarY = 31
		local stringTemplate = "CIWSP  VG  o*NZ  ^%>  Y X"
		local itemTable = {}
		itemTable["C"] = Items.chargeBeam
		itemTable["I"] = Items.iceBeam
		itemTable["W"] = Items.waveBeam
		itemTable["S"] = Items.spazerBeam
		itemTable["P"] = Items.plasmaBeam
		itemTable["V"] = Items.variaSuit
		itemTable["G"] = Items.gravitySuit
		itemTable["o"] = Items.morphBall
		itemTable["*"] = Items.bombs
		itemTable["N"] = Items.springBall
		itemTable["Z"] = Items.screwAttack
		itemTable["^"] = Items.highJumpBoots
		itemTable["%"] = Items.spaceJumpBoots
		itemTable[">"] = Items.speedBoosters
		itemTable["Y"] = Items.grappleBeam
		itemTable["X"] = Items.xRayScope
		
		local position = itemsBarX
		local charWidth = 4
		local gray = 0xFF999999
		local green = 0xFF00FF00
		local background = 0xBB000000
		local transparency = 0x00000000
		local barWidth = 0
		
		gui.drawRectangle(position -2, itemsBarY - 1, charWidth * string.len(stringTemplate) + 4, 9, transparency, background)
		
		for i = 1, string.len(stringTemplate) do
			local key = string.sub(stringTemplate, i, i)
			if itemTable[key] ~= " " then
				-- All of the drawing code should go here
				if itemTable[key] then
					gui.pixelText(position, itemsBarY, key, green, transparency)
				else 
					gui.pixelText(position, itemsBarY, key, gray, transparency)
				end
			end
			position = position + charWidth
			barWidth = barWidth + charWidth
		end
		-- gui.pixelText(itemsBarX, itemsBarY, iIcons.NotCollected, 0xFF999999, 0xBB000000)
		-- gui.pixelText(itemsBarX, itemsBarY, iIcons.Collected, 0xFF00FF00, 0x00000000)
	ends
end



while true do
	scaler()
	showStats()
	showMax()
	showCollectionRate()
	showItems()
	emu.frameadvance()
end