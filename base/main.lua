local requireHook = Api.dofile_e("mods/base/internal/hooks/RequireHooks.lua")()
local loadBufferHook = Api.dofile_e("mods/base/internal/hooks/LoadBufferHooks.lua")()
local modLoader = Api.dofile_e("mods/base/internal/LuaModLoader.lua")(requireHook, loadBufferHook)

_G.LoadBufferHook = loadBufferHook

local modsLoaded = modLoader:LoadModsInDir("mods",  
    function(modFolder, errCode, err)
        Log.Write("ModLoadedError:", modfolder .. ":", err, "(" .. tostring(errCode) .. ")")
    end)

Log.Write("Loaded mods:", tostring(modsLoaded))

requireHook:Inject()

Log.Write("Main.lua is done.")
