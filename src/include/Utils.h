#pragma once

#include "Globals.h"
#include <Windows.h>
#include <vector>
#include "Hook.h"

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
		static inline bool ElementExists(LPCTSTR szPath, bool mustBeFolder = false)
		{
			auto dwAttrib = GetFileAttributes(szPath);

            if(dwAttrib != INVALID_FILE_ATTRIBUTES)
            {
				if (mustBeFolder)
					return (dwAttrib & FILE_ATTRIBUTE_DIRECTORY) != 0;
                return true;
            }
            return false;
		}

		static inline bool StringEndWith(const string &str, const string &suffix)
		{
			return str.size() >= suffix.size() &&
				str.compare(str.size() - suffix.size(), suffix.size(), suffix) == 0;
		}

		static inline void GetElements(LPCSTR dir, std::vector<string>& out, bool mustBeFolder)
		{
			HANDLE fileHandle;
			WIN32_FIND_DATA ffd;
			LARGE_INTEGER szDir;
			WIN32_FIND_DATA fileData;
			fileHandle = FindFirstFile(dir, &ffd);

			if (INVALID_HANDLE_VALUE == fileHandle)
				return;
			do
			{
				if (!mustBeFolder || ffd.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY)
				{
					
					auto str = ffd.cFileName;
					if(strcmp(str, ".") == 0|| strcmp(str, "..")  == 0)
						continue;

				 	out.push_back(ffd.cFileName);
				}
					
			} while (FindNextFile(fileHandle, &ffd) != 0);
		}

		static inline void StrVectorToIndexedTable(LuaState* state, std::vector<string>& vec)
		{
			lua_createtable(state, vec.size(), 0);

			int i = 0;
			for (auto elem : vec)
			{
				lua_pushstring(state, elem.c_str());
				lua_rawseti(state, -2, ++i);
			}
		}
	};
}
