local app = application.Create(os.getProcessInfo(os.getCurrentProcess()), os)
local mainForm = form.Create("Programs and Components")
app:addForm(mainForm, "Programs and Components")
mainForm:show()


function listInstalledSoftware()
	local keys = os.getRegistryBranchKeys("installed")
	local list = {}
	for i, v in ipairs(keys) do
		list[v] = os.getRegistryKeyValue("installed", v, "")
	end
	return list
end



local appList = widgets.ListBox.Create(mainForm, "appList")
appList.top = 2
appList.height = app.canvas.size.y - 5
appList.width = app.canvas.size.x + 1
appList.left = 0

local installed = listInstalledSoftware()
for k, v in pairs(installed) do
	appList:add(k)
end


local btnUninstall = widgets.Button.Create(mainForm, "btnUninstall")
btnUninstall.width = 12
btnUninstall.left = app.canvas.size.x - btnUninstall.width
btnUninstall.top = app.canvas.size.y - 2
btnUninstall.caption = "Uninstall"
btnUninstall.visible = false

btnUninstall.onClick = function(sender)
	if fs.exists("/temp.wpk") then
		fs.delete("/temp.wpk")
	end
	fs.move(os.getSystemPath() .. "/setup/" .. os.getRegistryKeyValue("uninstall", appList.list[appList.index], nil), "temp.wpk")

	local handler = os.shell.run("setup \"home:/temp.wpk\" -uninstall")
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
			fs.delete("/temp.wpk")
			os.shell.run("progcomp")
			app:terminate()
		end
	end
end


local btnRepair = widgets.Button.Create(mainForm, "btnRepair")
btnRepair.width = 9
btnRepair.left = app.canvas.size.x - btnUninstall.width - btnRepair.width - 1
btnRepair.top = app.canvas.size.y - 2
btnRepair.caption = "Repair"
btnRepair.visible = false

btnRepair.onClick = function(sender)
	if fs.exists("/temp.wpk") then
		fs.delete("/temp.wpk")
	end
	fs.copy(os.getSystemPath() .. "/setup/" .. os.getRegistryKeyValue("uninstall", appList.list[appList.index], nil), "temp.wpk")

	local handler = os.shell.run("setup \"home:/temp.wpk\"")
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
			fs.delete("/temp.wpk")
			os.shell.run("progcomp")
			app:terminate()
		end
	end
end



appList.onClick = function(sender)
	btnUninstall.visible = false
	btnRepair.visible = false
	if os.getRegistryKeyValue("uninstall", sender.list[sender.index], nil) ~= nil then
		btnUninstall.visible = true
		btnRepair.visible = true
	end
end


app:run()