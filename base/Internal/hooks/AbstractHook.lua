local AbstractHook= Api.class("AbstractHook")
local fileHookInfoClass = Api.dofile_e("mods/base/Api/FileHookInfo.lua")

function AbstractHook:initialize(objectKey)
    assert_e(Api.IsString(objectKey))
    
    self._preHooks = {nil, { } }
    self._postHooks = { nil, { } }
    
    self._objectKey = objectKey
end

AbstractHook.JSON_PRE = "Pre"
AbstractHook.JSON_POST = "Post"
AbstractHook.JSON_KEY = "Key"
AbstractHook.JSON_VALUE = "Value"

function AbstractHook:HandleHook(hookTable, key)
    -- i'd assert the params but this is going to be called thousands of times per second when booting so i'd rather save some load time.
    
	if hookTable[key] == nil or #hookTable[key] == 0 then return end

	for _, hookData in ipairs(hookTable[key]) do
        Log.Debug("Handling hook:", Api.json.encode(hookData))
        Api.dofile_e(hookData:GetScriptExecuteDir(), hookData)
	end
end

function AbstractHook:_append_hooks(hookTable, jobjTable, modHandle)
    assert_e(Api.IsTable(hookTable))
    assert_e(not jobjTable or Api.IsTable(jobjTable))
    assert_e(Api.IsTable(modHandle))
    Log.Debug("Appending hooks for:", tostring(hookTable))
    
    if not jobjTable or #jobjTable == 0 then
        Log.Debug(tostring(self), tostring(jobjTable), "JObject table of mod", modFolder, "is empty or null.")
        return 0
    end

	for __, entry in ipairs(jobjTable) do
        local key = entry[self.JSON_KEY]
        local value = entry[self.JSON_VALUE]
        
        if key == nil then
            return 1, "AbstractHook: json key: " .. self.JSON_KEY .. " null object"
        end
        
        if value == nil then
            return 1, "AbstractHook: json key: " .. self.JSON_VALUE .. " null object"
        end
        
        local hookData = fileHookInfoClass(key, value, modHandle, "./mods/" .. modHandle:GetModFolder() .. "/" .. value, tostring(self))
        
        -- make sure tables have values
        local modHookTable = modHandle:GetHooks()
        modHookTable[self._objectKey] = modHookTable[self._objectKey] or {}
		hookTable[key] = hookTable[key] or { }
        
        -- insert hook into the mod handle's hook table
        table.insert(modHookTable[self._objectKey], hookData)
        
        -- insert hook data into the indexed table hookTable[requireString]
		table.insert(hookTable[key], hookData)
        
        Log.Debug("Loaded hookData:", Api.json.encode(hookData))
	end
    
    return 0
end

function AbstractHook:ReadConfig(modHandle, config, modFolder)
    assert_e(Api.IsTable(modHandle))
    assert_e(Api.IsTable(config))
    assert_e(Api.IsString(modFolder))
    
    -- check for malforms
    local obj = config[self._objectKey]
    if obj == nil then
        Log.Warn("AbstractHook: config[" .. self._objectKey .. "] is nil")
        return 0, nil
    end 
    
    local code, err = self:_append_hooks(self._preHooks, obj[self.JSON_PRE], modHandle)
    if code ~= 0 then return code, err end
    code, err = self:_append_hooks(self._postHooks, obj[self.JSON_POST], modHandle)
    if code ~= 0 then return code, err end
    
    return 0, nil
end

return AbstractHook