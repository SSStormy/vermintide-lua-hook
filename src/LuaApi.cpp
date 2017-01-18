#include "include/LuaApi.h"
#include <Windows.h>
#include <sstring>

namespace VermHook
{
	int LuaApi::Console::Out(LuaState* state)
    {
        // Handle vaargs
        int args = lua_gettop(state);

        std::wstringstream sstr;
        for(int i = 0; i < args; i++)
        {
            sstr.putback(lua_tolstring(state, -1, NULL));
            sstr.putback(' ');
            lua_pop(state, 1);
        }
        
        std::cout << ">> Lua: " << sstr << std::endl;
        
		return 0;
	}

	int LuaApi::Console::Create(LuaState* state)
	{
		bool result = static_cast<bool>(AllocConsole());
		lua_pushboolean(state, result);
	
		if (result)
		{
#pragma warning(disable:4996)
			freopen("CONOUT$", "w", stdout);
			freopen("CONOUT$", "w", stderr);
			freopen("CONIN$", "r", stdin);
			SetConsoleTitle("Vermintide LUA");
		}

		return 1;
	}

    int LuaApi::Directory::GetFiles(LuaState* state)
    {
    }

    int LuaApi::Directory::GetFolders(LuaState* state)
    {
    }

    int LuaApi::Directory::ElementExists(LuaState* state)
    {
        
    }

    inline const char* LuaApi::Directory::AssertStrArg(LuaState* state)
    { 
        if(lua_gettop(state) > 1)
        {
            asdf // todo : either lua_error or luaL_error here (luaL preferrably)
        }

        return luaL_tolstring(state, -1, NULL);
    }

}
