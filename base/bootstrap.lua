
-- [[ Bootstrap/Globals/Utils ]] --

-- Checks if a table has a value.
_G.table.has_value = table.has_value or function(tab, val)
    for index, value in ipairs (tab) do
        if value == val then
            return true
        end
    end
    return false
end