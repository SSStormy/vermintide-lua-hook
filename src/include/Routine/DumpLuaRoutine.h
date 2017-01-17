#pragma once
#include "../Globals.h"
#include "../IATHook.h"

namespace VermHook
{
	class DumpLuaRoutine
	{
	public:
		void PostInit();
	private:
		unique_ptr<IATHook> LoadBufferHook;
	};
}