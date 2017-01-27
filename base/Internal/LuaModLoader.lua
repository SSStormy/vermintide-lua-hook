local LuaModLoader = Api.class("LuaModLoader")
local modHandleClass = Api.dofile_e("mods/base/API/ModHandle.lua")

-- owner: ModManager
function LuaModLoader:initialize(owner, ...)
    assert_e(owner)
    self._owner = owner
end

function LuaModLoader:GetOwner() return self._owner end

--[[ ---------------------------------------------------------------------------------------
        Name: LoadModsInDir
        Desc: Attetmpts to load all mods in the given directory. Mods with duplicate
              keys will be reported to the error table.
        Args: 
            (string directory)      - the directory where mods should be loaded from.
            (string disabledMods)   - an indexed table of mod names, whose hooks
                                      shouldn't be loaded.
        Returns: Always:
                (table) key - ModHandle:GetKey(), value - ModHandle; all loaded mods
                (table) key - mod dir string, value - error message; the mod error table:
                        a table of errors encountered while trying to load mods. 
                        Empty if no errors.
        
--]] ---------------------------------------------------------------------------------------
function LuaModLoader:LoadModsInDir(directory, disabledMods)
    assert_e(Api.IsString(directory))
    assert_e(Api.IsTable(disabledMods))
    
    -- dont bother iterating over a folder that doesn't exist
    if not Path.ElementExists(directory, true) then return {} end
    
    local modsLoaded = { }
    local errors = { }
    
    for _, modDir in ipairs(Path.GetElements(directory)) do
        local result = self:LoadMod(directory, modDir, disabledMods)
        
        if Api.IsString(result) then
            errors[modDir] = result
        else
            local key = result:GetKey()
            
            -- check if key already exists
            if modsLoaded[key] == nil then
                modsLoaded[key] = result
            else
                errors[modDir] = "Duplicate key in loaded mods table: " .. key
            end
        end
    end
    
    return modsLoaded, errors
end

--[[ ---------------------------------------------------------------------------------------
        Name: LoadMod
        Desc: Attetmpts to load the mod at the given directory. Nothing will be done if
              the modFolderDir points to the base mod.
        Args: 
            (string directory)   - a directory in which we should look for modFolder
            (string modFolder)   - a the name of the folder in which the mod resides in
            (string disabledMods)- an indexed table of mod names, whose hooks shouldn't be loaded.
        Returns: 
            On success:
                (ModHandle) - a mod handle to the newly loaded mod.
            On failiure/error:
                (string)    - represents the message of the error that occurd
                
        
--]] ---------------------------------------------------------------------------------------
function LuaModLoader:LoadMod(directory, modFolder, disabledMods)
    Log.Debug("Loading mod:", directory)

    assert_e(Api.IsString(directory))
    assert_e(Api.IsString(modFolder))
    assert_e(Api.IsTable(disabledMods))
    
    if "base" == modFolderDir then return 0 end
    
    local cfg = Api.SafeParseJsonFile("./" .. directory .. "/" .. modFolder .. "/" .. "config.json")
    if not Api.IsTable(cfg) then return cfg end
    
    -- [[ verify schema ]] --
    local KEY_NAME = "Name"
    local KEY_VERSION = "Version"
    local KEY_AUTHOR = "Author"
    local KEY_CONTACT = "Contact"
    local KEY_WEBSITE =  "Website"
    
    local function verifyStringField(tabl, key)
        if tabl[key] == nil             then return "tabl." .. key .. " is nil." end
        if not Api.IsString(tabl[key])  then return "tabl." .. key .. " failed testtype()." end
    end
    
    local result 
    result = verifyStringField(cfg, KEY_NAME)       if result then return result end
    result = verifyStringField(cfg, KEY_VERSION)    if result then return result end
    result = verifyStringField(cfg, KEY_AUTHOR)     if result then return result end
    result = verifyStringField(cfg, KEY_CONTACT)    if result then return result end
    result = verifyStringField(cfg, KEY_WEBSITE)    if result then return result end
    
    local mod = modHandleClass(self:GetOwner(), modFolder, disabledMods, cfg[KEY_NAME], cfg[KEY_VERSION], cfg[KEY_AUTHOR], cfg[KEY_CONTACT], cfg[KEY_WEBSITE])
    
    if mod:IsEnabled() then
        -- iterate over all readers and let them read their part of the config.
        for _, reader in ipairs(self._configReaders) do
            local code, err = reader:ReadConfig(mod, cfg, dir)
            if code ~= 0 then return err end
        end
    end
    
    Log.Debug("Loaded mod:", directory)
    return mod
end

return LuaModLoader