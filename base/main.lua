local requireHook = Api.dofile_e("mods/base/internal/hooks/RequireHooks.lua")()
local loadBufferHook = Api.dofile_e("mods/base/internal/hooks/LoadBufferHooks.lua")()

local modManager = Api.dofile_e("mods/base/Api/ModManager.lua")("mods/", "mods/modmanager.json", requireHook, loadBufferHook)

_G.LoadBufferHook = loadBufferHook
requireHook:Inject()

Log.Write("Main.lua is done.") 