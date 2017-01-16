#include "Utils.h"

namespace VermHook
{
	inline void Utils::DllFail(string reason)
	{
		MessageBox(NULL, reason.c_str(), NULL, MB_OK);
		abort();
	}

	inline BOOL Utils::FileExists(LPCTSTR szPath)
	{
		auto dwAttrib = GetFileAttributes(szPath);

		return (dwAttrib != INVALID_FILE_ATTRIBUTES &&
			!(dwAttrib & FILE_ATTRIBUTE_DIRECTORY));
	}

	inline bool Utils::StringEndWith(const string &str, const string &suffix)
	{
		return str.size() >= suffix.size() &&
			str.compare(str.size() - suffix.size(), suffix.size(), suffix) == 0;
	}
}
