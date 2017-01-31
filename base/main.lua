local requireHook = Api.dofile_e("mods/base/internal/hooks/RequireHooks.lua")()
local loadBufferHook = Api.dofile_e("mods/base/internal/hooks/LoadBufferHooks.lua")()

assert(requireHook)
assert(loadBufferHook)

Api.ModManager = Api.dofile_e("mods/base/Api/ModManager.lua")("mods/", "mods/modmanager.json", requireHook, loadBufferHook)
local baseMod = Api.Std.require("mods/base/Api/ModHandle")("base", "base", {}, "base", "v1.0.0", "ssstormy", nil, nil)

assert(baseMod)
assert(Api.ModManager)

_G.LoadBufferHook = loadBufferHook
requireHook:Inject()


loadBufferHook:AddHook("@scripts/game_state/state_ingame.lua", nil, 
    [[
        Api.ChatConsole:HijackChat()
    ]], baseMod, false)
    
loadBufferHook:AddHook("@scripts/ui/hud_ui/team_member_unit_frame_ui_definitions.lua", "Internal/PostPlay.lua", nil, baseMod, false)
    
Log.Write("Main.lua is done.") 