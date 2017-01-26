if false then
    console.create()
end

require("mods/base/Api/ApiBootstrap")
require("mods/base/Internal/InternalBootstrap")

_G.table.has_value = table.has_value or function(tab, val)
    for index, value in ipairs (tab) do
        if value == val then
            return true
        end
    end
    return false
end

Log.Write("Bootstrap done.")
