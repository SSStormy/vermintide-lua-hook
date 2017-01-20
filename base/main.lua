
-- Loads and executes a lue file, prefixing ./mods/base/ to the filename.

local lf = _G.loadfile
_G.dofile_base = function(filename)
	local dir = "./mods/base/" .. filename
	return assert(loadfile(dir)())
end

local json = dofile_base("dkjson.lua")

local pre_hooks = { nil, {} }
local post_hooks = { nil, {} }

local function append_hooks(hookvar, newval, moddir)
	if newval == nil then
		return
	end

	for __, obj in ipairs(newval) do
		local req= obj["Require"]
		hookvar[req] = hookvar[req] or { }		
		table.insert(hookvar[req], "./mods/" .. moddir .. "/" .. obj["Script"])
	end
end

-- [[ Parse mods ]] --
for _, modFolder in ipairs(path.get_elements("mods")) do
	if modFolder ~= "base"  then
		console.out(modFolder)
		local fileCfg, error = io.open("./mods/" .. modFolder .. "/" .. "config.json", "r")

		if fileCfg ~= nil then
			local cfg, pos, err = json.decode (fileCfg:read("*all"), 1, nil)
			if err then
				console.out("Failed parsing config.json in", modfolder, "error:", err)
			else
				append_hooks(pre_hooks, cfg["pre_hooks"], modFolder)
				append_hooks(post_hooks, cfg["post_hooks"], modFolder)
			end
		else
			console.out("Could not open config.json in", modfolder, "error:", error)
		end
	end
end

local function handle_hook(htab, filename)
	if htab[filename] == nil then
		return
	end

	for _, hook in ipairs(htab[filename]) do
		console.out(filename, "Executing hook", hook)
		assert(lf(hook))()
	end
end

old_require = _G.require
_G.require = function(filename)
	handle_hook(pre_hooks, filename)
	local retval = old_require(filename)
	handle_hook(post_hooks, filename)
	return retval
end