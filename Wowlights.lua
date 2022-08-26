--   ## WoW Lights - ©2022 J∆•Softcode (www.jdsoftcode.net) ##

-------------------------- DEFINE USER SLASH COMMANDS ------------------------

SLASH_WOWLT1 = "/wlights"

-------------------------- ADD-ON GLOBALS ------------------------

WoWLights = {}							--  namespace for all addon functions

WowPtGridSize = 3.35
WLTexWide = 6
WLTexHigh = 3

WLhasBeenLoaded = false;

local whiteColorInt   = 16777215
local blackColorInt   = 0
local redColorInt     = 16711680
local orangeColorInt  = 16744448
local yellowColorInt  = 16776960
local greenColorInt   = 65280
local cyanColorInt    = 65535
local blueColorInt    = 255
local magentaColorInt = 16711935

local goldColorInt = yellowColorInt
local silverColorInt = 8421504
local copperColorInt = 12023884
local deathColorInt = 6579300

local combatColorInt = redColorInt

OribosZoneNames = "Oribos Орибос"	--  All western + Russian
InBetweenZoneNames = "The In-Between Der Zwischenraum La Zona Intermedia Entre-Deux O Intermédio Промежуток" 
										--  English, German, Spanish, French, Portugues, Russian

local playerBgGrid = { -- this needs to be loadable and editable; change for character/talent spec
	redColorInt,  -- array is indexed 1-18
	blackColorInt,
	yellowColorInt,
	blackColorInt,
	greenColorInt,
	blackColorInt,
	blackColorInt,
	orangeColorInt,
	blackColorInt,
	magentaColorInt,
	blackColorInt,
	blueColorInt,
	cyanColorInt,
	blackColorInt,
	redColorInt,
	blackColorInt,
	greenColorInt,
	blackColorInt
}



------------------------------ STARTUP MAIN FRAME  ---------------------------

WoWLightsFrame = CreateFrame("Frame","WoW Lights",UIParent)
WoWLightsFrame:SetFrameStrata("LOW")
-- ?? do not parent="UIParent" so my frame remains while interface is hidden, and does not scale up/down with UI

WoWLightsFrame:SetScript("OnEvent", function(self, event, ...) 
	WoWLights:OnEvent(self,event, ...) 
end)

--WoWLightsFrame:SetScript("OnUpdate", function(self, elapsed) 
--	WoWLights:OnUpdate(elapsed) 
--end)

WoWLightsFrame:RegisterEvent("ADDON_LOADED")

---------------------- HANDLE SETTINGS BOX CONTROLS -------------

local function pickedNewColor()
	rr, gg, bb = ColorPickerFrame:GetColorRGB()
	print("got r="..rr.." g="..gg.." b="..bb)
end

local function rejectedNewColor()
	print("cancelled color pick")
end

--local function handleSelectNewColor(colorInt)
--	rr, gg, bb = 0,1.0,0 -- how to do this with function defined below?
--	ColorPickerFrame:SetColorRGB(rr, gg, bb)
--	ColorPickerFrame.func = pickedNewColor
--	ColorPickerFrame.cancelFunc = rejectedNewColor
--	ColorPickerFrame:Hide() 
--	ColorPickerFrame:Show() 
--end


------------------------- CREATE SETTINGS FRAME ----------------------------

WoWLightsOptionsFrame = CreateFrame("Frame","WoWLightsOpt",UIParent,"PortraitFrameTemplate")
WoWLightsOptionsFrame:Hide()
WoWLightsOptionsFrame:SetFrameStrata("HIGH")
WoWLightsOptionsFrame:SetPoint("CENTER")
WoWLightsOptionsFrame:SetSize(500,300)
WoWLightsOptionsFrame:SetScript("OnShow", function(self, ff) PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN) end)
WoWLightsOptionsFrame:SetScript("OnHide", function(self, ff) PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE) end)
WoWLightsOptPortrait:SetTexture("Interface\\MERCHANTFRAME\\UI-BuyBack-Icon")

local t = WoWLightsOptionsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
t:SetText("WoW Lights Settings")
t:SetSize(200,36)
t:SetPoint("TOPLEFT",WoWLightsOptionsFrame,"TOPLEFT",160,7)

local t1 = WoWLightsOptionsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
t1:SetText("Keyboard Basic Colors")
t1:SetSize(200,36)
t1:SetPoint("TOPLEFT",WoWLightsOptionsFrame,"TOPLEFT",110,-35)

local t2 = WoWLightsOptionsFrame:CreateFontString(nil, "ARTWORK", "GameFontWhiteSmall")
t2:SetText("Click to change one color")
t2:SetSize(200,36)
t2:SetPoint("TOPLEFT",WoWLightsOptionsFrame,"TOPLEFT",108,-138)

local t3 = WoWLightsOptionsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
t3:SetText("Character: Waldokind")
t3:SetSize(200,36)
t3:SetPoint("TOPLEFT",WoWLightsOptionsFrame,"TOPLEFT",250,-70)
WoWLightsOptionsFrame.charString = t3

local t4 = WoWLightsOptionsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
t4:SetText("Spec: Retribution")
t4:SetSize(200,36)
t4:SetPoint("TOPLEFT",WoWLightsOptionsFrame,"TOPLEFT",270,-100)
WoWLightsOptionsFrame.specString = t4

local t5 = WoWLightsOptionsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
t5:SetText("Combat Flash Brightness")
t5:SetSize(200,36)
t5:SetPoint("TOPLEFT",WoWLightsOptionsFrame,"TOPLEFT",20,-180)

local t6 = WoWLightsOptionsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
t6:SetText("Frame Size")
t6:SetSize(200,36)
t6:SetPoint("TOPLEFT",WoWLightsOptionsFrame,"TOPLEFT",300,-180)


local b1 = CreateFrame("Button",nil,WoWLightsOptionsFrame,"UIPanelButtonTemplate")
b1:SetText("Set Row 1")
b1:SetPoint("TOPLEFT",WoWLightsOptionsFrame,"TOPLEFT",20,-70)
b1:SetSize(100,24)
b1:SetScript("OnClick", function(self, btn,down) 
	ColorPickerFrame:SetColorRGB(0,1.0,0)
	ColorPickerFrame.func = pickedNewColor
	ColorPickerFrame.cancelFunc = rejectedNewColor
	ColorPickerFrame:Hide() 
	ColorPickerFrame:Show() 
	end)

local b2 = CreateFrame("Button",nil,WoWLightsOptionsFrame,"UIPanelButtonTemplate")
b2:SetText("Set Row 2")
b2:SetPoint("TOPLEFT",WoWLightsOptionsFrame,"TOPLEFT",20,-95)
b2:SetSize(100,24)
b2:SetScript("OnClick", function(self, btn,down) PlaySound(SOUNDKIT.IG_MINIMAP_ZOOM_OUT) end)

local b3 = CreateFrame("Button",nil,WoWLightsOptionsFrame,"UIPanelButtonTemplate")
b3:SetText("Set Row 3")
b3:SetPoint("TOPLEFT",WoWLightsOptionsFrame,"TOPLEFT",20,-120)
b3:SetSize(100,24)
b3:SetScript("OnClick", function(self, btn,down) PlaySound(SOUNDKIT.IG_MINIMAP_ZOOM_OUT) end)

local b4 = CreateFrame("Button",nil,WoWLightsOptionsFrame,"UIPanelButtonTemplate")
b4:SetText("Memorize")
b4:SetPoint("TOPLEFT",WoWLightsOptionsFrame,"TOPLEFT",350,-140)
b4:SetSize(100,24)
b4:SetScript("OnClick", function(self, btn,down) PlaySound(SOUNDKIT.IG_MINIMAP_ZOOM_OUT) end)

local b5 = CreateFrame("Button",nil,WoWLightsOptionsFrame,"UIPanelButtonTemplate")
b5:SetText("Reset Animation")
b5:SetPoint("TOPLEFT",WoWLightsOptionsFrame,"TOPLEFT",20,-270)
b5:SetSize(150,24)
b5:SetScript("OnClick", function(self, btn,down) PlaySound(SOUNDKIT.IG_MINIMAP_ZOOM_OUT) end)

local b6 = CreateFrame("Button",nil,WoWLightsOptionsFrame,"UIPanelButtonTemplate")
b6:SetText("Cancel")
b6:SetPoint("TOPLEFT",WoWLightsOptionsFrame,"TOPLEFT",270,-270)
b6:SetSize(100,24)
b6:SetScript("OnClick", function(self, btn,down) PlaySound(SOUNDKIT.IG_MINIMAP_ZOOM_OUT) end)

local b7 = CreateFrame("Button",nil,WoWLightsOptionsFrame,"UIPanelButtonTemplate")
b7:SetText("OK")
b7:SetPoint("TOPLEFT",WoWLightsOptionsFrame,"TOPLEFT",380,-270)
b7:SetSize(100,24)
b7:SetScript("OnClick", function(self, btn,down) PlaySound(SOUNDKIT.IG_MINIMAP_ZOOM_OUT) end)


local s1 = CreateFrame("Slider","slider",WoWLightsOptionsFrame,"OptionsSliderTemplate")
s1:SetPoint("TOPLEFT",WoWLightsOptionsFrame,"TOPLEFT",45,-210)
s1:SetMinMaxValues(3, 10)
s1:SetValueStep(1)
sliderLow:SetText("faint")
sliderHigh:SetText("bright")
s1:SetValue(6)
s1:SetScript("OnValueChanged", function(self, evt, arg1) print(evt) end)


local e1 = CreateFrame("EditBox",nil,WoWLightsOptionsFrame,"InputBoxTemplate")
e1:SetPoint("TOPLEFT",WoWLightsOptionsFrame,"TOPLEFT",378,-212)
e1:SetSize(50,24)
e1:SetMultiLine(false)
e1:SetAutoFocus(false)
e1:SetFontObject("ChatFontNormal")
e1:SetText("3.4")
e1:SetScript("OnEnterPressed", function(self) print(self:GetText()) end)



---------------------------- SLASH COMMAND HANDERS ---------------------------
SlashCmdList["WOWLT"] = function(msg, theEditFrame) WoWLightsOptionsFrame:Show() end



--------------------------- GRID MATH UTILITIES -----------------------------
-- returns array index (0-17) of background grid location (row, col)
local function indexOf(row, col)
	return row*WLTexWide + col
end

-- returns x,y: a random point between (0,0) and (17,7) on default scaling
local function randomGridPoint()
	local xMax = 0.5 + (WLTexWide-1) * WowPtGridSize
	local yMax = 0.5 + (WLTexHigh-1) * WowPtGridSize
	return fastrandom(0,xMax), fastrandom(0,yMax)
	
end

-------------------------- COLOR CONVERT UTILITIES -----------------------------

-- convert red, green, and blue in floating point 0...1 scale to a colorInt
local function color1ToInt(r, g, b)
	return math.floor(r*255)*65536 + math.floor(g*255)*256 + math.floor(b*255)
end

-- convert red, green, and blue in 8-bit 0...255 scale to a colorInt
local function color255ToInt(r, g, b)
	return r*65536 + g*256 + b
end

-- convert a colorInt to WoW compatible red, green, and blue in floating point 0...1 scale
local function intToColor(color)
	local b = (color % 256)
	local g = ((color-b) % 65536) / 256
	local r = (color-b-g*256) / 65536
	return r/255,g/255,b/255
end


------------------ BUILDERS FOR THE GRAPHIC COMPONENTS --------------------

-- create the overlay zone that appears on all the keys at once
local function makeAlloverFrame(ff)

	local aof = CreateFrame("Frame","$parentOverall",ff)
	aof:SetSize(WowPtGridSize * WLTexWide, WowPtGridSize * WLTexHigh)
	aof:SetPoint("TOPLEFT", ff, "TOPLEFT", 0, 0)

	aof.tex = aof:CreateTexture("allOverTex","OVERLAY")
	aof.tex:SetAllPoints()
	local tr, tg, tb = intToColor(combatColorInt)
	aof.tex:SetColorTexture(tr, tg, tb,1)
	aof:SetAlpha(0)

	aof.fadeInOut = aof:CreateAnimationGroup()
	aof.fadeInOut:SetLooping("BOUNCE")

	aof.fader = aof.fadeInOut:CreateAnimation("ALPHA")
	aof.fader:SetFromAlpha(0.8)
	aof.fader:SetToAlpha(0.0)
	aof.fader:SetDuration(1.0)
	
	return aof
end

-- construct the background lights grid of 18 samples using global var: playerBgGrid
local function makeBackground(ff)
	local baseTex = {}
	for r = 0,WLTexHigh-1 do
		for c = 0, WLTexWide-1 do
			local bgColor = playerBgGrid[indexOf(r,c)+1]
			local tex = ff:CreateTexture("bgTex","BACKGROUND")
			tex:SetSize(WowPtGridSize,WowPtGridSize)
			tex:SetPoint("BOTTOMLEFT", ff, "BOTTOMLEFT", c*WowPtGridSize, (WLTexHigh-1-r)*WowPtGridSize)
			local tr, tg, tb = intToColor(bgColor)
			tex:SetColorTexture(tr, tg, tb, 1)	
			baseTex[indexOf(r,c)] = tex
		end
	end
	
	return baseTex
end

-- create the money exchange animation frame
local function makeMoneyWipe(ff)

	local wiper = CreateFrame("Frame","$parentWiper",ff)
	wiper:SetSize(WowPtGridSize*WLTexWide,WowPtGridSize)
	wiper:SetPoint("TOPLEFT", ff, "TOPLEFT", 0, 0)

	wiper.tex = wiper:CreateTexture("wipeTex","ARTWORK")
	wiper.tex:SetAllPoints()
	local tr, tg, tb = intToColor(goldColorInt)
	wiper.tex:SetColorTexture(tr, tg, tb,1)
	wiper:SetAlpha(0) -- texture is hidden until animated

	wiper.wipeDown = wiper:CreateAnimationGroup()
	wiper.wipeDown:SetLooping("NONE")

	wiper.wipe = wiper.wipeDown:CreateAnimation("TRANSLATION")
	wiper.wipe:SetOffset(0,-(WowPtGridSize-1)*WLTexHigh)
	wiper.wipe:SetDuration(0.5)
	
	wiper.wipe:SetScript("OnPlay", function(self)
		self:GetParent():GetParent():SetAlpha(1) -- reveal the texture
	end)

	wiper.wipe:SetScript("OnFinished", function(self)
		self:GetParent():GetParent():SetAlpha(0) -- hide the texture again
	end)
	
	return wiper
end


-- helper to create part of the multi-part vertical animation frame
local function makeVerticalWipeSegment(ff, segNum, colorInt, duration, startDelay)
	local wiper = CreateFrame("Frame","$parentVertWipe"..segNum,ff)
	wiper:SetSize(WowPtGridSize*WLTexWide,WowPtGridSize)
	wiper:SetPoint("TOPLEFT", ff, "TOPLEFT", 0, 0)

	wiper.tex = wiper:CreateTexture("vwipeTex"..segNum,"ARTWORK",-segNum)
	wiper.tex:SetAllPoints()
	local tr, tg, tb = intToColor(colorInt)
	wiper.tex:SetColorTexture(tr, tg, tb,1)
	wiper:SetAlpha(0) -- texture is hidden until animated

	wiper.wipeDown = wiper:CreateAnimationGroup()
	wiper.wipeDown:SetLooping("NONE")

	wiper.wipe = wiper.wipeDown:CreateAnimation("TRANSLATION")
	wiper.wipe:SetOffset(0,-(WowPtGridSize-1)*WLTexHigh)
	wiper.wipe:SetDuration(duration)
	wiper.wipe:SetStartDelay(startDelay)
	
	wiper.wipe:SetScript("OnUpdate", function(self)
		if self:GetParent():GetParent():GetAlpha() == 0 and not self:IsDelaying() then 
			self:GetParent():GetParent():SetAlpha(1) -- reveal the texture
		end
	end)

	wiper.wipe:SetScript("OnFinished", function(self)
		self:GetParent():GetParent():SetAlpha(0) -- hide the texture again
	end)
	
	return wiper
end


-- create a 5-part vertical rainbow animation
local function makeVerticalRainbowWipe(ff)

	local dur = 0.5
	local stagger = dur/3
	wipe1 = makeVerticalWipeSegment(ff, 1, redColorInt, dur, 0)
	wipe2 = makeVerticalWipeSegment(ff, 2, orangeColorInt, dur, stagger)
	wipe3 = makeVerticalWipeSegment(ff, 3, yellowColorInt, dur, stagger*2)
	wipe4 = makeVerticalWipeSegment(ff, 4, greenColorInt, dur, stagger*3)
	wipe5 = makeVerticalWipeSegment(ff, 5, blueColorInt, dur, stagger*4)	
	return {wipe1, wipe2, wipe3, wipe4, wipe5}
end


-- helper to create part of a multi-part horizontal animation frame
local function makeHorizontalWipeSegment(ff, segNum, colorInt, duration, startDelay)
	local wiper = CreateFrame("Frame","$parentHorzWipe"..segNum,ff)
	wiper:SetSize(WowPtGridSize, WLTexHigh*WowPtGridSize)
	wiper:SetPoint("TOPLEFT", ff, "TOPLEFT", 0, 0)

	wiper.tex = wiper:CreateTexture("hwipeTex"..segNum,"ARTWORK",-segNum)
	wiper.tex:SetAllPoints()
	local tr, tg, tb = intToColor(colorInt)
	wiper.tex:SetColorTexture(tr, tg, tb,1)
	wiper:SetAlpha(0) -- texture is hidden until animated

	wiper.wipeRight = wiper:CreateAnimationGroup()
	wiper.wipeRight:SetLooping("NONE")

	wiper.wipe = wiper.wipeRight:CreateAnimation("TRANSLATION")
	wiper.wipe:SetOffset(WowPtGridSize*WLTexWide, 0)
	wiper.wipe:SetDuration(duration)
	wiper.wipe:SetStartDelay(startDelay)
	
	wiper.wipe:SetScript("OnUpdate", function(self)
		if self:GetParent():GetParent():GetAlpha() == 0 and not self:IsDelaying() then 
			self:GetParent():GetParent():SetAlpha(1) -- reveal the texture
		end
	end)

	wiper.wipe:SetScript("OnFinished", function(self)
		self:GetParent():GetParent():SetAlpha(0) -- hide the texture again
	end)
	
	return wiper
end

-- create a horizontal blue/white animation with gaps
local function makeHorizontalBlueWhiteWipe(ff)

	local dur = 0.75
	local stagger = dur/6
	wipe1 = makeHorizontalWipeSegment(ff, 1, blueColorInt, dur, 0)
	wipe2 = makeHorizontalWipeSegment(ff, 2, whiteColorInt, dur, stagger)
	--gap
	wipe3 = makeHorizontalWipeSegment(ff, 3, blueColorInt, dur, stagger*5)
	wipe4 = makeHorizontalWipeSegment(ff, 4, whiteColorInt, dur, stagger*6)
	--gap
	wipe5 = makeHorizontalWipeSegment(ff, 5, blueColorInt, dur, stagger*10)
	wipe6 = makeHorizontalWipeSegment(ff, 6, whiteColorInt, dur, stagger*11)
	return {wipe1, wipe2, wipe3, wipe4, wipe5, wipe6}
end


-- helper to create a horizontal bar moving from center
local function makeHorizontalMirrorSegment(ff, segNum, colorInt, duration, startDelay, moveSign)
	local wiper = CreateFrame("Frame","$parentMirrorWipe"..segNum,ff)
	wiper:SetSize(WowPtGridSize, WLTexHigh*WowPtGridSize)
	wiper:SetPoint("CENTER", ff, "CENTER", 0, 0)

	wiper.tex = wiper:CreateTexture("hwipeTex"..segNum,"ARTWORK")
	wiper.tex:SetAllPoints()
	local tr, tg, tb = intToColor(colorInt)
	wiper.tex:SetColorTexture(tr, tg, tb,1)
	wiper:SetAlpha(0) -- texture is hidden until animated

	wiper.wipeOut = wiper:CreateAnimationGroup()
	wiper.wipeOut:SetLooping("NONE")

	wiper.wipe = wiper.wipeOut:CreateAnimation("TRANSLATION")
	wiper.wipe:SetOffset(WowPtGridSize*WLTexWide*moveSign/2, 0)
	wiper.wipe:SetDuration(duration)
	wiper.wipe:SetStartDelay(startDelay)
	
	wiper.wipe:SetScript("OnUpdate", function(self)
		if self:GetParent():GetParent():GetAlpha() == 0 and not self:IsDelaying() then 
			self:GetParent():GetParent():SetAlpha(1) -- reveal the texture
		end
	end)

	wiper.wipe:SetScript("OnFinished", function(self)
		self:GetParent():GetParent():SetAlpha(0) -- hide the texture again
	end)
	
	return wiper
end

-- create fireworks!
local function makeFireworksWipe(ff)

	local dur = 0.5
	local stagger = dur/3.5
	
	local sequence = {
		whiteColorInt, 
		yellowColorInt, 
		whiteColorInt, 
		yellowColorInt, 
		whiteColorInt, 
		yellowColorInt, 
		blueColorInt,
		whiteColorInt, 
		yellowColorInt, 
		whiteColorInt, 
		yellowColorInt, 
		whiteColorInt, 
		redColorInt,	
		whiteColorInt, 
		yellowColorInt, 
		whiteColorInt, 
		yellowColorInt, 
		whiteColorInt }
		
	local wipes = {}
	
	for i,color in ipairs(sequence) do
		wipes[i*2]   = makeHorizontalMirrorSegment(ff, i*2,   color, dur, stagger*i, 1)
		wipes[i*2+1] = makeHorizontalMirrorSegment(ff, i*2+1, color, dur, stagger*i, -1)
	end
	
	return wipes
end


-- helper to create a color-pulsing square
local function makePulser(ff, segNum)
	local pulser = CreateFrame("Frame","$parentPulser"..segNum,ff)
	pulser:SetSize(WowPtGridSize,WowPtGridSize)
	pulser:SetPoint("TOPLEFT", ff, "TOPLEFT", 0, 0)

	pulser.tex = pulser:CreateTexture("pulserTex"..segNum,"ARTWORK",-segNum)
	pulser.tex:SetAllPoints()
--	pulser.tex:SetColorTexture(1,1,1,1)
	pulser:SetAlpha(0) -- texture is hidden while not animating

	pulser.pulse = pulser:CreateAnimationGroup()
	pulser.pulse:SetLooping("BOUNCE")

	pulser.alphaPulse = pulser.pulse:CreateAnimation("ALPHA")
	pulser.alphaPulse:SetFromAlpha(0.0)
	pulser.alphaPulse:SetToAlpha(0.8)

	return pulser
end


local function makeColorButton(btnName, colorInt, parent, x, y)
	local b = CreateFrame("Button",btnName,parent)
	b:SetPoint("TOPLEFT",parent,"TOPLEFT",x,y)
	b:SetSize(25,25)
	b.tex = b:CreateTexture(nil, "OVERLAY")
	r,g,u = intToColor(colorInt)
	b.tex:SetColorTexture(r,g,u,1)
	b:SetNormalTexture(b.tex)
	b:SetScript("OnClick", function(self, btn,down) PlaySound(SOUNDKIT.IG_MINIMAP_ZOOM_IN) end)
	return b
end



--------------------- ANIMATION MODIFICATION UTILITIES --------------------

-- void: setAlloverColor(ff.alloverFrame, colorInt, color alpha[, texture alpha])
local function setAlloverColor(alloverFrame, colorInt, a, vis)
	local r,g,b = intToColor(colorInt)
	alloverFrame.tex:SetColorTexture(r,g,b,a)
	if vis == nil then
		vis = 1.0
	end
	aof:SetAlpha(vis)
end

-- void: setBackgroundColor(ff.baseTex, row/0-2, column/0-5, colorInt)
local function setBackgroundTexColor(bg, row, col, colorInt)
	local r,g,b = intToColor(colorInt)
	bg[indexOf(row,col)]:SetColorTexture(r, g, b, 1.0)
end

local function setBgToColorWithWhiteBox(bg, colorInt)
	for i=0,17 do
		bg[i]:SetColorTexture(1, 1, 1, 1.0)
	end
	local r,g,b = intToColor(colorInt)
	for i=1,WLTexWide-2 do
		bg[indexOf(1,i)]:SetColorTexture(r, g, b, 1.0);
	end
end

local function setMoneyWipeColor(wiper, colorInt)
	local r,g,b = intToColor(colorInt)
	wiper.tex:SetColorTexture(r, g, b, 1.0)
end

-- void: applyPlayerDefaultBackColors(ff.baseTex)
local function applyPlayerDefaultBackColors(bg)
	for i=0,17 do
		local r,g,b = intToColor(playerBgGrid[i+1])
		bg[i]:SetColorTexture(r, g, b, 1.0)
	end
--	r,g,b = GetClassColor(UnitClassBase("PLAYER"))
--	bg[0]:SetColorTexture(r, g, b, 1.0);
end

-- void: applyCheckerboard(ff.baseTex, colorInt_1, colorInt_2)
local function applyCheckerboard(bg, c1, c2)
	r1, g1, b1 = intToColor(c1)
	r2, g2, b2 = intToColor(c2)

	for i=0, 2 do

		for j=0,5 do
			local idx = indexOf(i,j)

			if (idx+i)%2 == 0 then
				bg[idx]:SetColorTexture(r1, g1, b1, 1.0)
			else
				bg[idx]:SetColorTexture(r2, g2, b2, 1.0)			
			end
		end
	end
end 

-- call with ff.pulser as first element
local function updatePulser(pulser, x, y, colorInt, speed)
	pulser:SetPoint("TOPLEFT", pulser:GetParent(), "TOPLEFT", x, -y)
	local tr, tg, tb = intToColor(colorInt)
	pulser.tex:SetColorTexture(tr, tg, tb, 1)
	pulser.alphaPulse:SetDuration(speed)
end



------------------------ DEFINE TRIGGERED ANIMATIONS -----------------------

local function moveMoney(ff, moneyGain)
        if math.abs(moneyGain) < 100 then 
        	setMoneyWipeColor(ff.moneyAnim, copperColorInt)
        elseif math.abs(moneyGain) < 10000 then 
        	setMoneyWipeColor(ff.moneyAnim, silverColorInt)
        else 
        	setMoneyWipeColor(ff.moneyAnim, goldColorInt)
        end

        if moneyGain > 0 then
        	ff.moneyAnim.wipeDown:Play()
        else
        	ff.moneyAnim.wipeDown:Play(true) -- play "up" (in reverse)
        end
end

local function launchFireworks(ff)
		for i=2,37 do
			ff.fireworks[i].wipeOut:Play()
		end
		C_Timer.After(1.0, function() applyCheckerboard(ff.baseTex, whiteColorInt, yellowColorInt) end)
		for t=3.0, 4.0, 0.2 do
			C_Timer.After(t, function() applyCheckerboard(ff.baseTex, yellowColorInt, whiteColorInt) end)
			C_Timer.After(t+0.1, function() applyCheckerboard(ff.baseTex, whiteColorInt, yellowColorInt) end)		
		end
		for t=4.2, 4.4, 0.2 do
			C_Timer.After(t, function() applyCheckerboard(ff.baseTex, yellowColorInt, blackColorInt) end)
			C_Timer.After(t+0.1, function() applyCheckerboard(ff.baseTex, blackColorInt, yellowColorInt) end)
		end
		C_Timer.After(4.6, function() applyPlayerDefaultBackColors(ff.baseTex) end)
end

local function deathComes(ff)
	local dr, dg, db = intToColor(deathColorInt)
	-- paint the field grey
	for i=0,17 do
		ff.baseTex[i]:SetColorTexture(dr, dg, db, 1)
	end
	-- randomize and start each pulser
	for i=1, 8 do
		local rx, ry = randomGridPoint()
		local colorInt = whiteColorInt
		if i%2 == 0 then
			colorInt = blackColorInt
		end
		local speed = 0.8 + 1.5 * fastrandom()
		updatePulser(ff.pulsers[i], rx, ry, colorInt, speed)
		ff.pulsers[i].pulse:Play()
	end
end

local function cheatDeath(ff)
	for i=1, 8 do
		ff.pulsers[i].pulse:Stop()
	end
	applyPlayerDefaultBackColors(ff.baseTex)
end

local function updateInBetweenFlight(ff)
	local zone = GetZoneText()
	zone = string.gsub(zone,"%-","%%%-")  -- string.find() uses patterns so must escape '-'
	if string.find(OribosZoneNames, zone) ~= nil or string.find(InBetweenZoneNames, zone) ~= nil then
		if UnitOnTaxi("player") then
			ff.fireworks[2].wipeOut:Play()
			ff.fireworks[3].wipeOut:Play()
		end
		-- keep calling myself every 1.5sec while in the special zones, and play animation if on taxi
		C_Timer.After(1.5, function() updateInBetweenFlight(ff) end)
	end
end




---##################################
---##########  ON_LOAD   ############
---##################################
local function OnLoad(ff)
	
	-- placement and size of WoW Lights
	ff:SetSize(WowPtGridSize * WLTexWide, WowPtGridSize * WLTexHigh)
	ff:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 0, 0)

	ff.alloverFrame = makeAlloverFrame(ff)
	ff.baseTex = makeBackground(ff)
	ff.moneyAnim = makeMoneyWipe(ff)
	ff.rainbowAnim = makeVerticalRainbowWipe(ff)
	ff.talentAnim = makeHorizontalBlueWhiteWipe(ff)
	ff.fireworks = makeFireworksWipe(ff)
	
	ff.pulsers = {}
	for i=1,8 do
		ff.pulsers[i] = makePulser(ff, i)
	end	
	
	ff.alloverFrame:SetFrameStrata("HIGH")
	ff.moneyAnim:SetFrameStrata("MEDIUM")

	-- events I'm interested in:
	ff:RegisterEvent("PLAYER_ENTERING_WORLD")
	ff:RegisterEvent("PLAYER_STARTED_MOVING")
	ff:RegisterEvent("PLAYER_STOPPED_MOVING")
	ff:RegisterEvent("PLAYER_REGEN_DISABLED")
	ff:RegisterEvent("PLAYER_REGEN_ENABLED")
	ff:RegisterEvent("PLAYER_MONEY")
	ff:RegisterEvent("TRANSMOGRIFY_SUCCESS")
	ff:RegisterEvent("NEW_TOY_ADDED")
	ff:RegisterEvent("ACHIEVEMENT_EARNED")
	ff:RegisterEvent("PLAYER_LEVEL_UP")
	ff:RegisterEvent("PLAYER_DEAD")
	ff:RegisterEvent("PLAYER_ALIVE")
	ff:RegisterEvent("PLAYER_UNGHOST")	
	ff:RegisterEvent("READY_CHECK")
	ff:RegisterEvent("DUEL_REQUESTED")
	ff:RegisterEvent("ROLE_POLL_BEGIN")
	ff:RegisterEvent("CHAT_MSG_RAID_WARNING")
	ff:RegisterEvent("HEARTHSTONE_BOUND")
	ff:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	
	-- logic to filter on not every talent change?
	ff:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	
	-- TODO
	f:RegisterEvent("PLAYER_CONTROL_GAINED")
	f:RegisterEvent("PLAYER_CONTROL_LOST") -- darken the lights to indicate out of control

	

	
	ff.wasMoney = GetMoney()	
	
	-- create the light color programming buttons for settings
	for row = 0,2 do
		for col = 0, 5 do		
			makeColorButton(row..col, playerBgGrid[1+indexOf(row,col)], WoWLightsOptionsFrame, 130+(25*col), -70-25*row)
		end
    end
	
end


---##################################
---#########  ON_EVENT   ############
---##################################
function WoWLights:OnEvent(ff,event, ...)
	--print("WoW lights Event: "..event)
	local arg1, arg2 = ...;
    if event == "PLAYER_ENTERING_WORLD" then        -- set stuff up
        WoWLightsFrame:Show()
        
    elseif event == "ADDON_LOADED" then
    	if not WLhasBeenLoaded then 
    		OnLoad(ff)
    		WLhasBeenLoaded = true
    	end
    	        
    	        
    	        
    elseif event == "PLAYER_STARTED_MOVING" then
--		setBackgroundTexColor(ff.baseTex, 0, 1, whiteColorInt)
--		setBackgroundTexColor(ff.baseTex, 0, 3, whiteColorInt)
--		setBackgroundTexColor(ff.baseTex, 0, 5, whiteColorInt)

		

    elseif event == "PLAYER_STOPPED_MOVING" then
--    	setBackgroundTexColor(ff.baseTex, 0, 1, blackColorInt)
--    	setBackgroundTexColor(ff.baseTex, 0, 3, blackColorInt)
--    	setBackgroundTexColor(ff.baseTex, 0, 5, blackColorInt)
    	
    	
    	
    elseif event == "PLAYER_REGEN_DISABLED" then
    	ff.alloverFrame.fadeInOut:Play()
    	
    elseif event == "PLAYER_REGEN_ENABLED" then
    	ff.alloverFrame.fadeInOut:Stop()
    	
    elseif event == "TRANSMOGRIFY_SUCCESS" or event == "NEW_TOY_ADDED" then
    	ff:UnregisterEvent("TRANSMOGRIFY_SUCCESS") -- only take first call, not every piece of gear!
		for i,wiper in ipairs(ff.rainbowAnim) do
			wiper.wipeDown:Play()
		end
		C_Timer.After(1.5, function() ff:RegisterEvent("TRANSMOGRIFY_SUCCESS") end)

    elseif event == "ACTIVE_TALENT_GROUP_CHANGED" then
		for i,wiper in ipairs(ff.talentAnim) do
			wiper.wipeRight:Play()
		end

    elseif event == "ACHIEVEMENT_EARNED" or event == "PLAYER_LEVEL_UP" then
    	launchFireworks(ff)
		
    elseif event == "PLAYER_MONEY" then
        local moneyGain = GetMoney() - ff.wasMoney
        moveMoney(ff,moneyGain )
        ff.wasMoney = GetMoney()
        
    elseif event == "PLAYER_DEAD" then
        deathComes(ff)
    elseif event == "PLAYER_ALIVE" then
           -- UnitIsDeadOrGhost == true means must have released to graveyard but actually still dead
        if not UnitIsDeadOrGhost("player") then
			cheatDeath(ff)
        end                                         
    elseif event == "PLAYER_UNGHOST" then  -- after corps run or spirit healer
			cheatDeath(ff)
			
    elseif event == "READY_CHECK" then
		setBgToColorWithWhiteBox(ff.baseTex, greenColorInt)
		C_Timer.After(1.5, function() applyPlayerDefaultBackColors(ff.baseTex) end)
    elseif event == "DUEL_REQUESTED" then
		setBgToColorWithWhiteBox(ff.baseTex, redColorInt)
		C_Timer.After(1.5, function() applyPlayerDefaultBackColors(ff.baseTex) end)
    elseif event == "ROLE_POLL_BEGIN" then
		setBgToColorWithWhiteBox(ff.baseTex, blueColorInt)
		C_Timer.After(1.5, function() applyPlayerDefaultBackColors(ff.baseTex) end)
    elseif event == "CHAT_MSG_RAID_WARNING" then
		setBgToColorWithWhiteBox(ff.baseTex, orangeColorInt)
		C_Timer.After(1.5, function() applyPlayerDefaultBackColors(ff.baseTex) end)

    elseif event == "HEARTHSTONE_BOUND" then
		applyCheckerboard(ff.baseTex, cyanColorInt, blackColorInt)
		C_Timer.After(1.0, function() applyCheckerboard(ff.baseTex, blackColorInt, cyanColorInt) end)
		C_Timer.After(2.0, function() applyPlayerDefaultBackColors(ff.baseTex) end)
    	
	elseif event == "ZONE_CHANGED_NEW_AREA" then
		updateInBetweenFlight(ff)





    else
    	print("WoWLights: Registered for but didn't handle "..event)  
    end    
end


---##################################
---#########  ON_UPDATE   ###########
---##################################
--function WoWLights:OnUpdate(elapsed)
--
--end
