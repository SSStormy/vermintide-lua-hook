#include "include/LuaApi.h"
#include <Windows.h>

namespace VermHook
{
	int LuaApi::Console::Out(LuaState* state)
	{
		LOG(">> Lua: " << lua_tolstring(state, -1, NULL));
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
}