#include <Windows.h>
#include "include/Utils.h"
#include "include\LuaApi.h"

namespace VermHook
{
	int LuaApi::Console::Out(LuaState* state)
	{
		// Handle vaargs
		int args = lua_gettop(state);
		if (args <= 0)
			return 0;

		std::cout << ">> Lua:";

		for (int i = 0; i < args; i++)
		{
			// for handling a sigsegv on lua_tolstring with index 1 being nil
			int type = lua_type(state, 1);

			std::cout << " " <<
				((type != LUA_TNIL)
					? lua_tolstring(state, 1, NULL)
					: "nil");

			lua_remove(state, 1);
		}

		std::cout << std::endl;

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


#define PARAM_CHECK(errmsg) \
int argc = lua_gettop(state); \
	if (argc == 0 || argc > 2) \
		return luaL_error(state, errmsg); \
	auto path = lua_tolstring(state, 1, NULL); \
	bool dirOnly = false; \
	luaC_pop(state); \
	if (argc == 2) { \
		dirOnly = lua_toboolean(state, 1); \
		luaC_pop(state); } 

	int LuaApi::Path::GetElements(LuaState* state)
	{
		PARAM_CHECK("Invalid GetElements params");

		if (!Utils::ElementExists(path, dirOnly))
		{
			lua_pushnil(state);
			return 1;
		}

		std::vector<string> out;
		Utils::GetElements((string(path) + "/*").c_str(), out, dirOnly);
		Utils::StrVectorToIndexedTable(state, out);
		return 1;
	}

	int LuaApi::Path::ElementExists(LuaState* state)
	{
		PARAM_CHECK("Invalid Elements exists params");
		lua_pushboolean(state, Utils::ElementExists(path, dirOnly));
		return 1;
	}
}