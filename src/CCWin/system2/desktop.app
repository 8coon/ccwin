local app = application.Create(os.getProcessInfo(os.getCurrentProcess()), os)
local desktop = form.Create("Desktop")
local lastTime = 0



app.canvas.effect = {
	getbgcolor = function(self, x, y, bgcolor, forecolor, char)
		if (y == 1) or (x == app.canvas.size.x) then
			return config.DESKTOP_COLOR
		else
			return bgcolor
		end
	end,

	getforecolor = function(self, x, y, bgcolor, forecolor, char)
		return forecolor
	end,

	getchar = function(self, x, y, bgcolor, forecolor, char)
		if (y == 1) or (x == app.canvas.size.x) then
			return " "
		else
			return char
		end
	end,
}



app:addForm(desktop, "Desktop")
desktop:show()
desktop.bgcolor = config.DESKTOP_COLOR
desktop.controlBox = false
desktop.drawTitle = false

os.getProcessInfo(os.getCurrentProcess()).showInTaskbar = false

desktop.onTerminate = function(sender)
	return false
end


local listView = widgets.FileListView.Create(desktop, "listView")
listView.bgcolor = config.DESKTOP_COLOR
listView.top = 1
listView.left = 1
listView.width = app.canvas.size.x
listView.height = app.canvas.size.y - 1
listView.path = os.getSystemPath() .. "/userdata/Desktop"
listView.widgets.scrollBar.visible = false
listView:refreshList()

listView.onClick = function(sender)
	local time = os.time()

	if (time - lastTime) * 10 < config.PROCESS_TIMER then
		local selected = listView.selectedList
		if #selected > 0 then
			--listView:navigate(listView.list[selected[1]].name)
			--listView.selectedList = {}
			if listView.list[selected[1]].dir then
				os.shell.run("explorer \"" .. listView.path .. "/" .. listView.list[selected[1]].name .. "\"")
			else
				local fileName = string.gsub("\"home:/" .. listView.path .. "/" .. listView.list[selected[1]].name .. "\"", "//", "/")
				os.shell.run(fileName)
			end
		end
	end

	lastTime = time
end



--for i=1,100 do
	--table.insert(listView.list, { icon = {}, name = "Tst" .. i .. ".app" })
	--table.insert(listView.list, { icon = {}, name = "Brian Griffin" })
--end


os.startTimer(2, function() 
	listView:refreshList()
	desktop:refresh()
end )
app:run()
