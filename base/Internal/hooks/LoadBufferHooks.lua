local absSuper =  Api._internal.GetAbstractHook()
local LoadBufferHooks = Api.class("LoadBufferHooks", absSuper)

function LoadBufferHooks:initialize()
    absSuper.initialize(self, Api._internal.LoadBufferKey)
end

-- called by cpp
function LoadBufferHooks:_notify_pre(name)
    assert_e(Std.IsString(name))
    self:HandleHook(self._preHooks, name)
end

-- called by cpp
function LoadBufferHooks:_notify_post(name)
    assert_e(Std.IsString(name))
    self:HandleHook(self._postHooks, name)
end

return LoadBufferHooks