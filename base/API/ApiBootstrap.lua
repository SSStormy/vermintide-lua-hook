assert(_G.Api == nil)
assert(_G.require)
assert(_G.dofile)
assert(_G.loadfile)

_G.Api = 
{
    --[[ 
        Unmodified standard LUA functions. 
        Keeping backups in case the game decides to overwrite one of these.
    --]]
    Std= 
    {
        require     = _G.require,
        dofile      = _G.dofile,
        loadfile    = _G.loadfile,
        loadstring  = _G.loadstring,
        debug       = _G.debug,
        type        = _G.type,
        pcall       = _G.pcall
    }
}


--[[ ---------------------------------------------------------------------------------------
        Extended standard LUA 
--]] ---------------------------------------------------------------------------------------

--[[ ---------------------------------------------------------------------------------------
        Name: dofile_e
        Desc: An extension to the standard dofile method that exposes vaargs which will be
                packed and exposed to the given script as "..."
        Args: any type variadic
        Returns: see loadfile()
        
--]] ---------------------------------------------------------------------------------------
Api.dofile_e = function(fn, ...) 
    return assert(Api.Std.loadfile(fn))({...}) 
end

--[[ ---------------------------------------------------------------------------------------
    Name: IsType
    Desc: Check if a given objects built-in type name matches the argument typename string.
    Args: any type object, string expected type name;
    Returns: 0 = types match; 1 = otherwise.
--]] ---------------------------------------------------------------------------------------
Api.IsType = function(obj, typename) 
    if Api.Std.type(obj) ~= typename then return 1 end
    return 0 
end

Api.IsString    = function(obj) return Api.IsType(obj, "string") end
Api.IsBool      = function(obj) return Api.IsType(obj, "boolean") end
Api.IsNumber    = function(obj) return Api.IsType(obj, "number") end
Api.IsFunction  = function(obj) return Api.IsType(obj, "function") end
Api.IsTable     = function(obj) return Api.IsType(obj, "table") end
    

--[[ ---------------------------------------------------------------------------------------
        Imported libraries 
--]] ---------------------------------------------------------------------------------------

Api.class = Api.Std.require("mods/base/imports/middleclass")
Api.json = Api.Std.require("mods/base/imports/dkjson")

--[[ ---------------------------------------------------------------------------------------
        Classes 
--]] ---------------------------------------------------------------------------------------

Api.HookHandle = Api.Std.require("mods/base/Api/HookHandle")

Log.Write("Api bootstrap done.")
