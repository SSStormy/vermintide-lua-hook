#pragma once

#include <stdlib.h>
#include "globals.h"
#include <Windows.h>

#define SAVE_PWD char __callbackOldPwd[300]; \
				GetCurrentDirectory(300, __callbackOldPwd); \
				unique_ptr<const char[]> __oldPWD(__callbackOldPwd)

#define SAVE_PWD_N(ndir) SAVE_PWD; SetCurrentDirectory(ndir)

#define RESTORE_PWD SetCurrentDirectory(__oldPWD.get())

namespace VermHook
{
	class Utils
	{
	public:
		static BOOL FileExists(LPCTSTR szPath)
		{
			auto dwAttrib = GetFileAttributes(szPath);

			return (dwAttrib != INVALID_FILE_ATTRIBUTES &&
				!(dwAttrib & FILE_ATTRIBUTE_DIRECTORY));
		}
		static inline bool StringEndWith(const string &str, const string &suffix)
		{
			return str.size() >= suffix.size() &&
				str.compare(str.size() - suffix.size(), suffix.size(), suffix) == 0;
		}
	};
}