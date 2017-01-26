Api._internal = 
{
    AppendBase          = function(str) return "mods/base/" .. str                                         end,
    dofile_b            = function(fn)  return Api.Std.dofile(Api._internal.AppendBase(fn))                end,
    require_b           = function(fn)  return Api.Std.require(Api._internal.AppendBase(fn))               end,
    GetAbstractHook     = function()    return Api._internal.dofile_b("internal/hooks/AbstractHook.lua")   end,
    
    LoadBufferKey   = "LoadBuffer",
    RequireKey      = "Require"
}

Log.Write("Internal bootstrap done.")