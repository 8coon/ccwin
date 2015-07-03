local app = application.Create(os.getProcessInfo(os.getCurrentProcess()), os)
local mainForm = form.Create("LUA Editor")
local currentFileName = ""
local commandArgs = ""


app:addForm(mainForm, "LUA Editor")
mainForm:show()
mainForm.bgcolor = colors.black


local textArea = widgets.TextArea.Create(mainForm, "textArea", widgets)
textArea.left = 1
textArea.top = 2
textArea.height = app.canvas.size.y - 2
textArea.width = app.canvas.size.x
textArea.text = ""
textArea.bgcolor = colors.black
textArea.forecolor = colors.white



function SyntaxHighlighter_Create()
	local charList = {}
	charList["+"] = true
	charList["-"] = true
	charList["*"] = true
	charList["/"] = true
	charList["="] = true
	charList["~"] = true
	charList[">"] = true
	charList["<"] = true


	local keyList = {}
	keyList["function"] = false
	keyList["if"] = false
	keyList["then"] = false
	keyList["return"] = false
	keyList["end"] = false
	keyList["elseif"] = false
	keyList["else"] = false
	keyList["local"] = false
	keyList["_G"] = false
	keyList["for"] = false
	keyList["in"] = false
	keyList["do"] = false
	keyList["repeat"] = false
	keyList["until"] = false
	keyList["while"] = false
	keyList[".."] = false
	keyList["and"] = false
	keyList["or"] = false
	keyList["not"] = false


	stringConstChars = {}
	stringConstChars["\""] = true
	stringConstChars["\'"] = true


	local numChars = {}
	numChars["0"] = true
	numChars["1"] = true
	numChars["2"] = true
	numChars["3"] = true
	numChars["4"] = true
	numChars["5"] = true
	numChars["6"] = true
	numChars["7"] = true
	numChars["8"] = true
	numChars["9"] = true



	local otherChars = {}
	otherChars["."] = true
	otherChars[":"] = true
	otherChars["("] = true
	otherChars[")"] = true
	otherChars["{"] = true
	otherChars["}"] = true
	otherChars["["] = true
	otherChars["]"] = true
	otherChars["\\"] = true	


	local highlighter = {
		specialChars = {
			list = charList,
			bgcolor = colors.black,
			forecolor = colors.red,			
		},

		keyWords = {
			list = keyList,
			bgcolor = colors.black,
			forecolor = colors.red,
		},

		stringConsts = {
			list = stringConstChars,
			bgcolor = colors.black,
			forecolor = colors.yellow,
		},

		comments = {
			bgcolor = colors.black,
			forecolor = colors.gray,
		},

		numbers = {
			list = numChars,
			bgcolor = colors.black,
			forecolor = colors.purple,
		},

		others = {
			list = otherChars,
			bgcolor = colors.black,
			forecolor = colors.lightGray,
		},

		commentOpened = false,
		bracketOpened = false,
		bogCommentOpened = false,
		bigBracketOpened = false,
		echoed = false,
		highlightCanvas = nil,

		scrolling = {
			left = 0,
			top = 0,
		},



		getWordColor = function(self, word)
			if self.keyWords.list[word] ~= nil then
				return self.keyWords.forecolor
			else
				return nil
			end
		end,


		getStringConstColor = function(self, word)
			if user.stringstarts(word, "[[") then
				self.bigBracketOpened = true
			end

			if user.stringends(word, "]]") then
				self.bigBracketOpened = false
			end


			if self.bigBracketOpened then
				return self.stringConsts.forecolor
			end
		end,


		getCommentColor = function(self, word)
			if (not self.commentOpened) or (not self.bigCommentOpened) then
				if user.stringstarts(word, "--") then
					self.commentOpened = true
				end
			end

			if self.commentOpened or self.bigCommentOpened then
				return self.comments.forecolor
			end
		end,


		countSpaces = function(self, str)
			local index = 1

			if string.sub(str, index, index) == " " then
				repeat
					index = index + 1
				until not (string.sub(str, index, index) == " ")
			end

			return index
		end,



		parseAreaData = function(self, areaData, forecolor, sizeX, sizeY)
			self.highlightCanvas = user.CreateCanvas(256, #areaData)
			self.bigBracketOpened = false



			for i = self.scrolling.top, self.scrolling.top + sizeY do
				local v = areaData[i] or ""
				local line = string.gsub(string.gsub(string.gsub(v, "\t", " "), "\r", ""), "\0", "")
				local left = self:countSpaces(line)
				line = string.sub(line, left)
				local words = user.split(line, " ")
				--self.bracketOpened = false
				self.commentOpened = false


				for j, word in ipairs(words) do
					self.highlightCanvas.bgcolor = self:getCommentColor(word) or self:getStringConstColor(word) or self:getWordColor(word) or forecolor
					self.highlightCanvas:setCursorPos(left, i)
					self.highlightCanvas:write(word)

					left = left + string.len(word) + 1
				end
			end
		end,


		setScrolling = function(self, scrolling)
			self.scrolling = scrolling
		end,


		getbgcolor = function(self, x, y, bgcolor, forecolor, char)
			if (self.bracketOpened) or (self.stringConsts.list[char] ~= nil)  then
				return self.stringConsts.bgcolor
			else
				if self.specialChars.list[char] ~= nil then
					return self.specialChars.bgcolor
				else
					return bgcolor
				end
			end
		end,


		getforecolor = function(self, x, y, bgcolor, forecolor, char)
			local x = x + self.scrolling.left - 1
			local y = y + self.scrolling.top

			if (self.highlightCanvas ~= nil) and (self.highlightCanvas.data[y] ~= nil) and (self.highlightCanvas.data[y][x] ~= nil) then
				if self.highlightCanvas.data[y][x].bgcolor ~= forecolor then
					return self.highlightCanvas.data[y][x].bgcolor
				else
					if ((self.bracketOpened) or (self.stringConsts.list[char] ~= nil)) then
						return self.stringConsts.forecolor
					end
				end
			end

			if self.specialChars.list[char] ~= nil then
				return self.specialChars.forecolor
			elseif self.numbers.list[char] ~= nil then
				return self.numbers.forecolor
			elseif self.others.list[char] ~= nil then
				return self.others.forecolor
			else
				return forecolor
			end
		end,


		getchar = function(self, x, y, bgcolor, forecolor, char)
			if x == 1 then self.bracketOpened = false end

			if char == "\\" then
				self.echoed = true
			end


			if (self.stringConsts.list[char] ~= nil) and (not (self.echoed)) then
				if self.bracketOpened then self.bracketOpened = false else self.bracketOpened = true end
			end

			self.echoed = false
			return char
		end,
	}

	return highlighter
end




textArea.syntaxHighlighter = SyntaxHighlighter_Create()




function loadFile(fileName)
	local file = fs.open(fileName, "r")
	local text = ""

	if file ~= nil then
		text = file.readAll()
		file.close()
	end

	currentFileName = fileName
	mainForm.name = "[" .. fileName .. "] - LUA Editor"
	os.sendMessage(hwnd, {msg = "refresh"})

	textArea:setText(text)
	textArea:refresh()
end


function saveFile(fileName)
	local file = fs.open(fileName, "w")
	local text = textArea:getText()

	if file ~= nil then
		file.write(text)
		file.close()
	end

	currentFileName = fileName
	mainForm.name = "[" .. fileName .. "] - LUA Editor"
end


function loadArgs()
	local settings = iniFiles.read(os.getSystemPath() .. "/system2/luaedit.ini") or {}
	local debug = settings.debug or { args = "" }

	commandArgs = debug.args

	settings.debug = debug
	iniFiles.write(os.getSystemPath() .. "/system2/luaedit.ini", settings)
end


function saveArgs()
	local settings = iniFiles.read(os.getSystemPath() .. "/system2/luaedit.ini") or {}
	local debug = settings.debug or { args = commandArgs }

	settings.debug = debug
	iniFiles.write(os.getSystemPath() .. "/system2/luaedit.ini", settings)
end






local saveDialog = widgets.dialogs.SaveDialog.Create(mainForm, "SaveDialog")

saveDialog.onExecute = function(sender)
	local fileName = string.gsub(sender.fileName, "home:/", "", 1)
	saveFile(fileName)
end



local openDialog = widgets.dialogs.OpenDialog.Create(mainForm, "OpenDialog")

openDialog.onExecute = function(sender)
	local fileName = string.gsub(sender.fileName, "home:/", "", 1)
	loadFile(fileName)
end



function file_newClick()
	os.shell.run("notepad")
	app:terminate()
end

function file_openClick()
	openDialog:execute()
end

function file_saveClick()
	if currentFileName ~= "" then
		saveFile(currentFileName)
	else
		saveDialog:execute()
	end
end

function file_saveAsClick()
	saveDialog:execute()
end

function file_exitClick()
	app:terminate()
end




local fileMenu = widgets.PopupMenu.Create()
table.insert(fileMenu.items, widgets.PopupMenu.CreateItem("New", function(sender) file_newClick() end))
table.insert(fileMenu.items, widgets.PopupMenu.CreateItem("Open", function(sender) file_openClick() end))
table.insert(fileMenu.items, widgets.PopupMenu.CreateItem("Save", function(sender) file_saveClick() end))
table.insert(fileMenu.items, widgets.PopupMenu.CreateItem("-", nil))
table.insert(fileMenu.items, widgets.PopupMenu.CreateItem("Save As..", function(sender) file_saveAsClick() end))
table.insert(fileMenu.items, widgets.PopupMenu.CreateItem("-", nil))
table.insert(fileMenu.items, widgets.PopupMenu.CreateItem("Exit", function(sender) file_exitClick() end))


local runMenu = widgets.PopupMenu.Create()
table.insert(runMenu.items, widgets.PopupMenu.CreateItem("Run", function(sender)
	if currentFileName ~= "" then
		saveFile(currentFileName)
	else
		saveDialog:execute()
	end

	os.shell.run(currentFileName .. " " .. commandArgs)
end))

table.insert(runMenu.items, widgets.PopupMenu.CreateItem("-", nil))

table.insert(runMenu.items, widgets.PopupMenu.CreateItem("Command line arguments", function(sender)
	os.messageBox("input", "Command line argunemts:", "Run", 
		{ 
			{caption = "OK", 
				onClick = function(sender)
					commandArgs = sender.parent.widgets.edit.text
					saveArgs()
					os.hideMessageBox()
				end
			},

			{caption = "Cancel", 
				onClick = function(sender)
					os.hideMessageBox()
				end
			},
		}, commandArgs)
end))



local helpMenu = widgets.PopupMenu.Create()
table.insert(helpMenu.items, widgets.PopupMenu.CreateItem("About", function(sender) os.shell.run("winver \"LUA Editor\"") end))


local menu = widgets.MenuBar.Create(mainForm, "Menu")
table.insert(menu.items, widgets.MenuBar.CreateItem("File", function(sender) widgets.popupMenu(fileMenu, sender.left, sender.top + 2) end))
table.insert(menu.items, widgets.MenuBar.CreateItem("Run", function(sender) widgets.popupMenu(runMenu, sender.left, sender.top + 2) end))
table.insert(menu.items, widgets.MenuBar.CreateItem("Help", function(sender) widgets.popupMenu(helpMenu, sender.left, sender.top + 2) end))








if params[2] ~= nil then
	loadFile(string.gsub(params[2], "home:/", "", 1))
end

loadArgs()



os.startTimer(5, function()
	textArea:refresh(true)
	os.sendMessage(hwnd, {msg = "refresh"})
end )
app:run()