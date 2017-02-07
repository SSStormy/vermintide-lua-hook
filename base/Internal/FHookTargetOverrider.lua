--[[
    We place this in a separate function due to any calls made to debug.source,
    when the debug struct cotains stack that describes us being in this function,
    returns the whole function string instead of the file it's defined in.
--]]

local signature = ...
assert_e(Api.IsString(signature))
Log.Debug("Overrider received signature:", signature)

return function(...)
    local entry = Api.FunctionHookClass.Hooks[signature]
    
    local function callAll(tabl, ...)
        for k,v in ipairs(tabl) do
            Log.Debug("Handling callAll for fhook value:", tostring(v))
            local status, ret = Api.Std.pcall(v:GetHookFunction(), ...)
            if not status then
                Log.Warn("Function hook Api.Std.pcall failed, error:", tostring(ret))
                Log.Debug("Hook data:")
                Log.Dump(Api.json.encode(v))
                Log.Debug("In hook table:")
                Log.Dump(Api.json.encode(tabl))
            end
        end
    end
    
    if entry == nil then
        Log.Warn("TARGET OVERRIDER FOR SIGNATURE", signature, "COULD NOT FIND ITS SIGNATURE'S ENTRY IN THE HOOK TABLE!")
        return nil
    end
    
    Log.Debug("Handling pre", signature)
    callAll(entry.PreHooks, ...)
    
    Log.Debug("Calling original", signature)
    local retvals = {entry.Original(...)}
    
    Log.Debug("Handling post", signature)
    callAll(entry.PostHooks, ...)
    
    return unpack(retvals)
end
