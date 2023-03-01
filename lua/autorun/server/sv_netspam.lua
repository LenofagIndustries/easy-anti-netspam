-- https://github.com/LenofagIndustries/easy-anti-netspam
-- Pasted from gm.lenofag.ru/sandbox code (my server)

timer.Create("LFI:NETSpamProtection", 1, 0, function()
    for _, ply in ipairs(player.GetHumans()) do
        ply.NETsPerSecond = 0
    end
end)

-- Specifies maximum NEts per second (kicks after )
local MaxNETsPerSecond = 100

-- Whitelist some NEts if you wish
local goodnets = {
    ["editvariable"] = true, -- spams in Context menu while touching some sliders
    ["simfphys_mousesteer"] = true, -- spams by simfphys every time you move your mouse
    ["simfphys_request_ppdata"] = true -- spams by simfphys
}

-- You can rename this convar's name if you want
-- Use this convar if you want every (except whitelisted) NETs to be printed in server's console
local cvar = CreateConVar("gmlfi_net_log", "0", FCVAR_NONE, "Log all nets", 0, 1)

net.Incoming = function(len, ply)
    if ply.KickForNETSpam then return end -- this can spam with kicks

    local name = util.NetworkIDToString(net.ReadHeader())
    if not name or not goodnets[name] then
        ply.NETsPerSecond = ply.NETsPerSecond ~= nil and ply.NETsPerSecond + 1 or 1
        if cvar:GetBool() and name and not goodnets[name] then print(string.format("[NETLOG] %s [%s] - %s", ply:Name(), ply:IPAddress(), name)) end
        if ply.NETsPerSecond >= MaxNETsPerSecond then
            print(string.format("Kicked %s [%s] for NET spamming%s", ply:Name(), ply:SteamID(), name and string.format(" [%s]", name) or ""))
            ply.KickForNETSpam = true
            ply:Kick("Kicked for NET spamming" .. (name and string.format(" [%s]", name) or "")) -- < You can change punishment action here
        return end
    end
    
    -- Does exactly same thing as default net.Incoming
    if not name then return end

    local func = net.Receivers[string.lower(name)]
    if not func then return end

    len = len - 16 -- net.ReadHeader() = 16 bit
    func(len, ply)
end

hook.Add("PlayerInitialSpawn", "LFI:NETSpamProtection", function(ply)
    ply.NETsPerSecond = 0
    ply.KickForNETSpam = false
end)