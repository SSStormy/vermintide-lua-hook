AbstractHook = AbstractHook or HookGlobals.class("AbstractHook")

function AbstractHook:initialize(jsonObjectTag)
    console.out("in abstract hook")
    self._pre_hooks = { nil, { } }
    self._post_hooks = { nil, { } }
    
    self.json_object_tag = jsonObjectTag
    console.out("out of abstract")
end

AbstractHook.static = 
{
    json_pre = "Pre",
    json_post = "Post",
    json_key = "Key",
    json_value = "Value"
}

function AbstractHook:handle_hook(hookTable, key)
	if hookTable[key] == nil or #hookTable[key] == 0 then
		return
	end

	for _, hook in ipairs(hookTable[key]) do
		HookGlobals.dofile(hook)
	end
end

local function append_hooks(hookTable, jobjTable, modFolder)
    if #jobjTable == 0 then
        return 0
    end
    
	for __, entry in ipairs(jobjTable) do
        local key = entry[self.static.json_key]
        local value = entry[self.static.json_value]
        
        if key == nil then
            return 1, "AbstractHook: json key: " .. self.static.json_key .. " null object"
        end
        
        if value == nil then
            return 1, "AbstractHook: json key: " .. self.static.json_value .. " null object"
        end
        
        -- be extra sure the hookTable contains a 'requireString' k-v pair
		hookTable[key] = hookTable[key] or { }
        
        -- insert the relative script directory into the indexed table hookTable[requireString]
		table.insert(hookTable[key], "./mods/" .. modFolder .. "/" .. value)
        console.out("AbstractHook:", key, value)
	end
end

function AbstractHook:read_config(config, modFolder)
    -- check for malforms
    local obj = config[self.static.json_object_tag]
    if obj == nil then
        return 1, "AbstractHook: config[" .. self.static.json_object_tag .. "] is nil"
    end 
    
    append_hooks(self._pre_hooks, obj[self.static.json_pre], modFolder)
    append_hooks(self._post_hooks, obj[self.static.json_post], modFolder)
    
    return 0, nil
end
