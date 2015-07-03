local running = true
local oldFs = fs
os.getProcessInfo(hwnd).showInTaskbar = false

local mounted = {}



local function copyTable(t)
	t = t or {}
	local r = {}
	for k, v in pairs(t) do
		if type(v) == "table" then
			r[k] = copyTable(v)
		else
			r[k] = v
		end
	end
	return r
end

local function readArchive(fname, data)
	local f = loadfile(fname)

	local env = {
		string = string,
		table = table,
		pcall = pcall,
		print = function(s) end,

		fs = {
			makeDir = function(path) end,
			open = function(path, mode)
				return {
					write = function(d) end,
					close = function() end,
				}
			end,
		}
	}

	setfenv(f, env)
	local names, values = f()

	for i = 1, #names do
		local l = user.split(names[i], "/")
		local p = ""
		if #l > 1 then
			pcall(function()
				for i = 1, #p - 2 do
					p = p .. "/" .. l[i]
				end
			end)
		end

		pcall(function()
			values[i] = string.gsub(values[i], "\\%[\\%[", "%[%[")
			values[i] = string.gsub(values[i], "\\%]\\%]", "%]%]")
			data[names[i]] = values[i]
		end)
	end
end


local function cp(p)
	return tostring(string.gsub(string.gsub("/" .. (p or "/"), "//", "/"), "home:/", ""))
end


local function log(msg)
	--local f = fs.open("/mount_log.txt", "a")
	--f.write(msg .. "\r\n")
	--f.close()
end



local _fs = copyTable(fs)



fs = {
	list = function(path)
		path = cp(path)
		local parts = user.split(path, "/")
		local p = ""
		local starts = false
		local startsFrom = -1
		local l = {}

		for i, v in ipairs(parts) do
			for k, s in pairs(mounted) do
				local cv = cp(s.path)
				local ck = cp(p)
				local _, c1 = string.gsub(cv, "%/", "")
				local _, c2 = string.gsub(cv, "%/", "")
				
				log(tostring(i) .. " -- " .. cv .. " -- " .. ck)
				if (cv == ck) and (c1 == c2) then
					starts = true
					startsFrom = i
					table.insert(l, s.name)
					log("TRUE")
				end

				if starts and v == s.name then
				end

				p = p .. "/" .. v
			end
		end

		if starts and (startsFrom == #parts) then
			local ls = _fs.list(path)

			for i, v in ipairs(l) do
				table.insert(ls, v)
			end

			--table.insert(ls, s.name)
			return ls
		else
			return _fs.list(path)
		end
	end,

	exists = function(path)
		return _fs.exists(path)
	end,

	isDir = function(path)
		return _fs.isDir(path)
	end,

	isReadOnly = function(path)
		return _fs.isReadOnly(path)
	end,

	getName = function(path)
		return _fs.getName(path)
	end,

	getDrive = function(path)
		return _fs.getDrive(path)
	end,

	getSize = function(path)
		return _fs.getSize(path)
	end,

	getFreeSpace = function(path)
		return _fs.getFreeSpace(path)
	end,

	makeDir = function(path)
		return _fs.makeDir(path)
	end,

	move = function(fromPath, toPath)
		return _fs.move(fromPath, toPath)
	end,

	copy = function(fromPath, toPath)
		return _fs.copy(fromPath, toPath)
	end,

	delete = function(path)
		return _fs.delete(path)
	end,

	combine = function(basePath, localPath)
		return _fs.combine(basePath, localPath)
	end,

	open = function(path, mode)
		return _fs.open(path, mode)
	end,

	find = function(wildcard)
		return _fs.find(wildcard)
	end,

	getDir = function(path)
		return _fs.getDir(path)
	end,
}

kernel.kiLoadGlobalAPI("fs", fs)
os.sendMessage(hwnd, {msg = "mount", path = "/", name = "temp", src = "setup.wpk"})


while running do
	local message = os.getMessage(hwnd)

	if message ~= nil then
		if message.msg == "mount" then
			mounted[message.path .. message.name] = {
				files = {},
				src = message.src,
				name = message.name,
				path = message.path,
				readOnly = --[[message.readOnly or ]]true,
			}

			readArchive(message.src, mounted[message.path .. message.name].files)
		end
	end
end
