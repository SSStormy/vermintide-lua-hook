require("BaseSettings.lua")
BaseSettings.current = BaseSettings.debug

if BaseSettings.redirect_print then
    print_old  = print
    print = function(...)
        console.out(...)
        print(...)
    end
end

if BaseSettings.create_console then
    console.create()
end

console.out("Init base/main.lua")

_G.dofile = dofile or function(filename)
    local f = assert(loadfile(filename))
    return f()
end




