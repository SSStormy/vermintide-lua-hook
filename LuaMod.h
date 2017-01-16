#pragma once
#include "json.hpp"
#include "globals.h"

namespace VermHook
{
	class LuaMod
	{
		static const string KeyHookPre;
		static const string KeyHookPost;
		static const string KeyVermScript;
		static const string KeySriptExec;
		static const string KeyModName;

	public:
		class LuaHook
		{
		public:
			const string VermScript;
			const string ScriptExec;
			LuaHook(const string& vscript, const string& scriptExec);
		};

		const string ModDirectoryName;
		const string ModName;

		LuaMod(const string& modname, const string& configFd);

		// TODO : replace these with std::maps for easy lookup when given name from loadbuffer
		const std::vector<shared_ptr<LuaHook>> GetPreHooks() const;
		const std::vector<shared_ptr<LuaHook>> GetPostHooks() const;
		const string GetModName() const;

	private:
		using json = nlohmann::json;
		json _config;

		string _modName;
		std::vector<shared_ptr<LuaHook>> _preHooks;
		std::vector<shared_ptr<LuaHook>> _postHooks;

		inline void LoadHooks(std::vector<shared_ptr<LuaHook>>& hooks, const string& keyName);
	};
}