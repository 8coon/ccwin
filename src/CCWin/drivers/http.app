local running = true
local downloading = {}
local hosts = {}


os.getProcessInfo(hwnd).showInTaskbar = false
os.getProcessInfo(hwnd).title = "Http service"
kernel.kiRegisterEventReceiver("http_success")
kernel.kiRegisterEventReceiver("http_failure")

if fs.exists(kernel.env.GetOsPath() .. "drivers/etc/hosts") then
	local file = fs.open(kernel.env.GetOsPath() .. "drivers/etc/hosts", "r")
	local data = file.readAll()
	file.close()

	data = string.gsub(data, "\r", "")

	local h = user.split(data, "\n")
	for i, v in ipairs(h) do
		local hostData = user.split(v, "	")
		hosts[hostData[1]] = hostData[2]
	end
end


function getRequestURL(baseURL)
	for k, v in pairs(hosts) do
		if string.match(baseURL, k) then
			local oldBaseURL = baseURL
			baseURL = string.gsub(baseURL, "%?", "%%%?")
			baseURL = string.gsub(baseURL, "%/", "%%%/")
			baseURL = string.gsub(baseURL, "%\\", "%%%\\")
			baseURL = string.gsub(baseURL, "%&", "%%%&")
			baseURL = string.gsub(baseURL, "%.", "%%%.")
			baseURL = string.gsub(baseURL, "%:", "%%%:")
			baseURL = string.gsub(baseURL, "%^", "%%%^")
			baseURL = string.gsub(baseURL, "%$", "%%%$")
			baseURL = string.gsub(v, "%%BASEURL%%", baseURL)
			baseURL = string.gsub(baseURL, "%%BASEURL_ENCODED%%", string.gsub(kernel.env.textutils.urlEncode(oldBaseURL), "%%", "%%%%"))
		end
	end

	return baseURL
end




while running do
	local message = os.getMessage(hwnd)

	if message ~= nil then
		if message.msg == "request" then
			--pcall(function()
				table.insert(downloading, { url = getRequestURL(message.url), postData = message.postData, headers = message.headers, 
					onSuccess = message.onSuccess, onFail = message.onFail })
				kernel.env.http.request(getRequestURL(message.url), message.postData, message.headers)
			--end)
		end

		if message.msg == "http_success" then
			local removal = {}

			for k, v in pairs(downloading) do
				if v.url == message.arg1 then
					v.onSuccess(message.arg1, message.arg2)
					table.insert(removal, k)
				end
			end

			for k, v in pairs(removal) do
				table.remove(downloading, k)
			end

			removal = nil
		end

		if message.msg == "http_failure" then
			local removal = {}

			for k, v in pairs(downloading) do
				if v.url == message.arg1 then
					v.onFail(message.arg1)
					table.insert(removal, k)
				end
			end

			for k, v in pairs(removal) do
				table.remove(downloading, k)
			end

			removal = nil
		end


		--if (#downloading > 0) and (current == nil) then
		--	current = table.remove(downloading)
			
		--end
	end
end


kernel.kiUnRegisterEventReceiver("http_success")
kernel.kiUnRegisterEventReceiver("http_failure")