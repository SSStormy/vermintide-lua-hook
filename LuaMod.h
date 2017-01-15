#pragma once

#include "json.hpp"

namespace VermHook
{
	class LuaMod
	{
	public:
		LuaMod(const char* );
		~LuaMod();
		LuaMod(const LuaMod* other);
	private:
		using json = nlohmann::json;

		json _config;
	};
}