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
		static void InitLua(LuaState* state);
	};
}