--
-- HorrorClown (PewX)
-- Using: IntelliJ IDEA 14 Ultimate
-- Date: 17.01.2015 - Time: 20:01
-- pewx.de // iGaming-mta.de // iRace-mta.de // iSurvival.de // mtasa.de
--
CDXEdit = inherit(CDXManager)

function CDXEdit:constructor(sTitle, nDiffX, nDiffY, nWidth, nHeight, bNumeric, bMasked, parent)
    self.title = sTitle
    self.text = ""
    self.diffX = nDiffX
    self.diffY = nDiffY
    self.w = nWidth
    self.h = nHeight
    self.parent = parent or false
    self.clickExecute = {}
    self.numeric = bNumeric
    self.masked = bMasked
    self.alpha = 255

    local pX, pY = self.parent:getPosition()
    self.x = pX + self.diffX
    self.y = pY + self.diffY

    self.clickFunc = bind(self.onEditClick, self)
    self.editFunc = bind(self.onEdit, self)
    self.keyFunc = bind(self.onEditKey, self)

    self:addClickFunction(
        function()
            if not self.clicked then
                self.clicked = true
                self.parent.mouseClickActive = false
                self.parent:defocus()

                addEventHandler("onClientClick", root, self.clickFunc)
                addEventHandler("onClientCharacter", root, self.editFunc)
                addEventHandler("onClientKey", root, self.keyFunc)
            end
        end
    )

    table.insert(self.parent.subElements, self)
end

function CDXEdit:destructor()

end

function CDXEdit:getText()
    return self.numeric and tonumber(self.text) or self.text
end

function CDXEdit:setText(sText)
    self.text = sText
end

function CDXEdit:onEditClick()
    if not isHover(self.x, self.y, self.w, self.h) then
        guiSetInputEnabled(false)
        self.clicked = false
        removeEventHandler("onClientClick", root, self.clickFunc)
        removeEventHandler("onClientCharacter", root, self.editFunc)
        removeEventHandler("onClientKey", root, self.keyFunc)
    else
        self.markedAll = false
        self.lctrl = false
        guiSetInputEnabled(true)
    end
end

function CDXEdit:onEdit(key)
    if self.markedAll then self.text = "" end
    self.markedAll = false
    self.lctrl = false

    if self.numeric and tonumber(key) then
        self.text = self.text .. key
    elseif not self.numeric then
        self.text = self.text .. key
    end
end

function CDXEdit:onEditKey(key, bDown)
    if key == "backspace" and not bDown then if isTimer(self.doTimer) then killTimer(self.doTimer) end end

    if key == "lctrl" then self.lctrl = true end
    if self.lctrl and key == "a" then
        self.markedAll = true
    end

    if bDown and key == "backspace" then
        if self.markedAll then self.text = "" end

        self.text = self.text:sub(0, #self.text-1)
        self.timer = setTimer(
            function()
                if getKeyState("backspace") then
                    self.doTimer = setTimer(
                        function()
                            self.text = self.text:sub(0, #self.text-1)
                        end
                        , 50, 0)
                end
            end
            , 200, 1)
        return
    end

    if bDown and key == "end" then
        self.markedAll = false
        self.lctrl = false
    end
end

function CDXEdit:render()
    if self.parent.moving then
        local pX, pY = self.parent:getPosition()
        self.x = pX + self.diffX
        self.y = pY + self.diffY
    end

    self.lineColor = tocolor(100, 100, 100, self.alpha)
    self.textColor = tocolor(0, 0, 0, self.alpha)
    if self.clicked then
        self.lineColor = tocolor(255, 80, 0, self.alpha)
        local tw = dxGetTextWidth(self.masked and string.rep("?", #self.text) or self.text, 1, "arial")
        if self.markedAll then
            self.textColor = tocolor(255, 255, 255, self.alpha)
            dxDrawRectangle(self.x + 5, self.y + 4, tw, self.h - 8, tocolor(0, 170, 255, self.alpha))
        else
            if getTickCount()%1000 > 500 then
                dxDrawRectangle(self.x + 5 + tw, self.y + 4, 1, self.h - 8, tocolor(0, 0, 0, self.alpha))
            end
        end
    end

    --dxDrawLine(self.x, self.y + self.h, self.x + self.w, self.y + self.h, self.lineColor, 2)
    if self.text == "" then dxDrawText(self.title, self.x + 5, self.y, self.x + self.w, self.y + self.h, tocolor(150, 150, 150, self.alpha), 1, "arial", "left", "center") end
    dxDrawText(self.masked and string.rep("?", #self.text) or self.text, self.x + 5, self.y, self.x + self.w, self.y + self.h, self.textColor, 1, "arial", "left", "center", true)
end