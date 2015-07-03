local app = application.Create(os.getProcessInfo(os.getCurrentProcess()), os)
local mainForm = form.Create("Open With...")
app:addForm(mainForm, "Open With...")
mainForm:show()


local args = params
local customName = ""
local customPath = ""

function firstToUpper(str)
    return (str:gsub("^%l", string.upper))
end


function listInstalledSoftware()
	keys = os.getRegistryBranchKeys("installed")
	list = {}
	for i, v in ipairs(keys) do
		list[v] = os.getRegistryKeyValue("installed", v, "")
	end
	return list
end



local openDialog = widgets.dialogs.OpenDialog.Create(mainForm, "OpenDialog")
openDialog.onExecute = function(sender)
	if sender.fileName ~= nil then
		customName = firstToUpper(string.gsub(os.extractFileName(sender.fileName), "%.app", ""))
		customPath = "\"" .. sender.fileName .. "\" \"%FILENAME%\"" 
		sender.parent.widgets.appList:add(customName)
	end

	os.sendMessage(hwnd, {msg = "refresh"})
end



local lbl1 = widgets.Label.Create(mainForm, "lbl1")
lbl1.left = 2
lbl1.top = 2
lbl1.caption = "Choose program you want to use:"
lbl1.width = app.canvas.size.x - 2
lbl1.height = 1


local appList = widgets.ListBox.Create(mainForm, "appList")
appList.top = 4
appList.height = app.canvas.size.y - 7
appList.width = app.canvas.size.x + 1
appList.left = 0

local installed = listInstalledSoftware()
for k, v in pairs(installed) do
	appList:add(k)
end


local chbRemember = widgets.CheckBox.Create(mainForm, "chbRemember")
chbRemember.width = 25
chbRemember.left = 2
chbRemember.top = app.canvas.size.y - 2
chbRemember.checked = true
chbRemember.caption = "Remember my choice"
if args[2] == "?" then
	chbRemember.checked = false
	chbRemember.grayed = true
end


local btnOpen = widgets.Button.Create(mainForm, "btnOpen")
btnOpen.width = 9
btnOpen.left = app.canvas.size.x - btnOpen.width
btnOpen.top = app.canvas.size.y - 2
btnOpen.caption = "Open"
btnOpen.onClick = function(sender)
	if chbRemember.checked then
		if installed[appList.list[appList.index]] ~= nil then
			os.setRegistryKeyValue("extensions", args[2], installed[appList.list[appList.index]])
		else
			os.setRegistryKeyValue("extensions", args[2], openDialog.fileName .. " \"%FILENAME%\"")
		end
	end
	--error(tostring(args[3]))
	if installed[appList.list[appList.index]] ~= nil then
		os.shell.run(tostring(string.gsub(installed[appList.list[appList.index]], "%%FILENAME%%", tostring(args[3]))))
	else
		os.shell.run(tostring(string.gsub(openDialog.fileName .. " \"%FILENAME%\"", "%%FILENAME%%", tostring(args[3]))))
	end
	app:terminate()
end


local btnBrowse = widgets.Button.Create(mainForm, "btnBrowse")
btnBrowse.width = 9
btnBrowse.left = app.canvas.size.x - btnOpen.width - btnBrowse.width - 1
btnBrowse.top = app.canvas.size.y - 2
btnBrowse.caption = "Browse"
btnBrowse.onClick = function(sender)
	openDialog:execute()
end


app:run()