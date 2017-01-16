#pragma once

#include "json.hpp"
#include <vector>
namespace VermHook
{

#define KEY_HOOK_PRE "HookPre"
#define KEY_HOOK_POST "HookPost"
#define KEY_VERM_SCRIPT	"VermScript"
#define KEY_SCRIPT_EXEC "ModScriptExec"
#define KEY_MOD_NAME "Name"

	class LuaMod
	{
	public:
		class LuaHook
		{
		public:
			const char* VermScript;
			const char* ScriptExec;
			LuaHook(const char* vscript, const char* scriptExec);
			~LuaHook();
		};

		const char* ModDirectoryName;
		const char* ModName;

		std::vector<LuaHook*>* PreHooks = new std::vector<LuaHook*>();
		std::vector<LuaHook*>* PostHooks = new std::vector<LuaHook*>();

		LuaMod(const char* modname, const char* configFd);
		~LuaMod();

	private:
		using json = nlohmann::json;

		json _config;

		void LoadHooks(std::vector<LuaHook*>* hooks, const char* keyName);
	};
}