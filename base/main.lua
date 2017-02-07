--[[ ---------------------------------------------------------------------------------------
                                            Mod API
--]] ---------------------------------------------------------------------------------------

Api.RequireHook = Api.dofile_e("mods/base/internal/hooks/RequireHooks.lua")()
Api.LoadBufferHook = Api.dofile_e("mods/base/internal/hooks/LoadBufferHooks.lua")()

assert(Api.RequireHook)
assert(Api.LoadBufferHook)

Api.ModManager = Api.dofile_e("mods/base/Api/ModManager.lua")("mods/", "mods/modmanager.json", Api.RequireHook, Api.LoadBufferHook)
local baseMod = Api.Std.require("mods/base/Api/ModHandle")("base", "base", {}, "base", "v1.0.0", "ssstormy", nil, nil)

assert(baseMod)
assert(Api.ModManager)

_G.__loadBufferHook = Api.LoadBufferHook
Api.RequireHook:Inject()

--[[ ---------------------------------------------------------------------------------------
                                        Chat console init
--]] ---------------------------------------------------------------------------------------

Api.LoadBufferHook:AddHook("@scripts/game_state/state_ingame.lua", nil, 
    [[
        Api.ChatConsole:HijackChat()
    ]], baseMod, false)
    
Api.LoadBufferHook:AddHook("@scripts/ui/hud_ui/team_member_unit_frame_ui_definitions.lua", nil, "script_data.debug_enabled = true", baseMod, false)
    
--[[ ---------------------------------------------------------------------------------------
                                        Chat commands 
--]] ---------------------------------------------------------------------------------------

-- clear console
assert(Api.ChatConsole:RegisterCommand(Api.ConsoleCommandClass("clear", "Clears the chat.", baseMod, 
            function(...) global_chat_gui:create_ui_elements() end)))

-- evaluate script
assert(Api.ChatConsole:RegisterCommand(Api.ConsoleCommandClass("e", "Evaluates lua input.", baseMod, 
            function(cmd, input) 
                local chunk, err = Api.Std.loadstring(input)
                if chunk == nil then return err end
                return chunk()
            end)))

-- execute script file
assert(Api.ChatConsole:RegisterCommand(Api.ConsoleCommandClass("f", "Executes lua file in mods/file/__INPUT__.lua", baseMod, 
            function(cmd, input) 
                local chunk, err = Api.Std.loadfile("mods/file/" .. input .. ".lua")
                if chunk == nil then return error end
                return chunk() 
            end)))


local function printHelp(_, input)
    local specificCmd = Api.Trim(input)
    
    if not specificCmd or specificCmd == '' then
       -- print all commands
       Api.ChatConsole:PrintChat("Available commands:")
        for key, _ in pairs(Api.ChatConsole._commands) do
            Api.ChatConsole:PrintChat(key)
        end
        
        return
    end
    
    -- info about specific command
    local cmd = Api.ChatConsole:GetCommand(specificCmd)
    if not cmd then Api.ChatConsole:PrintChat(specificCmd .. ": command not found.") return end
    Api.ChatConsole:PrintChat(cmd:GetTrigger() .. " --- " .. cmd:GetDescription())
end

local function getModFromInput(input)
    if not input or input == ' ' then Api.ChatConsole:PrintChat("No input.") return nil end
    local mods = Api.ModManager:GetMods()
    
    -- find mod.
    local mod
    for k,imod in pairs(mods) do
       if imod:GetName() == input then 
           mod = imod 
        end
    end
    return mod
end

local function disableMod(_, input)
    local mod = getModFromInput(input)
    
    if not mod then Api.ChatConsole:PrintChat("Mod not found.") return end
    if not mod:IsEnabled() then Api.ChatConsole:PrintChat("Mod is already disabled.") return end
    
    Api.ModManager:Disable(mod)
    Api.ChatConsole:PrintChat("Disabled " .. mod:GetName())
end

local function enableMod(_, input)
    local mod = getModFromInput(input)
    
    if not mod then Api.ChatConsole:PrintChat("Mod not found.") return end
    if mod:IsEnabled() then Api.ChatConsole:PrintChat("Mod is already enabled.") return end
    
    Api.ModManager:Enable(mod)
    Api.ChatConsole:PrintChat("Enabled " .. mod:GetName())
end

local function listMods(_, input)
    local mods = Api.ModManager:GetMods()
    Api.ChatConsole:PrintChat("Loaded mods:")
    for k,mod in pairs(mods) do
        local statusString
        if mod:IsEnabled() then statusString = "enabled" else statusString = "disabled" end
        Api.ChatConsole:PrintChat(mod:GetName() .. " --- " .. statusString)
    end
end

local function getModInfo(_, input)
    local mod = getModFromInput(input)
    if not mod then Api.ChatConsole:PrintChat("Mod not found.") return end
    
    Api.ChatConsole:PrintChat(mod:GetName())
    Api.ChatConsole:PrintChat("  Name: " .. mod:GetName())
    Api.ChatConsole:PrintChat("  Author: " .. mod:GetAuthor())
    Api.ChatConsole:PrintChat("  Version: " .. mod:GetVersion())
    Api.ChatConsole:PrintChat("  Contact: " .. tostring(mod:GetContact()))
    Api.ChatConsole:PrintChat("  Website: " .. tostring(mod:GetWebsite()))
    Api.ChatConsole:PrintChat("  Enabled: " .. tostring(mod:IsEnabled()))
    Api.ChatConsole:PrintChat("  ModFolder: " .. mod:GetModFolder())
    Log.Debug("Hook dump:")
    Log.Dump(Api.json.encode(mod:GetHooks()))
end

assert(Api.ChatConsole:RegisterCommand(Api.ConsoleCommandClass("help", "Prints all available commands or help about a particular one.", baseMod, printHelp)))
assert(Api.ChatConsole:RegisterCommand(Api.ConsoleCommandClass("mod info", "Prints basic information about the mod.", baseMod, getModInfo)))
assert(Api.ChatConsole:RegisterCommand(Api.ConsoleCommandClass("mod list", "Lists loaded mods.", baseMod, listMods)))
assert(Api.ChatConsole:RegisterCommand(Api.ConsoleCommandClass("mod enable", "Enables a mod, identified by it's name.", baseMod, enableMod)))
assert(Api.ChatConsole:RegisterCommand(Api.ConsoleCommandClass("mod disable", "Disables a mod, identified by it's name.", baseMod, disableMod)))


Log.Write("Main.lua is done.") 
