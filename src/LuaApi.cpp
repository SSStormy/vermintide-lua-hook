#include <Windows.h>
#include "include/Utils.h"
#include "include\LuaApi.h"
#include <sstream>
#include "include/Globals.h"
#include <assert.h>
#include "include/Globals.h"

namespace VermHook
{
	int LuaApi::Log::Write(LuaState* state)
	{
		Logger::Write(ConcatVaargs(state));
		return 0;
	}

#define TRACE_WRITE(method) \
		LuaDebug *debug = new LuaDebug(); \
		auto stackResult = lua_getstack(state, 1, debug); \
		auto infoResult = lua_getinfo(state, "Sl", debug); \
		Logger::method(ConcatVaargs(state), debug->source, debug->currentline); \
		delete debug;

	int LuaApi::Log::Warn(LuaState* state)
	{
		TRACE_WRITE(Warn);
		return 0;
	}
	int LuaApi::Log::Debug(LuaState* state)
	{
		TRACE_WRITE(Debug);
		return 0;
	}

	int LuaApi::Log::Dump(LuaState* state)
	{
		Logger::RawWrite("                "s + ConcatVaargs(state));
		Logger::NewLine();
		return 0;
	}

	int LuaApi::Log::Toggle(LuaState* state)
	{
		Logger::IsLoggingOn = !Logger::IsLoggingOn;
		luaC_pushboolean(state, Logger::IsLoggingOn);
		return 1;
	}

	int LuaApi::Log::IsEnabled(LuaState* state)
	{
		luaC_pushboolean(state, Logger::IsLoggingOn == true);
		return 1;
	}

	string LuaApi::Log::ConcatVaargs(LuaState* state)
	{
		// Handle vaargs
		int args = lua_gettop(state);
		if (args <= 0)
			return "null";

		std::stringstream str;

		for (int i = 0; i < args; i++)
		{
			// for handling a sigsegv on lua_tolstring with index 1 being nil
			int type = lua_type(state, 1);

			str << ((type != LUA_TNIL)
					? lua_tolstring(state, 1, NULL)
					: "nil");

			if(i != args)
				str << " ";

			lua_remove(state, 1);
		}

		return str.str();
	}

	int LuaApi::Log::Create(LuaState* state)
	{
		bool result = AllocConsole() == TRUE;
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
		dirOnly =luaC_toboolean(state, 1); \
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
		luaC_pushboolean(state, Utils::ElementExists(path, dirOnly));
		return 1;
	}
}