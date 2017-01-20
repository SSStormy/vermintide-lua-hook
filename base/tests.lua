local function test_console_out()
	console.out("one|", "|two|", "|three|", "|four")
	console.out()
	console.out(nil)
	console.out(nil, nil)
	console.out(nil, nil, nil)
	console.out(nil, "|mixed|", nil)
	console.out("is that a nil at the end|", "|mixed|", nil)
	console.out(nil, "|mixed|", "|it's at the start")
	console.out("ohno|", nil, "|it's in the middle")
	return 0
end

local function test_paths(elems, expected)
	assert(#elems == #expected)

	for idx, path in ipairs(elems) do
		assert(table.has_value(expected, path))
	end
end

local function test_path_elem_all_list()
	local elems = path.get_elements("mods/base/test/test_path")
	local expected = {
		"hello friends i am a folder",
		"how do you do lads",
		"i am. a very, special1 snowflak15l;e",
		"no",
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
	local elems = path.get_elements("mods/base/test/test_path", true)
		local expected = {
		"hello friends i am a folder",
		"how do you do lads",
		"i am. a very, special1 snowflak15l;e",
		"no",
		"that is nice to hear, friend",
	}

	test_paths(elems, expected)

	return 0
end

local function test_path_elem_exists_file()
	assert(path.element_exists("mods/base/test/test_path/textfile.txt"))
	assert(path.element_exists("mods/base/test/test_path/exciting, a file!"))
	assert(not path.element_exists("mods/base/test/test_path/i dont exist"))
	return 0
end

local function test_path_elem_exists_folder()
	assert(path.element_exists("mods/base/test/test_path/i am. a very, special1 snowflak15l;e", true))
	assert(path.element_exists("mods/base/test/test_path/i am. a very, special1 snowflak15l;e"))

	assert(path.element_exists("mods/base/test/test_path/no", true))
	assert(path.element_exists("mods/base/test/test_path/no"))

	assert(not path.element_exists("mods/base/test/test_path/i dont exist", true))
	assert(not path.element_exists("mods/base/test/test_path/textfile.txt", true))
	return 0
end


local function test(...)
	local n = select('#', ...)
	for i = 1,n  do
		local v = select(i, ...)
		assert(v())
	end
end

test(
	test_console_out, 
	test_path_elem_all_list,
	test_path_elem_folder_list,
	test_path_elem_exists_file,
	test_path_elem_exists_folder
)

