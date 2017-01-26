local absSuper = Api._internal.GetAbstractHook()
local RequireHooks = Api.class("RequireHooks", absSuper)

function RequireHooks:initialize()
    absSuper.initialize(self, Api._internal.RequireKey)
end

function RequireHooks:Inject()
    Log.Debug("RequireHooks inject")
    self._oldRequire = _G.require
    
    _G.require = function(filename)
        self:HandleHook(self._preHooks, filename)
        local retval = self._oldRequire(filename)
        self:HandleHook(self._postHooks, filename)
        return retval
    end
end

return RequireHooks 