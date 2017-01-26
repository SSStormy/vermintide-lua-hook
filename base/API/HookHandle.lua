local HookHandle = Api.class("HookHandle")

--[[
        Defines a handle for a lua function hook.
        
        At it's core, hooking works by keeping track of all active hooks (HookHandle.Hooks table)
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
        Args: string signature of the target function;
              function that's going to hooked/injected - the hook function
        (opt) boolean true (default) = pre function call, false = post
            
        Returns: A HookHandle class instance.
--]] ---------------------------------------------------------------------------------------
function HookHandle:initialize(targetSignature, hookFunction, isPre)
    self._targetSignature = targetSignature    
    self._targetFunction = nil
    self._isPre = isPre
    self._isActive = false
    self._hookFunction = hookFunction
end

--[[ ---------------------------------------------------------------------------------------
        Desc:  Stores all active hooks
        Key:   string signature of the target function (e.g: "Api.Std.loadfile" )
        Value: 
        {
            Original = Reference to original function of the same signature
            PreHooks = indexed table of active pre hooks to this function
            PostHooks = indexed table of active post hooks to this function
        }
--]] ---------------------------------------------------------------------------------------
HookHandle.Hooks = { }
    
--[[ ---------------------------------------------------------------------------------------
        Name: Create
        Desc: Creates and enables a hook for the given lua function signature. 
        Args: string signature of the target function;
          function that's going to hooked/injected - the hook function
        (opt) boolean true (default) = pre function call, false = post
        
        Returns: A HookHandle class instance.
--]] ---------------------------------------------------------------------------------------
HookHandle.Create = function(funcSignature, preHook)
    local handle = hookHandleClass(funcSignature, preHook or true)
    handle:enable()
    return handle
end


--[[ ---------------------------------------------------------------------------------------
        Name: GetTargetFunction
        Desc: Gets and returns the hook handler's target function.
        Args: (optional )bool - true to use cache (set during HookHandle:Enable()) (default), 
                     false to eval a new reference.
        Returns: The target function or nil if it was not found.
--]] ---------------------------------------------------------------------------------------
function HookHandle:GetTargetFunction(shouldUseCache)
    
    if (shouldUseCache or true) and self._targetFunction ~= nil then
        return self._targetFunction
    else
        local ret = Api.pcall(Api.Std.loadstring("return " .. self:GetTargetSignature()))
        if not ret then
            return nil
        elseif not Api.IsFunction(ret) then
            Log.Warn("GetTargetFunction eval returns returns a type other then function.")
            Log.Debug("Hook dump:", Api.json.encode(self))
            return nil
        end
        
        return ret
    end
end

--[[ ---------------------------------------------------------------------------------------
        Name: GetHookFunction
        Returns: Returns the hook's hook function.
--]] ---------------------------------------------------------------------------------------
function HookHandle:GetHookFunction() return self._hookFunction end

--[[ ---------------------------------------------------------------------------------------
        Name: GetTargetSignature
        Returns: The signature of the target function for this hook handler.
--]] ---------------------------------------------------------------------------------------
function HookHandle:GetTargetSignature() return self._targetSignature end

--[[ ---------------------------------------------------------------------------------------
        Name: IsPreHook
        Desc: Checks whether the handled hook is a precall (true) or a postcall (false) hook 
        Returns: bool, true = precall; false = postcall
--]] ---------------------------------------------------------------------------------------
function HookHandle:IsPreHook() return self._isPre end

--[[ ---------------------------------------------------------------------------------------
        Name: IsActive
        Desc: Checks whether the handled hook is active or otherwise.
        Returns: bool, true = active, false = otherwise
--]] ---------------------------------------------------------------------------------------
function HookHandle:IsActive() return self._isActive end

--[[ ---------------------------------------------------------------------------------------
        Name: SetPreHook
        Desc: Sets whether this hook is a precall or a postcall hook. 
              Can only be done if not IsActive().
        Args: bool, true = set to prehook; false = set to posthook.
--]] ---------------------------------------------------------------------------------------
function HookHandle:SetPreHook(isPreHook)
    if self:IsActive() then return end
    self._isPre = isPreHook
end

--[[ ---------------------------------------------------------------------------------------
        Name: Disable
        Desc: Disables the hook. Can only be done if IsActive()
--]] ---------------------------------------------------------------------------------------
function HookHandle:Disable()
    assert(false) -- todo : disable hook
    
    if not self:IsActive() then return end
   
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
function HookHandle:Enable(allowDuplicates)
    if self:IsActive() then return end
    
    self._targetFunction = self:GetTargetFunction(false)
    
    -- make sure signature is all good
    if self._targetFunction == nil then
        Log.Warn("Failed evaluating target function for HookHandle.")
        Log.Debug("Hook dump:", Api.json.encode(self))
        return             
    end
    
    -- hook entry didn't exist, create a new one.
    if HookHandle.Hooks[self:GetTargetSignature()] == nil then
        self:_create_hooks_entry()
    end
    
    -- add ourselves to the new, or to the existing hook entry.
    if self:_append_hooks_entry(allowDuplicates or false) ~= 0 then
        return -- it's handled inline
    end
    
    -- we're active now.
    self._isActive = true
end

local targetOverrider =  [[
local signature = ...

return function(...) 
    local entry = HookHandle.Hooks[signature]
    
    local function callAll(tabl)
        for k,v in ipairs(tabl) do
            if not pcall( v:GetHookFunction()(...) ) then
                Log.Warn("Function hook pcall failed.")
                Log.Debug("Hook data:", Api.json.encode(v))
                Log.Debug("In hook table:", Api.json.encode(tabl))
            end
        end
    end
    
    if entry == nil then
        Log.Warn("TARGET OVERRIDER FOR SIGNATURE", signature, "COULD NOT FIND ITS SIGNATURE'S ENTRY IN THE HOOK TABLE!")
        return nil
    end
    
    callAll(entry.PreHooks)
    entry.Original(...)
    callAll(entry.PostHooks)
end
]]

function HookHandle:_create_hooks_entry()
    
    -- have to be extra sure
    local sign = self:GetTargetSignature()
    assert(not HookHandle.Hooks[sign])
    
    -- add entry
    HookHandle.Hooks[sign] =
    {
        Original = self:GetTargetFunction(),
        PreHooks = { },
        PostHooks = { }
    }
    
    -- [[ overwrite original method with new one. ]] --
    
    -- Instantiate the targetOverrider function and capture the target signature
    local customFunc = Api.Std.loadstring(targetOverrider)(sign)
    -- Assign the customFunc onto the target signature. 
    -- ... is substituted for customFunc
    Api.Std.loadstring(sign .. "= ...")(customFunc) 
end

function HookHandle:_append_hooks_entry(allowDuplicates)
    local entry = HookHandle.Hooks[self:GetTargetSignature()]
    assert(entry)
    
    local tabl = nil
    
    if self:IsPreHook() then
        tabl = entry.PreHooks
    else
        tabl = entry.PostHooks
    end
    
    if not allowDuplicates then 
        
        for _, hook in ipairs(tabl) do
            
            if hook:GetTargetFunction() == self:GetTargetFunction() and hook:GetHookFunction() == self:GetHookFunction() then
                
                Log.Warn("Duplicate hooks found in table at", tostring(tabl))
                Log.Debug("Tables: PreHook:", tostring(entry.PreHooks), "PostHook:", tostring(entry.PostHook))
                Log.Debug("Our hook dump:", Api.json.encode(self))
                Log.Debug("Other hook dump:", Api.json.encode(hook))
                return 1
            end
        end
    end
    
    return 0
end

