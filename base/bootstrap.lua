
-- [[ Bootstrap/Globals/Utils ]] --

-- Checks if a table has a value.

assert(not HookGlobals)
_G.HookGlobals = { }

-- Make a backup of these core lua functions, since they are overriden during the game's init process
assert(_G.loadfile)
assert(_G.require)
HookGlobals.lua_loadfile = _G.loadfile
HookGlobals.lua_require = _G.require

HookGlobals.append_base = function(str)
    return "./mods/base/" .. str
end

HookGlobals.dofile = function(fn)
    return assert(HookGlobals.lua_loadfile(fn))()
end

HookGlobals.dofile_base = function(fn)
    return HookGlobals.dofile(HookGlobals.append_base(fn))
end

HookGlobals.class = HookGlobals.dofile_base("imports/middleclass.lua")

_G.table.has_value = table.has_value or function(tab, val)
    for index, value in ipairs (tab) do
        if value == val then
            return true
        end
    end
    return false
end

