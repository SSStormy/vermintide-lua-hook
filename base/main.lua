local requireHook = Api.dofile_e("mods/base/internal/hooks/RequireHooks.lua")()
local loadBufferHook = Api.dofile_e("mods/base/internal/hooks/LoadBufferHooks.lua")()

_G.LoadBufferHook = loadBufferHook
