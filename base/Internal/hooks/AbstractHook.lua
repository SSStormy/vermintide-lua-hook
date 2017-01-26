local AbstractHook= Api.class("AbstractHook")

function AbstractHook:initialize(jsonObjectTag)
    assert(jsonObjectTag ~= nil)
    self._preHooks = { nil, { } }
    self._postHooks = { nil, { } }
    
    self._jsonObjectTag = jsonObjectTag
end

AbstractHook.JSON_PRE = "Pre"
AbstractHook.JSON_POST = "Post"
AbstractHook.JSON_KEY = "Key"
AbstractHook.JSON_VALUE = "Value"

function AbstractHook:HandleHook(hookTable, key)
	if hookTable[key] == nil or #hookTable[key] == 0 then
		return
	end

	for _, hookData in ipairs(hookTable[key]) do
        Log.Debug("Handling hook:", Api.json.encode(hookData))
        Api.dofile_e(hookData.ScriptExecuteDir, hookData)
	end
end

function AbstractHook:_append_hooks(hookTable, jobjTable, modFolder)
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
        
        -- be extra sure the hookTable contains a 'requireString' k-v pair
		hookTable[key] = hookTable[key] or { }
        
        local hookData = 
        {
            Key = key,
            Script = value,
            ModFolder= modFolder,
            ScriptExecuteDir = "./mods/" .. modFolder .. "/" .. value,
            HookHandlerName = self.name
        }
        
        -- insert hook data into the indexed table hookTable[requireString]
		table.insert(hookTable[key], hookData)
        
        Log.Debug("Loaded hookData:", Api.json.encode(hookData))
        Log.Write("AbstractHook:", key, value)
	end
end

function AbstractHook:ReadConfig(config, modFolder)
    Log.Debug(tostring(self), " reading config of", modFolder)
    
    -- check for malforms
    local obj = config[self._jsonObjectTag]
    if obj == nil then
        Log.Warn("AbstractHook: config[" .. self._jsonObjectTag .. "] is nil")
        return 0, nil
    end 
    
    local code, err = self:_append_hooks(self._preHooks, obj[self.JSON_PRE], modFolder)
    if code ~= 0 then return code, err end
    code, err = self:_append_hooks(self._postHooks, obj[self.JSON_POST], modFolder)
    if code ~= 0 then return code, err end
    
    return 0, nil
end

return AbstractHook