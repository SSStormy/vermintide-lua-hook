local FunctionHookHandle = Api.class("FunctionHookHandle")

--[[
        Defines a handle for a lua function hook.
        
        At it's core, hooking works by keeping track of all active hooks (FunctionHookHandle.Hooks table)
        and by overriding the target signature with a custom function, which call the hooks
        and the original function.
        
        In theory, since this type of hooking is nothing but us assigning a new
        value to a given location, it is possible to create class instance hooks -- hooks
        are only hooked to an fucntion of an instanced class and not the definition of
        the function inside the class -- as well as global scope hooks.
--]]

--[[ ---------------------------------------------------------------------------------------
        Name: Initialize
        Desc: Creates a disabled hook for the given lua function signature.
        Args: 
            (string targetSignature)- the string signature of the target function.
                                      E.g "Api.Std.require" or "instance.SomeFunction"
            (function hookFunction) - The function that's going to hooked/injected
    (opt)   (bool isPre)            - whether the function is a prehook (true, default) or posthook (false)
--]] ---------------------------------------------------------------------------------------
function FunctionHookHandle:initialize(targetSignature, hookFunction, isPre)
    assert_e(Api.IsString(targetSignature)) 
    assert_e(Api.IsFunction(hookFunction))
    
    self._targetSignature = targetSignature    
    self._isPre = isPre or true
    self._hookFunction = hookFunction
        
    self._isActive = false
    self._targetFunction = nil
    
    getmetatable(self).__tojson = function(s, state)
        return "{" .. "\"targetSignature\": \"" .. tostring(s:GetTargetSignature()) .. "\"," ..
        "\"isPre\": \"" .. tostring(s:IsPreHook()) .. "\"," ..
        "\"hookFunction\": \"" .. tostring(s:GetHookFunction()) .. "\"," ..
        "\"isActive\": \"" .. tostring(s:IsActive()) .. "\"," ..
        "\"targetFunction\": \"" .. tostring(s:GetTargetFunction()) .. "\"}"
    end
end

--[[ ---------------------------------------------------------------------------------------
        Desc:  Stores all active hooks. You might want to stay away from writing to this.
        Key:   string signature of the target function (e.g: "Api.Std.loadfile" )
        Value: 
        {
            Original = Reference to original function of the same signature
            PreHooks = indexed table of active pre FunctionHookHandle to this function
            PostHooks = indexed table of active post FunctionHookHandle to this function
        }
--]] ---------------------------------------------------------------------------------------
FunctionHookHandle.Hooks = { }
    
--[[ ---------------------------------------------------------------------------------------
        Name: Create
        Desc: Creates and enables a hook for the given lua function signature. 
        Args: 
            (string targetSignature)- the string signature of the target function.
                                      E.g "Api.Std.require" or "instance.SomeFunction"
            (function hookFunction) - The function that's going to hooked/injected
    (opt)   (bool isPre)            - whether the function is a prehook (true) or posthook (false)
                                      default = true
    (opt)   (bool allowDuplicates)  - see FunctionHookHandle:Enable(allowDuplicates)
        Returns: A FunctionHookHandle class instance.
--]] ---------------------------------------------------------------------------------------
FunctionHookHandle.Create = function(targetSignature, hookFunction, isPre, allowDuplicates)
    local handle = FunctionHookHandle(targetSignature, hookFunction, isPre)
    handle:Enable(allowDuplicates)
    
    -- do some tests
    local entry = FunctionHookHandle.Hooks[targetSignature]
    assert_e(entry)
    Log.Debug(targetSignature, "Pre hooks:")
    Log.Dump(Api.json.encode(entry.PreHooks))
    Log.Debug(targetSignature, "Post hooks:")
    Log.Dump(Api.json.encode(entry.PostHooks))
    
    return handle
end


--[[ ---------------------------------------------------------------------------------------
        Name: GetTargetFunction
        Desc: Gets and returns the hook handler's target function.
        Args: (optional) bool - true to use cache (set during FunctionHookHandle:Enable()) (default), 
                     false to eval a new reference.
        Returns: The target function or nil if it was not found.
--]] ---------------------------------------------------------------------------------------
function FunctionHookHandle:GetTargetFunction(shouldUseCache)
    
    if shouldUseCache == nil or shouldUseCache then
        
        if self._targetFunction == nil then 
            Log.Warn("Tried to force cache GetTargetFunction but cache was null.\r\n"..debug.traceback())
            Log.Debug("Function hook handle dump:")
            Log.Dump(Api.json.encode(self))
        end
        
        return self._targetFunction 
    end
    
    local func = Api.Std.loadstring("return " .. self:GetTargetSignature())()
    
    if not Api.IsFunction(func) then
        Log.Warn("GetTargetFunction eval returns returns a type other then function:", type(func))
        Log.Debug("Hook dump:")
        Log.Dump(Api.json.encode(self))
        return nil
    end
    
    return func
end

--[[ ---------------------------------------------------------------------------------------
        Name: GetHookFunction
        Returns: Returns the hook's hook function.
--]] ---------------------------------------------------------------------------------------
function FunctionHookHandle:GetHookFunction() return self._hookFunction end

--[[ ---------------------------------------------------------------------------------------
        Name: GetTargetSignature
        Returns: The signature of the target function for this hook handler.
--]] ---------------------------------------------------------------------------------------
function FunctionHookHandle:GetTargetSignature() return self._targetSignature end

--[[ ---------------------------------------------------------------------------------------
        Name: IsPreHook
        Desc: Checks whether the handled hook is a precall (true) or a postcall (false) hook 
        Returns: bool, true = precall; false = postcall
--]] ---------------------------------------------------------------------------------------
function FunctionHookHandle:IsPreHook() return self._isPre end

--[[ ---------------------------------------------------------------------------------------
        Name: IsActive
        Desc: Checks whether the handled hook is active or otherwise.
        Returns: bool, true = active, false = otherwise
--]] ---------------------------------------------------------------------------------------
function FunctionHookHandle:IsActive() return self._isActive end

--[[ ---------------------------------------------------------------------------------------
        Name: SetPreHook
        Desc: Sets whether this hook is a precall or a postcall hook. 
              Can only be done if not IsActive().
        Args: bool, true = set to prehook; false = set to posthook.
--]] ---------------------------------------------------------------------------------------
function FunctionHookHandle:SetPreHook(isPreHook)
    assert_e(Api.IsBool(isPreHook))
    if self:IsActive() then return end
    self._isPre = isPreHook
end

--[[ ---------------------------------------------------------------------------------------
        Name: Disable
        Desc: Disables the hook. Can only be done if IsActive()
--]] ---------------------------------------------------------------------------------------
function FunctionHookHandle:Disable()
    if not self:IsActive() then return end
    local sign = self:GetTargetSignature()

    Log.Debug("Disabling a hook handle for signature", sign)

    local entry = FunctionHookHandle.Hooks[sign]

    -- figure out which table we should be removing the hook from
    local tabl
    if self:IsPreHook() then
        tabl = entry.PreHooks
    else
        tabl = entry.PostHooks
    end
    assert_e(Api.IsTable(tabl))
    
    -- remove our FunctionHookHandle from the hook table.
    local index = table.get_index(tabl, self)
    if index == nil then return end
    table.remove(tabl, index)
    
     
     -- check if the entry now hold two empty tables.
    if #entry.PreHooks <= 0 and #entry.PostHooks <= 0 then
        
        -- remove the hook entry
        Log.Debug("Removed now empty hook entry for signature", sign)
        FunctionHookHandle.Hooks[sign] = nil

        -- assign the original function back to it's signature
        Api.Std.loadstring(sign .. "=...")(self:GetTargetFunction())
        Log.Debug("Reassigned original function to signature", sign)
    end
  
    self._isActive = false
end



--[[ ---------------------------------------------------------------------------------------
        Name: Enable
        Desc: Enables the hook. Can only be done if not IsActive()
        Args: (opt) boolean, which determines whether to proceed hooking even if the appropriate 
                hook table (PreHook or PostHook) already contains one or more of hooks that 
                share the same target signature and hook function:
                True = proceed hooking. 
                False = do not hook, report message to Log.Warn and extra info to Log.Debug (default)
                
--]] ---------------------------------------------------------------------------------------
function FunctionHookHandle:Enable(allowDuplicates)
    if self:IsActive() then return end
    
    self._targetFunction = self:GetTargetFunction(false)
    
    -- make sure signature is all good
    if self._targetFunction == nil then
        Log.Warn("Failed evaluating target function for FunctionHookHandle.")
        Log.Debug("Hook dump:")
        Log.Dump(Api.json.encode(self))
        return             
    end
    
    -- hook entry didn't exist, create a new one.
    if FunctionHookHandle.Hooks[self:GetTargetSignature()] == nil then
        self:_create_hooks_entry()
    end
    
    self._isActive = true
    
    -- add ourselves to the new, or to the existing hook entry.
    if self:_append_hooks_entry(allowDuplicates or false) ~= 0 then
        return -- handled inline
    end
end

function FunctionHookHandle:_create_hooks_entry()
    
    -- have to be extra sure
    local sign = self:GetTargetSignature()
    assert_e(not FunctionHookHandle.Hooks[sign])
    
    -- add entry
    FunctionHookHandle.Hooks[sign] =
    {
        Original = self:GetTargetFunction(),
        PreHooks = { },
        PostHooks = { }
    }
    
    
    -- [[ overwrite original method with new one. ]] --
    
    -- Instantiate the targetOverrider function and capture the target signature
    local overriderChunk, err1 = Api.Std.loadfile("mods/base/Internal/FHookTargetOverrider.lua")
    --local overriderChunk, err1 = Api.Std.loadstring("local signature = \"" .. sign .. "\"\r\n" .. targetOverrider)
    assert_e(overriderChunk, "Target overrider loadstring evaluated to a nil chunk: " .. tostring(err1))
    
    local customFunc, err2 = overriderChunk(sign)
    assert_e(Api.IsFunction(customFunc), "Overrider function isn't a function: " .. type(customFunc) .. " err: " .. tostring(err2))
     
    -- Assign the customFunc onto the target signature. 
    -- ... is substituted for customFunc
    Api.Std.loadstring(sign .. "= ...")(customFunc)
    
    Log.Debug("Created new hooks entry for signature:", sign)
end

function FunctionHookHandle:_append_hooks_entry(allowDuplicates)
    local sign = self:GetTargetSignature()
    local entry = FunctionHookHandle.Hooks[sign]
    
    assert_e(entry)
    Log.Debug("Appending hooks entry of signature:", sign)
    
    local tabl = nil
    
    if self:IsPreHook() then
        tabl = entry.PreHooks
    else
        tabl = entry.PostHooks
    end
    
    -- check for dupes
    if not allowDuplicates then 
        for _, hook in ipairs(tabl) do
            if hook:GetHookFunction() == self:GetHookFunction() then
                Log.Warn("Duplicate hooks found in table at", tostring(tabl))
                Log.Debug("Tables: PreHook:", tostring(entry.PreHooks), "PostHook:", tostring(entry.PostHook))
                Log.Debug("Our hook dump:")
                Log.Dump(Api.json.encode(self))
                Log.Debug("Other hook dump:")
                Log.Dump(Api.json.encode(hook))
                return 1
            end
        end
        
    end
        
    table.insert(tabl, self)
    return 0
end

return FunctionHookHandle
