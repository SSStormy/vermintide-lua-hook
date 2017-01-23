local hJson = HookGlobals.dofile_base("imports/dkjson.lua")

LuaModLoader = LuaModLoader or HookGlobals.class("LuaModLoader")

LuaModLoader.static =
{
    loadModsReturn_noDir        = -1,   -- load_mods_in_dir was passed an invalid dir
    
    loadModsError_success       = 0,    -- all's good
    loadModsError_noDir         = 1,    -- directory doesn't exist
    loadModsError_ioConfig      = 2,    -- io failiure with the mod config
    loadModsError_parseConfig   = 3,    -- could not parse config as a json file
}

function LuaModLoader:initialize(...)
    self.config_readers = {...}
end


--[[
    Loads all mods (not including the base mod) in the given directory.
    errorHandler signature:
        string - mod folder
        int    - error code (see LuaModLoader.static.loadModsError_*)
        string - error message
    
    returns: int:
                if negative:    see LuaModLoader.static.loadModsReturn_*,
                non-negative:   amount of mods loaded.
                
--]]
function LuaModLoader:load_mods_in_dir(dir, errorHandler)
    modsLoaded = 0
    
    -- dont bother iterating over a folder that doesn't exist
    if not path.element_exists(dir, true) then
        return self.static.loadModsReturn_noDir
    end
    
    for _, modFolder in ipairs(path.get_elements(dir)) do
        local code, err = self.load_mod(modFolder)
        
        -- error handle load_mod
        if errorHandler ~= nil and code ~= self.static.loadModsError_success then
            errorHandler(modFolder, code, err)
        else
            modsLoaded = modsLoaded + 1
        end
    end
    
    return modsLoaded
end

--[[
    Loads a mod in the given directory
    Returns:
        int     - error code. (see LuaModLoader.static.loadModsError_*)
        string  - error message or nil.
--]]
function LuaModLoader:load_mod(dir)
    
    if modFolder ~= "base"  then
        
        -- read config.json in mod folder and error handle
        local fileCfg, fopenErr = io.open("./mods/" .. modFolder .. "/" .. "config.json", "r")
        
        if fileCfg == nil then
            return self.static.loadModsError_ioConfig, fopenErr
        end 
        
        -- read everything in the config file then pass that to our json decoder, error handle.
        local cfg, pos, jsonErr = hJson.decode (fileCfg:read("*all"), 1, nil)
        
        if jsonErr then
            return self.static.loadModsReturn_parseConfig, jsonErr
        end
            
        -- iterate over all readers and let them read their part of the config.
        for __, reader in ipairs(self.config_readers) do
            local code, err = reader.read_config(cfg, modFolder)
            
            if code ~= 0 then
                return self.static.loadModsReturn_parseConfig, err
            end
        end
    end

    return self.static.loadModsReturn_success, nil
end
