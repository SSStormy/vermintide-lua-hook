local requireHook = Api.dofile_e("mods/base/internal/hooks/RequireHooks.lua")()
local loadBufferHook = Api.dofile_e("mods/base/internal/hooks/LoadBufferHooks.lua")()

assert(requireHook)
assert(loadBufferHook)

local modManager = Api.dofile_e("mods/base/Api/ModManager.lua")("mods/", "mods/modmanager.json", requireHook, loadBufferHook)
local baseMod = Api.Std.require("mods/base/Api/ModHandle")("base", "base", {}, "base", "v1.0.0", "ssstormy", nil, nil)

assert(baseMod)
assert(modManager)

_G.LoadBufferHook = loadBufferHook
requireHook:Inject()


loadBufferHook:AddHook("@scripts/game_state/state_ingame.lua", nil, 
    [[
        Api.ChatConsole:HijackChat()
    ]], baseMod, false)
    
Log.Write("Main.lua is done.") 