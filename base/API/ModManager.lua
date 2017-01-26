local ModManager = Api.class("ModManager")
ModManager:_mod_loader_class = Api.dofile_e("mods/base/internal/LuaModLoader.lua")

--[[ ---------------------------------------------------------------------------------------
        Name: initialize
        Desc: Constructs a ModManager and loads available mods
        Args: 
            (string modDir)     - directory of the folder in which mods are stored in
            (string configDir)  - directory of the mod manager config. 
                                  a new file will be created if file at dir doesn't exist 
            (AbstractHook ...)  - vaargs of abstract hook, that will be passed to the loader  
--]] ---------------------------------------------------------------------------------------
function ModManager:initialize(modDir, configDir, ...)
    assert(Path.ElementExists(modDir, true), "modDir " .. modDir .. " doesn't exist in the fs.")
    self._mod_dir = modDir
    self._config_dir = configDir


    self._mod_loader = self_mod_loader_class(...)
    self._mods_loaded = self._mod_loader:LoadModsInDir(self._mod_dir,  
        function(modFolder, errCode, err)
            Log.Write("ModLoadedError:", modfolder .. ":", err, "(" .. tostring(errCode) .. ")")
        end)
end

--[[ ---------------------------------------------------------------------------------------
        Name: LoadConfig 
        Desc: Static function. Loads and verifies the schema of a mod config.
        Args: 
            (string configDir)  - directory of the mod manager config. 
        Returns:
            (table)     - Either the loaded config or a new empty table.
            (string)    - Error message. If the config was loaded successfully, this is nil.
--]] ---------------------------------------------------------------------------------------
function ModManager.LoadConfig(configDir)
   assert(false) -- todo : LoadConfig 
end

Log.Write("Loaded mods:", tostring(modsLoaded))

requireHook:Inject()

Log.Write("Main.lua is done.")   
end

function ModManager:GetMods()

function ModManager:Enable()
    
function ModManager:Disable()


local ModHandle = Api.class("ModHandle")

--[[ ---------------------------------------------------------------------------------------
        Name: initialize
        Desc: The constructor for immutable ModHandle class instances. Should only be used by
              LuaModLoader.
        Args: 
            (ModManager owner)  - a reference to the ModManager that owns this handle.
            (string name)       - the name of the mod
            (string version)    - the version of the mod. This doesn't have to stick to a 
                                versioning scheme. 
    (opt)   (string author)     - the author of the mod (default: "Anonymous")
    (opt)   (string contact)    - the contact info for the 
    (opt)   (string website)    - the website of the mod
--]] ---------------------------------------------------------------------------------------
function ModHandle:initialize(owner, name, version, author, contact, website)
    self._owner = owner
    self._name = name
    self._verion = version
    self._author = author or "Anonymous" 
    self._contact = contact or nil
    self._website = website or nil
    
    sell._enabled = false
end


--[[ ---------------------------------------------------------------------------------------
        Name: GetKey 
        Desc: Returns a human readable key, which is guaranteed to be equal to keys of 
              mod handles which share the same name, version and author as this mod handle.
        Returns: (string) key
--]] ---------------------------------------------------------------------------------------
function ModHandle:GetKey()
    return self:GetName() .. " " .. self:GetVersion() .. " by " .. self:GetAuthor()
end

--[[ ---------------------------------------------------------------------------------------
        Name: IsEnabled 
        Desc: Checks if the handled mod is enabled
        Returns: (bool) true = enabled, false otherwise 
--]] ---------------------------------------------------------------------------------------
function ModHandle:IsEnabled() return self:_enabled end
 
--[[ ---------------------------------------------------------------------------------------
        Name: GetName 
        Returns: (string) the name of the mod 
--]] ---------------------------------------------------------------------------------------   
function ModHandle:GetName() return self:_name end

--[[ ---------------------------------------------------------------------------------------
        Name: GetVersion 
        Returns: (string) the version of the mod 
--]] ---------------------------------------------------------------------------------------   
function ModHandle:GetVersion() return self:_version end

--[[ ---------------------------------------------------------------------------------------
        Name: GetAuthor 
        Returns: (string) the author of the mod 
--]] ---------------------------------------------------------------------------------------   
function ModHandle:GetAuthor() return self:_author end

--[[ ---------------------------------------------------------------------------------------
        Name: GetContact 
        Returns: (string) the contact of the mod's author or nil 
--]] ---------------------------------------------------------------------------------------   
function ModHandle:GetContact() return self:_contact end

--[[ ---------------------------------------------------------------------------------------
        Name: GetWebsite 
        Returns: (string) the website of the mod or nil
--]] ---------------------------------------------------------------------------------------   
function ModHandle:GetWebsite() return self:_website end
    

return ModManager

