Log.Debug("Called PostPlay.lua")

-- notify player of any failed mod loads

local configError = Api.ModManager:GetLoadConfigError()
local modLoadErrors = Api.ModManager:GetLoadModsError()

local function writeChat(message)
   Api.ChatConsole.SendLocalChat(message, true, false, "VermHook: ")
end

if configError then
    writeChat("Error loading config: " .. tostring(configError))
end

if modLoadErrors then
    writeChat("Errors loading mods:")
    
    for k,v in pairs(modLoadErrors) do
       writeChat(tostring(k) .. ": " .. tostring(v)) 
    end
end