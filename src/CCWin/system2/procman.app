local app = application.Create(os.getProcessInfo(os.getCurrentProcess()), os)
local mainForm = form.Create("Task Manager")

app:addForm(mainForm, "Task Manager")
mainForm:show()


local procList = widgets.ListBox.Create(mainForm, "procList")
procList.top = 4
procList.height = app.canvas.size.y - 7
procList.width = app.canvas.size.x + 1
procList.left = 0
procList.infoList = {}
procList.columns = 4
procList.columnWidth = { 14, app.canvas.size.x - 12 - 4 - 5 - 9, 5}



local lblInfo = widgets.Label.Create(mainForm, "lblInfo")
lblInfo.width = app.canvas.size.x
lblInfo.top = 3
lblInfo.left = 1
lblInfo.caption = "Window        Process"
local s = string.rep(" ", app.canvas.size.x - string.len(lblInfo.caption) - 12 - 1 - string.len("RAM") - 1)
lblInfo.caption = lblInfo.caption .. s .. "PID" .. "   " .. "RAM Usage"



local btnTerm = widgets.Button.Create(mainForm, "btnTerm")
btnTerm.width = 14
btnTerm.left = app.canvas.size.x - btnTerm.width
btnTerm.top = app.canvas.size.y - 2
btnTerm.caption = " Terminate"

btnTerm.onClick = function(sender)
	if procList.list[procList.index][3] > 0 then
		os.killProcess(procList.list[procList.index][3])
		sender.parent:refresh()
	end
end


lblPath = widgets.Label.Create(mainForm, "lblPath")
lblPath.width = app.canvas.size.x - btnTerm.width - 3
lblPath.top = app.canvas.size.y - 2
lblPath.left = 2
lblPath.forecolor = colors.gray

lblPath.onRefresh = function(sender)
	if procList.list[procList.index] ~= nil then
		local info = os.getProcessInfo(procList.list[procList.index][3])
		sender.caption = "home:/" .. (info.fileName or "")

		if sender.caption == "home:/" then sender.caption = "" end
	end
end



function GetProcessMemory(pid)
	return os.getProcessUsedMemory(pid)
end

function GetSystemMemory()
	return os.getProcessUsedMemory(-1)
end

function FormatProcessMemory(mem)
	if mem == -1 then
		return ""
	else
		local kBytes = mem / 1024

		if kBytes > 1000 then
			return tostring(user.round(mem / 1024 / 1024, 2)) .. " Mb"
		elseif kBytes > 100 then
			return tostring(user.round(mem / 1024, 1)) .. " Kb"	
		else
			return tostring(user.round(mem / 1024, 2)) .. " Kb"
		end
	end
end





mainForm.onRefresh = function(sender)
end


function refreshData(sender)
	sender.widgets.procList:clear()
	sender.widgets.procList.infoList = {}

	sender.widgets.procList:add({"System", " ", 0, FormatProcessMemory(GetSystemMemory()), 0})
	table.insert(sender.widgets.procList.infoList, {fileName = " ", hwnd = 0})

	for i, v in ipairs(os.getValidHWNDList(false)) do
		local info = os.getProcessInfo(v)

		sender.widgets.procList:add({info.title, os.extractFileName(info.fileName), info.hwnd, 
			FormatProcessMemory(GetProcessMemory(v)), tostring(info.etime / config.PROCESS_TIMER * 100) .. "%"})
		table.insert(sender.widgets.procList.infoList, {fileName = info.fileName, hwnd = v})
	end
end








function file_newClick()
	os.shell.run("exec.app")
end


function help_aboutClick()
end



local fileMenu = widgets.PopupMenu.Create()
table.insert(fileMenu.items, widgets.PopupMenu.CreateItem("New (Run..)", function(sender) file_newClick() end))
table.insert(fileMenu.items, widgets.PopupMenu.CreateItem("-", nil))
table.insert(fileMenu.items, widgets.PopupMenu.CreateItem("Exit", function(sender) app:terminate() end))

local helpMenu = widgets.PopupMenu.Create()
table.insert(helpMenu.items, widgets.PopupMenu.CreateItem("About", function(sender) help_aboutClick() end))


local menu = widgets.MenuBar.Create(mainForm, "Menu")
table.insert(menu.items, widgets.MenuBar.CreateItem("File", function(sender) widgets.popupMenu(fileMenu, sender.left, sender.top + 2) end))
table.insert(menu.items, widgets.MenuBar.CreateItem("Help", function(sender) widgets.popupMenu(helpMenu, sender.left, sender.top + 2) end))


os.startTimer(2, function()
	refreshData(mainForm)
	os.sendMessage(hwnd, {msg = "refresh"})
end )

refreshData(mainForm)
app:run()