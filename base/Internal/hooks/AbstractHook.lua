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
AbstractHook.JSON_FILE = "File"
AbstractHook.JSON_CHUNK = "Chunk"

function AbstractHook:HandleHook(hookTable, key)
    -- i'd assert the params but this is going to be called thousands of times per second when booting so i'd rather save some load time.
    
	if hookTable[key] == nil or #hookTable[key] == 0 then return end

	for _, hookData in ipairs(hookTable[key]) do
        Log.Debug("Handling hook:", Api.json.encode(hookData))
        
        if hookData:GetFileExecuteDir() ~= nil then
            Log.Debug("Handling file")
            Api.dofile_e(hookData:GetFileExecuteDir(), hookData)
        end
        
        if hookData:GetChunk() ~= nil then
            Log.Debug("Handling chunk")
            assert_e(pcall(hookData:GetChunk())) -- asserted pcall for the stacktrace
        end
        
	end
end

--[[ ---------------------------------------------------------------------------------------
        Name: AddHook
        Desc: Adds a new hook to this hook handler.
        Args: 
            (string key)            - the key of the hook. This will be the value which triggers the hook.
            (string file)           - directory of the file to execute
            (string chunk)          - the lua chunk to executed
            (ModHandle modHandle)   - a reference to the handle of the mod who will own this new hook.
            (bool isPreHook)        - true = hook is a prehook; false = hook is a posthook
        Returns: Always: the new hook handle.
        
--]] ---------------------------------------------------------------------------------------
function AbstractHook:AddHook(key, file, chunk, modHandle, isPreHook)
    assert_e(Api.IsString(key))
    assert_e(Api.IsString(file) or Api.IsString(chunk))
    assert_e(Api.IsTable(modHandle))
    assert_e(Api.IsBool(isPreHook))
    
    local hookData = fileHookInfoClass(key, file, chunk, modHandle, tostring(self))
    
    local hookTable
    
    if isPreHook then
        hookTable = self._preHooks
    else
        hookTable = self._postHooks
    end
    
    -- make sure tables have values
    local modHookTable = modHandle:GetHooks()
    modHookTable[self._objectKey] = modHookTable[self._objectKey] or {}
    hookTable[key] = hookTable[key] or { }
    
    -- insert hook into the mod handle's hook table
    table.insert(modHookTable[self._objectKey], hookData)
    
    -- insert hook data into the indexed table hookTable[requireString]
    table.insert(hookTable[key], hookData)
    
    Log.Debug("Added hook data:", Api.json.encode(hookData))
    
    return hookData
end

function AbstractHook:_json_append_hooks(isPreHook, jobjTable, modHandle)
    assert_e(Api.IsBool(isPreHook))
    assert_e(not jobjTable or Api.IsTable(jobjTable))
    assert_e(Api.IsTable(modHandle))
    Log.Debug("Appending hook for isPreHook state: ", tostring(isPreHook))
    
    if not jobjTable or #jobjTable == 0 then
        Log.Debug(tostring(self), tostring(jobjTable), "JObject table of mod", modFolder, "is empty or nil.")
        return 0
    end

	for __, entry in ipairs(jobjTable) do
        local file = entry[self.JSON_FILE]
        local chunk = entry[self.JSON_CHUNK]
        
        local key = entry[self.JSON_KEY]
        
        if key == nil then
            return 1, "AbstractHook failed: json key: " .. self.JSON_KEY .. " nil object"
        end
        
        if file == nil and chunk == nil then
            return 1, "AbstractHook failed: both " .. JSON_FILE .. " and " .. JSON_CHUNK .. " are nil."
        end
        
        self:AddHook(key, file, chunk, modHandle, isPreHook)
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
    
    Log.Debug(Api.json.encode(obj))
    
    local code, err = self:_json_append_hooks(true, obj[self.JSON_PRE], modHandle)
    if code ~= 0 then return code, err end
    code, err = self:_json_append_hooks(false, obj[self.JSON_POST], modHandle)
    if code ~= 0 then return code, err end
    
    return 0, nil
end

return AbstractHook