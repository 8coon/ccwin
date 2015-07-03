local app = application.Create(os.getProcessInfo(os.getCurrentProcess()), os)
local mainForm = form.Create("Run...")
app:addForm(mainForm, "Run...")
mainForm:show()


local txtCmd = widgets.Edit.Create(mainForm, "txtCmd")
txtCmd.left = 2
txtCmd.top = 5
txtCmd.width = app.canvas.size.x - 2
txtCmd.text = ""


local btnCmd = widgets.Button.Create(mainForm, "btnCmd")
btnCmd.width = 9
btnCmd.left = app.canvas.size.x - btnCmd.width
btnCmd.top = app.canvas.size.y - 2
btnCmd.caption = " Run"

btnCmd.onClick = function(sender)
	if (txtCmd.text == nil) or (txtCmd.text == "") then
		os.messageBox("message", "Please specify any command.", "Error", 
		{ 
			{caption = "OK", 
				onClick = function(sender)
					os.hideMessageBox()
				end
			},
		}, "defText")
	else
		os.shell.run(txtCmd.text)
		app:terminate()
	end
end



local lblExec = widgets.Label.Create(mainForm, "lblExec")
lblExec.left = 2
lblExec.top = 2
lblExec.caption = "Type the name of a program, folder or document"-- and it will be opened."
lblExec.width = app.canvas.size.x - 2
lblExec.height = 1

local lblExec = widgets.Label.Create(mainForm, "lblExec2")
lblExec.left = 2
lblExec.top = 3
lblExec.caption = "and it will be opened."
lblExec.width = app.canvas.size.x - 2
lblExec.height = 1

local lblExec = widgets.Label.Create(mainForm, "lblExec3")
lblExec.left = 2
lblExec.top = 7
lblExec.caption = "Built-in commands:"
lblExec.width = app.canvas.size.x - 2
lblExec.height = 1

local lblExec = widgets.Label.Create(mainForm, "lblExec4")
lblExec.left = 5
lblExec.top = 9
lblExec.caption = "exec   explorer   lnkcreate   paintbrush" --   procman   winver
lblExec.width = app.canvas.size.x - 8
lblExec.height = 1
lblExec.forecolor = colors.gray

local lblExec = widgets.Label.Create(mainForm, "lblExec5")
lblExec.left = 5
lblExec.top = 11
lblExec.caption = "procman   winver"
lblExec.width = app.canvas.size.x - 8
lblExec.height = 1
lblExec.forecolor = colors.gray



app:run()