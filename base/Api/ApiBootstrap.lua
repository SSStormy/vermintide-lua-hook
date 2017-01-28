assert(_G.Api == nil)
assert(_G.require)
assert(_G.dofile)
assert(_G.loadfile)

_G.Api = 
{
    --[[ 
        Unmodified standard LUA functions. 
        Keeping backups in case the game decides to overwrite one of these.
    --]]
    Std= 
    {
        require     = _G.require,
        dofile      = _G.dofile,
        loadfile    = _G.loadfile,
        loadstring  = _G.loadstring,
        debug       = _G.debug,
        type        = _G.type,
        pcall       = _G.pcall,
    }
}


--[[ ---------------------------------------------------------------------------------------
                                        Helpers/Utils
--]] ---------------------------------------------------------------------------------------

--[[ ---------------------------------------------------------------------------------------
        Name: assert_e
        Desc: Asserts an expression. The assertion succeeds if the expression returns a
              non-falsy (not nil && not false) value.
              
              When the assertion fails, a message box containing the given message and
              the stack trace, the message + stack trace are written to Log.Warn()
              
        Args: 
            (expr)          - the expression to assert.
    (opt)   (string message)- the message to display upon a failed assertion. Default: "assertion failed!".
                              Illegal types set the value to default.
                              
        Returns: the value returned by evaluating the expression (and the message if expr is true)
--]] ---------------------------------------------------------------------------------------
_G.assert_e = function(expr, message)
    if expr then return expr, message end
        
    local msg = message

    if type(msg) ~= "string" then
        msg = "assertion failed!" 
    end
    
    msg = msg .. "\r\n" .. debug.traceback()
    
    Log.Warn(msg) 
    return assert(expr, msg)
end

--[[ ---------------------------------------------------------------------------------------
        Name: IsType
        Desc: Check if a given objects built-in type name matches the argument typename string.
        Args: any type object, string expected type name;
        Returns: (bool) true = types match; false = otherwise.
--]] ---------------------------------------------------------------------------------------
Api.IsType = function(obj, typename)
    assert_e(type(typename) == "string") -- type checking the type name parameter of a type checking function :ok_hand:
    return Api.Std.type(obj) == typename
end

Api.IsString    = function(obj) return Api.IsType(obj, "string") end
Api.IsBool      = function(obj) return Api.IsType(obj, "boolean") end
Api.IsNumber    = function(obj) return Api.IsType(obj, "number") end
Api.IsFunction  = function(obj) return Api.IsType(obj, "function") end
Api.IsTable     = function(obj) return Api.IsType(obj, "table") end

--[[ ---------------------------------------------------------------------------------------
        Name: dofile_e
        Desc: An extension to the standard dofile method that exposes vaargs which will be
                packed and exposed to the given script as "...", as well was perform
                loadfile and execution error checking via assert_e..
        Args: any type variadic
        Returns: whatever value the executed file returns.
        
--]] ---------------------------------------------------------------------------------------
Api.dofile_e = function(fn, ...)
    -- this doesn't want to cooperate with me when i try to code-golf it 
    local ret, chunk = Api.Std.pcall(Api.Std.loadfile, fn)
    assert_e(ret, chunk)
    ret, chunk = Api.Std.pcall(chunk, ...)
    assert_e(ret, chunk)
    return chunk
end

--[[ ---------------------------------------------------------------------------------------
        Name: has_value
        Desc: Checks if the given table contains a value. This compares values using
              the == operator.
        Args: 
            (table tab)     - the table in which we'll be looking for the value
            (object val)    - the value we'll be looking for.
        Returns: true = value exists in table; false = otherwise
        
--]] ---------------------------------------------------------------------------------------
_G.table.has_value = table.has_value or function(tab, val)
    assert_e(Api.IsTable(tab))
    
    for index, value in ipairs (tab) do
        if value == val then
            return true
        end
    end
    return false
end

--[[ ---------------------------------------------------------------------------------------
        Name: get_index
        Desc: Tries to find the index of the first appearance of the given value in the
              given table.
        Args: 
            (table tab)     - the table in which we'll be looking for the value
            (object val)    - the value whose index we'll be looking for.
        Returns: 
            On found:
                (int) - index of the value (val) in the table (tab)
            On failiure: 
                nil
--]] ---------------------------------------------------------------------------------------
_G.table.get_index = table.get_index or function(tab, val)
    assert_e(Api.IsTable(tab))
    for i, value in ipairs(tab) do
        if value == val then
            return i
        end
    end
    return nil
end

--[[ ---------------------------------------------------------------------------------------
        Name: SafeParseJsonFile
        Desc: Reads and parses a JSON file, handling any errors along the way.
        Args: 
            (string fileDir)    - the directory pointing to the JSON file.
        Returns:
                On success:
                    (table)     - represents the JSON file.
                On error:
                    (string)    - an error message.
                
--]] ---------------------------------------------------------------------------------------
Api.SafeParseJsonFile = function(fileDir)
    local expr = assert_e(Api.IsString(fileDir))
    
    local fileCfg, fopenErr = io.open(fileDir, "r")
    if fileCfg == nil then return fopenErr end
    
    local cfg, pos, jsonErr = Api.json.decode (fileCfg:read("*all"), 1, nil)
    if jsonErr then return "JSON Pos: (" .. tostring(pos) .. ") Error:" .. jsonErr end
    
    fileCfg:close()
    return cfg
end

--[[ ---------------------------------------------------------------------------------------
                                    Imported libraries 
--]] ---------------------------------------------------------------------------------------

Api.class = Api.Std.require("mods/base/imports/middleclass")
Api.json = Api.Std.require("mods/base/imports/dkjson")

--[[ ---------------------------------------------------------------------------------------
                                        Classes 
--]] ---------------------------------------------------------------------------------------

Api.FunctionHook = Api.Std.require("mods/base/Api/FunctionHookHandle")

--]] ---------------------------------------------------------------------------------------
Log.Write("Api bootstrap done.")
