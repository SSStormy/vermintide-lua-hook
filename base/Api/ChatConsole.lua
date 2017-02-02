local CLexer = Api.class("CLexer")

function CLexer:initialize(input)
    self._stream = { }
    input:gsub(".", function(s) table.insert(self._stream, s) end)
    self._input = input
    self._pos = 1
end

function CLexer:IsWhitespace(char)
    return char == " " or char == "\n" or char == "\t" or char == "\r"
end

function CLexer:Lookahead()
    return self._stream[self._pos]
end

function CLexer:HandleWord()
    local buffer = ""
    
    repeat
        buffer = buffer .. self:Lookahead()
        self:Consume()
    until self:IsWhitespace(self:Lookahead()) or self:Lookahead() == nil
    
    return { Pos = self._pos, Data = buffer}
end

function CLexer:Consume()
    self._pos = self._pos + 1
end
    
function CLexer:NextToken()
    while self:Lookahead() ~= nil do
        if self:IsWhitespace(self:Lookahead()) then self:Consume()
        else return self:HandleWord() end
    end
    
    return nil
end

local ChatConsole = Api.class("ChatConsole")
local CommandPrefix = ";"

function ChatConsole:initialize()
    self._commands = { } -- key: command string; value: ConsoleCommand
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
        Args: (ConsoleCommand command) the command to register.
        Returns: (bool) true, when registered successfully, otherwise, false.
--]] ---------------------------------------------------------------------------------------
function ChatConsole:RegisterCommand(command)
    assert_e(Api.IsTable(command))
    assert_e(Api.IsString(command:GetTrigger()))

    Log.Debug("Registering command:", Api.json.encode(command))
    if self._commands[command:GetTrigger()] ~= nil then 
        Log.Debug("Failed registering command.")
        return false 
    end
    
    self._commands[command:GetTrigger()] = command
    Log.Debug("Registered")
    return true
end

--[[ ---------------------------------------------------------------------------------------
        Name: GetCommand
        Args:
            (string command)    - the command trigger.
        Return: nil or the ConsoleCommand table of the given command.
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
    Log.Debug("Unregistering command:", command)
end

function ChatConsole:HandleChatInput(input)
    local lexer = CLexer(input)
    local token = lexer:NextToken()
    local cmdKey = ""
    local status, err= nil
    
    -- iterate over each token, appending the current one to the last and testing for a command with that key
    while token ~= nil do
        
        cmdKey = cmdKey .. token.Data
        
        status, err = self:TryCommand(cmdKey, input:sub(token.Pos):match'^%s*(.*%S)' or '')
        if status then return true, err end
        
        cmdKey = cmdKey .. " "
        token = lexer:NextToken()
    end
    
    return false, err
end

function ChatConsole:TryCommand(cmdKey, args)
    Log.Debug("Cmd:", "\"" .. tostring(cmdKey) .. "\"", "Args:", "\"" .. tostring(args) .. "\"")
    
    if cmdKey == nil then return false, "No command specified." end
    local cmd = self._commands[cmdKey]
    if cmd == nil then return false, "Command not found." end
        
    local status, result = pcall(cmd:GetCallback(), cmdKey, args)
    if not status then return true, "Command failed: " .. tostring(result) end
    return true, result
end

return ChatConsole