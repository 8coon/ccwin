local app = application.Create(os.getProcessInfo(os.getCurrentProcess()), os)
local mainForm = form.Create("Create Shortcut")

app:addForm(mainForm, "Create Shortcut")
mainForm:show()


local saveDialog = widgets.dialogs.SaveDialog.Create(mainForm, "SaveDialog")
local openDialog = widgets.dialogs.OpenDialog.Create(mainForm, "OpenDialog")
local ico = false

saveDialog.onExecute = function(sender)
	sender.parent.widgets.shName.text = sender.fileName or ""
	os.sendMessage(hwnd, {msg = "refresh"})
end

openDialog.onExecute = function(sender)
	if ico then
		sender.parent.widgets.icoName.text = sender.fileName or ""
	else
		sender.parent.widgets.fileName.text = sender.fileName or ""
	end

	os.sendMessage(hwnd, {msg = "refresh"})
end




local lbl1 = widgets.Label.Create(mainForm, "lbl1")
lbl1.left = 2
lbl1.top = 2
lbl1.caption = "File destination:"
lbl1.width = app.canvas.size.x - 2
lbl1.height = 1

local fileName = widgets.Edit.Create(mainForm, "fileName")
fileName.left = 2
fileName.top = 4
fileName.width = app.canvas.size.x - 2 - 2 - 1
fileName.text = params[2] or ""

local btnBrowse1 = widgets.Button.Create(mainForm, "btnBrowse1")
btnBrowse1.width = 2
btnBrowse1.left = app.canvas.size.x - btnBrowse1.width
btnBrowse1.top = 4
btnBrowse1.forecolor2 = btnBrowse1.forecolor
btnBrowse1.caption = ".."
btnBrowse1.onClick = function(sender)
	ico = false
	openDialog:execute()
end



local lbl2 = widgets.Label.Create(mainForm, "lbl2")
lbl2.left = 2
lbl2.top = 6
lbl2.caption = "Shortcut destination:"
lbl2.width = app.canvas.size.x - 2
lbl2.height = 1

local shName = widgets.Edit.Create(mainForm, "shName")
shName.left = 2
shName.top = 8
shName.width = app.canvas.size.x - 5
shName.text = params[3] or ""

local btnBrowse2 = widgets.Button.Create(mainForm, "btnBrowse2")
btnBrowse2.width = 2
btnBrowse2.left = app.canvas.size.x - btnBrowse2.width
btnBrowse2.top = 8
btnBrowse2.forecolor2 = btnBrowse2.forecolor
btnBrowse2.caption = ".."
btnBrowse2.onClick = function(sender)
	saveDialog:execute()
end


local lbl3 = widgets.Label.Create(mainForm, "lbl3")
lbl3.left = 2
lbl3.top = 10
lbl3.caption = "Icon:"
lbl3.width = app.canvas.size.x - 2
lbl3.height = 1

local icoName = widgets.Edit.Create(mainForm, "icoName")
icoName.left = 2
icoName.top = 12
icoName.width = app.canvas.size.x - 5
icoName.text = params[4] or ""

local btnBrowse3 = widgets.Button.Create(mainForm, "btnBrowse3")
btnBrowse3.width = 2
btnBrowse3.left = app.canvas.size.x - btnBrowse3.width
btnBrowse3.top = 12
btnBrowse3.forecolor2 = btnBrowse3.forecolor
btnBrowse3.caption = ".."
btnBrowse3.onClick = function(sender)
	ico = true
	openDialog:execute()
end



local btnCmd = widgets.Button.Create(mainForm, "btnCmd")
btnCmd.width = 9
btnCmd.left = app.canvas.size.x - btnCmd.width
btnCmd.top = app.canvas.size.y - 2
btnCmd.caption = "Create"

btnCmd.onClick = function(sender)
	if (fileName.text == nil) or (fileName.text == "") or
	   (shName.text == nil) or (shName.text == "") or
	   (icoName.text == nil) or (icoName.text == "") then
		os.messageBox("message", "Please specify any command.", "Error", 
		{ 
			{caption = "OK", 
				onClick = function(sender)
					os.hideMessageBox()
				end
			},
		}, "defText")
	else
		local lnk = {
			shortcut = {
				file = fileName.text,
				icon = icoName.text,
			}
		}

		if not user.stringends(shName.text, ".lnk") then shName.text = shName.text .. ".lnk" end
		if user.stringstarts(shName.text, "home:/") then shName.text = string.gsub(shName.text, "home:/", "", 1) end

		iniFiles.write(shName.text, lnk)
		app:terminate()
	end
end



--os.sendMessage(hwnd, {msg = "refresh"})

app:run()