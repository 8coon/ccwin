local app = application.Create(os.getProcessInfo(os.getCurrentProcess()), os)
local desktop = form.Create("Control Panel")
local lastTime = 0

app:addForm(desktop, "Control Panel")
desktop.bgcolor = colors.white
desktop:show()


local infoPanel = widgets.Panel.Create(desktop, "infoPanel")
infoPanel.top = 1
infoPanel.left = 0
infoPanel.width = 13
infoPanel.height = app.canvas.size.y - 1
infoPanel.bgcolor = colors.blue
infoPanel:refresh()

infoPanel.canvas.bgcolor = colors.blue
infoPanel.canvas.forecolor = colors.white


local lblInfo = widgets.Label.Create(infoPanel, "lblInfo")
lblInfo.top = 2
lblInfo.left = 2
lblInfo.height = 10
lblInfo.width = 11
lblInfo.multiline = true
lblInfo.bgcolor = colors.blue
lblInfo.forecolor = colors.white

lblInfo.caption = "Click on\nany item to\nget more\ninfo."




local listView = widgets.ListView.Create(desktop, "listView")
listView.top = 2
listView.left = 14
listView.width = app.canvas.size.x - 13
listView.height = app.canvas.size.y - 2

listView.getIcon = function(sender, item)
	return item.icon
end




local icon = user.loadCanvas("home:/" .. os.getSystemPath() .. "/system2/programs.pic")
table.insert(listView.list, { icon = icon, name = "Add/Remove Software", dir = false,
	_cmd = "progcomp",
	_desc = "Manage sys-\ntem compo-\nnents and\nsoftware."})

local icon = user.loadCanvas("home:/" .. os.getSystemPath() .. "/system2/date.pic")
table.insert(listView.list, { icon = icon, name = "Date&Time", dir = false,
	_cmd = "datetime",
	_desc = "Edit cur-\nrent date\nand time\nrepresen-\ntation."})

local icon = user.loadCanvas("home:/" .. os.getSystemPath() .. "/system2/display.pic")
table.insert(listView.list, { icon = icon, name = "Display", dir = false,
	_cmd = "",
	_desc = "Manage mo-\nnitor and\ncolor set-\ntings."})

local icon = user.loadCanvas("home:/" .. os.getSystemPath() .. "/system2/hardware.pic")
table.insert(listView.list, { icon = icon, name = "Hardware", dir = false,
	_cmd = "",
	_desc = "Manage\nhardware."})

local icon = user.loadCanvas("home:/" .. os.getSystemPath() .. "/system2/network.pic")
table.insert(listView.list, { icon = icon, name = "Network", dir = false,
	_cmd = "",
	_desc = "Manage net-\nwork set-\ntings."})

local icon = user.loadCanvas("home:/" .. os.getSystemPath() .. "/system2/system.pic")
table.insert(listView.list, { icon = icon, name = "System", dir = false,
	_cmd = "",
	_desc = "Manage sys-\ntem set-\ntings\n(For expe-\nrienced\nusers)."})




listView.onClick = function(sender)
	local time = os.time()

	if (time - lastTime) * 10 < config.PROCESS_TIMER then
		local selected = listView.selectedList
		if #selected > 0 then
			os.shell.run(listView.list[selected[1]]._cmd)
		end
	else
		pcall(function()
			local selected = listView.selectedList
			lblInfo.caption = tostring(listView.list[selected[1]]._desc)
			lblInfo:refresh()
		end)
	end

	lastTime = time
end




--os.startTimer(2, function() 
--	os.sendMessage(hwnd, {msg = "refresh"})
--end )
app:run()
