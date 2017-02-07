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
    
Api.LoadBufferHook:AddHook("@scripts/ui/hud_ui/team_member_unit_frame_ui_definitions.lua", "Internal/PostPlay.lua", nil, baseMod, false)
    
    
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

assert(Api.ChatConsole:RegisterCommand(Api.ConsoleCommandClass("help", "Prints all available commands or help about a particular one.", baseMod, printHelp)))

Log.Write("Main.lua is done.") 
