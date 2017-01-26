assert_e(_G.Api == nil)
assert_e(_G.require)
assert_e(_G.dofile)
assert_e(_G.loadfile)

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
        pcall       = _G.pcall
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
              the stack trace is shown.
              
        Args: 
            (expr)          - the expression to assert.
    (opt)   (string message)- the message to display upon a failed assertion. Default: "assertion failed!"
        Returns: the value returned by evaluating the expression.
--]] ---------------------------------------------------------------------------------------
_G.assert_e = function(expr, message)
    return Api.Std.assert_e(expr, m .. "\r\n" .. debug.traceback())
end

--[[ ---------------------------------------------------------------------------------------
        Name: IsType
        Desc: Check if a given objects built-in type name matches the argument typename string.
        Args: any type object, string expected type name;
        Returns: 0 = types match; 1 = otherwise.
--]] ---------------------------------------------------------------------------------------
Api.IsType = function(obj, typename)
    assert_e(type(typename) == "string") -- type checking the type name parameter of a type checking function :ok_hand:
    if Api.Std.type(obj) ~= typename then return 1 end
    return 0 
end

Api.IsString    = function(obj) return Api.IsType(obj, "string") end
Api.IsBool      = function(obj) return Api.IsType(obj, "boolean") end
Api.IsNumber    = function(obj) return Api.IsType(obj, "number") end
Api.IsFunction  = function(obj) return Api.IsType(obj, "function") end
Api.IsTable     = function(obj) return Api.IsType(obj, "table") end

--[[ ---------------------------------------------------------------------------------------
        Name: dofile_e
        Desc: An extension to the standard dofile method that exposes vaargs which will be
                packed and exposed to the given script as "..."
        Args: any type variadic
        Returns: see loadfile()
        
--]] ---------------------------------------------------------------------------------------
Api.dofile_e = function(fn, ...) 
    return assert_e(Api.Std.loadfile(fn))({...}) 
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
    for i, val in ipairs(tab) do
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
    assert_e(Api.IsString(fileDir))
    
    local fileCfg, fopenErr = io.open(fileDir, "r")
    if fileCfg == nil then return fopenErr end
    
    local cfg, pos, jsonErr = Api.json.decode (fileCfg:read("*all"), 1, nil)
    if jsonErr then return "JSON Pos: (" .. tostring(pos) .. ") Error:" .. jsonErr end
    
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

Api.FunctionHookHandle = Api.Std.require("mods/base/Api/FunctionHookHandle")

--]] ---------------------------------------------------------------------------------------
Log.Write("Api bootstrap done.")
