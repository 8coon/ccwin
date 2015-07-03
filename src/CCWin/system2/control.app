local app = application.Create(os.getProcessInfo(os.getCurrentProcess()), os)
local desktop = form.Create("Control Panel")
local lastTime = 0

app:addForm(desktop, "Control Panel")
desktop.bgcolor = colors.white
desktop:show()


local infoPanel = widgets.PaintBox.Create(desktop, "infoPanel")
infoPanel.top = 1
infoPanel.left = 0
infoPanel.width = 13
infoPanel.height = app.canvas.size.y - 1
infoPanel.bgcolor = colors.blue
infoPanel:refresh()

--local cpanel = user.loadCanvas("home:/" .. os.getSystemPath() .. "/assets/cpanel.pic")
--infoPanel.canvas:draw(0, 0, cpanel)
infoPanel.canvas:setCursorPos(2, 4)
infoPanel.canvas.bgcolor = colors.blue
infoPanel.canvas.forecolor = colors.white
--infoPanel.canvas:write("Control")


local listView = widgets.ListView.Create(desktop, "listView")
listView.top = 2
listView.left = 14
listView.width = app.canvas.size.x - 13
listView.height = app.canvas.size.y - 2

listView.getIcon = function(sender, item)
	return item.icon
end




local icon = user.loadCanvas("home:/" .. os.getSystemPath() .. "/system2/programs.pic")
table.insert(listView.list, { icon = icon, name = "Add/Remove Software", dir = false, _cmd = "progcomp" })

local icon = user.loadCanvas("home:/" .. os.getSystemPath() .. "/system2/date.pic")
table.insert(listView.list, { icon = icon, name = "Date&Time", dir = false, _cmd = "" })

local icon = user.loadCanvas("home:/" .. os.getSystemPath() .. "/system2/display.pic")
table.insert(listView.list, { icon = icon, name = "Display", dir = false, _cmd = "" })

local icon = user.loadCanvas("home:/" .. os.getSystemPath() .. "/system2/hardware.pic")
table.insert(listView.list, { icon = icon, name = "Hardware", dir = false, _cmd = "" })

local icon = user.loadCanvas("home:/" .. os.getSystemPath() .. "/system2/network.pic")
table.insert(listView.list, { icon = icon, name = "Network", dir = false, _cmd = "" })

local icon = user.loadCanvas("home:/" .. os.getSystemPath() .. "/system2/system.pic")
table.insert(listView.list, { icon = icon, name = "System", dir = false, _cmd = "" })




listView.onClick = function(sender)
	local time = os.time()

	if (time - lastTime) * 10 < config.PROCESS_TIMER then
		local selected = listView.selectedList
		if #selected > 0 then
			os.shell.run(listView.list[selected[1]]._cmd)
		end
	end

	lastTime = time
end




--os.startTimer(2, function() 
--	os.sendMessage(hwnd, {msg = "refresh"})
--end )
app:run()