local function TokenizeInput(input)
    local QUOTE_TOKEN = "\""

    local function isWhiteSpace(char) 
        return char == ' ' or char == '\r' or char == '\n' or char == '\t'
    end
    
    local lexData = 
    {
        original = input,
        stream = { },
        pos = 1,
        
        matchRawChar= function(self, expected)
            return stream[pos] == expected
        end,
        
        matchChar = function(self, expected)
            local privatePos = pos
            while isWhiteSpace(stream[privatePos]) do
                privatePos = privatePos + 1
            end
            return stream[privatePos] == expected
        end,
        
        consumeRawChar= function(self)
            self.pos = self.pos + 1
            return self.stream[self.pos - 1]
        end,
        
        consumeChar = function(self)
            local c
            repeat c = self:consumeRawChar() until not isWhiteSpace(c)
            return c
        end
    }
    message:gsub(".", function(c) table.insert(lexData.stream,c) end)
    
    local function matchStatement(data)
        local STATEMENT_TOKEN = ";"
        local c = data:consumeChar()
        if c ~= STATEMENT_TOKEN then error("Couldn't match statement token. Expected: " .. STATEMENT_TOKEN .. " found: " .. tostring(c)) end
    end
    
    local function tokenizeQuote(data)
        
    end

    local function tokenizeId(data)
        local c = data:nextChar()
        if c == QUOTE_TOKEN then return tokenizeQuote(data) end
        local id = c
    end
end

local function ParseTokens(tokens)
    
end

local function SubmitInput(input)
    
end

function RegisterCommand(command, callback)
    
end