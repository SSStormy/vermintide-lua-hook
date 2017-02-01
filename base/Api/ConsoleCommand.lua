local ConsoleCommand = Api.class("ConsoleCommand")

--[[ ---------------------------------------------------------------------------------------
        Name: initialize
        Desc: Constructs new unregistered console command.
        Args: 
            (string trigger)        - the string that triggers the command.
            (string description)    - a short description of what the command does.
            (ModHandle modHandle)   - a reference to the mod, which owns this command.
            (function callback)     - the function, which will be called when this command 
                                      is executed.
                                      Signature: (string trigger) - same as trigger
                                                   (string input) - everything, in the input 
                                                                    string, past the trigger
--]] ---------------------------------------------------------------------------------------
function ConsoleCommand:initialize(trigger, description, modHandle, callback)
    assert_e(Api.IsString(trigger))
    assert_e(Api.IsString(description))
    assert_e(Api.IsTable(modHandle))
    assert_e(Api.IsFunction(callback))
    
    self._trigger = trigger
    self._description = description
    self._modHandle = modHandle
    self._callback = callback
    
    getmetatable(self).__tojson = function(s, state)
        return "{" .. "\"trigger\": \"" .. tostring(s:GetTrigger()) .. "\"," ..
        "\"description\": \"" .. tostring(s:GetDescription()) .. "\"," ..
        "\"modHandle\": \"" .. tostring(s:GetModHandle()) .. "\"," ..
        "\"callback\": \"" .. tostring(s:GetCallback()) .. "\"}"
    end
end

function ConsoleCommand:GetTrigger() return self._trigger end

function ConsoleCommand:GetDescription() return self._description end

function ConsoleCommand:GetModHandle() return self._modHandle end

function ConsoleCommand:GetCallback() return self._callback end

return ConsoleCommand