local app = application.Create(os.getProcessInfo(os.getCurrentProcess()), os)
local mainForm = form.Create("Notepad")
local currentFileName = ""


app:addForm(mainForm, "Notepad")
mainForm:show()


local textArea = widgets.TextArea.Create(mainForm, "textArea", widgets)
textArea.left = 1
textArea.top = 2
textArea.height = app.canvas.size.y - 2
textArea.width = app.canvas.size.x
textArea.text = ""




function loadFile(fileName)
	local file = fs.open(fileName, "r")
	local text = ""

	if file ~= nil then
		text = file.readAll()
		file.close()
	end

	currentFileName = fileName
	mainForm.name = "[" .. fileName .. "] - Notepad"
	os.sendMessage(hwnd, {msg = "refresh"})

	textArea:setText(text)
	textArea:refresh()
end


function saveFile(fileName)
	local file = fs.open(fileName, "w")
	local text = textArea:getText()

	if file ~= nil then
		file.write(text)
		file.close()
	end

	currentFileName = fileName
	mainForm.name = "[" .. fileName .. "] - Notepad"
end






local saveDialog = widgets.dialogs.SaveDialog.Create(mainForm, "SaveDialog")

saveDialog.onExecute = function(sender)
	local fileName = string.gsub(sender.fileName, "home:/", "", 1)
	saveFile(fileName)
end



local openDialog = widgets.dialogs.OpenDialog.Create(mainForm, "OpenDialog")

openDialog.onExecute = function(sender)
	local fileName = string.gsub(sender.fileName, "home:/", "", 1)
	loadFile(fileName)
end



function file_newClick()
	os.shell.run("notepad")
	app:terminate()
end

function file_openClick()
	openDialog:execute()
end

function file_saveClick()
	if currentFileName ~= "" then
		saveFile(currentFileName)
	else
		saveDialog:execute()
	end
end

function file_saveAsClick()
	saveDialog:execute()
end

function file_exitClick()
	app:terminate()
end




local fileMenu = widgets.PopupMenu.Create()
table.insert(fileMenu.items, widgets.PopupMenu.CreateItem("New", function(sender) file_newClick() end))
table.insert(fileMenu.items, widgets.PopupMenu.CreateItem("Open", function(sender) file_openClick() end))
table.insert(fileMenu.items, widgets.PopupMenu.CreateItem("Save", function(sender) file_saveClick() end))
table.insert(fileMenu.items, widgets.PopupMenu.CreateItem("-", nil))
table.insert(fileMenu.items, widgets.PopupMenu.CreateItem("Save As..", function(sender) file_saveAsClick() end))
table.insert(fileMenu.items, widgets.PopupMenu.CreateItem("-", nil))
table.insert(fileMenu.items, widgets.PopupMenu.CreateItem("Exit", function(sender) file_exitClick() end))

local helpMenu = widgets.PopupMenu.Create()
table.insert(helpMenu.items, widgets.PopupMenu.CreateItem("About", function(sender) os.shell.run("winver Notepad") end))


local menu = widgets.MenuBar.Create(mainForm, "Menu")
table.insert(menu.items, widgets.MenuBar.CreateItem("File", function(sender) widgets.popupMenu(fileMenu, sender.left, sender.top + 2) end))
table.insert(menu.items, widgets.MenuBar.CreateItem("Help", function(sender) widgets.popupMenu(helpMenu, sender.left, sender.top + 2) end))




if params[2] ~= nil then
	loadFile(string.gsub(params[2], "home:/", "", 1))
end




app:run()