#pragma once
#pragma once

#include <iostream>
#include "windows.h"

#define LOG(msg) \
    std::cout << __FILE__ << "(" << __LINE__ << "): " << msg << std::endl
	
#define DLLFAIL(reason) \
	MessageBox(NULL, reason, NULL, MB_OK); \
	abort()

inline LPCSTR BackupCurrentDirectory()
{
#define PWDSIZE 256
	char* oldPwd = new char[PWDSIZE];
	GetCurrentDirectory(PWDSIZE, oldPwd);
	
#undef PWDSIZE
	return oldPwd;
}