#include "LuaMod.h"
#include "windows.h"
#include "globals.h"
#include <fstream>

namespace VermHook
{
	void LuaMod::LoadHooks(std::vector<LuaHook*>* hooks, const char* keyName)
	{
#define HASSERT(test, n, ...) if(test) { DLLFAIL_C(n+1, ModDirectoryName, ##__VA_ARGS__); }
#define HVERIFY(key) HASSERT(jhook[key].is_null() || !jhook[key].is_string(), 2, ": invalid hook: ", key);

		json::value_type jobj = _config[keyName];

		HASSERT(jobj.is_null(), 3, ": is null key: ", keyName);
		HASSERT(!jobj.is_array(), 3, ": json object of key ", keyName, " is not an array.");

		for (auto jhook : jobj)
		{
			HASSERT(jhook.is_null(), 1, ": null hook.");

			HVERIFY(KEY_VERM_SCRIPT);
			HVERIFY(KEY_SCRIPT_EXEC);

			hooks->push_back(new LuaHook(
				jhook[KEY_VERM_SCRIPT].get<std::string>().c_str(), 
				jhook[KEY_SCRIPT_EXEC].get<std::string>().c_str()));
		}
#undef HASSERT
#undef HVERIFY
	}

	LuaMod::LuaMod(const char* modDir, const char* configFd)
	{
		ModDirectoryName = modDir;

		_config = json::parse(std::ifstream(configFd));

		/* Verify schema */
#define VERIFY(key) if(_config[key].is_null()) { \
			DLLFAIL_C(3, modDir, ": invalid config key: ", key); }

		VERIFY(KEY_MOD_NAME);
		ModName = _config[KEY_MOD_NAME].get<std::string>().c_str();
#undef VERIFY

		LoadHooks(PreHooks, KEY_HOOK_PRE);
		LoadHooks(PostHooks, KEY_HOOK_POST);
			
		LOG("Loaded mod: " << ModName);;
		for(auto h : *PreHooks) LOG("Pre: [" << h->VermScript << " -> " << h->ScriptExec);
		for (auto h : *PostHooks) LOG("Post: [" << h->VermScript << " -> " << h->ScriptExec);

	}
	LuaMod::~LuaMod()
	{
		delete &_config;
		delete[] ModName;
		delete[] ModDirectoryName;
		delete PreHooks;
		delete PostHooks;
	}

	LuaMod::LuaHook::LuaHook(const char* vscript, const char* scriptExec)
	{
		VermScript = vscript;
		ScriptExec = scriptExec;
	}
	LuaMod::LuaHook::~LuaHook()
	{
		delete[] VermScript;
		delete[] ScriptExec;
	}
}