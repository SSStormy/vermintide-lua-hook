local ModManager = Api.class("ModManager")
ModManager._mod_loader_class = Api.dofile_e("mods/base/internal/LuaModLoader.lua")

--[[
    An indexed table of string that represent mod keys of mods that are disabled
--]]
local KEY_DISABLED = "DisabledMods"         

--[[ ---------------------------------------------------------------------------------------
        Name: initialize
        Desc: Constructs a ModManager and loads available mods
        Args: 
            (string modDir)     - directory of the folder in which mods are stored in
            (string configDir)  - directory pointing to the the mod manager config file.
                                A new file will be created if file at dir doesn't exist 
            (AbstractHook ...)  - vaargs of abstract hook, that will be passed to the loader  
--]] ---------------------------------------------------------------------------------------
function ModManager:initialize(modDir, configDir, ...)
    assert_e(Api.IsString(modDir) and Api.IsString(configDir))
    assert_e(Path.ElementExists(modDir, true), "modDir " .. modDir .. " doesn't exist in the fs.")
    
    self._config, self._cfg_load_result = self:LoadConfig(configDir)
    
    self._mod_dir = modDir
    self._config_dir = configDir

    self._mod_loader = self_mod_loader_class(...)
    self._mods, self._moad_load_result = self._mod_loader:LoadModsInDir(self._mod_dir, self._config[KEY_DISABLED])
end

--[[ ---------------------------------------------------------------------------------------
        Name: GetMods
        Returns: (table) returns a table of loaded ModHandles. 
                  Signature is equal to that of the mod list returned from
                  LuaModLoader:LoadModsInDir
--]] ---------------------------------------------------------------------------------------
function ModManager:GetMods() return self._mods end

--[[ ---------------------------------------------------------------------------------------
        Name: GetLoadModsError
        Returns: (table) Returns the error table returned by LoadModsInDir.
--]] ---------------------------------------------------------------------------------------
function ModManager:GetLoadModsError() return self._moad_load_result end
    
--[[ ---------------------------------------------------------------------------------------
        Name: GetLoadConfigError
        Returns: (string) Returns the error message LoadConfig returned if config
                          loading did fail. Otherwise, nil.
--]] ---------------------------------------------------------------------------------------
function ModManager:GetLoadConfigError() return self._cfg_load_result end

--[[ ---------------------------------------------------------------------------------------
        Name: GetModDir
        Returns: (string) The folder of mods this mod manager loads from.
--]] ---------------------------------------------------------------------------------------
function ModManager:GetModDir() return self._mod_dir end
    
--[[ ---------------------------------------------------------------------------------------
        Name: GetConfigDir
        Returns: (table) A directory pointing to the mod manager's config file.
--]] ---------------------------------------------------------------------------------------
function ModManager:GetConfigDir() return self._config_dir end

--[[ ---------------------------------------------------------------------------------------
        Name: GetConfig
        Returns: (table) The config of the mod loader as a table.
--]] ---------------------------------------------------------------------------------------
function ModManager:GetConfig() return self._config end


--[[ ---------------------------------------------------------------------------------------
        Name: Enable
        Desc: Enables a given ModHandle, if exists in the mod list but is not enabled.
              After enabling the mod, the hooks will not be initialized. The game
              needs to be restarted in order to do that.
--]] ---------------------------------------------------------------------------------------
function ModManager:Enable(modHandle)
    assert_e(Api.IsTable(modHandle))
    
    local key = modHandle:GetKey()

    if self._mods[key] == nil then return end
    if modHandle:IsEnabled() then return end
    
    local disabledMods = modHandle:GetConfig()[DisabledMods]
    local index = disabledMods:get_index(key)
    
    if index == nil then 
        Log.Warn("Tried to enable mod while it is not in the disabled list.")
        Log.Debug("Mod handle dump:", Api.json.encode(modHandle))
        Log.Debug("Disabled mod dump:", Api.json.encode(disabledMods))
        return
    end
    
    modHandle._enabled = true
    table.remove(disabledMods, index)
    self:SaveConfig()
end
    
--[[ ---------------------------------------------------------------------------------------
        Name: Disable
        Desc: Disables a given mod handle from being loaded. Once disabled, the mod's hooks
              will persist until the game restarts.
--]] ---------------------------------------------------------------------------------------
function ModManager:Disable(modHandle)
    assert_e(Api.IsTable(modHandle))
    
    local key = modHandle:GetKey()
    
    if self._mods[key] == nil then return end
    if not modHandle:IsEnabled() then return end
    local disabledMods = modHandle:GetConfig()[DisabledMods]
   
    -- check for duplicates
    local index = disabledMods:get_index(key)
    if index ~= nil then return end
   
    table.insert(disabledMods, key)
    modHandle._enabled = false
    self:SaveConfig()
end    

    
--[[ ---------------------------------------------------------------------------------------
        Name: SaveConfig
        Desc: Saves the mod manager's config back to the same file pointed by GetConfigDir()
        Returns:
            On success:     nil
            On Failiure:    (string) error message
--]] ---------------------------------------------------------------------------------------
function ModManager:SaveConfig()
    local fHandle, err = io.open(self:GetConfigDir(), "w+")
    if not fHandle then return err end
    
    fHandle:write(Api.json.encode(self.GetConfig()))
end

--[[ ---------------------------------------------------------------------------------------
        Name: LoadConfig 
        Desc: Static function. Loads and verifies the schema of a mod config.
        Args: 
            (string configDir)  - directory pointing to the the mod manager config file.
        Returns:
            (table)     - Either the loaded config or a new empty table.
            (string)    - Error message. If the config was loaded successfully, this is nil.
--]] ---------------------------------------------------------------------------------------
function ModManager.LoadConfig(configDir)
    assert_e(Api.IsString(configDir))
    
    -- [[ read/parse json ]] --
    local cfg = Api.SafeParseJsonFile(configDir)
    if Api.IsString(cfg) then return {}, cfg end
    
    -- [[ verify schema ]] --
    local function jsonVerifyArray(cfg, key, typecheck)
        if cfg[key] == nil                      then return "cfg." .. KEY_DISABLED .. " is nil." end
        if not Api.IsTable(cfg[key])            then return "cfg." .. KEY_DISABLED .. " is not a table." end
        
        -- type check elements
        for i,v in cfg[key] do 
            if not typecheck(v) then 
                return "cfg." .. KEY_DISABLED .. "[" .. tostring(i) .. "]" .. " is not a string." 
            end
        end
        
    end
    
    local result 
    result = jsonVerifyArray(cfg, KEY_DISABLED, Api.IsString) if result then return {}, result end
    
    return cfg, nil
end

return ModManager

