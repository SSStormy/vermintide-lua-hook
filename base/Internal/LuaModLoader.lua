local LuaModLoader = Api.class("LuaModLoader")

LuaModLoader.static =
{
    loadModsReturn_noDir        = -1,   -- load_mods_in_dir was passed an invalid dir
    
    loadModsError_success       = 0,    -- all's good
    loadModsError_noDir         = 1,    -- directory doesn't exist
    loadModsError_ioConfig      = 2,    -- io failiure with the mod config
    loadModsError_parseConfig   = 3,    -- could not parse config as a json file
}

function LuaModLoader:initialize(...)
    self._configReaders = {...}
end


--[[
    Loads all mods (not including the base mod) in the given directory.
    errorHandler signature:
        string - mod folder
        int    - error code (see LuaModLoader.loadModsError_*)
        string - error message
    
    returns: int:
                if negative:    see LuaModLoader.loadModsReturn_*,
                non-negative:   amount of mods loaded.
                
--]]
function LuaModLoader:LoadModsInDir(dir, errorHandler)
    modsLoaded = 0
    
    -- dont bother iterating over a folder that doesn't exist
    if not Path.ElementExists(dir, true) then
        return self.loadModsError_noDir
    end
    
    for _, modDir in ipairs(Path.GetElements(dir)) do
        local code, err = self:LoadMod(modDir)
        
        -- error handle load_mod
        if errorHandler ~= nil and code ~= self.loadModsError_success then
            errorHandler(modDir, code, err)
        else
            modsLoaded = modsLoaded + 1
        end
    end
    
    return modsLoaded
end

--[[
    Loads a mod in the given directory
    Returns:
        int     - error code. (see LuaModLoader.loadModsError_*)
        string  - error message or nil.
--]]
function LuaModLoader:LoadMod(dir)
    assert(dir ~= nil)
    
    if dir ~= "base"  then
        
        -- read config.json in mod folder and error handle
        local fileCfg, fopenErr = io.open("./mods/" .. dir .. "/" .. "config.json", "r")
        
        if fileCfg == nil then
            return self.loadModsError_ioConfig, fopenErr
        end 
        
        -- read everything in the config file then pass that to our json decoder, error handle.
        local cfg, pos, jsonErr = Api.json.decode (fileCfg:read("*all"), 1, nil)
        
        if jsonErr then
            return self.loadModsError_parseConfig, jsonErr
        end
            
        -- iterate over all readers and let them read their part of the config.
        for __, reader in ipairs(self._configReaders) do
            local code, err = reader:ReadConfig(cfg, dir)
            
            if code ~= 0 then
                return self.loadModsError_parseConfig, err
            end
        end
    end

    Log.Debug("Loaded", dir)
    return self.loadModsError_success, nil
end

return LuaModLoader
