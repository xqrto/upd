return function(userAttr)
    if not userAttr then
        warn("Kein User-Attribut übergeben!")
        return
    end

    -- URL zum eigentlichen Hub
    local url = "https://raw.githubusercontent.com/xqrto/AllHubs/main/User/" .. userAttr .. "/Hub.lua"

    -- Lade das Hub-Script
    local success, err = pcall(function()
        loadstring(game:HttpGet(url, true))()
    end)

    if not success then
        warn("Fehler beim Laden des Hub-Scripts: "..err)
    end
end
