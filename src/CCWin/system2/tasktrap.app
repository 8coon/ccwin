local app = application.Create(os.getProcessInfo(os.getCurrentProcess()), os)
local taskbar = form.Create("Taskbar")


app:addForm(taskbar, "Taskbar")
taskbar:show()


taskbar.onRefresh = function(sender)
	app.canvas:fillrect(1, 1, app.canvas.size.x, app.canvas.size.y, colors.black)
end

os.startTimer(1, function() taskbar:refresh() end )
app:run()
