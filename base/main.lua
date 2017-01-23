HookGlobals.dofile_base("LuaModLoader.lua")
HookGlobals.dofile_base("hooks/RequireHooks.lua")
HookGlobals.dofile_base("hooks/LoadBufferHooks.lua")


if false then
    console.create()
end

console.out("hooks")
local requireHooks = RequireHooks()
console.out("past hooks")
_G.HookGlobals.LoadBufferHook = LoadBufferHooks()


local modLoader = LuaModLoader(requireHooks, _G.HookGlobals.LoadBufferHook)

local modsLoaded = modLoader:load_mods_in_dir("mods",  
    function(modFolder, errCode, err)
        console.out(modfolder .. ":", err, "(" .. tostring(errCode) .. ")")
    end)

console.out("Loaded mods:", tostring(modsLoaded))

requireHooks:inject()

console.out("Main.lua is done.")