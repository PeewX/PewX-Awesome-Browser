--
-- HorrorClown (PewX)
-- Using: IntelliJ IDEA 14 Ultimate
-- Date: 26.07.2015 - Time: 04:18
-- pewx.de // iGaming-mta.de // iRace-mta.de // iSurvival.de // mtasa.de
--
CBrowserManager = {}

function CBrowserManager:constructor()
    self.createBrowserFunc = bind(CBrowserManager.createBrowser, self)
    self.sConfigPath = "res/config/browserDefinitions.xml"

    self:loadBrowserDefinitions()
    self:initBrowserDefinitions()
end

function CBrowserManager:destructor()

end

function CBrowserManager:createBrowser()
    if not self.browser then
        self.browser = new(CBrowser, self.tBrowserDefinitions.startupSizeX, self.tBrowserDefinitions.startupSizeY)
    elseif not self.browser.exists then
        self.browser = new(CBrowser, self.tBrowserDefinitions.startupSizeX, self.tBrowserDefinitions.startupSizeY)
    else
        outputChatBox(tostring(self.browser.state))
    end
end

function CBrowserManager:loadBrowserDefinitions()
    local xml = XML.load(self.sConfigPath)
    if not xml then return end

    --Main browser definitions
    local eConfigNode = xml:findChild("config", 0)
    self.tBrowserDefinitions = {}

    for _, eChild in ipairs(eConfigNode:getChildren()) do
        self.tBrowserDefinitions[eChild:getName()] = eChild:getValue()
    end

    --Color definitions
    local eColorsNode = xml:findChild("colors", 0)
    self.tColorDefinitions = {}

    for _, eMasterChild in ipairs(eColorsNode:getChildren()) do
        self.tColorDefinitions[eMasterChild:getName()] = {}

        for _, eChild in ipairs(eMasterChild:getChildren()) do
           self.tColorDefinitions[eMasterChild:getName()][eChild:getName()] = eChild:getValue()
       end
    end

    xml:unload()
    self.bDefinitionsLoaded = true
end

function CBrowserManager:initBrowserDefinitions()
    --Info & Timer
    if self.tBrowserDefinitions.info and self.tBrowserDefinitions.info ~= "" then
        outputChatBox(self.tBrowserDefinitions.info, 255, 255, 255, true)

        if self.tBrowserDefinitions.infoTimer and tonumber(self.tBrowserDefinitions.infoTimer) > 0 then
            setTimer(
                function()
                    outputChatBox(self.tBrowserDefinitions.info, 255, 255, 255, true)
                end, self.tBrowserDefinitions.infoTimer*1000, 0
            )
        end
    end

    --Command
    if self.tBrowserDefinitions.command then
       addCommandHandler(self.tBrowserDefinitions.command, self.createBrowserFunc)
    end
end

function CBrowserManager:getColors()
    return self.tColorDefinitions
end