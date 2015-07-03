local app = application.Create(os.getProcessInfo(os.getCurrentProcess()), os)
local mainForm = form.Create("Shut Down")
app:addForm(mainForm, "Shut Down")
mainForm:show()
mainForm.controlBox = false


local lblCmd = widgets.Label.Create(mainForm, "lblCmd")
lblCmd.left = 2
lblCmd.top = 2
lblCmd.width = app.canvas.size.x - 2
lblCmd.caption = "What do you want the computer to do?"

local top = math.floor(app.canvas.size.y / 2) - 6


lblShutdown = widgets.Label.Create(mainForm, "lblShutdown")
lblShutdown.left = 5
lblShutdown.top = 4 + top
lblShutdown.width = app.canvas.size.x - 9
lblShutdown.caption = "-> Shut Down"
lblShutdown.forecolor = colors.blue

lblShutdown.onClick = function(sender)
	os.shell.shutdown()
end


lblRestart = widgets.Label.Create(mainForm, "lblRestart")
lblRestart.left = 5
lblRestart.top = 6 + top
lblRestart.width = app.canvas.size.x - 9
lblRestart.caption = "-> Restart"
lblRestart.forecolor = colors.blue

lblRestart.onClick = function(sender)
	os.shell.restart()
end


lblRestart2 = widgets.Label.Create(mainForm, "lblRestart2")
lblRestart2.left = 5
lblRestart2.top = 8 + top
lblRestart2.width = app.canvas.size.x - 9
lblRestart2.caption = "-> Restart in CraftOS mode"
lblRestart2.forecolor = colors.blue


lblRestart2.onClick = function(sender)
	os.shell.restart(true)
end


btnCancel = widgets.Button.Create(mainForm, "btnCancel")
btnCancel.left = app.canvas.size.x - 10
btnCancel.top = app.canvas.size.y - 2
btnCancel.width = 10
btnCancel.caption = "Cancel"

btnCancel.onClick = function(sender)
	app:terminate()
end







os.getProcessInfo(os.getCurrentProcess()).showInTaskbar = false
app:run()