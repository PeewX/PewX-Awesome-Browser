--
-- HorrorClown (PewX)
-- Using: IntelliJ IDEA 14 Ultimate
-- Date: 26.07.2015 - Time: 04:17
-- pewx.de // iGaming-mta.de // iRace-mta.de // iSurvival.de // mtasa.de
--
if CLIENT then
    x, y = guiGetScreenSize()

    function isHover(startX, startY, width, height)
        if isCursorShowing() then
            local pos = {getCursorPosition()}
            return (x*pos[1] >= startX) and (x*pos[1] <= startX + width) and (y*pos[2] >= startY) and (y*pos[2] <= startY + height)
        end
        return false
    end
end