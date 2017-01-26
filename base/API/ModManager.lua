local ModManager = Api.class("ModManager")

function ModManager:initialize()
    
end


function ModManager:Enable()
    
    
end

function ModManager:Disable()
    
end


local ModHandle = Api.class("ModHandle")

--[[ ---------------------------------------------------------------------------------------
        Name: initialize
        Desc: The constructor for immutable ModHandle class instances. Should only be used by
            LuaModLoader.
        Args: 
            (string name)    - the name of the mod
            (string version) - the version of the mod. This doesn't have to stick to a 
                               versioning scheme. 
    (opt)   (string author)  - the author of the mod
    (opt)   (string contact) - the contact info for the 
    (opt)   (string website) - the website of the mod
--]] ---------------------------------------------------------------------------------------

function ModHandle:initialize(name, version, author, contact, website)
    self._name = name
    self._verion = version
    self._author = author
    self._contact = contact
    self._website = website
    
    sell._enabled = false
end

function ModHandle:IsEnabled()
    
end

function ModHandle:GetName()

function ModHandle:GetVersion()

function ModHandle:GetAuthor()

function ModHandle:GetContact()

function ModHandle:GetWebsite()
    

return ModManager

