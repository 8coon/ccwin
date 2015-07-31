local running = true
local oldFs = fs
os.getProcessInfo(hwnd).showInTaskbar = false


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


local _fs = copyTable(fs)


function normalize(path, root)
	local original = path
	path = path or ""
	root = root or ""

	if string.find(path, "/.") then
		path = user.split(tostring(string.gsub(tostring(string.gsub(path, "\\", "/")), "//", "/")), "/")
		local p = {}
		for i, v in ipairs(path) do
			if v == "." then
				p = {}
			elseif v == ".." then
				table.remove(p)
			else
				table.insert(p, v)
			end
		end

		path = root
		for i, v in ipairs(p) do
			path = path .. "/" .. v
		end
	else
		path = root .. "/" .. path
	end

	--local file = _fs.open("log.txt", "a")
	--file.write(original .. " == " .. path .. "\r\n")
	--file.close()

	return path
end


function fn(path)
	path = normalize(path)
	path = user.split(path, "/")
	local p = {}
	local ps = ""
	for i, v in ipairs(path) do
		if not _fs.exists(ps .. "/" .. v) then
			if _fs.exists(ps) then
				local ls = _fs.list(ps)
				local real = v
				for k, sv in pairs(ls) do
					if string.lower(v) == string.lower(sv) then
						real = sv
						break
					end
				end
				ps = ps .. "/" .. real
			else
				ps = ps .. "/" .. v
			end
		else
			ps = ps .. "/" .. v
		end
	end

	return ps
end


fs = {
	list = function(path)
		local l = _fs.list(fn(path))
		local result = {}
		for i, v in ipairs(l) do
			if not (user.stringends(string.lower(v), ".ds_store")) then
				table.insert(result, v)
			end
		end
		return result
	end,

	exists = function(path)
		return _fs.exists(fn(path))
	end,

	isDir = function(path)
		return _fs.isDir(fn(path))
	end,

	isReadOnly = function(path)
		return _fs.isReadOnly(fn(path))
	end,

	getName = function(path)
		return _fs.getName(fn(path))
	end,

	getDrive = function(path)
		return _fs.getDrive(fn(path))
	end,

	getSize = function(path)
		return _fs.getSize(fn(path))
	end,

	getFreeSpace = function(path)
		return _fs.getFreeSpace(fn(path))
	end,

	makeDir = function(path)
		return _fs.makeDir(fn(path))
	end,

	move = function(fromPath, toPath)
		return _fs.move(fn(fromPath), fn(toPath))
	end,

	copy = function(fromPath, toPath)
		return _fs.copy(fn(fromPath), fn(toPath))
	end,

	delete = function(path)
		return _fs.delete(fn(path))
	end,

	combine = function(basePath, localPath)
		return _fs.combine(fn(basePath), fn(localPath))
	end,

	open = function(path, mode)
		return _fs.open(fn(path), mode)
	end,

	find = function(wildcard)
		return _fs.find(wildcard)
	end,

	getDir = function(path)
		return _fs.getDir(fn(path))
	end,
}

kernel.kiLoadGlobalAPI("fs", fs)
os.sendMessage(hwnd, {msg = "mount", path = "/", name = "temp", src = "setup.wpk"})


while running do
	local message = os.getMessage(hwnd)

	if message ~= nil then
		if message.msg == "normalize_path" then
			
		end
	end
end
