
--[[-------------------------
        Test C functions
--]]------------------------

local function test_console_out()
	Log.Write("one|", "|two|", "|three|", "|four")
	Log.Write()
	Log.Write(nil)
	Log.Write(nil, nil)
	Log.Write(nil, nil, nil)
	Log.Write(nil, "|mixed|", nil)
	Log.Write("is that a nil at the end|", "|mixed|", nil)
	Log.Write(nil, "|mixed|", "|it's at the start")
	Log.Write("ohno|", nil, "|it's in the middle")
	return 0
end

local function test_paths(elems, expected)
	assert_e(#elems == #expected)

	for idx, path in ipairs(elems) do
		assert_e(table.has_value(expected, path))
	end
end

local function test_path_elem_all_list()
	local elems = Path.GetElements("mods/base/test/test_path")
	local expected = {
		"hello friends i am a folder",
		"how do you do lads",
		"i am. a very, special1 snowflak15l;e",
		"test_mod",
		"that is nice to hear, friend",
		"another_text_file.txt",
		"exciting, a file!",
		"textfile.txt",
		"woah is that a dat file.dat"
	}

	test_paths(elems, expected)

	return 0
end

local function test_path_elem_folder_list()
	local elems = Path.GetElements("mods/base/test/test_path", true)
		local expected = {
		"hello friends i am a folder",
		"how do you do lads",
		"i am. a very, special1 snowflak15l;e",
		"test_mod",
		"that is nice to hear, friend",
	}

	test_paths(elems, expected)

	return 0
end

local function test_path_elem_exists_file()
	assert_e(Path.ElementExists("mods/base/test/test_path/textfile.txt"))
	assert_e(Path.ElementExists("mods/base/test/test_path/exciting, a file!"))
	assert_e(not Path.ElementExists("mods/base/test/test_path/i dont exist"))
	return 0
end

local function test_path_elem_exists_folder()
	assert_e(Path.ElementExists("mods/base/test/test_path/i am. a very, special1 snowflak15l;e", true))
	assert_e(Path.ElementExists("mods/base/test/test_path/i am. a very, special1 snowflak15l;e"))

	assert_e(Path.ElementExists("mods/base/test/test_path/test_mod", true))
	assert_e(Path.ElementExists("mods/base/test/test_path/test_mod"))

	assert_e(not Path.ElementExists("mods/base/test/test_path/i dont exist", true))
	assert_e(not Path.ElementExists("mods/base/test/test_path/textfile.txt", true))
	return 0
end


local function test(...)
	local n = select('#', ...)
	for i = 1,n  do
		local v = select(i, ...)
		assert_e(v())
	end
end


test(
	test_console_out, 
	test_path_elem_all_list,
	test_path_elem_folder_list,
	test_path_elem_exists_file,
	test_path_elem_exists_folder
)