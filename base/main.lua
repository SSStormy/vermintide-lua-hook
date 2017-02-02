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

_G.__loadBufferHook = loadBufferHook
requireHook:Inject()

--[[ ---------------------------------------------------------------------------------------
                                        Chat console init
--]] ---------------------------------------------------------------------------------------

loadBufferHook:AddHook("@scripts/game_state/state_ingame.lua", nil, 
    [[
        Api.ChatConsole:HijackChat()
    ]], baseMod, false)
    
loadBufferHook:AddHook("@scripts/ui/hud_ui/team_member_unit_frame_ui_definitions.lua", "Internal/PostPlay.lua", nil, baseMod, false)
    
    
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

Log.Write("Main.lua is done.") 
