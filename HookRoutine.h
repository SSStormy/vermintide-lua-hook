#pragma once
#include "globals.h"
#include "vlua.h"
#include "LuaMod.h"

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
	};

	class ModLoaderRoutine : public HookRoutine
	{
	public:
		LPCSTR RelativeModFolderDirectory;
		std::vector<LuaMod*>* Mods = new std::vector<LuaMod*>();

		ModLoaderRoutine(const char* relativeModFldr);
		~ModLoaderRoutine();

		void PostInit();
		void ReloadMods();
	private:
		void LoadMod(LPCSTR rFdir);
	};
}