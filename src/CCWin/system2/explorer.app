local app = application.Create(os.getProcessInfo(os.getCurrentProcess()), os)
local desktop = form.Create("Explorer")
local lastTime = 0
local lastPlacesTime = 0
local lastSearchTime = 0

local showPlaces = true
local showSearch = false


local frmWarning = form.Create("Warning")
app:addForm(frmWarning, "Warning")
frmWarning.controlBox = false


app:addForm(desktop, "Explorer")
desktop:show()
desktop.bgcolor = colors.white


desktop.onTerminate = function(sender)
	--return false
	return true
end



local lblWarning = widgets.Label.Create(frmWarning, "lblWarning")
lblWarning.left = 2
lblWarning.top = 2
lblWarning.width = app.canvas.size.x - 4
lblWarning.caption = "The following files were not copied:"

local lstWarning = widgets.ListBox.Create(frmWarning, "lstWarning")
lstWarning.top = 4
lstWarning.left = 0
lstWarning.width = app.canvas.size.x + 1
lstWarning.height = app.canvas.size.y - 4 - 3

local btnWarning = widgets.Button.Create(frmWarning, "btnWarning")
btnWarning.width = 9
btnWarning.left = app.canvas.size.x - btnWarning.width
btnWarning.top = app.canvas.size.y - 2
btnWarning.caption = "OK"

btnWarning.onClick = function(sender)
	desktop:show()
	os.sendMessage(hwnd, {msg = "refresh"})
end





local listView = widgets.FileListView.Create(desktop, "listView")
listView.bgcolor = colors.white
listView.top = 1 + 3 + 1
listView.left = 1
listView.width = app.canvas.size.x
listView.height = app.canvas.size.y - 1 - 3 - 1
--listView.top = 2
--listView.left = 1
--istView.width = app.canvas.size.x
--listView.height = app.canvas.size.y - 2

listView.path = "home:/"
listView:refreshList()

listView.onClick = function(sender)
	listView.isCtrlDown = app:isCtrlDown()

	local time = os.time()

	if (time - lastTime) * 10 < config.PROCESS_TIMER then
		local selected = listView.selectedList
		if #selected > 0 then
			--listView:navigate(listView.list[selected[1]].name, true, os)
			--listView.selectedList = {}
			if listView.list[selected[1]].dir then
				listView:navigate(listView.list[selected[1]].name, true, os)
				listView.selectedList = {}
			else
				local fileName = string.gsub("home:/" .. listView.path .. "/" .. listView.list[selected[1]].name, "//", "/")
				os.shell.run(fileName)
			end
		end
	end

	lastTime = time
end

listView.onNavigate = function(sender, path)
	sender.parent.widgets["Panel"].widgets["AddressBar"].text = path
	sender.selectedList = {}
end

listView.onContextMenu = function(sender, item, x, y)
	local menu = widgets.PopupMenu.Create()
	--menu.bgcolor = colors.lightGray
	menu.tag = item
	table.insert(menu.items, widgets.PopupMenu.CreateItem("Open", function(sender) listView:navigate(menu.tag.name, true, os) end))
	table.insert(menu.items, widgets.PopupMenu.CreateItem("-", nil))
	table.insert(menu.items, widgets.PopupMenu.CreateItem("Open containing folder", function(sender) os.shell.run("explorer \"" .. sender.path .. "\"") end))

	--widgets.popupMenu(menu, x + 1, y + 1)
end



local panel = widgets.Panel.Create(desktop, "Panel")
panel.top = 2
panel.left = 0
panel.width = app.canvas.size.x
panel.height = 3
panel.bgcolor = colors.lightGray


local backButton = widgets.Button.Create(panel, "BackButton")
backButton.left = 2
backButton.top = 2
backButton.height = 1
backButton.width = 9
backButton.forecolor2 = colors.white
backButton.align = "center"
backButton.caption = " <- Back"

backButton.onClick = function(sender)
	listView:goBack()
end


local addressBar = widgets.Edit.Create(panel, "AddressBar")
addressBar.left = 2 + 9 + 1
addressBar.top = 2
addressBar.height = 1
addressBar.width = app.canvas.size.x - 2 - 9 - 1 - 5
addressBar.text = "home:/"

addressBar.onRefresh = function(sender)
	sender.text = string.gsub(sender.text, "%/%/", "%/")
end



local goButton = widgets.Button.Create(panel, "GoButton")
goButton.left = 2 + 9 + 1 + addressBar.width + 1
goButton.top = 2
goButton.height = 1
goButton.width = 4
goButton.forecolor2 = colors.white
goButton.align = "center"
goButton.caption = " Go"

goButton.onClick = function(sender)
	if addressBar.text:find("home:/") then
		listView:navigate(addressBar.text)
	else
		listView:navigate("home:/" .. addressBar.text)
	end
end


local function OpenWithText(fname)
	local p = user.split(fname, ".")

	if #p == 1 then
		return "Run in Emulator"
	elseif string.lower(p[#p]) == "app" then
		return "Run"
	else
		return "Open"
	end
end


local fileMenu = widgets.PopupMenu.Create()
table.insert(fileMenu.items, widgets.PopupMenu.CreateItem("New...", function(sender)
		os.messageBox("input", "New file name:", "Create File...", 
		{ 
			{caption = "OK", 
				onClick = function(sender)
					local fileName = sender.parent.widgets.edit.text

					if string.find(fileName, "%/") or string.find(fileName, "%\\") or
						string.find(fileName, "%:") or string.find(fileName, "%*") or
						string.find(fileName, "%?") or string.find(fileName, "%\"") or
						string.find(fileName, "%<") or string.find(fileName, "%>") or
						string.find(fileName, "%|") then
						app:showMessage("Invalid file name.")
					else
						app:showMessage(string.gsub(listView.path, "home:/", "", 1) .. "/" .. fileName)
						if fs.exists(string.gsub(listView.path, "home:/", "", 1) .. "/" .. fileName) then
							os.messageBox("message", "\"" .. fileName .. "\"Already exists. Delete?", "Warning", 
							{ 
								{caption = "Yes", 
									onClick = function(sender)
										fs.delete(string.gsub(listView.path, "home:/", "", 1) .. "/" .. fileName)

										local f = fs.open(string.gsub(listView.path, "home:/", "", 1) .. "/" .. fileName, "w")
										f.write("\r\n")
										f.close()

										os.hideMessageBox()
									end
								},

								{caption = "No",
									onClick = function(sender)
										os.hideMessageBox()
									end
								} 

							}, "defText")
						else
							local f = fs.open(string.gsub(listView.path, "home:/", "", 1) .. "/" .. fileName, "w")
							f.write("\r\n")
							f.close()
						end
					end

					listView:refreshList()
					desktop:refresh()
					os.hideMessageBox()
				end
			},

			{caption = "Cancel",
				onClick = function(sender)
					os.hideMessageBox()
				end
			} 

		}, "New File.txt")	
end))
table.insert(fileMenu.items, widgets.PopupMenu.CreateItem("New folder", function(sender)
		os.messageBox("input", "New folder name:", "Create Folder...", 
		{ 
			{caption = "OK", 
				onClick = function(sender)
					local fileName = sender.parent.widgets.edit.text

					if string.find(fileName, "%/") or string.find(fileName, "%\\") or
						string.find(fileName, "%:") or string.find(fileName, "%*") or
						string.find(fileName, "%?") or string.find(fileName, "%\"") or
						string.find(fileName, "%<") or string.find(fileName, "%>") or
						string.find(fileName, "%|") then
						app:showMessage("Invalid folder name.")
					else
						app:showMessage(string.gsub(listView.path, "home:/", "", 1) .. "/" .. fileName)
						if fs.exists(string.gsub(listView.path, "home:/", "", 1) .. "/" .. fileName) then
							os.messageBox("message", "\"" .. fileName .. "\"Already exists. Delete?", "Warning", 
							{ 
								{caption = "Yes", 
									onClick = function(sender)
										fs.delete(string.gsub(listView.path, "home:/", "", 1) .. "/" .. fileName)

										fs.makeDir(string.gsub(listView.path, "home:/", "", 1) .. "/" .. fileName)

										os.hideMessageBox()
									end
								},

								{caption = "No",
									onClick = function(sender)
										os.hideMessageBox()
									end
								} 

							}, "defText")
						else
							fs.makeDir(string.gsub(listView.path, "home:/", "", 1) .. "/" .. fileName)
						end
					end

					listView:refreshList()
					desktop:refresh()
					os.hideMessageBox()
				end
			},

			{caption = "Cancel",
				onClick = function(sender)
					os.hideMessageBox()
				end
			} 

		}, "New Folder")	
end))
table.insert(fileMenu.items, widgets.PopupMenu.CreateItem("Create shortcut", function(sender)
	if #(listView.selectedList) > 0 then
		os.shell.run("lnkcreate \"" .. listView.path .. "/" .. listView.list[listView.selectedList[1]].name .. "\" \"" ..
			listView.path .. "/" .. listView.list[listView.selectedList[1]].name .. ".lnk\"")
	end
end))
table.insert(fileMenu.items, widgets.PopupMenu.CreateItem("-", function(sender)  end))
table.insert(fileMenu.items, widgets.PopupMenu.CreateItem("Refresh", function(sender) 
	listView:refreshList()
	desktop:refresh() end))
table.insert(fileMenu.items, widgets.PopupMenu.CreateItem("-", function(sender)  end))

table.insert(fileMenu.items, widgets.PopupMenu.CreateItem("Open", 
	function(sender)
		if #(listView.selectedList) > 0 then
			os.shell.run("\"" .. listView.path .. "/" .. listView.list[listView.selectedList[1]].name .. "\"")
		end
	end))

table.insert(fileMenu.items, widgets.PopupMenu.CreateItem("Open with...",
	function(sender)
		if #(listView.selectedList) > 0 then
			local s = listView.list[listView.selectedList[1]].name
			local ext = "?"
			if (string.len(s) > 0) and (string.find(s, "%.") and s[0] ~= "." ) then
				local fn = user.split(s, ".")
				ext = fn[#fn]
			end

			os.shell.run("opendlg " .. ext .. " \"" ..
				listView.path .. "/" .. listView.list[listView.selectedList[1]].name .. "\"")
		end
	end))

table.insert(fileMenu.items, widgets.PopupMenu.CreateItem("Run in CraftOS Mode", 
	function(sender)
		if #(listView.selectedList) > 0 then
			os.shell.run("ncvm.app \"" .. listView.path .. "/" .. listView.list[listView.selectedList[1]].name .. "\"")
		end
	end))

table.insert(fileMenu.items, widgets.PopupMenu.CreateItem("-", function(sender)  end))
table.insert(fileMenu.items, widgets.PopupMenu.CreateItem("Exit", function(sender) app:terminate() end))


local editMenu = widgets.PopupMenu.Create()
table.insert(editMenu.items, widgets.PopupMenu.CreateItem("Cut", function(sender)
	local selList = listView.selectedList
	if #selList > 0 then
		local fileList = { action = "_MOVE", files = {} }

		for i, v in ipairs(listView.selectedList) do
			table.insert(fileList.files, listView.path .. "/" .. listView.list[v].name)
		end

		os.copyToClipboard(fileList, "_FILELIST")
	end
end))
table.insert(editMenu.items, widgets.PopupMenu.CreateItem("Copy", function(sender)
	local selList = listView.selectedList
	if #selList > 0 then
		local fileList = { action = "_COPY", files = {} }

		for i, v in ipairs(listView.selectedList) do
			table.insert(fileList.files, listView.path .. "/" .. listView.list[v].name)
		end

		os.copyToClipboard(fileList, "_FILELIST")
	end
end))
table.insert(editMenu.items, widgets.PopupMenu.CreateItem("Paste", function(sender)
	local fileList = os.pasteFromClipboard("_FILELIST")
	local conflictList = {}

	if (fileList ~= nil) and (fileList.files ~= nil) then
		--error("paste")

		for i, v in ipairs(fileList.files) do
			local from = string.gsub(v, "home:/", "", 1)
			local to = string.gsub(listView.path, "home:/", "", 1) .. "/" .. os.extractFileName(from)

			if fs.exists(to) then
				table.insert(conflictList, {from = from, to = to})
			else
				if fileList.action == "_COPY" then
					fs.copy(from, to)
				else
					fs.move(from, to)
				end
			end
		end

		if #conflictList > 0 then
			frmWarning.widgets.lstWarning.list = {}

			for i, v in ipairs(conflictList) do
				table.insert(frmWarning.widgets.lstWarning.list, "home:/" .. v.from)
			end

			frmWarning:show()
			os.sendMessage(hwnd, {msg = "refresh"})
		end

		-----------------------
		listView:refreshList()
		desktop:refresh()
	end
end))
table.insert(editMenu.items, widgets.PopupMenu.CreateItem("-", nil))
table.insert(editMenu.items, widgets.PopupMenu.CreateItem("Rename", function(sender)
	local selList = listView.selectedList
	if #selList > 0 then
		os.messageBox("input", "New file name:", "Rename \"" .. listView.list[selList[1]].name .. "\"", 
		{ 
			{caption = "OK", 
				onClick = function(sender)
					local fileName = sender.parent.widgets.edit.text

					if string.find(fileName, "%/") or string.find(fileName, "%\\") or
						string.find(fileName, "%:") or string.find(fileName, "%*") or
						string.find(fileName, "%?") or string.find(fileName, "%\"") or
						string.find(fileName, "%<") or string.find(fileName, "%>") or
						string.find(fileName, "%|") then
						app:showMessage("Invalid file name.")
					else
						fs.move(string.gsub(listView.path, "home:/", "", 1) .. "/" .. listView.list[selList[1]].name,
							string.gsub(listView.path, "home:/", "", 1) .. "/" .. fileName)
					end

					listView:refreshList()
					desktop:refresh()
					os.hideMessageBox()
				end
			},

			{caption = "Cancel",
				onClick = function(sender)
					os.hideMessageBox()
				end
			} 

		}, listView.list[selList[1]].name)
	end
end))
table.insert(editMenu.items, widgets.PopupMenu.CreateItem("Delete", function(sender)
	local selList = listView.selectedList
	if #selList > 0 then
		os.messageBox("message", "Are you sure?", "Deleting Files", 
		{ 
			{caption = "Yes", 
				onClick = function(sender)
					for i, v in ipairs(listView.selectedList) do
						fs.delete(string.gsub(listView.path, "home:/", "", 1) .. "/" .. listView.list[v].name)
					end

					listView:refreshList()
					desktop:refresh()
					os.hideMessageBox()
				end
			},

			{caption = "No",
				onClick = function(sender)
					os.hideMessageBox()
				end
			} 

		}, "defText")
	end
end))

local helpMenu = widgets.PopupMenu.Create()
table.insert(helpMenu.items, widgets.PopupMenu.CreateItem("About", function(sender) os.shell.run("winver Explorer") end))



local searchBox = widgets.Edit.Create(desktop, "searchBox")
searchBox.top = 8
searchBox.left = 18
searchBox.width = 14
searchBox.height = 1
searchBox.visible = false
searchBox.text = ""


local searchList = widgets.ListBox.Create(desktop, "searchList")
searchList.top = listView.top
searchList.left = listView.left
searchList.width = listView.width
searchList.height = listView.height
searchList.visible = false
searchList.onMouseClick = function(sender, button, x, y)
	local time = os.time()

	if (time - lastSearchTime) * 10 < config.PROCESS_TIMER then
		if (#(searchList.list) > 0) and (x < sender.left + sender.width - 1) then
			local nav = string.gsub(searchList.list[searchList.index], "//", "/")
			if not fs.isDir(nav) then
				nav = os.extractFilePath(nav)
			end
			if not user.stringstarts(nav, "home:/") then
				nav = "home:/" .. nav
			end

			os.shell.run("explorer.app \"" .. nav .. "\"")
		end
	end

	lastSearchTime = time
end


local searchPanel = widgets.PaintBox.Create(desktop, "searchPanel")
searchPanel.top = listView.height - 10 + 5
searchPanel.left = 0
searchPanel.width = 14
searchPanel.height = 10
searchPanel.bgcolor = colors.blue
searchPanel:refresh()

local MikuSprites = {}
MikuSprites["idle"]    = user.loadCanvas(os.getSystemPath() .. "/assets/Miku/idle.pic")
MikuSprites["s1"]      = user.loadCanvas(os.getSystemPath() .. "/assets/Miku/s1.pic")
MikuSprites["s2"]      = user.loadCanvas(os.getSystemPath() .. "/assets/Miku/s2.pic")
MikuSprites["happy1"]  = user.loadCanvas(os.getSystemPath() .. "/assets/Miku/happy1.pic")
MikuSprites["happy2"]  = user.loadCanvas(os.getSystemPath() .. "/assets/Miku/happy2.pic")
MikuSprites["up"]      = user.loadCanvas(os.getSystemPath() .. "/assets/Miku/up.pic")
MikuSprites["down"]    = user.loadCanvas(os.getSystemPath() .. "/assets/Miku/down.pic")
MikuBalloonPic         = user.loadCanvas(os.getSystemPath() .. "/assets/Miku/balloon.pic")

local MikuEnabled = false
local MikuJustEnabled = false
local MikuShowingBalloon = false
local MikuCurrent = "lifting"  -- "lifting", "idle", "searching", "happy", "comingdown"
local MikuCurrentText = ""
local MikuCurrentWord = 0
local MikuCurrentTextSplit = {}
local MikuPartStr = ""
local MikuCounter = 0
local MikuBeforeActionCounter = 0
local MikuSaying = 0
local MikuGoingToIdle = false
local MikuGoingToExit = false
local oldListViewLeft = 0


listView.onAfterRefresh = function(sender)
	if MikuShowingBalloon then
		if sender.canvas ~= nil then
			sender.canvas:draw(-1, 0, MikuBalloonPic, nil, true, colors.purple)
			sender.canvas:setCursorPos(4, 3)
			sender.canvas.forecolor = colors.black
			sender.canvas:write(MikuPartStr)

			if searchBox.visible then
				desktop.focusedWidget = searchBox
			end
		end
	end
end


searchPanel.mouseClick = function(sender)
	if (MikuCurrent == "idle") and (MikuSaying == 0) then
		MikuCurrent = "happy"
		MikuCounter = 0
		MikuBeforeActionCounter = 0
		MikuShowingBalloon = false
	end

	if (MikuCurrent == "idle") and (MikuSaying == 2) then
		searchBox.visible = false
		desktop.focusedWidget = nil
		MikuShowingBalloon = false
		MikuSaying = 3
		MikuBeforeActionCounter = 0
		MikuCurrent = "searching"

		listView.visible = false
		oldListViewLeft = listView.left

		searchList.top = listView.top
		searchList.left = listView.left
		searchList.width = listView.width
		searchList.height = listView.height

		listView.left = app.canvas.size.x + 2
		searchList.visible = true
		searchBox.visible = false
		desktop.focusedWidget = nil

		if not app:createThread(function()
			local function searchIn(path)
				local list = fs.list(path)
				for i, v in ipairs(list) do
					if string.find(v, searchBox.text) ~= nil then
						searchList:add(path .. "/" .. v)
					end
					coroutine.yield()
					if fs.isDir(path .. "/" .. v) then
						searchIn(path .. "/" .. v)
					end
				end
			end

			MikuSaying = 6
			searchIn("/")
			MikuSaying = 4
			MikuGoingToIdle = true
		end) then error("Unable to create search thread!") end
	end

	if (MikuCurrent == "idle") and (MikuSaying == 4) then
		MikuSaying = 5
		MikuGoingToIdle = false
		MikuGoingToExit = true
		MikuCounter = 0
		MikuCurrent = "happy"
		searchList:clear()
		MikuAnimate()
		searchPanel.visible = false
		MikuBeforeActionCounter = 0
		os.sendMessage(hwnd, {msg = "refresh"})
	end

	--[[if (MikuCurrent == "searching") and MikuSaying == 6 then
		MikuSaying = 5
		MikuGoingToIdle = true
		MikuGoingToExit = false
		MikuCounter = 0
		MikuCurrent = "happy"
		MikuBeforeActionCounter = 0
		app.threads = {}
	end]]
end


function MikuSay(text)
	if text ~= MikuCurrentText then
		MikuCurrentText = text
		MikuCurrentTextSplit = user.split(text, " ")
		MikuCurrentWord = 0
		MikuPartStr = ""
	end

	if MikuCurrentWord < #MikuCurrentTextSplit then
		MikuCurrentWord = MikuCurrentWord + 1
		MikuPartStr = MikuPartStr .. MikuCurrentTextSplit[MikuCurrentWord] .. " "
	end
end


function MikuAnimate()
	if MikuJustEnabled then
		MikuCurrent = "idle"
		MikuCounter = 0
		MikuEnabled = true
		MikuJustEnabled = false
		MikuSaying = 0
	end

	if MikuEnabled then
		if MikuCurrent == "idle" then
			MikuCounter = MikuCounter + 1

			if MikuSaying == 0 then
				if MikuCounter == 1 then
					searchPanel.canvas:clear()
					searchPanel.canvas:draw(0, searchPanel.height - 10, MikuSprites["idle"])
				elseif MikuCounter == 3 then
					MikuShowingBalloon = true
					MikuSay("")
				elseif (MikuCounter >= 5) and (MikuCounter < 12) then
					MikuSay("Hi! I'm Miku.")
				elseif (MikuCounter >= 12) and (MikuCounter < 16) then
					MikuSay("I am here to")
				elseif (MikuCounter >= 16) and (MikuCounter < 22) then
					MikuSay("find files.")
				elseif (MikuCounter >= 22) and (MikuCounter < 25) then
					MikuSay("Click me!")
				end
			end

			if MikuSaying == 1 then
				if MikuCounter == 1 then
					searchPanel.canvas:clear()
					searchPanel.canvas:draw(0, searchPanel.height - 10, MikuSprites["idle"])
				elseif MikuCounter == 3 then
					MikuShowingBalloon = true
					MikuSay("")
				elseif (MikuCounter >= 5) and (MikuCounter < 8) then
					MikuSay("Tell me what")
				elseif (MikuCounter >= 8) and (MikuCounter < 12) then
					MikuSay("should I")
				elseif (MikuCounter >= 12) and (MikuCounter < 17) then
					MikuSay("look for:")
				elseif MikuCounter == 17 then
					searchBox.visible = true
					desktop.focusedWidget = searchBox
					MikuSaying = 2
				end
			end

			if MikuSaying == 4 then
				if MikuCounter == 1 then
					searchPanel.canvas:clear()
					searchPanel.canvas:draw(0, searchPanel.height - 10, MikuSprites["idle"])
				elseif MikuCounter == 3 then
					MikuShowingBalloon = true
					MikuSay("")
				elseif (MikuCounter >= 5) and (MikuCounter < 8) then
					if #(searchList.list) > 0 then
						MikuSay("Look what I found!")
					else
						MikuSay("I found nothing!")
					end
				end
			end
		elseif MikuCurrent == "happy" then
			MikuCounter = MikuCounter + 1
			MikuBeforeActionCounter = MikuBeforeActionCounter + 1

			if MikuBeforeActionCounter == 12 then
				if not MikuGoingToExit then
					MikuBeforeActionCounter = 0
					MikuCounter = 0
					MikuSaying = MikuSaying + 1
					MikuCurrent = "idle"
				else
					MikuGoingToExit = false
					showSearch = false
					os.shell.run("explorer.app \"" .. listView.path .. "\"")
					app:terminate()
					RepositionEverything()
				end
			end

			if MikuCounter == 1 then
				searchPanel.canvas:clear()
				searchPanel.canvas:draw(0, searchPanel.height - 10, MikuSprites["happy1"])
			elseif MikuCounter == 3 then
				searchPanel.canvas:clear()
				searchPanel.canvas:draw(0, searchPanel.height - 10, MikuSprites["happy2"])
			elseif MikuCounter == 5 then
				searchPanel.canvas:clear()
				searchPanel.canvas:draw(0, searchPanel.height - 10, MikuSprites["happy1"])
				MikuCounter = 0
			end
		elseif MikuCurrent == "searching" then
			MikuCounter = MikuCounter + 1

			if MikuCounter == 1 then
				searchPanel.canvas:clear()
			elseif MikuCounter == 2 then
				searchPanel.canvas:clear()
				searchPanel.canvas:draw(0, searchPanel.height - 4, MikuSprites["up"])
			elseif MikuCounter == 3 then
				searchPanel.canvas:clear()
				searchPanel.canvas:draw(0, searchPanel.height - 8, MikuSprites["up"])
			elseif MikuCounter == 4 then
				searchPanel.canvas:clear()
				searchPanel.canvas:draw(0, searchPanel.height - 9, MikuSprites["up"])
			elseif MikuCounter == 5 then
				searchPanel.canvas:clear()
				searchPanel.canvas:draw(0, searchPanel.height - 10, MikuSprites["down"])
			elseif MikuCounter == 6 then
				if MikuGoingToIdle then
					MikuCurrent = "idle"
					MikuCounter = 0
					return nil
				end
				searchPanel.canvas:clear()
				searchPanel.canvas:draw(0, searchPanel.height - 10, MikuSprites["s1"])
			elseif MikuCounter == 10 then
				searchPanel.canvas:clear()
				searchPanel.canvas:draw(0, searchPanel.height - 10, MikuSprites["s2"])
			elseif MikuCounter == 14 then
				searchPanel.canvas:clear()
				searchPanel.canvas:draw(0, searchPanel.height - 10, MikuSprites["s1"])
			elseif MikuCounter == 18 then
				searchPanel.canvas:clear()
				searchPanel.canvas:draw(0, searchPanel.height - 10, MikuSprites["s2"])
			elseif MikuCounter == 22 then
				searchPanel.canvas:clear()
				searchPanel.canvas:draw(0, searchPanel.height - 10, MikuSprites["s1"])
			elseif MikuCounter == 23 then
				searchPanel.canvas:clear()
				searchPanel.canvas:draw(0, searchPanel.height - 9, MikuSprites["down"])
			elseif MikuCounter == 24 then
				searchPanel.canvas:clear()
				searchPanel.canvas:draw(0, searchPanel.height - 8, MikuSprites["down"])
			elseif MikuCounter == 25 then
				searchPanel.canvas:clear()
				searchPanel.canvas:draw(0, searchPanel.height - 4, MikuSprites["down"])
			elseif MikuCounter == 26 then
				searchPanel.canvas:clear()
			elseif MikuCounter >= 30 then
				MikuCounter = 0
			end
		end
	else
		MikuShowingBalloon = false

		if searchList.visible then
			listView.left = oldListViewLeft
			listView.visible = true
			searchList.visible = false
			desktop.focusedWidget = nil
		end

		if searchBox.visible then
			searchBox.visible = false
			desktop.focusedWidget = nil
		end
	end
end



searchPanel.canvas.effect = {
	getbgcolor = function(self, x, y, bgcolor, forecolor, char)
		if bgcolor == colors.white then
			return searchPanel.bgcolor
		end
		if bgcolor == colors.purple then
			return colors.white
		end
		return bgcolor
	end,
	getforecolor = function(self, x, y, bgcolor, forecolor, char)
		return forecolor
	end,
	getchar = function(self, x, y, bgcolor, forecolor, char)
		return char
	end,
}

searchPanel.canvas.bgcolor = colors.blue
--searchPanel.canvas:draw(0, 0, MikuSprites["idle"])



--[[local lblPlaces = widgets.Label.Create(desktop, "lblPlaces")
lblPlaces.top = 5
lblPlaces.left = 1
lblPlaces.width = 14
lblPlaces.height = 1
lblPlaces.bgcolor = colors.white
lblPlaces.caption = "Places:"
lblPlaces.visible = false]]

local popularPlaces = widgets.ListBox.Create(desktop, "popularPlaces")
popularPlaces.top = 5
popularPlaces.left = 0
popularPlaces.width = 14
popularPlaces.height = listView.height - searchPanel.height
popularPlaces.bgcolor = colors.white

places_titles = {}
table.insert(places_titles, "Home")
table.insert(places_titles, "Documents")
table.insert(places_titles, "Desktop")
table.insert(places_titles, "System")
table.insert(places_titles, "ROM")

places_locations = {
	Home = "home:/",
	Documents = "home:/$WIN$/userdata/Documents/",
	Desktop = "home:/$WIN$/userdata/Desktop/",
	System = "home:/$WIN$/",
	ROM = "home:/rom/",
}

for i, v in ipairs(places_titles) do
	popularPlaces:add(v)
end


sides = peripheral.getNames()
for i, v in ipairs(sides) do
	if peripheral.getType(v) == "drive" then
		places_locations[disk.getMountPath(v)] = "home:/" .. disk.getMountPath(v)
		table.insert(places_titles, disk.getMountPath(v))
		popularPlaces:add(disk.getMountPath(v))
	end
end


popularPlaces.onClick = function(sender)
	local time = os.time()

	if (time - lastPlacesTime) * 10 < config.PROCESS_TIMER then
		local nav = string.gsub(places_locations[sender.list[sender.index]], "%$WIN%$", os.getSystemPath())
		listView:navigate(nav)
		listView.selectedList = {}
	end

	lastPlacesTime = time
end



function RepositionEverything()
	if showPlaces or showSearch then
		listView.left = 14
		listView.width = app.canvas.size.x - 13
	else
		listView.left = 1
		listView.width = app.canvas.size.x
	end

	if showPlaces and showSearch then
		searchPanel.top = listView.height - 10 + 5
		searchPanel.height = 10
		searchPanel.visible = true
		popularPlaces.height = listView.height - searchPanel.height
		popularPlaces.visible = true
	else
		if showPlaces then
			searchPanel.visible = false
			popularPlaces.height = listView.height
			popularPlaces.visible = true
		elseif showSearch then
			popularPlaces.visible = false
			searchPanel.top = 5
			searchPanel.height = listView.height
			searchPanel.visible = true
		else
			popularPlaces.visible = false
			searchPanel.visible = false
		end
	end

	if searchPanel.visible and not MikuJustEnabled and not MikuEnabled then
		MikuJustEnabled = true
	end

	if not searchPanel.visible and MikuEnabled then
		MikuEnabled = false
	end

	os.sendMessage(hwnd, {msg = "refresh"})
end


local panelsMenu = widgets.PopupMenu.Create()
table.insert(panelsMenu.items, widgets.PopupMenu.CreateItem("[X] Popular Places",
	function(sender)
		if showPlaces then
			sender.text = "[ ] Popular Places"
		else
			sender.text = "[X] Popular Places"
		end
		showPlaces = not showPlaces
		RepositionEverything()
	end))

table.insert(panelsMenu.items, widgets.PopupMenu.CreateItem("[ ] Search",
	function(sender)
		if showSearch then
			sender.text = "[ ] Search"
		else
			sender.text = "[X] Search"
		end
		showSearch = not showSearch
		RepositionEverything()
	end))


local menu = widgets.MenuBar.Create(desktop, "Menu")
table.insert(menu.items, widgets.MenuBar.CreateItem("File", function(sender) widgets.popupMenu(fileMenu, sender.left, sender.top + 2) end))
table.insert(menu.items, widgets.MenuBar.CreateItem("Edit", function(sender) widgets.popupMenu(editMenu, sender.left, sender.top + 2) end))
table.insert(menu.items, widgets.MenuBar.CreateItem("Window", function(sender) widgets.popupMenu(panelsMenu, sender.left, sender.top + 2) end))
table.insert(menu.items, widgets.MenuBar.CreateItem("Help", function(sender) widgets.popupMenu(helpMenu, sender.left, sender.top + 2) end))

RepositionEverything()


if params[2] ~= nil then
	listView:navigate(params[2])
else
	listView:navigate("home:/")
end



local lastTimerTime = os.time()
local delta = 0.05

local function timerRefresh()
	if lastTimerTime > 0 then
		delta = 0.25 / ((os.time() - lastTimerTime) * 60 * 6 * 6)
		--error(tostring(delta))
		--app:showMessage(tostring(delta), "")
	end

	os.startTimer(delta, timerRefresh)
	MikuAnimate()
	if MikuEnabled then
		os.sendMessage(hwnd, {msg = "refresh"})
	end
	lastTimerTime = os.time()
end

os.startTimer(0.05, timerRefresh)

app:run()