#include "HookRoutine.h"
#include "hook.h"
#include "IATHook.h"
#include <sstream>
#include <fstream>
#include "Utils.h"

namespace VermHook
{
	namespace
	{
		static const string LuaIdentifier = ".lua"s;

		int hep_luaL_loadbuffer(LuaState* state, const char* buf, size_t sz, const char* name)
		{
			int result = luaL_loadbuffer(state, buf, sz, name);

			SAVE_PWD;

			std::stringstream ss;
			ss.str(name);
			std::string item;
			while (std::getline(ss, item, '/'))
			{
				auto cstr = item.c_str();
				if (Utils::StringEndWith(item, LuaIdentifier))
				{
					std::ofstream out(item);
					out.write(buf, sz);
					out.close();

					continue;
				}

				CreateDirectory(cstr, NULL);
				SetCurrentDirectory(cstr);
			}

			RESTORE_PWD;
			return result;
		}
	}

	DumpLuaRoutine::~DumpLuaRoutine()
	{
		LoadBufferHook->Unhook();
	}

	void DumpLuaRoutine::PostInit()
	{
		LOG("Routine: DumpLua");
		LoadBufferHook.reset(IATHook::Hook(LuaModule, "luaL_loadbuffer", (DWORD)hep_luaL_loadbuffer));
	}
}