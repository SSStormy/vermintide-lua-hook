#include "LuaMod.h"
#include "globals.h"
#include <Windows.h>
#include <fstream>
#include "Utils.h"

namespace VermHook
{
	const string LuaMod::KeyHookPre = "HookPre"s;
	const string LuaMod::KeyHookPost = "HookPost"s;
	const string LuaMod::KeyVermScript = "VermScript"s;
	const string LuaMod::KeySriptExec = "ModScriptExec"s;
	const string LuaMod::KeyModName = "Name"s;

	inline void LuaMod::LoadHooks(std::vector<shared_ptr<LuaHook>>& hooks, const string& keyName)
	{
		json::value_type jobj = _config[keyName];

		// TODO : fail on bad config

		for (auto jhook : jobj)
		{
			hooks.push_back(std::make_shared<LuaHook>(
				jhook[KeyVermScript].get<string>(),
				jhook[KeySriptExec].get<string>()));
		}
	}

	LuaMod::LuaMod(const string& modDir, const string& configFd) 
		: ModDirectoryName(modDir)
	{
		_config = json::parse(std::ifstream(configFd));

		_modName = _config[KeyModName].get<string>();

		LoadHooks(_preHooks, KeyHookPre);
		LoadHooks(_postHooks, KeyHookPost);

		LOG("Loaded mod: " << ModName);
		for (auto& h : _preHooks) LOG("Pre: [" << h->VermScript << " -> " << h->ScriptExec);
		for (auto& h : _postHooks) LOG("Post: [" << h->VermScript << " -> " << h->ScriptExec);

	}

	LuaMod::LuaHook::LuaHook(const string& vscript, const string& scriptExec) : VermScript(vscript), ScriptExec(scriptExec)
	{

	}

	const std::vector<shared_ptr<LuaMod::LuaHook>> LuaMod::GetPreHooks() const
	{
		return _preHooks;
	}

	const std::vector<shared_ptr<LuaMod::LuaHook>> LuaMod::GetPostHooks() const
	{
		return _postHooks;
	}

	const string LuaMod::GetModName() const
	{
		return _modName;
	}

}