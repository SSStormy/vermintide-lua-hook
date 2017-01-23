HookGlobals.dofile_base("hooks/AbstractHook.lua")

RequireHooks = RequireHooks or HookGlobals.class("RequireHooks", AbstractHook)

function RequireHooks:initialize()
        console.out("in RequireHooks")
    AbstractHook.initialize(self, "Require")
            console.out("out of RequireHooks")

end

function RequireHooks:inject()
    console.out("RequireHooks inject")
    self.old_require = _G.require
    
    _G.require = function(filename)
        self:handle_hook(self._pre_hooks, filename)
        local retval = self.old_require(filename)
        self:handle_hook(self._post_hooks, filename)
        return retval
    end
end

