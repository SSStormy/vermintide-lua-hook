local ModHandle = Api.class("FileHookInfo")

--[[ ---------------------------------------------------------------------------------------
        Name: initialize
        Desc: Creates an new immutable FileHookInfo class instance.
        Args: 
            (string key)                = the key (LoadBuffer name, or require module etc)
            (string script)             = directory, relative to the mod directory, to the script
            (string modHandle)          = a handle of the mod which owns this hook.
            (string scriptExecuteDir)   = directory, relative to the game exe, pointing to the script
            (string hookHandlerName)    = name of the hook handler that manages and created this hook.
        
--]] ---------------------------------------------------------------------------------------
function FileHookInfo:initialize(key, script, modHandle, scriptExecuteDir, hookHandlerName)
    assert_e(Api.IsString(key) and Api.IsString(script) and Api.IsString(modHandle) and Api.IsString(scriptExecuteDir) and Api.IsString(hookHandlerName))
    
    self._key = key
    self._script = script
    self._mod_handle = modHandle
    self._script_execute_dir = scriptExecuteDir
    self._hook_handler_name = hookHandlerName
end

--[[ ---------------------------------------------------------------------------------------
        Name: GetKey
        Returns: (string) the key of the mod. (LoadBuffer name, or require module etc)
--]] ---------------------------------------------------------------------------------------
function FileHookInfo:GetKey() return self._key end
    
    
--[[ ---------------------------------------------------------------------------------------
        Name:GetScript
        Returns: (string) directory, relative to the mod directory, to the hooked script
--]] ---------------------------------------------------------------------------------------
function FileHookInfo:GetScript() return self._script end
    
    
--[[ ---------------------------------------------------------------------------------------
        Name: GetModHandle
        Returns: (ModHandle) a handle of the mod which owns this hook.
--]] ---------------------------------------------------------------------------------------
function FileHookInfo:GetModHandle() return self._mod_handle end


--[[ ---------------------------------------------------------------------------------------
        Name: GetScriptExecuteDir
        Returns: (string) directory, relative to the game exe, pointing to the script
--]] ---------------------------------------------------------------------------------------
function FileHookInfo:GetScriptExecuteDir() return self._script_execute_dir end


--[[ ---------------------------------------------------------------------------------------
        Name: GetHookHandlerName
        Returns: (string) name of the hook handler that manages and created this hook.
--]] ---------------------------------------------------------------------------------------
function FileHookInfo:GetHookHandlerName() return self._hook_handler_name end
