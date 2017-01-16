#pragma once

#include "globals.h"
#include "vlua.h"
#include "LuaMod.h"
#include <vector>
#include "IATHook.h"

namespace VermHook
{
	class HookRoutine
	{
	public:
		virtual void PostInit() = 0;
		virtual ~HookRoutine() { }
	};

	class DumpLuaRoutine : public HookRoutine
	{
	public:
		void PostInit();
		DumpLuaRoutine::~DumpLuaRoutine();
	private:
		unique_ptr<IATHook> LoadBufferHook;
	};

	class ModLoaderRoutine : public HookRoutine
	{
	public:
		const static string BaseModFolderName;
		const static string ModConfigFilename;

		const string RelativeModFolderDirectory;


		ModLoaderRoutine(const string& relativeModFldr);
		~ModLoaderRoutine();

		void PostInit();
		void ReloadMods();
	private:
		std::vector<unique_ptr<IATHook>> _iatHooks;
		std::vector<unique_ptr<LuaMod>> _mods;
		void LoadMod(LPCSTR rFdir);
	};
}