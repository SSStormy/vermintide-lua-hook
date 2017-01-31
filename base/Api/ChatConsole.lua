local ChatConsole = Api.class("ChatConsole")
local CommandPrefix = ";"

function ChatConsole:initialize()
    self._commands = { } -- key: command string; value: callback
    self._isHijacked = false
end

--[[ ---------------------------------------------------------------------------------------
        Name: SendMessage
        Desc: The original send message function.
        Args:
            (table self)        - a reference to Managers.chat
            (integer channel)   - internally, always called with 1. Other details unknown.
            (string message)    - the message to send to other clients.
--]] ---------------------------------------------------------------------------------------
ChatConsole.SendMessage = function(...) Log.Warn("Tried to call unhijacked ChatConsole.SendMessage.", debug.traceback())  end

--[[ ---------------------------------------------------------------------------------------
        Name: SendLocalChat
        Desc: Sends a chat message to our client.
        Args: 
            (string message)    - the message to display
            (string isDev)      - sets the sender color to orange for true and blue for false.
                                  Requires the sender arg to be set.
            (string isSystem)   - whether to use a sender or not to.
    (opt)   (string sender)     - the sender.
--]] ---------------------------------------------------------------------------------------
function ChatConsole.SendLocalChat(message, isDev, isSystem, sender)
    assert_e(Api.IsString(message))
    
    local msg_tables = global_chat_gui.chat_output_widget.content.message_tables
    
    local msg = 
    {
        is_dev = isDev,
        is_system = isSystem,
        message = message,
        sender = sender
    }
    
    table.insert(msg_tables, msg)
end

local function detour(message)
    if message:sub(1,1) ~= CommandPrefix then return true end
    
    local status, result = Api.ChatConsole:HandleChatInput(message:sub(2))
    
    if result == nil then Log.Debug("command result is nil.") return false end
    
    local callbackMsg
    if not status then 
        Log.Debug("Error: " .. tostring(result)) 
        callbackMsg = "Error: " .. tostring(result)
    else
        Log.Debug(tostring(result))
        callbackMsg = tostring(result)
    end
    
    ChatConsole.SendLocalChat(callbackMsg, true, false, "LUA: ")
    
    return false
end

function ChatConsole:HijackChat()
    if self._isHijacked then return end
    self._isHijacked = true
    
    self.SendMessage = Managers.chat.send_chat_message
    assert_e(Api.IsFunction(Managers.chat.send_chat_message))
    assert_e(Api.IsFunction(self.SendMessage))
    
    Managers.chat.send_chat_message = function(self, channel, message, ...)
        local status, result = Api.logged_pcall(detour, message)
        
        if not status or result then Api.ChatConsole.SendMessage(Managers.chat, channel, message, ...) end
    end
    
    Log.Debug("ChatConsole: hijacked chat")
end

--[[ ---------------------------------------------------------------------------------------
        Name: RegisterCommand
        Desc: Attempts to register a chat command.
        Args: 
            (string command)        - the command trigger
            (function callback)     - the the callback of the command. 
                                      Signature: 
                                        (string command) - same as the command arg
                                        (string input)   - everything past command
                                      If return value is not null, it will be locally displayed
                                      in chat.
--]] ---------------------------------------------------------------------------------------
function ChatConsole:RegisterCommand(command, callback)
    assert_e(Api.IsString(command))
    assert_e(Api.IsFunction(callback))
    
    if self._commands[command] ~= nil then return false end
        
    self._commands[command] = callback
end

--[[ ---------------------------------------------------------------------------------------
        Name: GetCommand
        Args:
            (string command)    - the command trigger.
        Return: nil or the callback of the given command.
--]] ---------------------------------------------------------------------------------------
function ChatConsole:GetCommnand(command)
    assert_e(Api.IsString(command))
    return self._commands[command]
end

 --[[ ---------------------------------------------------------------------------------------
        Name: UnregisterCommand
        Args:
            (string command)    - the command trigger.
--]] ---------------------------------------------------------------------------------------
function ChatConsole:UnregisterCommand(command)
    assert_e(Api.IsString(command))
    self._commands[command] = nil
end

function ChatConsole:HandleChatInput(input)
    local spaceIndex = input:find(" ")
    
    local cmdKey
    local args
    
    if spaceIndex == nil then
        cmdKey = input
        args = nil
    else
        cmdKey= input:sub(1, spaceIndex-1)
        args = input:sub(spaceIndex+1)
    end
    
    Log.Debug("Cmd:", "\"" .. tostring(cmdKey) .. "\"", "Args:", "\"" .. tostring(args) .. "\"")
    
    if cmdKey == nil then return false, "No command specified." end
    local cmd = self._commands[cmdKey]
    if cmd == nil then return false, "Command not found." end
        
    local status, result = pcall(cmd, cmdKey, args)
    if not status then return false, "Command failed: " .. tostring(result) end
    
    return true, result
end

return ChatConsole