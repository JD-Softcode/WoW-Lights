--   ## WoW Lights - ©2022 J∆•Softcode (www.jdsoftcode.net) ##

-------------------------- ADD-ON GLOBALS ------------------------

WoWLights = {}							--  namespace for all addon functions

WowPtGridSize = 3.35
WLTexWide = 6
WLTexHigh = 3

WLcombatFlash = false
WLcombatFlashState = false
WLtotalTime = 0

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

local playerBgGrid = {}

local combatColorInt = redColorInt

------------------------------ STARTUP ---------------------------

WoWLightsFrame = CreateFrame("Frame","WoW Lights",UIParent)
-- ?? do not parent="UIParent" so my frame remains while interface is hidden, and does not scale up/down with UI

WoWLightsFrame:SetScript("OnEvent", function(self, event, ...) 
	WoWLights:OnEvent(self,event, ...) 
end)

WoWLightsFrame:SetScript("OnUpdate", function(self, elapsed) 
	WoWLights:OnUpdate(elapsed) 
end)

WoWLightsFrame:RegisterEvent("ADDON_LOADED")


-------------------------------- GRID UTILITIES ---------------------------------
local function indexOf(row, col)
	return row*WLTexWide + col
end

-------------------------------- COLOR UTILITIES --------------------------------

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


------------------ CREATE THE GRAPHIC COMPONENTS --------------------

-- run once to create the overlay zone that appears on all the keys at once
local function makeAlloverFrame(ff)

	local aof = CreateFrame("Frame","Overall",ff)
	aof:SetSize(WowPtGridSize * WLTexWide, WowPtGridSize * WLTexHigh)
	aof:SetPoint("TOPLEFT", ff, "TOPLEFT", 0, 0)

	aof.tex = aof:CreateTexture(nil,"OVERLAY")
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

-- run once to construct the background lights grig of 18 samples using global playerBgGrid
local function makeBackground(ff) -- The underlaying colors when no effects playing
	local baseTex = {}
	for r = 0,WLTexHigh-1 do
		for c = 0, WLTexWide-1 do
			local bgColor = playerBgGrid[indexOf(r,c)]
			local tex = ff:CreateTexture(nil,"BACKGROUND")
			tex:SetSize(WowPtGridSize,WowPtGridSize)
			tex:SetPoint("BOTTOMLEFT", ff, "BOTTOMLEFT", c*WowPtGridSize, (WLTexHigh-1-r)*WowPtGridSize)
			local tr, tg, tb = intToColor(bgColor)
			tex:SetColorTexture(tr, tg, tb, 1)	
			baseTex[indexOf(r,c)] = tex
		end
	end
	
	return baseTex
end



------------------------- COLOR MODIFICATION UTILITIES ------------------------
-- void: setAlloverColor(ff.alloverFrame, colorInt, color alpha[, texture alpha])
local function setAlloverColor(alloverFrame, colorInt, a, vis)
	local r,g,b = intToColor(colorInt)
	aof.tex:SetColorTexture(r,g,b,a)
	if vis == nil then
		vis = 1.0
	end
	aof:SetAlpha(vis)
end

-- void: setBackgroundColor(ff.baseTex, row/0-2, column/0-5, red, green, blue)
local function setBackgroundTexColor(bg, row, col, colorInt)
	local r,g,b = intToColor(colorInt)
	bg[indexOf(row,col)]:SetColorTexture(r, g, b, 1.0)
end



-------------------------- PLUG INTO EVENTS OF INTEREST ------------------------

local function OnLoad(ff)
	
	-- placement and size of WoW Lights
	ff:SetSize(WowPtGridSize * WLTexWide, WowPtGridSize * WLTexHigh)
	ff:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 0, 0)

	-- load the desired player background colors
	local rPerc, gPerc, bPerc = GetClassColor(UnitClassBase("PLAYER"))
	playerBgGrid[indexOf(0,0)] = color1ToInt(rPerc, gPerc, bPerc);
	playerBgGrid[indexOf(0,1)] = blackColorInt;
	playerBgGrid[indexOf(0,2)] = yellowColorInt;
	playerBgGrid[indexOf(0,3)] = blackColorInt;
	playerBgGrid[indexOf(0,4)] = greenColorInt;
	playerBgGrid[indexOf(0,5)] = blackColorInt;
	playerBgGrid[indexOf(1,0)] = blackColorInt;
	playerBgGrid[indexOf(1,1)] = orangeColorInt;
	playerBgGrid[indexOf(1,2)] = blackColorInt;
	playerBgGrid[indexOf(1,3)] = magentaColorInt;
	playerBgGrid[indexOf(1,4)] = blackColorInt;
	playerBgGrid[indexOf(1,5)] = blueColorInt;
	playerBgGrid[indexOf(2,0)] = cyanColorInt;
	playerBgGrid[indexOf(2,1)] = blackColorInt;
	playerBgGrid[indexOf(2,2)] = redColorInt;
	playerBgGrid[indexOf(2,3)] = blackColorInt;
	playerBgGrid[indexOf(2,4)] = greenColorInt;
	playerBgGrid[indexOf(2,5)] = blackColorInt;
	
	ff.alloverFrame = makeAlloverFrame(ff)
	ff.baseTex = makeBackground(ff)
	
	-- events I'm interested in:
	ff:RegisterEvent("PLAYER_ENTERING_WORLD")
	ff:RegisterEvent("PLAYER_STARTED_MOVING")
	ff:RegisterEvent("PLAYER_STOPPED_MOVING")
	ff:RegisterEvent("PLAYER_REGEN_DISABLED")
	ff:RegisterEvent("PLAYER_REGEN_ENABLED")
end


-------------------------- EVENT ROUTINES CALLED BY WOW ------------------------

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
    	setBackgroundTexColor(ff.baseTex, 0, 1, whiteColorInt)
    	setBackgroundTexColor(ff.baseTex, 0, 3, whiteColorInt)
    	setBackgroundTexColor(ff.baseTex, 0, 5, whiteColorInt)
    	    	
    elseif event == "PLAYER_STOPPED_MOVING" then
    	setBackgroundTexColor(ff.baseTex, 0, 1, blackColorInt)
    	setBackgroundTexColor(ff.baseTex, 0, 3, blackColorInt)
    	setBackgroundTexColor(ff.baseTex, 0, 5, blackColorInt)
    	
    elseif event == "PLAYER_REGEN_DISABLED" then
    	ff.alloverFrame.fadeInOut:Play()
    	
    elseif event == "PLAYER_REGEN_ENABLED" then
    	ff.alloverFrame.fadeInOut:Stop() -- restore to original state
    	
    else
    	print("WoWLights: Registered for but didn't handle "..event)  
    end    
end


---##################################
---#########  ON_UPDATE   ###########
---##################################
function WoWLights:OnUpdate(elapsed)

end
