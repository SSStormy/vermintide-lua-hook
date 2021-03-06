local FileHookInfo = Api.class("FileHookInfo")

--[[ ---------------------------------------------------------------------------------------
        Name: initialize
        Desc: Creates an new immutable FileHookInfo class instance.
        Args: 
            (string key)                = the key (LoadBuffer name, or require module etc)
            (string file)               = directory, relative to the mod directory, to a file script that will be executed
            (string chunkString)        = a string chunk of lua code that will be executed.
            (table  modHandle)          = a handle of the mod which owns this hook.
            (string hookHandlerName)    = name of the hook handler that manages and created this hook.
        
--]] ---------------------------------------------------------------------------------------
function FileHookInfo:initialize(key, file, chunkString, modHandle, hookHandlerName)
    assert_e(Api.IsString(key))
    assert_e(Api.IsString(chunkString) or Api.IsString(file))
    assert_e(Api.IsTable(modHandle))
    assert_e(Api.IsString(hookHandlerName))

    self._key = key
    self._file = file
    self._mod_handle = modHandle
    self._hook_handler_name = hookHandlerName

    if file then
        self._file_execute_dir = "./mods/" .. modHandle:GetModFolder() .. "/" .. file
    else
        self._file_execute_dir = nil
    end
    
    if chunkString then
        local _, chunk = assert_e(pcall(Api.Std.loadstring, chunkString))
        self._chunk = chunk
    end
    
    getmetatable(self).__tojson = function(s, state)
        return "{" .. "\"key\": \"" .. tostring(s:GetKey()) .. "\"," ..
        "\"file\": \"" .. tostring(s:GetFile()) .. "\"," ..
        "\"chunk\": \"" .. tostring(s:GetChunk()) .. "\"," ..
        "\"scriptExecuteDir\": \"" .. tostring(s:GetFileExecuteDir()) .. "\"," ..
        "\"hookHandlerName\": \"" .. tostring(s:GetHookHandlerName()) .. "\"," ..        
        "\"modHandle_key\": \"" .. tostring(s:GetModHandle():GetKey()) .. "\"}"
    end
end

--[[ ---------------------------------------------------------------------------------------
        Name: GetKey
        Returns: (string) the key of the mod. (LoadBuffer name, or require module etc)
--]] ---------------------------------------------------------------------------------------
function FileHookInfo:GetKey() return self._key end
    
    
--[[ ---------------------------------------------------------------------------------------
        Name:GetFile
        Returns: (string) directory, relative to the mod directory, to the hooked script
--]] ---------------------------------------------------------------------------------------
function FileHookInfo:GetFile() return self._file end
    
--[[ ---------------------------------------------------------------------------------------
        Name: GetChunk
        Returns: (string) the lua chunk to be executed.
--]] ---------------------------------------------------------------------------------------
function FileHookInfo:GetChunk() return self._chunk end
    
--[[ ---------------------------------------------------------------------------------------
        Name: GetModHandle
        Returns: (ModHandle) a handle of the mod which owns this hook.
--]] ---------------------------------------------------------------------------------------
function FileHookInfo:GetModHandle() return self._mod_handle end


--[[ ---------------------------------------------------------------------------------------
        Name: GetFileExecuteDir
        Returns: (string) directory, relative to the game exe, pointing to the file.
--]] ---------------------------------------------------------------------------------------
function FileHookInfo:GetFileExecuteDir() return self._file_execute_dir end

--[[ ---------------------------------------------------------------------------------------
        Name: GetHookHandlerName
        Returns: (string) name of the hook handler that manages and created this hook.
--]] ---------------------------------------------------------------------------------------
function FileHookInfo:GetHookHandlerName() return self._hook_handler_name end

return FileHookInfo
