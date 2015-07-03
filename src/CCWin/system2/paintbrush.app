local app = application.Create(os.getProcessInfo(os.getCurrentProcess()), os)
local mainForm = form.Create("Paintbrush")
local bgcolor = colors.black
local forecolor = colors.white
local char = " "

local fileName = ""
local saved = true



app:addForm(mainForm, "Paintbrush")
mainForm:show()
mainForm.bgcolor = colors.gray


mainForm.onRefresh = function(sender)
	if fileName ~= "" then
		--error(fileName)
		if saved then
			mainForm.name = "[" .. os.extractFileName(fileName) .. "] - Paintbrush"
		else
			mainForm.name = "[" .. os.extractFileName(fileName) .. "]* - Paintbrush"
		end
	else
		mainForm.name = "Paintbrush"
	end
end



function openFile()
	if not saved then
		os.messageBox("message", "Save changes in current file?", "Save Changes", 
		{ 
			{caption = "Yes", 
				onClick = function(sender)
					saveFile(fileName)
					os.hideMessageBox()
					saved = true
					mainForm.widgets.OpenDialog:execute()
				end
			},

			{caption = "No",
				onClick = function(sender)
					os.hideMessageBox()
					mainForm.widgets.OpenDialog:execute()
				end
			} 

		}, "defText")
	else
		mainForm.widgets.OpenDialog:execute()
	end
end


function saveFile()
	if fileName == "" then
		mainForm.widgets.SaveDialog:execute()
		fileName = mainForm.widgets.SaveDialog.fileName
	else
		mainForm.widgets.SaveDialog.fileName = fileName
		mainForm.widgets.SaveDialog:onExecute()
	end
end


local paintBox = widgets.PaintBox.Create(mainForm, "PaintBox")
paintBox.top = 3
paintBox.left = 1
paintBox.height = 3
paintBox.width = 5



--app:showMessage(params[2])
if params[2] ~= nil then
	--mainForm.name = "[" .. params[2] .. "] - Paintbrush"
	--error(params[2])
	local canvas = user.loadCanvas(params[2])
	if canvas ~= nil then
		paintBox.height = canvas.size.y
		paintBox.width = canvas.size.x
		paintBox.pheight = canvas.size.y
		paintBox.pwidth = canvas.size.x
		paintBox.canvas = canvas
		fileName = params[2]
	end
	saved = true
end



local saveDialog = widgets.dialogs.SaveDialog.Create(mainForm, "SaveDialog")
local openDialog = widgets.dialogs.OpenDialog.Create(mainForm, "OpenDialog")
--saveDialog:execute()


local statusBar = widgets.Label.Create(mainForm, "StatusBar")
statusBar.top = app.canvas.size.y - 1
statusBar.left = 1
statusBar.width = app.canvas.size.x
statusBar.caption = " "





--[[local resizer = widgets.Label.Create(mainForm, "resizer")
resizer.top = paintBox.top + paintBox.height
resizer.left = paintBox.left + paintBox.width
resizer.height = 1
resizer.width = 1
resizer.caption = "*"
resizer.bgcolor = colors.gray
resizer.forecolor = colors.lightBlue]]

--mainForm.onMouseDrag = function(sender, button, x, y)
--	resizer.left = x
--	resizer.top = y
--end



saveDialog.onExecute = function(sender)
	user.saveCanvas(paintBox.canvas, sender.fileName)
	saved = true
	fileName = sender.fileName
end

openDialog.onExecute = function(sender)
	local canvas = user.loadCanvas(sender.fileName)
	if canvas ~= nil then
		paintBox.height = canvas.size.y
		paintBox.width = canvas.size.x
		paintBox.canvas = canvas
	end
	saved = true
	fileName = sender.fileName
end





local palette = widgets.Panel.Create(mainForm, "Palette")
palette.left = app.canvas.size.x - 6
palette.width = 6
palette.top = 2
palette.height = app.canvas.size.y - 2
palette.bgcolor = colors.lightGray


function onPaletteItemClick(sender)
	bgcolor = sender.bgcolor
end

function onPaletteItemPopup(sender)
	forecolor = sender.bgcolor
end


palette.widgets.bgcolor = widgets.Label.Create(palette, "bgcolor")
palette.widgets.bgcolor.top = 10
palette.widgets.bgcolor.left = 2
palette.widgets.bgcolor.height = 2
palette.widgets.bgcolor.width = 3
palette.widgets.bgcolor.caption = " "

palette.widgets.bgcolor.onRefresh = function(sender)
	sender.bgcolor = bgcolor
end


palette.widgets.forecolor = widgets.Label.Create(palette, "forecolor")
palette.widgets.forecolor.top = 12
palette.widgets.forecolor.left = 3
palette.widgets.forecolor.height = 1
palette.widgets.forecolor.width = 3
palette.widgets.forecolor.caption = " "

palette.widgets.forecolor.onRefresh = function(sender)
	sender.bgcolor = forecolor
end


palette.widgets.char = widgets.Edit.Create(palette, "char")
palette.widgets.char.top = 14
palette.widgets.char.left = 2
palette.widgets.char.height = 1
palette.widgets.char.width = 4
palette.widgets.char.text = " "

palette.widgets.char.onRefresh = function(sender)
	--if string.len(sender.text) > 0 then
	--	char = sender.text--string.sub(sender.text, 1, 2)
	--end
end


paintBox.onMouseClick = function(sender, button, x, y)
	--if string.len(palette.widgets.char.text) > 0 then
		char = palette.widgets.char.text--string.sub(sender.text, 1, 2)
	--end

	sender.canvas.bgcolor = bgcolor
	sender.canvas.forecolor = forecolor
	sender.canvas:point(x - sender.left, y - sender.top, char)
	statusBar.caption = "[x = " .. x - sender.left .. ", y = " .. y - sender.top .. ", char = " .. char .. "]"
	saved = false
end

paintBox.onMouseDrag = paintBox.onMouseClick




palette.widgets.forecolor2 = widgets.Label.Create(palette, "forecolor2")
palette.widgets.forecolor2.top = 11
palette.widgets.forecolor2.left = 5
palette.widgets.forecolor2.height = 2
palette.widgets.forecolor2.width = 1
palette.widgets.forecolor2.caption = " "
palette.widgets.forecolor2.onRefresh = palette.widgets.forecolor.onRefresh



palette.widgets["orange"] = widgets.Label.Create(palette, "orange")
palette.widgets["orange"].bgcolor = colors.orange
palette.widgets["orange"].caption = " "
palette.widgets["orange"].left = 2
palette.widgets["orange"].width = 2
palette.widgets["orange"].top = 1
palette.widgets["orange"].onClick = onPaletteItemClick
palette.widgets["orange"].onPopup = onPaletteItemPopup


palette.widgets["magenta"] = widgets.Label.Create(palette, "magenta")
palette.widgets["magenta"].bgcolor = colors.magenta
palette.widgets["magenta"].caption = " "
palette.widgets["magenta"].left = 4
palette.widgets["magenta"].width = 2
palette.widgets["magenta"].top = 1
palette.widgets["magenta"].onClick = onPaletteItemClick
palette.widgets["magenta"].onPopup = onPaletteItemPopup


palette.widgets["lightBlue"] = widgets.Label.Create(palette, "lightBlue")
palette.widgets["lightBlue"].bgcolor = colors.lightBlue
palette.widgets["lightBlue"].caption = " "
palette.widgets["lightBlue"].left = 2
palette.widgets["lightBlue"].width = 2
palette.widgets["lightBlue"].top = 2
palette.widgets["lightBlue"].onClick = onPaletteItemClick
palette.widgets["lightBlue"].onPopup = onPaletteItemPopup


palette.widgets["yellow"] = widgets.Label.Create(palette, "yellow")
palette.widgets["yellow"].bgcolor = colors.yellow
palette.widgets["yellow"].caption = " "
palette.widgets["yellow"].left = 4
palette.widgets["yellow"].width = 2
palette.widgets["yellow"].top = 2
palette.widgets["yellow"].onClick = onPaletteItemClick
palette.widgets["yellow"].onPopup = onPaletteItemPopup


palette.widgets["lime"] = widgets.Label.Create(palette, "lime")
palette.widgets["lime"].bgcolor = colors.lime
palette.widgets["lime"].caption = " "
palette.widgets["lime"].left = 2
palette.widgets["lime"].width = 2
palette.widgets["lime"].top = 3
palette.widgets["lime"].onClick = onPaletteItemClick
palette.widgets["lime"].onPopup = onPaletteItemPopup


palette.widgets["pink"] = widgets.Label.Create(palette, "pink")
palette.widgets["pink"].bgcolor = colors.pink
palette.widgets["pink"].caption = " "
palette.widgets["pink"].left = 4
palette.widgets["pink"].width = 2
palette.widgets["pink"].top = 3
palette.widgets["pink"].onClick = onPaletteItemClick
palette.widgets["pink"].onPopup = onPaletteItemPopup



palette.widgets["lightGray"] = widgets.Label.Create(palette, "lightGray")
palette.widgets["lightGray"].bgcolor = colors.lightGray
palette.widgets["lightGray"].caption = " "
palette.widgets["lightGray"].left = 2
palette.widgets["lightGray"].width = 2
palette.widgets["lightGray"].top = 4
palette.widgets["lightGray"].onClick = onPaletteItemClick
palette.widgets["lightGray"].onPopup = onPaletteItemPopup


palette.widgets["gray"] = widgets.Label.Create(palette, "gray")
palette.widgets["gray"].bgcolor = colors.gray
palette.widgets["gray"].caption = " "
palette.widgets["gray"].left = 4
palette.widgets["gray"].width = 2
palette.widgets["gray"].top = 4
palette.widgets["gray"].onClick = onPaletteItemClick
palette.widgets["gray"].onPopup = onPaletteItemPopup



palette.widgets["cyan"] = widgets.Label.Create(palette, "cyan")
palette.widgets["cyan"].bgcolor = colors.cyan
palette.widgets["cyan"].caption = " "
palette.widgets["cyan"].left = 2
palette.widgets["cyan"].width = 2
palette.widgets["cyan"].top = 5
palette.widgets["cyan"].onClick = onPaletteItemClick
palette.widgets["cyan"].onPopup = onPaletteItemPopup


palette.widgets["purple"] = widgets.Label.Create(palette, "purple")
palette.widgets["purple"].bgcolor = colors.purple
palette.widgets["purple"].caption = " "
palette.widgets["purple"].left = 4
palette.widgets["purple"].width = 2
palette.widgets["purple"].top = 5
palette.widgets["purple"].onClick = onPaletteItemClick
palette.widgets["purple"].onPopup = onPaletteItemPopup



palette.widgets["blue"] = widgets.Label.Create(palette, "blue")
palette.widgets["blue"].bgcolor = colors.blue
palette.widgets["blue"].caption = " "
palette.widgets["blue"].left = 2
palette.widgets["blue"].width = 2
palette.widgets["blue"].top = 6
palette.widgets["blue"].onClick = onPaletteItemClick
palette.widgets["blue"].onPopup = onPaletteItemPopup


palette.widgets["brown"] = widgets.Label.Create(palette, "brown")
palette.widgets["brown"].bgcolor = colors.brown
palette.widgets["brown"].caption = " "
palette.widgets["brown"].left = 4
palette.widgets["brown"].width = 2
palette.widgets["brown"].top = 6
palette.widgets["brown"].onClick = onPaletteItemClick
palette.widgets["brown"].onPopup = onPaletteItemPopup



palette.widgets["green"] = widgets.Label.Create(palette, "green")
palette.widgets["green"].bgcolor = colors.green
palette.widgets["green"].caption = " "
palette.widgets["green"].left = 2
palette.widgets["green"].width = 2
palette.widgets["green"].top = 7
palette.widgets["green"].onClick = onPaletteItemClick
palette.widgets["green"].onPopup = onPaletteItemPopup


palette.widgets["red"] = widgets.Label.Create(palette, "red")
palette.widgets["red"].bgcolor = colors.red
palette.widgets["red"].caption = " "
palette.widgets["red"].left = 4
palette.widgets["red"].width = 2
palette.widgets["red"].top = 7
palette.widgets["red"].onClick = onPaletteItemClick
palette.widgets["red"].onPopup = onPaletteItemPopup


palette.widgets["black"] = widgets.Label.Create(palette, "black")
palette.widgets["black"].bgcolor = colors.black
palette.widgets["black"].caption = " "
palette.widgets["black"].left = 2
palette.widgets["black"].width = 2
palette.widgets["black"].top = 8
palette.widgets["black"].onClick = onPaletteItemClick
palette.widgets["black"].onPopup = onPaletteItemPopup


palette.widgets["white"] = widgets.Label.Create(palette, "white")
palette.widgets["white"].bgcolor = colors.white
palette.widgets["white"].caption = " "
palette.widgets["white"].left = 4
palette.widgets["white"].width = 2
palette.widgets["white"].top = 8
palette.widgets["white"].onClick = onPaletteItemClick
palette.widgets["white"].onPopup = onPaletteItemPopup






function file_newClick()
	os.shell.run("paintbrush")
	app:terminate()
end

function file_openClick()
	--openDialog:execute()
	openFile()
	os.sendMessage(hwnd, {msg = "refresh"})
end

function file_saveClick()
	saveFile()
	os.sendMessage(hwnd, {msg = "refresh"})
end

function file_saveAsClick()
	saveDialog:execute()
	fileName = saveDialog.fileName
	--saveFile()
	os.sendMessage(hwnd, {msg = "refresh"})
end

function file_exitClick()
	app:terminate()
end

function edit_resizeClick()
	os.messageBox("input", "New canvas size: (eg. " .. app.canvas.size.x .. "x" .. app.canvas.size.y .. ")", "Resize Canvas", 
		{ 
			{caption = "Apply", 
				onClick = function(sender)
					os.hideMessageBox()
					local size = sender.parent.widgets.edit.text

					if size ~= nil then
						if string.find(size, "x") then
							local data = user.split(size, "x")
							local x = tonumber(data[1])
							local y = tonumber(data[2])

							if x ~= nil and y ~= nil then
								paintBox.height = y
								paintBox.width = x + 1
								os.sendMessage(hwnd, {msg = "refresh"})
							end
						end
					end
				end
			},

			{caption = "Cancel", 
				onClick = function(sender)
					os.hideMessageBox()
				end
			},
		}, paintBox.width - 1 .. "x" .. paintBox.height)
end




local fileMenu = widgets.PopupMenu.Create()
table.insert(fileMenu.items, widgets.PopupMenu.CreateItem("New", function(sender) file_newClick() end))
table.insert(fileMenu.items, widgets.PopupMenu.CreateItem("Open", function(sender) file_openClick() end))
table.insert(fileMenu.items, widgets.PopupMenu.CreateItem("Save", function(sender) file_saveClick() end))
table.insert(fileMenu.items, widgets.PopupMenu.CreateItem("-", nil))
table.insert(fileMenu.items, widgets.PopupMenu.CreateItem("Save As..", function(sender) file_saveAsClick() end))
table.insert(fileMenu.items, widgets.PopupMenu.CreateItem("-", nil))
table.insert(fileMenu.items, widgets.PopupMenu.CreateItem("Exit", function(sender) file_exitClick() end))

local editMenu = widgets.PopupMenu.Create()
table.insert(editMenu.items, widgets.PopupMenu.CreateItem("Resize", function(sender) edit_resizeClick() end))

local helpMenu = widgets.PopupMenu.Create()
table.insert(helpMenu.items, widgets.PopupMenu.CreateItem("About", function(sender) os.shell.run("winver Paintbrush") end))


local menu = widgets.MenuBar.Create(mainForm, "Menu")
table.insert(menu.items, widgets.MenuBar.CreateItem("File", function(sender) widgets.popupMenu(fileMenu, sender.left, sender.top + 2) end))
table.insert(menu.items, widgets.MenuBar.CreateItem("Edit", function(sender) widgets.popupMenu(editMenu, sender.left, sender.top + 2) end))
table.insert(menu.items, widgets.MenuBar.CreateItem("Help", function(sender) widgets.popupMenu(helpMenu, sender.left, sender.top + 2) end))


--os.startTimer(0.05, function() mainForm:refresh() end )
os.sendMessage(hwnd, {msg = "refresh"})
app:run()