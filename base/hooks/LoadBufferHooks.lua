HookGlobals.dofile_base("hooks/AbstractHook.lua")

LoadBufferHooks = LoadBufferHooks or HookGlobals.class("LoadBufferHooks", AbstractHook)

function LoadBufferHooks:initialize()
    AbstractHook.initialize(self, "LoadBuffer")
end

function LoadBufferHooks:notify_pre(name)
    self:handle_hook(self._pre_hooks, name)
end

function LoadBufferHooks:notify_post(name)
    self:handle_hook(self._post_hooks, name)
end

