#include "HookRoutine.h"
#include "globals.h"
#include "vlua.h"
#include "hook.h"
#include "IATHook.h"
#include <vector>

#include <string>
#include <sstream>
#include <fstream>

namespace VermHook
{
	namespace
	{
		int hep_luaL_loadbuffer(lua_state* state, const char* buf, size_t sz, const char* name)
		{
			int result = luaL_loadbuffer(state, buf, sz, name);

			SAVE_PWD;

			std::stringstream ss;
			ss.str(name);
			std::string item;
			while (std::getline(ss, item, '/'))
			{
				const char* npath = item.c_str();
				size_t size = strlen(npath);
				// eh it works so fuck off
				if (npath[size - 4] == '.' && npath[size - 3] == 'l' &&npath[size - 2] == 'u' &&npath[size - 1] == 'a')
				{
					std::ofstream out(npath);
					out.write(buf, sz);
					out.close();

					continue;
				}

				CreateDirectory(npath, NULL);
				SetCurrentDirectory(npath);
			}

			RESTORE_PWD;
			return result;
		}
	}

	IATHook* hook_lbf = NULL;

	DumpLuaRoutine::~DumpLuaRoutine()
	{
		if (hook_lbf != NULL) 
		{
			hook_lbf->Unhook();
			delete hook_lbf;
		}
	}

	void DumpLuaRoutine::PostInit()
	{
		LOG("Routine: DumpLua");
		hook_lbf = IATHook::Hook(LUA_MODULE, "luaL_loadbuffer", (DWORD)hep_luaL_loadbuffer);
	}
}