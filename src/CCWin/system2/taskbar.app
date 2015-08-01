local app = application.Create(os.getProcessInfo(os.getCurrentProcess()), os)
local taskbar = form.Create("Taskbar")
local processCount = 0
local refreshCount = 0
local useAM = true
local scroll = 0
local shouldScroll = false

app:addForm(taskbar, "Taskbar")
taskbar:show()

os.getProcessInfo(os.getCurrentProcess()).showInTaskbar = false


local time = widgets.Label.Create(taskbar, "Time")
time.width = 7 + 3
time.left = app.canvas.size.x - time.width + 2
time.top = 0
time.align = "right"
time.bgcolor = colors.gray
time.forecolor = colors.white

time.onClick = function(sender)
	--if useAM then useAM = false else useAM = true end
end

time.onRefresh = function(sender)
	useAM = os.getRegistryKeyValue("datetime", "useAM", "false") == "true"
	sender.caption = tostring(textutils.formatTime(os.time(), useAM)) .. "%"
end



local leftButton = widgets.Button.Create(taskbar, "leftButton")
leftButton.caption = "<"
leftButton.left = 9
leftButton.width = 1
leftButton.top = 0
leftButton.forecolor2 = colors.lightGray

leftButton.onClick = function(sender)
	if shouldScroll then
		scroll = scroll + 4
		if scroll > 0 then scroll = 0 end
	end
end


local rightButton = widgets.Button.Create(taskbar, "rightButton")
rightButton.caption = ">"
rightButton.left = 10 + app.canvas.size.x - 9 - 6 - 2 + 1  - 3
rightButton.width = 1
rightButton.top = 0
rightButton.forecolor2 = colors.lightGray

rightButton.onClick = function(sender)
	if shouldScroll then
		scroll = scroll - 4
		if scroll < -10 * (processCount - 1) + processCount - 1 then scroll = -10 * (processCount - 1) + processCount - 1 end
	end
end




local panel = widgets.Panel.Create(taskbar, "Panel")
panel.top = 0
panel.height = 2
panel.width = app.canvas.size.x - 9 - 6 - 2  - 3
panel.left = 10
panel.bgcolor = colors.gray

--app.canvas:fillrect(1, 1, app.canvas.size.x, 1, colors.gray)

panel.onRefresh = function(sender)
	local hwnds = os.getValidHWNDList(true)

	if processCount > 0 then
		for i = 0, processCount do
			sender.widgets["button_" .. tostring(i)] = nil
		end
	end


	if #hwnds > 3 then
		shouldScroll = true
		leftButton.visible = true
		rightButton.visible = true

		if processCount ~= #hwnds then
			scroll = -10 * (#hwnds - 3) - #hwnds + 3
		end
	else
		shouldScroll = false
		leftButton.visible = false
		rightButton.visible = false
		scroll = 0
	end


	processCount = #hwnds
	sender.focusedWidget = nil




	for i, v in ipairs(hwnds) do
		local button = widgets.Button.Create(sender, "button_" .. tostring(i))
		local info = os.getProcessInfo(v)
		button.width = 10
		button.left = scroll + button.width * (i - 1) + i
		button.caption = --[["|" .. ]]info.title
		button.tag = v
		button.forecolor2 = colors.white

		if v == os.getActiveProcess() then
			button.bgcolor = colors.lightGray
			button.forecolor = colors.black
			button.forecolor2 = colors.black
		end

		button.onClick = function(sender)
			sender.bgcolor = colors.lightGray
			sender.forecolor = colors.black
			sender.forecolor2 = colors.black
			os.setActiveProcess(sender.tag)
		end
	end
end



function shutDown()
	os.shell.run("shutdown.app")
--[[	os.messageBox("message", "What do you want the computer to do?", "Shut Down", 
	{ 
		{caption = "Shut Down", 
			onClick = function(sender)
				os.hideMessageBox()
			end
		},

		{caption = "Restart",
			onClick = function(sender)
				os.hideMessageBox()
			end
		},

		{caption = "Restart in CraftOS mode",
			onClick = function(sender)
				os.hideMessageBox()
			end
		},

		{caption = "Cancel",
			onClick = function(sender)
				os.hideMessageBox()
			end
		}

	}, "defText")]]
end


local startMenu = widgets.PopupMenu.Create()
startMenu.forecolor2 = colors.red
table.insert(startMenu.items, widgets.PopupMenu.CreateItem("Shut Down..", function(sender) shutDown() end))
table.insert(startMenu.items, widgets.PopupMenu.CreateItem("-", nil))
table.insert(startMenu.items, widgets.PopupMenu.CreateItem("Run..", function(sender) os.shell.run("exec.app") end))
table.insert(startMenu.items, widgets.PopupMenu.CreateItem("Command Line", function(sender) os.shell.run("ncvm") end))
table.insert(startMenu.items, widgets.PopupMenu.CreateItem("Control Panel", function(sender) os.shell.run("control") end))
--table.insert(startMenu.items, widgets.PopupMenu.CreateItem("Help", nil))
table.insert(startMenu.items, widgets.PopupMenu.CreateItem("-", nil))
table.insert(startMenu.items, widgets.PopupMenu.CreateItem("Settings", function(sender) os.shell.run("explorer \"" .. os.getSystemPath() .. 
	"/userdata/ProgramGroups/Settings/\"") end))
table.insert(startMenu.items, widgets.PopupMenu.CreateItem("Documents", function(sender) os.shell.run("explorer \"" .. os.getSystemPath() .. 
	"/userdata/Documents/\"") end))
table.insert(startMenu.items, widgets.PopupMenu.CreateItem("Programs", function(sender) os.shell.run("explorer \"" .. os.getSystemPath() .. 
	"/userdata/ProgramGroups/Programs/\"") end))
table.insert(startMenu.items, widgets.PopupMenu.CreateItem("-", nil))
table.insert(startMenu.items, widgets.PopupMenu.CreateItem("Update Center", function(sender) os.shell.run("update") end))
table.insert(startMenu.items, widgets.PopupMenu.CreateItem("   ", nil))


local start = widgets.Button.Create(taskbar, "Start")
start.left = 1
start.top = 0
start.width = 7
start.bgcolor = colors.blue
start.forecolor = colors.white
start.caption = " Start"

start.onClick = function(sender)
	--startMenu:popUp(1, sender.parent:getCanvas().size.y - 2)
	widgets.popupMenu(startMenu, 1, sender.parent:getCanvas().size.y)
end






taskbar.onRefresh = function(sender)
	app.canvas:fillrect(1, 1, app.canvas.size.x, 1, colors.gray)
end

taskbar.onTerminate = function(sender)
	return false
end


os.startTimer(0.05, function() taskbar:refresh() end )
app:run()
