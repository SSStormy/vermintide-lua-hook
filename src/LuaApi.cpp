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
		int outCount; \
		string outSrc = nullptr; \
		GetFunctionInfo(state, &outCount, &outSrc); \
		Logger::method(ConcatVaargs(state), outSrc.c_str(), outCount);

	int LuaApi::Log::Warn(LuaState* state)
	{
		//TRACE_WRITE(Warn);
		return 0;
	}
	int LuaApi::Log::Debug(LuaState* state)
	{
		//TRACE_WRITE(Debug);

		LuaDebug debug;

		std::cout << lua_gettop(state) << std::endl;
		auto stackResult = lua_getstack(state, 1, &debug);
		LOG_T("Gotten stack");
		assert(stackResult == 1);
		auto infoResult = lua_getinfo(state, "Sl", &debug);
		assert(infoResult != 0);
		std::cout << debug.source << std::endl;

		LOG_T("Gotten info");

		//debug.currentline;
		//std::string(debug.source);

		return 0;
	}

	int LuaApi::Log::Dump(LuaState* state)
	{
		Logger::RawWrite("                "s + ConcatVaargs(state));
		Logger::NewLine();
		return 0;
	}

	void LuaApi::Log::GetFunctionInfo(LuaState* state, int* outCount, string* outSrc)
	{

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
		lua_pushboolean(state, Utils::ElementExists(path, dirOnly) ? 1 : 0);
		return 1;
	}
}