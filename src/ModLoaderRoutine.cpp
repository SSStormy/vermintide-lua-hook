#include "include/Hook.h"
#include "include/Globals.h"
#include "include/Routine/ModLoaderRoutine.h"
#include "include/IATHook.h"
#include "include/Utils.h"
#include "include/LuaApi.h"

namespace VermHook
{
	void ModLoaderRoutine::PostInit()
	{
		LOG("Routine: ModLoader");

		_iatInitHook = unique_ptr<IATHook>(IATHook::Hook(LuaModule, "luaL_openlibs", (DWORD)ModLoaderRoutine::InitLua));

		if (!Utils::ElementExists(Globals::BaseModInitFileDir))
		{
			LOG("Globals::BaseModInitFileDir (" << string(Globals::BaseModInitFileDir) << ") doesn't exist.");
			Globals::DllReturnValue = FALSE;
		}
	}
	
	void ModLoaderRoutine::InitLua(LuaState* state)
	{
		luaL_openlibs(state);

		LuaReg console[] =
		{
			{ "create", LuaApi::Console::Create },
			{ "out", LuaApi::Console::Out },
			{ NULL, NULL }
		};

		LOG("Registering console library.");
		luaL_register(state, "console", console);

		LOG("Loading base mod");
		int result = luaL_loadfile(state, Globals::BaseModInitFileDir);
		if (result != 0)
		{
			LOG("Failed loading base mod, errcode: " << result);
			Globals::DllReturnValue = FALSE;
			return;
		}

		LOG("Goodbye C++.");

		BENCHMARK_START;
		lua_call(state, 0, 0);
		BENCHMARK_END("Base main.lua");
	}
}
