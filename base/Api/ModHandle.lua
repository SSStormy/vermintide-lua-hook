local ModHandle = Api.class("ModHandle")

ModHandle.RequireKey = Api._internal.RequireKey
ModHandle.LoadBufferKey = Api._internal.LoadBufferKey

--[[ ---------------------------------------------------------------------------------------
        Name: initialize
        Desc: The constructor for immutable ModHandle class instances. Should only be used by
              LuaModLoader.
        Args: 
            (ModManager owner)  - a reference to the ModManager that owns this handle.
            (string modFolder)  - the name of the mod's folder            
            (table disabledMods)- a table containing disabled mods keys.
            (string name)       - the name of the mod
            (string version)    - the version of the mod. This doesn't have to stick to a 
                                versioning scheme. 
    (opt)   (string author)     - the author of the mod (default: "Anonymous")
    (opt)   (string contact)    - the contact info for the 
    (opt)   (string website)    - the website of the mod
--]] ---------------------------------------------------------------------------------------
function ModHandle:initialize(owner, modFolder, disabledMods, name, version, author, contact, website)
    assert_e(owner)
    assert_e(Api.IsString(modFolder))
    assert_e(Api.IsTable(disabledMods))
    assert_e(Api.IsString(name))
    assert_e(Api.IsString(version))
    
    self._owner = owner
    self._modFolder = modFolder
    self._name = name
    self._verion = version
    self._author = author or "Anonymous" 
    self._contact = contact or nil
    self._website = website or nil
    
    self._hooks = { }
    self._hooks[ModHandle.RequireKey] = { }    
    self._hooks[ModHandle.LoadBufferKey] = { }
    
    self._enabled = disabledMods[self:GetKey()] ~= nil
end

--[[ ---------------------------------------------------------------------------------------
        Name: GetHooks
        Returns: (table) a table containing all lua file hooks that this mod owns.
                Table structure:
                {
                    Value   = (string) ModHandle.RequireKey or ModHandle.LoadBufferKey
                    Key     = (table) indexed talbe of FileHookInfo
                }
--]] ---------------------------------------------------------------------------------------
function ModHandle:GetHooks() return self._hooks end

--[[ ---------------------------------------------------------------------------------------
        Name: GetKey 
        Desc: Returns a human readable key, which is guaranteed to be equal to keys of 
              mod handles which share the same name and author as this mod handle.
        Returns: (string) key
--]] ---------------------------------------------------------------------------------------
function ModHandle:GetKey()
    return self:GetName() .. " by " .. self:GetAuthor()
end

 --[[ ---------------------------------------------------------------------------------------
        Name: GetOwner
        Returns: (ModManager) the manager that created and handles this mod.
--]] ---------------------------------------------------------------------------------------   
function ModHandle:GetOwner() return self._owner end

--[[ ---------------------------------------------------------------------------------------
        Name: IsEnabled 
        Desc: Checks if the handled mod is enabled
        Returns: (bool) true = enabled, false otherwise 
--]] ---------------------------------------------------------------------------------------
function ModHandle:IsEnabled() return self._enabled end
 
 --[[ ---------------------------------------------------------------------------------------
        Name: GetModFolder
        Returns: (string) the name of the mod's folder
--]] ---------------------------------------------------------------------------------------   
function ModHandle:GetModFolder() return self._modFolder end

 
--[[ ---------------------------------------------------------------------------------------
        Name: GetName 
        Returns: (string) the name of the mod 
--]] ---------------------------------------------------------------------------------------   
function ModHandle:GetName() return self._name end

--[[ ---------------------------------------------------------------------------------------
        Name: GetVersion 
        Returns: (string) the version of the mod 
--]] ---------------------------------------------------------------------------------------   
function ModHandle:GetVersion() return self._version end

--[[ ---------------------------------------------------------------------------------------
        Name: GetAuthor 
        Returns: (string) the author of the mod 
--]] ---------------------------------------------------------------------------------------   
function ModHandle:GetAuthor() return self._author end

--[[ ---------------------------------------------------------------------------------------
        Name: GetContact 
        Returns: (string) the contact of the mod's author or nil 
--]] ---------------------------------------------------------------------------------------   
function ModHandle:GetContact() return self._contact end

--[[ ---------------------------------------------------------------------------------------
        Name: GetWebsite 
        Returns: (string) the website of the mod or nil
--]] ---------------------------------------------------------------------------------------   
function ModHandle:GetWebsite() return self._website end

--[[ ---------------------------------------------------------------------------------------
        Name: Disable 
        Desc: Disables this mod. Functionally equal to calling ModManager:Disable(self)
--]] ---------------------------------------------------------------------------------------   
function ModHandle:Disable() self:GetOwner():Disable(self) end

--[[ ---------------------------------------------------------------------------------------
        Name: Enables 
        Desc: Enables this mod. Functionally equal to calling ModManager:Enables(self)
--]] ---------------------------------------------------------------------------------------   
function ModHandle:Enables() self:GetOwner():Enables(self) end

return ModHandle