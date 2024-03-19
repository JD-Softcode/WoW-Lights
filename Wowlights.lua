--   ## WoW Lights - ©2022-24 J∆•Softcode (www.jdsoftcode.net) ##

------------------------------- DEFINE USER SLASH COMMANDS ----------------------------

SLASH_WOWLT1 = "/wlights"
SLASH_WOWLT2 = "/wowlights"

------------------------------------ ADD-ON GLOBALS ----------------------------------

WoWLights = {} --  namespace for addon functions

WLTexWide = 6 -- width of the color grid
WLTexHigh = 3 -- height of the color grid

-- Following values used when editing colors
WLColorBtnUnderEdit = 0
WLColorRowUnderEdit = 0
WLColorButtons = {}
WLOldRowColors = {}
WLUndoColorSetBuffer = {}
WLColorPickerInfo = {}
WLColorPickerInfo.hasOpacity = false
WLhasBeenLoaded = false

local version = select(4, GetBuildInfo())
WLisDragons = version > 100000
WLisClassic = version < 20000
WLisWrath = version > 20000 and version < 40000

WLUnspentTalentPoints = 0

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
local silverColorInt = 12632256
local copperColorInt = 12023884
local deathColorInt = 6579300

local combatColorInt = redColorInt

local defaultRow1 = 9183139
local defaultRow2 = 5973872
local defaultRow3 = 3542625

OribosZoneNames = "Oribos Орибос"   --  All western + Russian
InBetweenZoneNames = "The In-Between Der Zwischenraum La Zona Intermedia Entre-Deux O Intermédio Промежуток"
                                        --  English, German, Spanish, French, Portugues, Russian
-- ADD-ON SAVED GLOBALS, loaded by WoW
-- WLProfileMemory = {}
-- WLGridSqSize
-- WLCombatFlashAlpha

local playerBgGrid = { -- default colors shown if no name/realm/spec color profile is saved for this character
    defaultRow1, defaultRow1, defaultRow1, defaultRow1, defaultRow1, defaultRow1,
    defaultRow2, defaultRow2, defaultRow2, defaultRow2, defaultRow2, defaultRow2,
    defaultRow3, defaultRow3, defaultRow3, defaultRow3, defaultRow3, defaultRow3
}

local calibrateBgGrid = { -- shown when the "Cal Colors" button is clicked in settings window
    redColorInt ,blackColorInt, greenColorInt, blackColorInt, blueColorInt, blackColorInt,
    blackColorInt ,orangeColorInt, blackColorInt, magentaColorInt, blackColorInt, cyanColorInt,
    redColorInt ,blackColorInt, greenColorInt, blackColorInt, blueColorInt, blackColorInt
}



----------------------------------- STARTUP THE MAIN FRAME  ---------------------------------

WoWLightsFrame = CreateFrame("Frame","WoW Lights") -- not parented to UIParent, so immune to UI scaling

WoWLightsFrame:SetFrameStrata("LOW")

WoWLightsFrame:SetScript("OnEvent", function(self, event, ...)
    WoWLights:OnEvent(self,event, ...)
end)

--WoWLightsFrame:SetScript("OnUpdate", function(self, elapsed)
--  WoWLights:OnUpdate(elapsed)
--end)

WoWLightsFrame:RegisterEvent("ADDON_LOADED")



-------------------------------- CREATE THE SETTINGS FRAME --------------------------------

WoWLightsOptionsFrame = CreateFrame("Frame","WoWLightsOpt",UIParent,"PortraitFrameTemplate")
WoWLightsOptionsFrame:Hide()
WoWLightsOptionsFrame:SetFrameStrata("HIGH")
WoWLightsOptionsFrame:SetPoint("CENTER")
WoWLightsOptionsFrame:SetSize(500,300)
WoWLightsOptionsFrame:SetScript("OnShow", function(self, ff) PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN) end)
WoWLightsOptionsFrame:SetScript("OnHide", function(self, ff) PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE) end)
WoWLightsOptTitleText:SetText("WoW Lights Settings")
WoWLightsOptPortrait:SetTexture("Interface\\AddOns\\Wowlights\\wowlights_bg")

WoWLightsOptCloseButton:SetScript("OnEnter", function(self, motion)
    local tooltip = GetAppropriateTooltip();
    tooltip:SetOwner(self, "ANCHOR_RIGHT");
    tooltip:SetText("Same as OK button; changes will be saved.");
    tooltip:Show();
    end)
WoWLightsOptCloseButton:SetScript("OnLeave", function(self)
    local tooltip = GetAppropriateTooltip();
    if tooltip:GetOwner() == self then tooltip:Hide(); end
    end)

local t1 = WoWLightsOptionsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
t1:SetText("Keyboard Basic Colors")
t1:SetSize(200,36)
t1:SetPoint("TOPLEFT",WoWLightsOptionsFrame,"TOPLEFT",110,-35)

local t2 = WoWLightsOptionsFrame:CreateFontString(nil, "ARTWORK", "GameFontWhiteSmall")
t2:SetText("Click to change one color")
t2:SetSize(200,36)
t2:SetPoint("TOPLEFT",WoWLightsOptionsFrame,"TOPLEFT",108,-138)

local t3t = WoWLightsOptionsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
t3t:SetText("Character:")
t3t:SetSize(200,36)
t3t:SetJustifyH("CENTER")
t3t:SetPoint("TOPLEFT",WoWLightsOptionsFrame,"TOPLEFT",300,-35)

local t3 = WoWLightsOptionsFrame:CreateFontString(nil, "ARTWORK", "GameFontWhite")
t3:SetText("Waldokind")
t3:SetSize(200,36)
t3:SetJustifyH("CENTER")
t3:SetPoint("TOPLEFT",WoWLightsOptionsFrame,"TOPLEFT",300,-55)
WoWLightsOptionsFrame.charString = t3

local t4t = WoWLightsOptionsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
if not WLisClassic and not WLisWrath then
    t4t:SetText("Specialization:")
end
t4t:SetSize(200,36)
t4t:SetJustifyH("CENTER")
t4t:SetPoint("TOPLEFT",WoWLightsOptionsFrame,"TOPLEFT",300,-80)

local t4 = WoWLightsOptionsFrame:CreateFontString(nil, "ARTWORK", "GameFontWhite")
t4:SetText("Holy")
t4:SetSize(200,36)
t4:SetJustifyH("CENTER")
t4:SetPoint("TOPLEFT",WoWLightsOptionsFrame,"TOPLEFT",300,-100)
WoWLightsOptionsFrame.specString = t4

local t5 = WoWLightsOptionsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
t5:SetText("Combat Flash Brightness")
t5:SetSize(200,36)
t5:SetPoint("TOPLEFT",WoWLightsOptionsFrame,"TOPLEFT",20,-180)

local t6 = WoWLightsOptionsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
t6:SetText("Frame Size")
t6:SetSize(200,36)
t6:SetPoint("TOPLEFT",WoWLightsOptionsFrame,"TOPLEFT",300,-180)

local t7 = WoWLightsOptionsFrame:CreateFontString(nil, "ARTWORK", "GameFontWhiteSmall")
t7:SetText("Hide Colors")
t7:SetSize(200,36)
t7:SetPoint("TOPLEFT",WoWLightsOptionsFrame,"TOPLEFT",130,-265)



local b1 = CreateFrame("Button",nil,WoWLightsOptionsFrame,"UIPanelButtonTemplate")
b1:SetText("Color Row 1")
b1:SetPoint("TOPLEFT",WoWLightsOptionsFrame,"TOPLEFT",20,-70)
b1:SetSize(100,24)
b1:SetScript("OnClick", function(self, btn, down) WoWLights:RecolorColorRow(self,1) end)

local b2 = CreateFrame("Button",nil,WoWLightsOptionsFrame,"UIPanelButtonTemplate")
b2:SetText("Color Row 2")
b2:SetPoint("TOPLEFT",WoWLightsOptionsFrame,"TOPLEFT",20,-95)
b2:SetSize(100,24)
b2:SetScript("OnClick", function(self, btn, down) WoWLights:RecolorColorRow(self,2) end)

local b3 = CreateFrame("Button",nil,WoWLightsOptionsFrame,"UIPanelButtonTemplate")
b3:SetText("Color Row 3")
b3:SetPoint("TOPLEFT",WoWLightsOptionsFrame,"TOPLEFT",20,-120)
b3:SetSize(100,24)
b3:SetScript("OnClick", function(self, btn, down) WoWLights:RecolorColorRow(self,3) end)

local b4 = CreateFrame("Button",nil,WoWLightsOptionsFrame,"UIPanelButtonTemplate")
b4:SetText("Memorize")
b4:SetPoint("TOPLEFT",WoWLightsOptionsFrame,"TOPLEFT",350,-140)
b4:SetSize(100,24)
b4:SetScript("OnClick", function(self, btn, down) WoWLights:MemorizeColors() end)

local b5 = CreateFrame("Button",nil,WoWLightsOptionsFrame,"UIPanelButtonTemplate")
b5:SetText("Reset Animation")
b5:SetPoint("TOPLEFT",WoWLightsOptionsFrame,"TOPLEFT",20,-270)
b5:SetSize(145,24)
b5:SetScript("OnClick", function(self, btn, down) WoWLights:ResetAnims() end)

local b6 = CreateFrame("Button",nil,WoWLightsOptionsFrame,"UIPanelButtonTemplate")
b6:SetText("Cancel")
b6:SetPoint("TOPLEFT",WoWLightsOptionsFrame,"TOPLEFT",270,-270)
b6:SetSize(100,24)
b6:SetScript("OnClick", function(self, btn, down)
    WoWLightsOptionsFrame:Hide()
    WoWLights:HandleSettingsCancel()
    end)

local b7 = CreateFrame("Button",nil,WoWLightsOptionsFrame,"UIPanelButtonTemplate")
b7:SetText("OK")
b7:SetPoint("TOPLEFT",WoWLightsOptionsFrame,"TOPLEFT",380,-270)
b7:SetSize(100,24)
b7:SetScript("OnClick", function(self, btn,down)
    PlaySound(SOUNDKIT.IG_MINIMAP_ZOOM_OUT)
    WoWLightsOptionsFrame:Hide()
    ColorPickerFrame:Hide()
    -- the normal handlers change the saved globals as we go so don't need to do anything extra now
    end)

local b8 = CreateFrame("Button",nil,WoWLightsOptionsFrame,"UIMenuButtonStretchTemplate")
b8:SetPoint("TOPLEFT",WoWLightsOptionsFrame,"TOPLEFT",373,-235)
b8:SetText("Cal Colors")
b8:SetSize(55,16)
b8:SetScript("OnClick", function(self, btn,down)
    WoWLights:HandleShowCalibrationPattern()
    end)
b8:SetScript("OnEnter", function(self, motion)
    local tooltip = GetAppropriateTooltip();
    tooltip:SetOwner(self, "ANCHOR_RIGHT");
    tooltip:SetText("Place calibration pattern on the lights. Cancel to remove.");
    tooltip:Show();
    end)
b8:SetScript("OnLeave", function(self)
    local tooltip = GetAppropriateTooltip();
    if tooltip:GetOwner() == self then tooltip:Hide(); end
    end)


local s1 = CreateFrame("Slider","slider",WoWLightsOptionsFrame,"OptionsSliderTemplate")
s1:SetPoint("TOPLEFT",WoWLightsOptionsFrame,"TOPLEFT",45,-210)
s1:SetMinMaxValues(0.3, 1.0)
sliderLow:SetText("faint")
sliderHigh:SetText("bright")
WoWLightsOptionsFrame.flasherInput = s1
s1:SetScript("OnValueChanged", function(self, evt, arg1)
    WoWLights:ChangeCombatPulseIntensity(evt)
    end)

local e1 = CreateFrame("EditBox",nil,WoWLightsOptionsFrame,"InputBoxTemplate")
e1:SetPoint("TOPLEFT",WoWLightsOptionsFrame,"TOPLEFT",378,-210)
e1:SetSize(50,24)
e1:SetMultiLine(false)
e1:SetAutoFocus(false)
e1:SetFontObject("ChatFontNormal")
WoWLightsOptionsFrame.sizeInput = e1
e1:SetScript("OnEnterPressed", function(self)
    WoWLights:ChangeFrameSize(self:GetText())
    end)

local c1 = CreateFrame("CheckButton","WLhideBtn",WoWLightsOptionsFrame,"ChatConfigCheckButtonTemplate")
c1:SetPoint("TOPLEFT",WoWLightsOptionsFrame,"TOPLEFT",177,-270)
c1:SetSize(24,24)
WLhideBtn.tooltip = "Click to hide the color box"
c1:SetScript("OnClick", function(self, btn,down)
    PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
    if (self:GetChecked()) then
        WoWLightsFrame:Hide()
    else
        WoWLightsFrame:Show()
    end
    end)




-------------------------------- GRID MATH UTILITIES ----------------------------------
-- returns array index (0-17) of background grid location (row, col)
local function indexOf(row, col)
    return row*WLTexWide + col
end

-- returns x,y: a random point between (0,0) and (17,7) on default scaling
local function randomGridPoint()
    local xMax = 0.5 + (WLTexWide-1) * WLGridSqSize
    local yMax = 0.5 + (WLTexHigh-1) * WLGridSqSize
    return fastrandom(0,xMax), fastrandom(0,yMax)
end

local function setSettingsPlayerInfoAndGetColorSetKey()
    local playerName = UnitName("PLAYER")
    local playerRealm = GetRealmName()
    local playerSpec = ""
    if not WLisClassic and not WLisWrath then
        local specIndex = GetSpecialization()
        playerSpec = select(2, GetSpecializationInfo(specIndex))
        if playerSpec == nil then return -- handle the extra early call before spec info is available
        end
    end
    WoWLightsOptionsFrame.charString:SetText(playerName)
    WoWLightsOptionsFrame.specString:SetText(playerSpec)
    return playerName..playerRealm..playerSpec
end


------------------------------ COLOR CONVERT UTILITIES ---------------------------------

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


-------------------------------- SLASH COMMAND HANDERS --------------------------------


SlashCmdList["WOWLT"] = function(msg, theEditFrame)         -- /wlights

    WoWLightsOptionsFrame.flasherInput:SetValue(WLCombatFlashAlpha)
    WoWLightsOptionsFrame.sizeInput:SetText(WLGridSqSize)

    for i=1, WLTexWide * WLTexHigh do
        local colorInt = playerBgGrid[i]
        WLUndoColorSetBuffer[i] = colorInt
        rr,gg,bb = intToColor(colorInt)
        WLColorButtons[i].tex:SetColorTexture(rr,gg,bb,1)
    end

    WLUndoFlasherInput = WLCombatFlashAlpha
    WLUndoGridSizeInput = WLGridSqSize

    WoWLightsOptionsFrame:Show()
end



---------------------------- BUILDERS FOR THE GRAPHIC COMPONENTS -----------------------

-- create the overlay zone that appears on all the keys at once
local function makeAlloverFrame(ff)

    local aof = CreateFrame("Frame","$parentOverall",ff)
    aof:SetSize(WLGridSqSize * WLTexWide, WLGridSqSize * WLTexHigh)
    aof:SetPoint("TOPLEFT", ff, "TOPLEFT", 0, 0)

    aof.tex = aof:CreateTexture("allOverTex","OVERLAY")
    aof.tex:SetAllPoints()
    local tr, tg, tb = intToColor(combatColorInt)
    aof.tex:SetColorTexture(tr, tg, tb,1)
    aof:SetAlpha(0)

    aof.fadeInOut = aof:CreateAnimationGroup()
    aof.fadeInOut:SetLooping("BOUNCE")

    aof.fader = aof.fadeInOut:CreateAnimation("ALPHA")
    aof.fader:SetFromAlpha(WLCombatFlashAlpha)
    aof.fader:SetToAlpha(0.0)
    aof.fader:SetDuration(1.0)

    return aof
end

-- create the overlay of the overlay that appears on all the keys at once
local function makeCurtainFrame(ff)

    local aof = CreateFrame("Frame","$parentCurtain",ff)
    aof:SetSize(WLGridSqSize * WLTexWide, WLGridSqSize * WLTexHigh)
    aof:SetPoint("TOPLEFT", ff, "TOPLEFT", 0, 0)

    aof.tex = aof:CreateTexture("allOverTex","OVERLAY")
    aof.tex:SetAllPoints()
    local tr, tg, tb = intToColor(blackColorInt)
    aof.tex:SetColorTexture(tr, tg, tb, 1)
    aof:SetAlpha(0)

    return aof
end

-- construct the background lights grid of 18 samples using global var: playerBgGrid
local function makeBackground(ff)
    local baseTex = {}
    for r = 0,WLTexHigh-1 do
        for c = 0, WLTexWide-1 do
            local bgColor = playerBgGrid[indexOf(r,c)+1]
            local tex = ff:CreateTexture("bgTex","BACKGROUND")
            tex:SetSize(WLGridSqSize,WLGridSqSize)
            tex:SetPoint("BOTTOMLEFT", ff, "BOTTOMLEFT", c*WLGridSqSize, (WLTexHigh-1-r)*WLGridSqSize)
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
    wiper:SetSize(WLGridSqSize*WLTexWide,WLGridSqSize)
    wiper:SetPoint("TOPLEFT", ff, "TOPLEFT", 0, 0)

    wiper.tex = wiper:CreateTexture("wipeTex","ARTWORK")
    wiper.tex:SetAllPoints()
    local tr, tg, tb = intToColor(goldColorInt)
    wiper.tex:SetColorTexture(tr, tg, tb,1)
    wiper:SetAlpha(0) -- texture is hidden until animated

    wiper.wipeDown = wiper:CreateAnimationGroup()
    wiper.wipeDown:SetLooping("NONE")

    wiper.wipe = wiper.wipeDown:CreateAnimation("TRANSLATION")
    wiper.wipe:SetOffset(0,-(WLGridSqSize-1)*WLTexHigh)
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
    wiper:SetSize(WLGridSqSize*WLTexWide,WLGridSqSize)
    wiper:SetPoint("TOPLEFT", ff, "TOPLEFT", 0, 0)
    wiper.tex = wiper:CreateTexture("vwipeTex"..segNum,"ARTWORK",nil,-segNum)
    wiper.tex:SetAllPoints()
    local tr, tg, tb = intToColor(colorInt)
    wiper.tex:SetColorTexture(tr, tg, tb, 1)
    wiper:SetAlpha(0) -- texture is hidden until animated

    wiper.wipeDown = wiper:CreateAnimationGroup()
    wiper.wipeDown:SetLooping("NONE")

    wiper.wipe = wiper.wipeDown:CreateAnimation("TRANSLATION")
    wiper.wipe:SetOffset(0,-(WLGridSqSize-1)*WLTexHigh)
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
    wiper:SetSize(WLGridSqSize, WLTexHigh*WLGridSqSize)
    wiper:SetPoint("TOPLEFT", ff, "TOPLEFT", 0, 0)
    wiper.tex = wiper:CreateTexture("hwipeTex"..segNum,"ARTWORK",nil,-segNum)
    wiper.tex:SetAllPoints()
    local tr, tg, tb = intToColor(colorInt)
    wiper.tex:SetColorTexture(tr, tg, tb,1)
    wiper:SetAlpha(0) -- texture is hidden until animated

    wiper.wipeRight = wiper:CreateAnimationGroup()
    wiper.wipeRight:SetLooping("NONE")

    wiper.wipe = wiper.wipeRight:CreateAnimation("TRANSLATION")
    wiper.wipe:SetOffset(WLGridSqSize*WLTexWide, 0)
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
    wiper:SetSize(WLGridSqSize, WLTexHigh*WLGridSqSize)
    wiper:SetPoint("CENTER", ff, "CENTER", 0, 0)

    wiper.tex = wiper:CreateTexture("hwipeTex"..segNum,"ARTWORK")
    wiper.tex:SetAllPoints()
    local tr, tg, tb = intToColor(colorInt)
    wiper.tex:SetColorTexture(tr, tg, tb,1)
    wiper:SetAlpha(0) -- texture is hidden until animated

    wiper.wipeOut = wiper:CreateAnimationGroup()
    wiper.wipeOut:SetLooping("NONE")

    wiper.wipe = wiper.wipeOut:CreateAnimation("TRANSLATION")
    wiper.wipe:SetOffset(WLGridSqSize*WLTexWide*moveSign/2, 0)
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
        whiteColorInt, yellowColorInt, whiteColorInt, yellowColorInt, whiteColorInt,
        blueColorInt,
        whiteColorInt, yellowColorInt, whiteColorInt, yellowColorInt, whiteColorInt,
        redColorInt,
        whiteColorInt, yellowColorInt, whiteColorInt, yellowColorInt, whiteColorInt }

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
    pulser:SetSize(WLGridSqSize,WLGridSqSize)
    pulser:SetPoint("TOPLEFT", ff, "TOPLEFT", 0, 0)
    pulser.tex = pulser:CreateTexture("pulserTex"..segNum,"ARTWORK",nil,-segNum)
    pulser.tex:SetAllPoints()
    pulser:SetAlpha(0) -- texture is hidden while not animating

    pulser.pulse = pulser:CreateAnimationGroup()
    pulser.pulse:SetLooping("BOUNCE")

    pulser.alphaPulse = pulser.pulse:CreateAnimation("ALPHA")
    pulser.alphaPulse:SetFromAlpha(0.0)
    pulser.alphaPulse:SetToAlpha(0.8)

    return pulser
end





---------------------------- ANIMATION MODIFICATION UTILITIES --------------------------

-- void: setAlloverColor(ff.alloverFrame, colorInt, color alpha[, texture alpha])
local function setAlloverColor(alloverFrame, colorInt, a, vis)
    local r,g,b = intToColor(colorInt)
    alloverFrame.tex:SetColorTexture(r,g,b,a)
    if vis == nil then
        vis = 1.0
    end
    alloverFrame:SetAlpha(vis)
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

-- Called by settings event handler when the combat lights intensity slider is moved
local function setCombatFlashMaxAlpha(value)
    WoWLightsFrame.alloverFrame.fader:SetFromAlpha(value)
    WLCombatFlashAlpha = value
end


-- Called by settings event handler when ENTER is pressed in the grid size edit box
local function updateGridSize(size)
    -- size is guaranteed to be a number != 0
    if size ~= WLGridSqSize then
        for row=0, WLTexHigh-1 do
            for col=0, WLTexWide-1 do
                WoWLightsFrame.baseTex[indexOf(row,col)]:SetColorTexture(0,0,0,0) -- make existing texture translarent
            end
        end
        WLGridSqSize = size
        WoWLightsFrame.baseTex = makeBackground(WoWLightsFrame)
    end
end


--------------------------------- COLOR CHANGE HANDLERS ---------------------------------

-- Called by ColorPickerFrame when color wheel value is changed while one color square is being updated
local function colorSquareChanged()
    if WLColorBtnUnderEdit ~= nil then
        rr, gg, bb = ColorPickerFrame:GetColorRGB() -- get the new color
        colorInt = color1ToInt(rr, gg, bb) -- convert to in Int
        playerBgGrid[WLColorBtnUnderEdit.colorIndex] = colorInt -- change the prefs
        WoWLightsFrame.baseTex[WLColorBtnUnderEdit.colorIndex-1]:SetColorTexture(rr, gg, bb, 1.0) -- change the corner texture
        WLColorBtnUnderEdit.tex:SetColorTexture(rr,gg,bb,1) -- change the settings button
    end
end

-- Called by ColorPickerFrame when its Cancel button is clicked while one color square is being updated
local function colorSquareReset()
    if WLColorBtnUnderEdit ~= nil then
        colorInt = WLColorBtnUnderEdit.oldColorInt
        rr, gg, bb = intToColor(colorInt) -- get the old color
        playerBgGrid[WLColorBtnUnderEdit.colorIndex] = colorInt -- change the prefs
        WoWLightsFrame.baseTex[WLColorBtnUnderEdit.colorIndex-1]:SetColorTexture(rr, gg, bb, 1.0) -- change the corner texture
        WLColorBtnUnderEdit.tex:SetColorTexture(rr,gg,bb,1) -- change the settings button
    end
end

-- Called to make the color wheel appear to change one color square
local function makeColorButton(index, colorInt, parent, x, y)
    local b = CreateFrame("Button","colorBtn"..index,parent)
    b:SetPoint("TOPLEFT",parent,"TOPLEFT",x,y)
    b:SetSize(24,24)
    b.tex = b:CreateTexture(nil, "OVERLAY")
    rr,gg,bb = intToColor(colorInt)
    b.tex:SetColorTexture(rr,gg,bb,1)
    b:SetNormalTexture(b.tex)
    b.colorIndex = index
    b.oldColorInt = 0

    if WLisDragons then
       b:SetScript("OnClick", function(self, btn, down) -- btn is mouseBtnID; down is boolean
           PlaySound(SOUNDKIT.IG_MINIMAP_ZOOM_IN)
           WLColorBtnUnderEdit = self
           WLColorRowUnderEdit = 0
           self.oldColorInt = playerBgGrid[self.colorIndex]
           local rr,gg,bb = intToColor(self.oldColorInt)
           WLColorPickerInfo.r, WLColorPickerInfo.g, WLColorPickerInfo.b = rr,gg,bb
           WLColorPickerInfo.swatchFunc = colorSquareChanged
           WLColorPickerInfo.cancelFunc = colorSquareReset
           ColorPickerFrame:SetupColorPickerAndShow(WLColorPickerInfo)
       end)
   else
        b:SetScript("OnClick", function(self, btn, down) -- btn is mouseBtnID; down is boolean
            PlaySound(SOUNDKIT.IG_MINIMAP_ZOOM_IN)
            WLColorBtnUnderEdit = self
            WLColorRowUnderEdit = 0
            self.oldColorInt = playerBgGrid[self.colorIndex]
            local rr,gg,bb = intToColor(self.oldColorInt)
            ColorPickerFrame:SetColorRGB(rr,gg,bb)
            ColorPickerFrame.func = colorSquareChanged -- used by Wrath
            ColorPickerFrame.swatchFunc = colorSquareChanged -- used by Classic
            ColorPickerFrame.cancelFunc = colorSquareReset
            ColorPickerFrame:Hide()
            ColorPickerFrame:Show()
        end)
   end

    return b
end


-- Called by ColorPickerFrame when color wheel value is changed while a row is being updated
local function colorRowChanged()
    if WLColorRowUnderEdit > 0 then
        rr, gg, bb = ColorPickerFrame:GetColorRGB() -- get the new color
        colorInt = color1ToInt(rr, gg, bb) -- convert to in Int
        idxSt = 1 + WLTexWide * (WLColorRowUnderEdit-1)
        for ii = idxSt, (idxSt + WLTexWide - 1) do
            playerBgGrid[ii] = colorInt -- change the prefs
            WoWLightsFrame.baseTex[ii-1]:SetColorTexture(rr, gg, bb, 1.0) -- change the corner texture
            WLColorButtons[ii].tex:SetColorTexture(rr,gg,bb,1)  -- change the settings button
        end
    end
end

-- Called by ColorPickerFrame when its Cancel button is clicked while a row is being updated
local function colorRowReset()
    if WLColorRowUnderEdit > 0 then
        srcIndex = 1 + WLTexWide * (WLColorRowUnderEdit-1)  -- 1, 7, or 13
        for ii = srcIndex, (srcIndex + WLTexWide - 1) do
            colorInt = WLOldRowColors[ii-srcIndex]
            rr, gg, bb = intToColor(colorInt) -- get the old color
            playerBgGrid[ii] = colorInt -- change the prefs
            WoWLightsFrame.baseTex[ii-1]:SetColorTexture(rr, gg, bb, 1.0) -- change the corner texture
            WLColorButtons[ii].tex:SetColorTexture(rr,gg,bb,1)  -- change the settings button
        end
    end
end

-- Called to make the color wheel appear to change one row
function WoWLights:RecolorColorRow(self,rowNum)
    PlaySound(SOUNDKIT.IG_MINIMAP_ZOOM_IN)
    srcIndex = 1 + WLTexWide * (rowNum-1)  -- 1, 7, or 13
    WLColorRowUnderEdit = rowNum  -- 1, 2, 3
    WLColorBtnUnderEdit = nil
    for i = srcIndex, srcIndex + WLTexWide - 1 do
        WLOldRowColors[i-srcIndex] = playerBgGrid[i]
    end
    nowColorInt = playerBgGrid[srcIndex]
    local rr,gg,bb = intToColor(nowColorInt)

    if WLisDragons then
        WLColorPickerInfo.r, WLColorPickerInfo.g, WLColorPickerInfo.b = rr,gg,bb
        WLColorPickerInfo.swatchFunc = colorRowChanged
        WLColorPickerInfo.cancelFunc = colorRowReset
        ColorPickerFrame:SetupColorPickerAndShow(WLColorPickerInfo)
    else
        ColorPickerFrame:SetColorRGB(rr,gg,bb)
        ColorPickerFrame.func = colorRowChanged -- used by Wrath
        ColorPickerFrame.swatchFunc = colorRowChanged -- used by Classic
        ColorPickerFrame.cancelFunc = colorRowReset
        ColorPickerFrame:Hide()
        ColorPickerFrame:Show()
    end
end



--------------------------------- OTHER INTERFACE HANDLERS ---------------------------------

-- Called by slider control when the combat lights intensity slider is moved
function WoWLights:ChangeCombatPulseIntensity(value)
    setCombatFlashMaxAlpha(value) -- actual event handler
end


-- Called by edit box when ENTER is pressed in the grid size edit box
function WoWLights:ChangeFrameSize(sizeText)
    num = tonumber(sizeText)
    if num ~= nil and num > 1 and num < 100 then
        updateGridSize(num)
    end
end

-- Called by Memorize button in settings box
function WoWLights:MemorizeColors()
    PlaySound(SOUNDKIT.IG_QUEST_LIST_OPEN)
    local colorSetKey = setSettingsPlayerInfoAndGetColorSetKey()
    WLProfileMemory[colorSetKey] = playerBgGrid -- store the current 18 colors in the global saved table
end

-- Called when the Cancel button is clicked
function WoWLights:HandleSettingsCancel()
    ColorPickerFrame:Hide()
    PlaySound(SOUNDKIT.IG_MINIMAP_ZOOM_OUT)
    WoWLightsOptionsFrame:Hide()
    for i=1, WLTexWide * WLTexHigh do
        playerBgGrid[i] = WLUndoColorSetBuffer[i]
    end
    applyPlayerDefaultBackColors(WoWLightsFrame.baseTex)
    setCombatFlashMaxAlpha(WLUndoFlasherInput)
    updateGridSize(WLUndoGridSizeInput)
end

-- Called when the Cal Colors button is pressed
function WoWLights:HandleShowCalibrationPattern()
    for i=1, WLTexWide * WLTexHigh do
        local colorInt = calibrateBgGrid[i]
        playerBgGrid[i] = colorInt
        rr,gg,bb = intToColor(colorInt)
        WLColorButtons[i].tex:SetColorTexture(rr,gg,bb,1)
    end
    applyPlayerDefaultBackColors(WoWLightsFrame.baseTex)
end

local function darkenIfNotOnTaxi(ff)
    if not UnitOnTaxi("PLAYER") then
        setAlloverColor(ff.curtainFrame, blackColorInt, 0.5, 1.0) -- set curtain to 50% black
    end
end


------------------------------- DEFINE TRIGGERED ANIMATIONS ----------------------------

local function moveMoney(ff, moneyGain)
        if math.abs(moneyGain) < 100 then
            setMoneyWipeColor(ff.moneyAnim, copperColorInt)
        elseif math.abs(moneyGain) < 10000 then
            setMoneyWipeColor(ff.moneyAnim, silverColorInt)
        else
            setMoneyWipeColor(ff.moneyAnim, goldColorInt)
        end

        if moneyGain > 0 then
            ff.moneyAnim.wipe:SetStartDelay(0.0)
            ff.moneyAnim.wipe:SetEndDelay(0.2)
            ff.moneyAnim.wipeDown:Play()
        else -- play in reverse
            ff.moneyAnim.wipe:SetStartDelay(0.2)
            ff.moneyAnim.wipe:SetEndDelay(0.0)
            ff.moneyAnim.wipeDown:Play(true)
        end
end

local function launchFireworks(ff)
        for i=2,35 do
            ff.fireworks[i].wipeOut:Play()
        end
        C_Timer.After(1.0, function() applyCheckerboard(ff.baseTex, whiteColorInt, yellowColorInt) end)
        for t=3.0, 3.6, 0.2 do
            C_Timer.After(t, function() applyCheckerboard(ff.baseTex, yellowColorInt, whiteColorInt) end)
            C_Timer.After(t+0.1, function() applyCheckerboard(ff.baseTex, whiteColorInt, yellowColorInt) end)
        end
        for t=3.8, 4.2, 0.2 do
            C_Timer.After(t, function() applyCheckerboard(ff.baseTex, yellowColorInt, blackColorInt) end)
            C_Timer.After(t+0.1, function() applyCheckerboard(ff.baseTex, blackColorInt, yellowColorInt) end)
        end
        C_Timer.After(4.4, function() applyPlayerDefaultBackColors(ff.baseTex) end)
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
    if not WLisClassic and not WLisWrath then
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
end

local function updateHealthPulseRate()
    local combatAnim = WoWLightsFrame.alloverFrame.fader
    local effectiveHealth = UnitHealth("player")
    if WLisDragons then
        effectiveHealth = effectiveHealth + UnitGetTotalAbsorbs("player")
    end
    local healthFrac = effectiveHealth / UnitHealthMax("player")
    if healthFrac < 0.25 then
        combatAnim:SetDuration(0.4)
    elseif healthFrac < 0.5 then
        combatAnim:SetDuration(0.6)
    elseif healthFrac < 0.75 then
        combatAnim:SetDuration(0.8)
    else
        combatAnim:SetDuration(1.0)
    end
    if combatAnim:IsPlaying() then
        C_Timer.After(1.5, function() updateHealthPulseRate() end) -- call me again until animation stops
    end
end


------------------------------- USER INTERFACE UTILITIES --------------------------------

function WoWLights:ResetAnims()
    ff = WoWLightsFrame
    ff.alloverFrame.fadeInOut:Stop()
    ff.moneyAnim.wipeDown:Stop()
    cheatDeath(ff)
    for i,wiper in ipairs(ff.rainbowAnim) do
        wiper.wipeDown:Stop()
    end
    for i,wiper in ipairs(ff.talentAnim) do
        wiper.wipeRight:Stop()
    end
    for i=2,35 do
        ff.fireworks[i].wipeOut:Stop()
    end
    setAlloverColor(ff.curtainFrame, blackColorInt, 1.0, 0.0)
    applyPlayerDefaultBackColors(ff.baseTex)
end

function updateColorsForNewSpec(ff)
    local colorSetKey = setSettingsPlayerInfoAndGetColorSetKey()
    if colorSetKey ~= nil and WLProfileMemory ~= nil and WLProfileMemory[colorSetKey] ~= nil then
        for i=1, WLTexWide * WLTexHigh do
            local colorInt = WLProfileMemory[colorSetKey][i]
            playerBgGrid[i] = colorInt
            rr,gg,bb = intToColor(colorInt)
            WLColorButtons[i].tex:SetColorTexture(rr,gg,bb,1)
        end
        applyPlayerDefaultBackColors(WoWLightsFrame.baseTex)
    end
end


---##################################
---##########  ON_LOAD   ############
---##################################
local function OnLoad(ff)

    -- Initialize global saved vars if this is the first time we're ever starting
    if WLGridSqSize == nil or WLGridSqSize <= 0 then
        WLGridSqSize = 3.35
    end
    if WLCombatFlashAlpha == nil or WLCombatFlashAlpha <= 0 then
        WLCombatFlashAlpha = 0.8
    end

    if WLProfileMemory == nil then
        WLProfileMemory = {}
    end

    -- place and size WoW Lights
    ff:SetSize(WLGridSqSize * WLTexWide, WLGridSqSize * WLTexHigh)
    ff:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 0, 0)

    ff.alloverFrame = makeAlloverFrame(ff)
    ff.curtainFrame = makeCurtainFrame(ff)
    ff.baseTex = makeBackground(ff)
    ff.moneyAnim = makeMoneyWipe(ff)
    ff.rainbowAnim = makeVerticalRainbowWipe(ff)
    ff.talentAnim = makeHorizontalBlueWhiteWipe(ff)
    ff.fireworks = makeFireworksWipe(ff)

    ff.pulsers = {}
    for i=1,8 do
        ff.pulsers[i] = makePulser(ff, i)
    end

    ff.curtainFrame:SetFrameStrata("DIALOG") --highest
    ff.alloverFrame:SetFrameStrata("HIGH")
    ff.moneyAnim:SetFrameStrata("MEDIUM")

    -- create the light color programming buttons for settings window
    for row = 0,2 do
        for col = 0, 5 do
            local index = 1+indexOf(row,col)
            WLColorButtons[index] = makeColorButton(index, playerBgGrid[index], WoWLightsOptionsFrame, 130+(25*col), -70-25*row)
        end
    end

    -- events I'm interested in:
    ff:RegisterEvent("PLAYER_ENTERING_WORLD")
--  ff:RegisterEvent("PLAYER_STARTED_MOVING")
--  ff:RegisterEvent("PLAYER_STOPPED_MOVING")
    ff:RegisterEvent("PLAYER_REGEN_DISABLED")
    ff:RegisterEvent("PLAYER_REGEN_ENABLED")
    ff:RegisterEvent("PLAYER_MONEY")
    ff:RegisterEvent("NEW_TOY_ADDED")
    ff:RegisterEvent("ACHIEVEMENT_EARNED")
    ff:RegisterEvent("PLAYER_LEVEL_UP")
    ff:RegisterEvent("PLAYER_DEAD")
    ff:RegisterEvent("PLAYER_ALIVE")
    ff:RegisterEvent("PLAYER_UNGHOST")
    ff:RegisterEvent("READY_CHECK")
    ff:RegisterEvent("DUEL_REQUESTED")
    ff:RegisterEvent("CHAT_MSG_RAID_WARNING")
    ff:RegisterEvent("HEARTHSTONE_BOUND")
    ff:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    ff:RegisterEvent("PLAYER_CONTROL_GAINED")
    ff:RegisterEvent("PLAYER_CONTROL_LOST")

    if not WLisClassic then
        if not WLisWrath then
            ff:RegisterEvent("TRANSMOGRIFY_SUCCESS")
        end
        ff:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
        ff:RegisterEvent("ROLE_POLL_BEGIN")
    end
end




---##################################
---#########  ON_EVENT   ############
---##################################
function WoWLights:OnEvent(ff,event, ...)
    --print("WoW lights Event: "..event)
    local arg1, arg2 = ...;
    if event == "PLAYER_ENTERING_WORLD" then        -- set stuff up
        updateColorsForNewSpec(ff)
        WoWLightsOptionsFrame:EnableMouse(true) -- don't allow clicking thru the wallpaper
        tinsert(UISpecialFrames, WoWLightsOptionsFrame:GetName()) -- close it with the ESC key
        ff.wasMoney = GetMoney()
        if not WLisClassic and not WLisWrath then
            ff.oldSpec = GetSpecialization()
        end
        WoWLightsFrame:Show()

    elseif event == "ADDON_LOADED" then
        if not WLhasBeenLoaded then
            OnLoad(ff)
            WLhasBeenLoaded = true
        end

--   elseif event == "PLAYER_STARTED_MOVING" then
--      setBackgroundTexColor(ff.baseTex, 0, 1, whiteColorInt)
--    elseif event == "PLAYER_STOPPED_MOVING" then
--      setBackgroundTexColor(ff.baseTex, 0, 1, blackColorInt)

    elseif event == "PLAYER_REGEN_DISABLED" then
        ff.alloverFrame.fadeInOut:Play()
        C_Timer.After(0.25, function() updateHealthPulseRate() end)

    elseif event == "PLAYER_REGEN_ENABLED" then
        ff.alloverFrame.fadeInOut:Stop()

    elseif event == "TRANSMOGRIFY_SUCCESS" or event == "NEW_TOY_ADDED" then
        ff:UnregisterEvent("TRANSMOGRIFY_SUCCESS") -- only take first call, not every piece of gear!
        for i,wiper in ipairs(ff.rainbowAnim) do
            wiper.wipeDown:Play()
        end
        C_Timer.After(1.5, function() ff:RegisterEvent("TRANSMOGRIFY_SUCCESS") end)

    elseif event == "ACTIVE_TALENT_GROUP_CHANGED" then
        if arg2 ~= 0 then    -- arg2 == 0 only upon initial character login to the game world
            local specNow = GetSpecialization()
            if specNow ~= ff.oldSpec then -- if the actual spec has changed and not just a talent,
                for i,wiper in ipairs(ff.talentAnim) do
                    wiper.wipeRight:Play()
                end
                ff.oldSpec = specNow
            end
        end
        C_Timer.After(1.5, function() updateColorsForNewSpec(ff) end) -- updates button colors and settings text

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
    elseif event == "PLAYER_UNGHOST" then  -- after corpse run or spirit healer
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
        C_Timer.After(0.5, function() applyCheckerboard(ff.baseTex, blackColorInt, cyanColorInt) end)
        C_Timer.After(1.0, function() applyPlayerDefaultBackColors(ff.baseTex) end)

    elseif event == "ZONE_CHANGED_NEW_AREA" then
        updateInBetweenFlight(ff)

    elseif event == "PLAYER_CONTROL_LOST" then
        C_Timer.After(0.1, function() darkenIfNotOnTaxi(ff) end)
    elseif event == "PLAYER_CONTROL_GAINED" then
        setAlloverColor(ff.curtainFrame, blackColorInt, 1.0, 0.0) -- set curtain to transparent

    else
        print("WoW Lights: Registered for but didn't handle "..event)
    end
end


---##################################
---#########  ON_UPDATE   ###########
---##################################
--function WoWLights:OnUpdate(elapsed)
--
--end
