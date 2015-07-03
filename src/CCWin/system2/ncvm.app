local app = application.Create(os.getProcessInfo(os.getCurrentProcess()), os)
local mainForm = form.Create("Command Prompt")

app:addForm(mainForm, "Command Prompt")
mainForm:show()
mainForm.bgcolor = colors.black


local surface = widgets.GLSurface.Create(mainForm, "surface")
surface.height = app.canvas.size.y - 2
surface.width = app.canvas.size.x
surface.top = 2


local argcv = {}
if #params > 2 then
	for i = 3, #params do
		table.insert(argcv, params[i])
	end
end

--local cmd = string.gsub(params[0] or "home:/rom/programs/shell", "home:/", "")
local cmd = string.gsub(os.getSystemPath() .. "/sysWoW/rombios", "home:/", "")
local program = loadfile(cmd)
setfenv(program, legacyEnv)
local thread = coroutine.create(program)
local ended = false
local lastVisible = false
local running = true
local args = argcv
local messages = {}
local SHELL_INIT_FLAG = false


surface.onMouseClick = function(sender, button, x, y)
	table.insert(messages, {message = "mouse_click", button = button, x = x, y = y - 1})
end

surface.onMouseDrag = function(sender, button, x, y)
	table.insert(messages, {message = "mouse_drag", button = button, x = x, y = y - 1})
end

mainForm.onKeyPress = function(sender, key, char)
	table.insert(messages, {message = "key", key = key})

	if char ~= "" then
		table.insert(messages, {message = "char", char = char})
	end
end

mainForm.onMessage = function(sender, message)
	if (message[1] ~= "key") and (message[1] ~= "char") and
		(message[1] ~= "mouse_click") and (message[1] ~= "mouse_drag") then
		table.insert(messages, message)
	end
end


legacyEnv.term.clear()
legacyEnv.term.setCursorPos(1, 1)
legacyEnv.term.setCursorBlink(true)



legacyEnv.os.getSystemPath = os.getSystemPath
legacyEnv._WHAT_TO_RUN = string.gsub(params[2] or "", "home:/", "/")
if string.len(legacyEnv._WHAT_TO_RUN) == 0 then
	legacyEnv._WHAT_TO_RUN = nil
end


legacyEnv.os.pullEventRaw = function(target)
	local msg = nil

	while msg == nil do
		msg = table.remove(messages)

		if msg ~= nil then
			if (target ~= nil and msg.message == target) or target == nil then
				if msg.message == "key" then
					return "key", msg.key
				elseif msg.message == "char" then
					return "char", msg.char
				elseif msg.message == "mouse_click" then
					return "mouse_click", msg.button, msg.x, msg.y
				elseif msg.message == "mouse_drag" then
					return "mouse_drag", msg.button, msg.x, msg.y
				else
					return unpack(msg)
				end
			else
				msg = nil
			end
		else
			coroutine.yield()
		end
	end
end


legacyEnv.os.pullEvent = function(target)
	return legacyEnv.os.pullEventRaw(target)
end


legacyEnv.os.run = function(env, path, args)
	print(path)
end


setfenv(legacyEnv.read, legacyEnv)

legacyEnv.term.current = function()
	return legacyEnv.term
end

legacyEnv.term.redirect = function(obj)
end

legacyEnv.shell = nil



legacyEnv.http.request = function(url, postData, headers, handler)
	local function onSuccess(url, handle)
		if not handler then
			table.insert(messages, {"http_success", url, handle})
		else
			handler(true, url, handle)
		end
	end

	local function onFailure(url)
		if not handler then
			table.insert(messages, {"http_failure", url})
		else
			handler(false, url)
		end
	end


	local http = os.findWindowByTitle("http service")
	if http ~= nil then
		os.sendMessage(http, {
			msg = "request", 
			url = url,
			postData = postData,
			headers = headers,
			onSuccess = onSuccess,
			onFail = onFailure
		})
	else
		app:showMessage("Http service not found.\nPlease, reboot your computer.")
	end
end


legacyEnv.http.post = function(url, postData, headers)
	local result = nil
	local waiting = true
	local function handler(res, url, handle)
		result = handle
		waiting = false
	end

	legacyEnv.http.request(url, postData, headers, handler)
	while waiting do
		coroutine.yield()
	end

	return result
end


legacyEnv.http.get = function(url, headers)
	return legacyEnv.http.post(url, nil, headers)
end



mainForm.onRefresh = function(sender)
	os.redirectTerm(legacyEnv.term)
	if (coroutine.status(thread) == "suspended") and running then
		local status, message = pcall(function() assert(coroutine.resume(thread, unpack(args))) end)

		if (not status) and (not ended) then
			legacyEnv.term.setTextColor(colors.red)
			legacyEnv.term.setBackgroundColor(colors.black)
			legacyEnv.term.write(message)
			ended = true
		end
	end
	os.restoreTerm()

	--[[if cmd == "rom/programs/shell" and not SHELL_INIT_FLAG then
		--legacyEnv.os.run({}, "rom/startup")
		legacyEnv.term.write(tostring(legacyEnv.shell))
		SHELL_INIT_FLAG = true
	end]]

	local visible = os.getActiveProcess() == hwnd
	if visible ~= lastVisible then
		legacyEnv.term.setVisible(visible)
		lastVisible = visible
	end
	legacyEnv.term.redraw()
	legacyEnv.term.restoreCursor()
end


os.startTimer(0.1, function() --[[os.sendMessage(hwnd, {msg = "refresh"})]] mainForm:onRefresh() end )
app:run()