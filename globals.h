#pragma once

#include <iostream>
#include "windows.h"
#include <stdlib.h>

#define LOG(msg) \
    std::cout << __FILE__ << "(" << __LINE__ << "): " << msg << std::endl
	
#define DLLFAIL(reason) \
	MessageBox(NULL, reason, NULL, MB_OK); \
	abort()

#define SAVE_PWD LPCSTR __oldPWD = Utils::BackupCurrentDirectory()
#define RESTORE_PWD SetCurrentDirectory(__oldPWD); \
		delete[] __oldPWD; 

namespace Utils
{
	static char* Concat(int count, ...)
	{
#pragma warning(disable:4996)

		va_list ap;
		int i;

		// Find required length to store merged string
		int len = 1; // room for NULL
		va_start(ap, count);
		for (i = 0; i<count; i++)
			len += strlen(va_arg(ap, char*));
		va_end(ap);

		// Allocate memory to concat strings
		char *merged = (char*)calloc(sizeof(char), len);
		int null_pos = 0;

		// Actually concatenate strings
		va_start(ap, count);
		for (i = 0; i<count; i++)
		{
			char *s = va_arg(ap, char*);
			strcpy(merged + null_pos, s);
			null_pos += strlen(s);
		}
		va_end(ap);

		return merged;
	}

	static inline LPCSTR BackupCurrentDirectory()
	{
#define PWDSIZE 260
		char* oldPwd = new char[PWDSIZE];
		GetCurrentDirectory(PWDSIZE, oldPwd);

#undef PWDSIZE
		return oldPwd;
	}

	static BOOL FileExists(LPCTSTR szPath)
	{
		DWORD dwAttrib = GetFileAttributes(szPath);

		return (dwAttrib != INVALID_FILE_ATTRIBUTES &&
			!(dwAttrib & FILE_ATTRIBUTE_DIRECTORY));
	}
}

#define DLLFAIL_C(n, ...) char* __DFAILSTR = Utils::Concat(n, ##__VA_ARGS__); \
						DLLFAIL(__DFAILSTR); \
						delete[] __DFAILSTR