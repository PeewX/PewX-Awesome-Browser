--
-- HorrorClown (PewX)
-- Using: IntelliJ IDEA 14 Ultimate
-- Date: 19.12.2014 - Time: 18:41
-- pewx.de // iGaming-mta.de // iRace-mta.de // iSurvival.de // mtasa.de
--
CCore = {}

function CCore:constructor()
    self.managers = {}

    ---Manager Table: {"ManagerName", {arguments}}
    table.insert(self.managers, {"CDXManager", {}})
    table.insert(self.managers, {"CBrowserManager", {}})
end

function CCore:destructor()

end

function CCore:getManager(sName)
    return self[sName]
end

function CCore:startScript()
    for _, v in ipairs(self.managers) do
        if (type(_G[v[1]]) == "table") then
            self[tostring(v[1])] = new(_G[v[1]], unpack(v[2]))
            outputDebugString(("[CCore] Loading manager '%s'"):format(tostring(v[1])))
        else
            outputDebugString(("[CCore] Couldn't find manager '%s'"):format(tostring(v[1])))
        end
    end
end

--Create the Core Instance
addEventHandler("onClientResourceStart", resourceRoot,
    function()
        local s = getTickCount()
        outputDebugString("[CCore] Starting iGaming")
        Core = new(CCore)
        Core:startScript()
        outputDebugString(("[CCore] Starting finished (%sms)"):format(getTickCount()-s))
    end
)