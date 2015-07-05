local app = application.Create(os.getProcessInfo(os.getCurrentProcess()), os)
local waitForm = form.Create("CCWin Updater")
local list_url = os.getRegistryKeyValue("updater", "url", "https://raw.githubusercontent.com/8coon/ccwin/master/update/list.lua")
local list = {}


app:addForm(waitForm, "CCWin Updater")
waitForm:show()
fs.delete("/setup-cache/")
os.setRegistryKeyValue("updater", "url", list_url)


local lblWait = widgets.Label.Create(waitForm, "lblWait")
lblWait.left = 2
lblWait.top = math.floor(app.canvas.size.y / 2) - 1
lblWait.caption = "Fetching lists..."
lblWait.width = app.canvas.size.x - 2
lblWait.height = 1
lblWait.align = "center"



local mainForm = form.Create("CCWin Updater")
app:addForm(mainForm, "CCWin Updater")


local panelApps = widgets.Panel.Create(mainForm, "panelApps")
panelApps.left = 0
panelApps.top = 4
panelApps.width = app.canvas.size.x - 1
panelApps.height = app.canvas.size.y - 4
panelApps.bgcolor = colors.white

local scrollApps = widgets.ScrollBar.Create(mainForm, "scrollApps")
scrollApps.left = app.canvas.size.x
scrollApps.top = 4
scrollApps.height = app.canvas.size.y - 4
scrollApps.max = 0
scrollApps.value = 0
scrollApps.last = 0
scrollApps.step = 2

scrollApps.onChange = function(sender)
	local top = 0

	local count = 0
	for k, v in pairs(panelApps.widgets) do
		count = count + 1
	end

	for i = 0, count - 1 do
		local v = panelApps.widgets["__item_" .. tostring(i)]
		v.top = top - sender.value
		top = top + v.height
	end

	os.sendMessage(hwnd, {msg = "refresh"})
end


function updateScrollBar()
	scrollApps.max = 0

	for k, v in pairs(panelApps.widgets) do
		scrollApps.max = scrollApps.max + v.height
	end

	scrollApps.max = scrollApps.max - scrollApps.height
	if scrollApps.max < 0 then
		scrollApps.max = 0
	end

	if scrollApps.value >= scrollApps.max then
		scrollApps.value = scrollApps.max
	end
end



function addItem(item, index)
	if index == 0 then
		addItem(item, index + 1)
	end

	local title_raw = item.title
	local version_raw = item.version
	local author_raw = item.author
	local desc_raw = item.description
	local icon_raw = item.icon
	local min_version = item.minVersion
	local download_link = item.downloadLink

	fs.makeDir("/temp/")
	local file = fs.open("/temp/icon_temp.pic", "w")
	file.write(tostring(icon_raw))
	file.close()
	local icon_canvas = user.loadCanvas("home:/temp/icon_temp.pic")
	fs.delete("/temp/")



	local panel = widgets.Panel.Create(panelApps, "__item_" .. tostring(index))
	panel.left = 0
	panel.width = app.canvas.size.x - 1
	panel.height = 5
	panel.top = index * panel.height
	panel.bgcolor = colors.white
	panel:refresh()

	panel._mouseClick = panel.mouseClick
	panel.mouseClick = function(self, button, x, y)
		self:_mouseClick(button, x, y - self.top)
	end

	local icon = widgets.PaintBox.Create(panel, "icon")
	icon.left = 1
	icon.top = 1
	icon.height = 3
	icon.width = 5
	icon:refresh()
	icon.canvas:draw(0, 0, icon_canvas or icon.canvas)

	local title = widgets.Label.Create(panel, "title")
	title.left = icon.left + icon.width + 1
	title.top = 2
	title.caption = title_raw
	title.width = string.len(title.caption) + 1
	title.bgcolor = colors.white
	title.forecolor = colors.black

	local inst = widgets.Button.Create(panel, "inst")
	inst.width = 9
	inst.left = app.canvas.size.x - inst.width - 1
	inst.top = 2
	inst.url = download_link

	if item.installed then
		inst.left = inst.left - 1
		inst.width = inst.width + 1
		inst.caption = "Installed"
		inst.forecolor = colors.green
		inst.forecolor2 = colors.green
		inst.bgcolor = colors.white
	else
		inst.caption = " Install"

		inst.onClick = function(sender)
			local cancelled = false

			function onLocalSuccess(url, handle)
				os.hideMessageBox()

				if not cancelled then
					fs.makeDir("/setup-cache/")
					local file = fs.open("/setup-cache/setup.wpk", "w")
					file.write(handle.readAll())
					file.close()
					handle.close()

					local handler = os.shell.run("setup \"/setup-cache/setup.wpk\"")
					local running = true

					while running do
						coroutine.yield()
						local ls = os.getValidHWNDList()
						local found = false
						for k, v in pairs(ls) do
							if v == handler then
								found = true
							end
						end

						if not found then
							running = false
						end
					end

					fs.delete("/setup-cache/")
					os.shell.run("update")
					app:terminate()
				end
			end

			function onLocalFail(url)
				os.hideMessageBox()
				app:showMessage(url)
			end

			os.messageBox("message", "Downloading... Please, wait.", "CCWin Updater", {{
				caption = "Cancel", onClick = function(sender)
					cancelled = true
					os.hideMessageBox()
				end
			}}, "defText")

			local http = os.findWindowByTitle("http service")
			os.sendMessage(http, {msg = "request", url = sender.url, onSuccess = onLocalSuccess, onFail = onLocalFail})
		end
	end

	local va = widgets.Label.Create(panel, "va")
	va.left = title.left + title.width + 1
	va.top = 2
	va.width = app.canvas.size.x - title.left - title.width - inst.width - 3
	va.caption = version_raw .. ", by " .. author_raw
	va.bgcolor = colors.white
	va.forecolor = colors.lightGray

	local desc = widgets.Label.Create(panel, "desc")
	desc.left = title.left + 1
	desc.top = 4
	desc.width = app.canvas.size.x - desc.left - 2
	desc.caption = desc_raw
	desc.bgcolor = colors.white
	desc.forecolor = colors.gray

	local full_desc = {}
	local sp_desc = user.split(desc_raw, " ")
	local s = ""
	for i, v in ipairs(sp_desc) do
		local temp_s = s .. v
		if string.len(temp_s) > desc.width - 1 then
			table.insert(full_desc, s)
			s = v .. " "
		else
			s = s .. v .. " "
		end
	end
	if string.len(s) > 0 then
		table.insert(full_desc, s)
	end

	desc.full_desc = full_desc
	desc.index = index
	desc.expanded = false

	desc.onClick = function(sender)
		if not sender.expanded then
			sender.parent.height = sender.parent.height + #(sender.full_desc)
			sender.last_caption = sender.caption
			sender.caption = sender.full_desc[1]

			for i = 2, #(sender.full_desc) do
				if sender.full_desc[i] ~= nil then
					local lbl = widgets.Label.Create(sender.parent, "__lbl_" .. tostring(i))
					lbl.left = title.left + 1
					lbl.top = sender.top + i - 1
					lbl.width = app.canvas.size.x - desc.left - 2
					lbl.caption = sender.full_desc[i]
					lbl.bgcolor = colors.white
					lbl.forecolor = colors.gray

					lbl.onClick = function(sender)
						--sender.parent.widgets["desc"]:onClick()
					end
				end
			end

			local len = 0
			for k, v in pairs(sender.parent.parent.widgets) do
				len = len + 1
			end

			for i = sender.index + 1, len do
				local index = "__item_" .. tostring(i)
				if sender.parent.parent.widgets[index] ~= nil then
					sender.parent.parent.widgets[index].top = sender.parent.parent.widgets[index].top + #(sender.full_desc)
				end
			end

			sender.expanded = true
		else
			sender.parent.height = sender.parent.height - #(sender.full_desc)
			sender.caption = sender.last_caption

			for i = 2, #(sender.full_desc) do
				sender.parent.widgets["__lbl_" .. tostring(i)] = nil
			end

			local len = 0
			for k, v in pairs(sender.parent.parent.widgets) do
				len = len + 1
			end

			for i = sender.index + 1, len do
				local index = "__item_" .. tostring(i)
				if sender.parent.parent.widgets[index] ~= nil then
					sender.parent.parent.widgets[index].top = sender.parent.parent.widgets[index].top - #(sender.full_desc)
				end
			end

			sender.parent.focusedWidget = nil
			sender.expanded = false
		end

		updateScrollBar()
		os.sendMessage(hwnd, {msg = "refresh"})
	end
end


function clearItems()
	panelApps.widgets = {}
	panelApps.focusedWidget = nil
	scrollApps.max = 0
	scrollApps.value = 0
end



local tabs = {}

function selectTab(sender)
	for k, v in pairs(tabs) do
		v.bgcolor = colors.lightGray
		v.forecolor = colors.black
	end
	sender.bgcolor = colors.gray
	sender.forecolor = colors.white
	if sender.onSelect ~= nil then
		sender:onSelect()
	end

	clearItems()
	for i, v in ipairs(list[sender.key]) do
		addItem(v, i - 1)
	end
	updateScrollBar()
end


tabs[1] = widgets.Label.Create(mainForm, "lblUpdates")
tabs[1].left = 1
tabs[1].top = 3
tabs[1].caption = "Updates"
tabs[1].width = math.floor(app.canvas.size.x / 3)
tabs[1].height = 1
tabs[1].align = "center"
tabs[1].onClick = selectTab
tabs[1].key = "updates"

tabs[2] = widgets.Label.Create(mainForm, "lblAdditionalSoftware")
tabs[2].left = 1 + math.floor(app.canvas.size.x / 3)
tabs[2].top = 3
tabs[2].caption = "Software"
tabs[2].width = math.floor(app.canvas.size.x / 3)
tabs[2].height = 1
tabs[2].align = "center"
tabs[2].onClick = selectTab
tabs[2].key = "software"

tabs[3] = widgets.Label.Create(mainForm, "lblThirdPartySoftware")
tabs[3].left = 1 + math.floor(app.canvas.size.x / 3) * 2
tabs[3].top = 3
tabs[3].caption = "Third-Party"
tabs[3].width = app.canvas.size.x - tabs[3].left + 1
tabs[3].height = 1
tabs[3].align = "center"
tabs[3].onClick = selectTab
tabs[3].key = "thirdparty"


function onFail(url)
	lblWait.caption = "An error occured."
end


function onSuccess(url, handle)
	function sort(t)
		local new = {}
		local l1 = {}
		local l2 = {}
		local installed = os.getRegistryBranchKeys("installed")
		local sys_ver = os.getVersion()

		for k, v in pairs(t) do
			if (sys_ver.build >= v.minVersion) and (sys_ver.build < v.maxVersion) then
				local is_installed = false
				for k2, v2 in pairs(installed) do
					if string.lower(v2) == string.lower(v.title .. " " .. v.version) then
						is_installed = true
					end
				end

				v.installed = is_installed
				if is_installed then
					table.insert(l2, v)
				else
					table.insert(l1, v)
				end
			end
		end

		for k, v in pairs(l1) do
			table.insert(new, v)
		end

		for k, v in pairs(l2) do
			table.insert(new, v)
		end

		return new
	end

	local data = handle.readAll()
	local list_raw = {}
	handle.close()
	local status, res = pcall(loadstring(data))
	if status then
		list_raw = res
	else
		onFail(url)
	end

	list = {}
	list.updates = sort(list_raw.updates or {})
	list.software = sort(list_raw.software or {})
	list.thirdparty = sort(list_raw.thirdparty or {})
	selectTab(tabs[1])

	mainForm:show()
	os.sendMessage(hwnd, {msg = "refresh"})
end




local fileMenu = widgets.PopupMenu.Create()

table.insert(fileMenu.items, widgets.PopupMenu.CreateItem("Refresh", function(sender)
	os.shell.run("update")
	app:terminate()
end))

table.insert(fileMenu.items, widgets.PopupMenu.CreateItem("-", nil))
table.insert(fileMenu.items, widgets.PopupMenu.CreateItem("Exit", function(sender) app:terminate() end))

local manageMenu = widgets.PopupMenu.Create()
table.insert(manageMenu.items, widgets.PopupMenu.CreateItem("Add/Remove Software", function(sender) os.shell.run("progcomp") end))

local helpMenu = widgets.PopupMenu.Create()
table.insert(helpMenu.items, widgets.PopupMenu.CreateItem("About", function(sender) os.shell.run("winver") end))


local menu = widgets.MenuBar.Create(mainForm, "Menu")
table.insert(menu.items, widgets.MenuBar.CreateItem("File", function(sender) widgets.popupMenu(fileMenu, sender.left, sender.top + 2) end))
table.insert(menu.items, widgets.MenuBar.CreateItem("Manage", function(sender) widgets.popupMenu(manageMenu, sender.left, sender.top + 2) end))
table.insert(menu.items, widgets.MenuBar.CreateItem("Help", function(sender) widgets.popupMenu(helpMenu, sender.left, sender.top + 2) end))





local http = os.findWindowByTitle("http service")
os.sendMessage(http, {msg = "request", url = list_url, onSuccess = onSuccess, onFail = onFail})




--os.startTimer(0.5, function() os.sendMessage(hwnd, {msg = "refresh"}) end)
app:run()
