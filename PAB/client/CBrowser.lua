--
-- HorrorClown (PewX)
-- Using: IntelliJ IDEA 14 Ultimate
-- Date: 26.07.2015 - Time: 04:18
-- pewx.de // iGaming-mta.de // iRace-mta.de // iSurvival.de // mtasa.de
--
--requestBrowserDomains({"http://google.com", "http://facebook.com", "http://teamspeak.com", "http://chip.com", "http://chip.de", "http://mtasa.de"})
CBrowser = {}

function CBrowser:constructor(startX, startY)
    --Browser start properties
    self.isVisible = false
    self.isActive = true
    self.tabs = 0
    self.currentTab = 0
    self.tabs = {}
    self.mainColor = tocolor(70, 120, 180)
    self.lineColor = tocolor(80, 80 ,80)

    --Browser size configuration
    self.isMaximized = false
    self.browserDefaultSizeX = startX or 460
    self.browserDefaultSizeY = startY or 320

    self.browserSizeX = self.browserDefaultSizeX/1920*x
    self.browserSizeY = self.browserDefaultSizeY/1080*y
    self.browserStartX = x/2-self.browserSizeX/2
    self.browserStartY = y/2-self.browserSizeY/2
    self.browserTabHeight = 35/1920*x
    self.browserMenuHeight = 34
    self.menuIconSizeX = 80/1920*x
    self.menuIconSizeY = 30/1920*x

    self.defaultMenuOffset = 5/1920*x
    self.menuOffset = self.defaultMenuOffset

    self.defaultTabSize = 180
    self.tabSize = self.defaultTabSize

    --Function handlers
    self.renderFunc = bind(CBrowser.renderBrowser, self)
    self.bindKeyFunc = bind(CBrowser.toggleBrowser, self)
    self.bindKeyFunc2 = bind(CBrowser.createTab, self)
    self.onClickFunc = bind(CBrowser.onClick, self)
    self.commandFunc = bind(CBrowser.navigateTo, self)

    --bindKey("F1", "down", self.bindKeyFunc)
    bindKey("F2", "down", self.bindKeyFunc2)
    addCommandHandler("navigate", self.commandFunc)

    ------------------------------------
    --Development
    -----------------------------------

    --self:toggleBrowserSize()
    self:toggleBrowser()
    self:createTab()
    self.currentTab = 1
end

function CBrowser:navigateTo(_, sNavigateTo)
    if not self.isActive then return end
    if Browser.isDomainBlocked(sNavigateTo, true) then
        outputChatBox("Returned: Domain is blocked!")
        return
    end

    self:loadURL(sNavigateTo)
end

function CBrowser:destructor()
    removeCommandHandler("navigate", self.commandFunc)
    removeEventHandler("onClientRender", root, self.renderFunc)
    removeEventHandler("onClientClick", root, self.onClickFunc)
    unbindKey("F1", "down", self.bindKeyFunc)
    unbindKey("F2", "down", self.bindKeyFunc2)

    self = nil
end

function CBrowser:toggleBrowser()
    if self.isVisible then
        self.isVisible = false
        removeEventHandler("onClientRender", root, self.renderFunc)
        removeEventHandler("onClientClick", root, self.onClickFunc)
        showCursor(false)
        return
    end

    if not self.isVisible then
        self.isVisible = true
        addEventHandler("onClientRender", root, self.renderFunc)
        addEventHandler("onClientClick", root, self.onClickFunc)
        showCursor(true)
        return
    end
end

function CBrowser:toggleBrowserSize()
    if self.isMaximized then
        if self.lastMinimizedPosition then
            self.browserStartX = self.lastMinimizedPosition.startX
            self.browserStartY = self.lastMinimizedPosition.startY
            self.browserSizeX = self.lastMinimizedPosition.sizeX
            self.browserSizeY = self.lastMinimizedPosition.sizeY
        else
            self.browserSizeX = self.browserDefaultSizeX/1920*x
            self.browserSizeY = self.browserDefaultSizeY/1080*y
            self.browserStartX = x/2-self.browserSizeX/2
            self.browserStartY = y/2-self.browserSizeY/2
        end
        self.isMaximized = false
        self.menuOffset = self.defaultMenuOffset
        return
    end

    if not self.isMaximized then
        self.lastMinimizedPosition = {startX = self.browserStartX, startY = self.browserStartY, sizeX = self.browserSizeX, sizeY = self.browserSizeY}
        self.browserStartX = 0
        self.browserStartY = 0
        self.browserSizeX = x
        self.browserSizeY = y
        self.isMaximized = true
        self.menuOffset = 0
        return
    end
end

function CBrowser:close()
    self:destructor()
end

function CBrowser:onClick(sBTN, sState)
    if sBTN == "left" and sState == "down" then
        --Check, if the browser was clicked, if not, return all inputs
        if isHover(self.browserStartX, self.browserStartY, self.browserSizeX, self.browserSizeY) then
            self.mainColor = tocolor(70, 120, 180)
            self.isActive = true
        else
            self.mainColor = tocolor(190, 190, 190)
            self.isActive = false
            self.mouseClickActive = false
            return
        end

        --Get current browser size
        self.currentBrowserSize = {self.browserSizeX, self.browserSizeY}
        self.mouseClickActive = true

        --If close button was clicked... R.I.P. Browser
        if isHover(self.browserStartX + self.browserSizeX - self.defaultMenuOffset - 40, self.browserStartY, 40, self.menuIconSizeY) then
            self:close()
            return
        end

        --Check if a tab was clicked
        for i, tab in ipairs(self.tabs) do
            local tabStartX =  self.browserStartX + self.menuOffset + self.menuIconSizeX + 5 + (self.tabSize*(i-1))
            if isHover(tabStartX, self.browserStartY, self.tabSize, self.browserStartY + self.menuIconSizeY + 5) then
                self.currentTab = i
                self.tabChanged = true
                self.mouseClickActive = false
                if tab.resize then
                    tab.resize = false

                    outputChatBox("Browser size changed, recreate browser in current tab")
                    if isElement(self.tabs[self.currentTab].browser) then
                        destroyElement(self.tabs[self.currentTab].browser)
                    end
                    self.tabs[self.currentTab].browser = Browser(self.browserSizeX - self.menuOffset*2, self.browserSizeY - self.browserTabHeight - self.browserMenuHeight - self.menuOffset, false, false)
                    addEventHandler("onClientBrowserCreated", self.tabs[self.currentTab].browser,
                        function()
                            --self.tabs[self.currentTab].browser:loadURL(self.tabs[self.currentTab].URL)
                            source:loadURL(self.tabs[self.currentTab].URL)
                        end
                    )

                end
                return
            end
        end

        --If browser bar was clicked, where the browser can be moved
        if isHover(self.browserStartX, self.browserStartY, self.browserSizeX, self.browserTabHeight) then
            self.browserMoving = true
            local cX, cY = getCursorPosition()
            self.diff = {cX*x-self.browserStartX, cY*y-self.browserStartY}
        else
            self.browserMoving = false
        end

        --If the area was clicked to change the size
        if isHover(self.browserStartX + self.browserSizeX - 20, self.browserStartY + self.browserSizeY - 20, 20, 20) then
            self.browserChangingSize = true
        else
            self.browserChangingSize = false
        end
    else
        self.mouseClickActive = false
        if self.currentBrowserSize[1] ~= self.browserSizeX or self.currentBrowserSize[2] ~= self.browserSizeY then
            outputChatBox("Browser size changed, recreate browser in current tab")
            if isElement(self.tabs[self.currentTab].browser) then
                destroyElement(self.tabs[self.currentTab].browser)
            end
            self.tabs[self.currentTab].browser = Browser(self.browserSizeX - self.menuOffset*2, self.browserSizeY - self.browserTabHeight - self.browserMenuHeight - self.menuOffset, false, false)
            addEventHandler("onClientBrowserCreated", self.tabs[self.currentTab].browser,
                function()
                    self.tabs[self.currentTab].browser:loadURL(self.tabs[self.currentTab].URL)
                    source:loadURL(self.tabs[self.currentTab].URL)
                end
            )

            for i, tab in ipairs(self.tabs) do
               if i ~= self.currentTab then
                  tab.resize = true
               end
            end
        end
    end
end

function CBrowser:loadURL(sURL)
    self.tabs[self.currentTab].URL = sURL
    self.tabs[self.currentTab].browser:loadURL(sURL)
    outputChatBox("loadURL: " .. sURL)
end

function CBrowser:createTab()
    local tab = {}
    tab.title = "Speed dial"
    tab.browser = Browser(self.browserSizeX - self.menuOffset*2, self.browserSizeY - self.browserTabHeight - self.browserMenuHeight - self.menuOffset, false, false)
    addEventHandler("onClientBrowserCreated", tab.browser,
        function()
            --ToDo: Set default/home page local
            tab.URL = "http://pewx.de/res/pab/index.htm"
            tab.browser:loadURL(tab.URL)
        end
    )
    table.insert(self.tabs, tab)


end

function CBrowser:renderBrowser()
    local bx, by = self.browserStartX, self.browserStartY   --Shortcut for browser start position

    --Main Window
    dxDrawRectangle(bx, by, self.browserSizeX, self.browserSizeY, self.mainColor)

    --Menu bar for previous/next page, speed dial buttons and URL edit
    dxDrawRectangle(bx + self.menuOffset, by + self.browserTabHeight, self.browserSizeX  - self.menuOffset*2, self.browserMenuHeight, tocolor(215, 215, 215))

    --Menu Button
    dxDrawRectangle(bx + self.menuOffset, by, self.menuIconSizeX, self.menuIconSizeY, tocolor(240, 240, 240))

    --Close Button (This button will not change the x position if the browser will maximized)
    dxDrawRectangle(bx + self.browserSizeX - self.defaultMenuOffset - 40, by, 40, self.menuIconSizeY, tocolor(215, 0, 0))

    --Buttons (back, forward, refresh, home)
    local mbx, mby = bx + self.menuOffset + 5, self.browserStartY + self.browserTabHeight --Start positions for menu buttons (tabBrowserX/Y)
    dxDrawImage(mbx + 36*0, mby + 5, 24, 24, "res/img/back.png", 0, 0, 0, tocolor(120, 120, 120))
    dxDrawImage(mbx + 36*1, mby + 5, 24, 24, "res/img/forward.png", 0, 0, 0, tocolor(120, 120, 120))
    dxDrawImage(mbx + 36*2, mby + 5, 24, 24, "res/img/refresh.png", 0, 0, 0, tocolor(120, 120, 120))
    dxDrawImage(mbx + 36*3, mby + 5, 24, 24, "res/img/home.png", 0, 0, 0, tocolor(120, 120, 120))

    --URL edir bar
    dxDrawRectangle(mbx + 36*4, mby + 5,  - 36*4 + self.browserSizeX - self.menuOffset*2 - 5*2, 24, tocolor(245, 245, 245))
    dxDrawText(("%s"):format(self.tabs[self.currentTab].browser:getURL()), mbx + 36*4 + 5, mby + 5, mbx + 36*4 - 36*4 + self.browserSizeX - self.menuOffset*2 - 5*3,  mby + 5 + 24, tocolor(0, 0, 0), 1, "default", "left", "center", true)

    --Draw some awesome epic supi dupi lines :>
    --Upper line for menu bar, draw from left window to first tab
    local lpfat = bx + self.menuOffset + self.menuIconSizeX + 6 + (self.tabSize*(self.currentTab-1)) --left position from active tab
    dxDrawLine(bx + self.menuOffset, by + self.browserTabHeight, lpfat, by + self.browserTabHeight, self.lineColor)

    --Upper line for menu bar, draw from active tab to right window
    local rpfat = bx + self.menuOffset + self.menuIconSizeX + 5 + (self.tabSize*(self.currentTab))  --right position from active tab
    dxDrawLine(rpfat, by + self.browserTabHeight, bx + self.menuOffset + self.browserSizeX  - self.menuOffset*2, by + self.browserTabHeight, self.lineColor)

    --Lower line for menu bar, draw from left window to right window
    dxDrawLine(bx + self.menuOffset, by + self.browserTabHeight + self.browserMenuHeight - 1, bx + self.menuOffset + self.browserSizeX  - self.menuOffset*2, by + self.browserTabHeight + self.browserMenuHeight - 1, self.lineColor, 1)

    --Draw Tabs
    local tx, ty = bx + self.menuOffset + self.menuIconSizeX + 5, by
    for i, tab in ipairs(self.tabs) do
        local tabStartX = tx + (self.tabSize*(i-1))
        local tabColor = i == self.currentTab and tocolor(215, 215, 215) or tocolor(150, 150, 150)

        dxDrawRectangle(tabStartX, ty, self.tabSize, self.menuIconSizeY + 5, tabColor)
        dxDrawLine(tabStartX, ty, tabStartX, ty + self.menuIconSizeY + 5, self.lineColor)
        dxDrawText(tostring(tab.browser:getTitle()), tabStartX + 5, ty, tabStartX + self.tabSize - 10, ty + self.menuIconSizeY + 5, tocolor(0, 0, 0), 1, "default", "left", "center", true)


        if i == #self.tabs then
            dxDrawLine(tabStartX + self.tabSize, ty, tabStartX + self.tabSize, ty + self.menuIconSizeY + 5, self.lineColor)
        end
    end

    --Browser
    --dxDrawRectangle(bx + self.menuOffset, by + self.browserTabHeight + self.browserMenuHeight, self.browserSizeX - self.menuOffset*2, self.browserSizeY - self.browserTabHeight - self.browserMenuHeight - self.menuOffset)
    dxDrawImage(bx + self.menuOffset, by + self.browserTabHeight + self.browserMenuHeight, self.browserSizeX - self.menuOffset*2, self.browserSizeY - self.browserTabHeight - self.browserMenuHeight - self.menuOffset, self.tabs[self.currentTab].browser)

    --If the browser is maximized, end here and do not change position/size
    if self.isMaximized then return end
    ---------------
    if self.mouseClickActive then
        if self.browserMoving then
            local cX, cY = getCursorPosition()
            self.browserStartX, self.browserStartY = cX*x-self.diff[1], cY*y-self.diff[2]
        end

        if self.browserChangingSize then
            local fx, fy = getCursorPosition()
            local x, y = fx*x, fy*y
            self.browserSizeX = x - self.browserStartX
            self.browserSizeY = y - self.browserStartY

            if self.browserSizeX < 400 then
                self.browserSizeX = 400
            end

            if self.browserSizeY < 150 then
                self.browserSizeY = 150
            end
        end
    end
end

--
addCommandHandler("browser", function(_, x, y)
    new(CBrowser, tonumber(x), tonumber(y))
end)