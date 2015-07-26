--
-- HorrorClown (PewX)
-- Using: IntelliJ IDEA 14 Ultimate
-- Date: 26.07.2015 - Time: 04:18
-- pewx.de // iGaming-mta.de // iRace-mta.de // iSurvival.de // mtasa.de
--
CBrowser = {}

function CBrowser:constructor()
    --Browser start properties
    self.isVisible = false
    self.tabs = 0
    self.currentTab = 0
    self.eBrowsers = {}

    --Browser size configuration
    self.isMaximized = false
    self.browserSizeX = 800/1920*x
    self.browserSizeY = 600/1080*y
    self.browserStartX = x/2-self.browserSizeX/2
    self.browserStartY = y/2-self.browserSizeY/2
    self.browserTabHeight = 35/1920*x
    self.browserMenuHeight = 34
    self.menuIconSizeX = 80/1920*x
    self.menuIconSizeY = 30/1920*x

    self.defaultMenuOffset = 5/1920*x
    self.menuOffset = self.defaultMenuOffset

    self.defaultTabSize = 120
    self.tabSize = self.defaultTabSize



    --Function handlers
    self.renderFunc = bind(CBrowser.renderBrowser, self)
    self.bindKeyFunc = bind(CBrowser.toggleBrowser, self)
    self.bindKeyFunc2 = bind(CBrowser.toggleBrowserSize, self)
    self.onClickFunc = bind(CBrowser.onClick, self)
    bindKey("F1", "down", self.bindKeyFunc)
    bindKey("F2", "down", self.bindKeyFunc2)
    --self:toggleBrowserSize()
end

function CBrowser:destructor()

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
            self.browserSizeX = 800/1920*x
            self.browserSizeY = 600/1080*y
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

function CBrowser:onClick(sBTN, sState)
    if sBTN == "left" and sState == "down" then
        self.mouseClickActive = true

        if isHover(self.browserStartX, self.browserStartY, self.browserSizeX, self.browserTabHeight) then
            self.browserMoving = true
            local cX, cY = getCursorPosition()
            self.diff = {cX*x-self.browserStartX, cY*y-self.browserStartY}
        else
            self.browserMoving = false
        end

        if isHover(self.browserStartX + self.browserSizeX - 20, self.browserStartY + self.browserSizeY - 20, 20, 20) then
           self.browserChangingSize = true
        else
            self.browserChangingSize = false
        end
    else
        self.mouseClickActive = false
    end
end

function CBrowser:renderBrowser()
    local bx, by = self.browserStartX, self.browserStartY   --Shortcut for browser start position

    --Main Window
    dxDrawRectangle(bx, by, self.browserSizeX, self.browserSizeY, tocolor(124, 170, 255))

    --Menu for previous/next page, speed dial buttons and URL edit
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

    --Browser
    dxDrawRectangle(bx + self.menuOffset, by + self.browserTabHeight + self.browserMenuHeight, self.browserSizeX - self.menuOffset*2, self.browserSizeY - self.browserTabHeight - self.browserMenuHeight - self.menuOffset)


    --If the browser is maximized, end here and do not change position/size if possible
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
addCommandHandler("browser", function()
    new(CBrowser)
end)
