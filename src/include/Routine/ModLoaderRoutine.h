#pragma once

#include "../Globals.h"
#include "../Hook.h"
#include "../IATHook.h"

namespace VermHook
{
	class ModLoaderRoutine
	{
	public:
		void PostInit();
	private:
		unique_ptr<IATHook> _iatInitHook;
		unique_ptr<IATHook> _iatLoadBufferHook;

		static void InitLua(LuaState* state);
		static int LoadBufferHook(LuaState* state, const char* buf, size_t size, const char* name);
		static void CallLoadBufferNotifier(LuaState* state, const char* methodName, const char* bufName);
	};
}