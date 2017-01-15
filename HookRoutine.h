#pragma once
#include "globals.h"
#include "vlua.h"

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
		const char* RelativeModFolderDirectory;

		ModLoaderRoutine(const char* relativeModFldr);
		~ModLoaderRoutine();

		void PostInit();
		void ReloadMods();
	};
}