local app = application.Create(os.getProcessInfo(os.getCurrentProcess()), os)
local desktop = form.Create("Setup Wizard")


local lang = "EN-US"
local locale = iniFiles.read(os.getSystemPath() .. "/locale/" .. lang .. "/setup.ini").locale
local installing = false
local uninstalling = false

local setup = nil
if params[2] == nil then
	error(locale["30"])
	--setup = iniFiles.read("home:/Temp/Setup/setup.ini")
else
	fs.delete("/temp/")
	--error("ncvm \"" .. params[2] .. "\" \"/Temp/\"")
	local handler = os.shell.run("ncvm \"" .. params[2] .. "\" \"/Temp/\"")
	local running = true

	while running do
		coroutine.yield()
		local ls = os.getValidHWNDList()
		local found = false
		for k, v in pairs(ls) do
			if v == handler then
				found = true
			end
		end

		if not found then
			running = false
			os.setActiveProcess(hwnd)
		end
	end

	setup = iniFiles.read("home:/Temp/setup.ini")
end

setup.components.show = "false"

if params[3] == "-uninstall" then
	uninstalling = true
	setup.license.show = "false"
	setup.path.show = "false"
	setup.components.show = "false"
end



local function expandVars(s, p)
	local function getProgramPath()
		return "home:/Programs/"
	end

	local vars = {
		["%%APPNAME%%"]          = setup.application.name,
		["%%VERSION%%"]          = setup.application.version,
		["%%COMPANY%%"]          = setup.application.company,
		["%%PROGRAM%%"]          = getProgramPath(),
		["%%BLINDLY%%"]          = " ",
		["%%DESKTOP%%"]          = os.getSystemPath() .. "/userdata/Desktop/",
		["%%DOCUMENTS%%"]        = os.getSystemPath() .. "/userdata/Documents/",
		["%%PROGRAM_GROUPS%%"]   = os.getSystemPath() .. "/userdata/ProgramGroups/",
		["%%PROGRAMS%%"]         = os.getSystemPath() .. "/userdata/ProgramGroups/Programs/",
		["%%SETTINGS%%"]         = os.getSystemPath() .. "/userdata/ProgramGroups/Settings/",
		["%%SYSTEM%%"]           = os.getSystemPath(),
		["%%DRIVERS%%"]          = os.getSystemPath() .. "/drivers/",
		["%%SYSTEM_MODULES%%"]   = os.getSystemPath() .. "/system/",
		["%%SYSTEM_FILES%%"]     = os.getSystemPath() .. "/system2/",
		["%%CRAFTOS%%"]          = os.getSystemPath() .. "/sysWoW/",
	}

	if not p then vars["%%PATH%%"] = expandVars(setup.application.path, true) end
	if setup.license.blindly == "true" then vars["%%BLINDLY%%"] = " blindly " end

	for k, v in pairs(vars) do
		s = string.gsub(s, k, v)
	end

	return s
end
	



local frmStart = form.Create("Welcome")
app:addForm(frmStart, "Welcome")

local lbl1 = widgets.Label.Create(frmStart, "lbl1")
lbl1.left = 2
lbl1.top = 7
lbl1.caption = expandVars(locale["3"])
lbl1.width = app.canvas.size.x - 2
lbl1.height = 1

local lbl2 = widgets.Label.Create(frmStart, "lbl2")
lbl2.left = 2
lbl2.top = 9
lbl2.caption = expandVars(locale["4"])
lbl2.width = app.canvas.size.x - 2
lbl2.height = 1

local lbl3 = widgets.Label.Create(frmStart, "lbl3")
lbl3.left = 2
lbl3.top = 10
lbl3.caption = expandVars(locale["5"])
lbl3.width = app.canvas.size.x - 2
lbl3.height = 1

local lbl4 = widgets.Label.Create(frmStart, "lbl4")
lbl4.left = 2
lbl4.top = 12
lbl4.caption = expandVars(locale["6"])
lbl4.width = app.canvas.size.x - 2
lbl4.height = 1

local picHeader1 = widgets.PaintBox.Create(frmStart, "picHeader")
picHeader1.left = 0
picHeader1.top = 1
picHeader1.width = app.canvas.size.x + 1
picHeader1.height = 5
picHeader1:refresh()
if fs.exists("/Temp/" .. setup["application"].header) then
	local canvas = user.loadCanvas("home:/Temp/" .. setup.application.header):scale(picHeader1.width, picHeader1.height)
	picHeader1.canvas:draw(0, 0, canvas)
end

local btnNext = widgets.Button.Create(frmStart, "btnNext")
btnNext.width = 9
btnNext.left = app.canvas.size.x - btnNext.width
btnNext.top = app.canvas.size.y - 2
btnNext.caption = expandVars(locale["1"])

local btnBack = widgets.Button.Create(frmStart, "btnBack")
btnBack.width = 9
btnBack.left = 2
btnBack.top = app.canvas.size.y - 2
btnBack.caption = expandVars(locale["7"])

btnBack.onClick = function(sender)
	os.messageBox("message", expandVars(locale["8"]), expandVars(locale["9"]), 
		{ 
			{caption = expandVars(locale["11"]), 
				onClick = function(sender)
					os.hideMessageBox()
				end
			},
			{caption = expandVars(locale["10"]), 
				onClick = function(sender)
					app:terminate()
				end
			},
		}, "defText")
end

local frmLicense = form.Create("License Agreement")
app:addForm(frmLicense, "License Agreement")

local frmPath = form.Create("Installation Path")
app:addForm(frmPath, "Installation Path")

local frmComponents = form.Create("Installation Components")
app:addForm(frmComponents, "Installation Components")

local frmReady = form.Create("Ready")
app:addForm(frmReady, "Ready")

local frmProgress = form.Create("Installation in progress...")
app:addForm(frmProgress, "Installation in progress...")

local frmSuccess = form.Create("Installation Complete")
app:addForm(frmSuccess, "Installation Complete")

local lblStatus = widgets.Label.Create(frmProgress, "lblStatus")
lblStatus.left = 2
lblStatus.top = 12
lblStatus.caption = ""
lblStatus.width = app.canvas.size.x - 2
lblStatus.height = 1

local pbProgress = widgets.ProgressBar.Create(frmProgress, "pbProgress")
pbProgress.left = 2
pbProgress.top = 10
pbProgress.caption = ""
pbProgress.width = app.canvas.size.x - 2
pbProgress.height = 1

btnNext.onClick = function(sender)
	if uninstalling then
		frmProgress:show()

		app:createThread(function()
			local function uninstallPackage(name)
				local function countFiles(path)
					local result = 0
					local ls = fs.list(tostring(string.gsub(path, "home:/", "")))
					pbProgress.max = #ls
					pbProgress.position = 0
					coroutine.yield()

					for i, v in ipairs(ls) do
						if (v ~= ".") and (v ~= "..") then
							if fs.isDir(tostring(string.gsub(path, "home:/", "") .. "/" .. v)) then
								result = result + countFiles(path .. "/" .. v)
							else
								result = result + 1
								pbProgress.position = pbProgress.position + 1
								coroutine.yield()
							end
						end
					end
					return result
				end

				local function copyFiles(parent, path)
					local fullPath = tostring(string.gsub(parent .. "/" .. path, "home:/", ""))
					local ls = fs.list(fullPath)
					for k, v in pairs(ls) do
						if fs.isDir(fullPath .. "/" .. v) then
							copyFiles(parent, path .. "/" .. v)
						else
							local copyTo = tostring(string.gsub(expandVars("%PATH%"), "home:/", "/"))
							fs.makeDir(copyTo .. "/" .. path)

							local status, message = pcall(function()
								fs.delete(copyTo .. "/" .. path .. "/" .. v)
							end)

							pbProgress.position = pbProgress.position + 1
							coroutine.yield()
						end
					end
				end

				lblStatus.caption = expandVars(locale["31"])
				
				local package = iniFiles.read("home:/Temp/" .. name .. "/package.ini")
				local total = countFiles("home:/Temp/" .. name .. "/data/")

				pbProgress.max = total
				pbProgress.position = 0
				lblStatus.caption = ""
				coroutine.yield()

				lblStatus.caption = expandVars(locale["32"])
				copyFiles("home:/Temp/" .. name .. "/data", "/")
				lblStatus.caption = ""
				coroutine.yield()

				pbProgress.position = 0
				lblStatus.caption = expandVars(locale["32"])
				coroutine.yield()

				local shortcuts = iniFiles.read("home:/Temp/" .. name .. "/shortcuts.ini")
				pbProgress.max = 0
				for k, v in pairs(shortcuts) do
					pbProgress.max = pbProgress.max + 1
				end

				for k, v in pairs(shortcuts) do
					fs.delete(expandVars(v.location))
				end

			end

			installing = true
			uninstallPackage(setup.components.default)

			pbProgress.position = 0
			lblStatus.caption = ""
			coroutine.yield()

			for k, v in pairs(setup.extentions) do
				os.setRegistryKeyValue("extensions", k, "")
			end

			os.setRegistryKeyValue("installed", setup.application.name .. " " .. setup.application.version, nil)

			frmSuccess:show()
			coroutine.yield()
			installing = false
		end)
	else
		if setup.license.show == "true" then
			frmLicense:show()
		else
			if setup.path.show == "true" then
				frmPath:show()
			else
				if setup.components.show == "true" then
					frmComponents:show()
				else
					frmReady:show()
				end
			end
		end
	end
end




local txtLicense = widgets.TextArea.Create(frmLicense, "txtLicense", widgets)
txtLicense.left = 2
txtLicense.top = 2
txtLicense.height = app.canvas.size.y - 7
txtLicense.width = app.canvas.size.x - 2
txtLicense.text = ""

if fs.exists("/Temp/" .. setup.license.file) then
	local file = fs.open("/Temp/" .. setup.license.file, "r")
	txtLicense.text = file.readAll()
	file.close()
end

local chkAccept = widgets.CheckBox.Create(frmLicense, "chkAccept")
chkAccept.left = 2
chkAccept.top = txtLicense.height + 3
chkAccept.width = app.canvas.size.x - 2
chkAccept.caption = expandVars(locale["12"])
chkAccept.checked = false

local btnNext = widgets.Button.Create(frmLicense, "btnNext")
btnNext.width = 9
btnNext.left = app.canvas.size.x - btnNext.width
btnNext.top = app.canvas.size.y - 2
btnNext.caption = expandVars(locale["1"])

local btnBack = widgets.Button.Create(frmLicense, "btnBack")
btnBack.width = 9
btnBack.left = 2
btnBack.top = app.canvas.size.y - 2
btnBack.caption = expandVars(locale["2"])

btnBack.onClick = function(sender)
	frmStart:show()
end

btnNext.onClick = function(sender)
	if chkAccept.checked then
		if setup.path.show == "true" then
			frmPath:show()
		else
			if setup.components.show == "true" then
				frmComponents:show()
			else
				frmReady:show()
			end
		end
	else
		os.messageBox("message", expandVars(locale["13"]), expandVars(locale["14"]), 
			{ 
				{caption = expandVars(locale["15"]), 
					onClick = function(sender)
						os.hideMessageBox()
					end
				},
			}, "defText")
	end
end



local openDialog = widgets.dialogs.OpenDialog.Create(frmPath, "OpenDialog")
openDialog.dirOnly = true

openDialog.onExecute = function(sender)
	sender.parent.widgets.txtPath.text = sender.fileName or sender.parent.widgets.txtPath.text
	os.sendMessage(hwnd, {msg = "refresh"})
end

local picHeader1 = widgets.PaintBox.Create(frmPath, "picHeader")
picHeader1.left = 0
picHeader1.top = 1
picHeader1.width = app.canvas.size.x + 1
picHeader1.height = 5
picHeader1:refresh()
if fs.exists("/Temp/" .. setup["application"].header) then
	local canvas = user.loadCanvas("home:/Temp/" .. setup.application.header):scale(picHeader1.width, picHeader1.height)
	picHeader1.canvas:draw(0, 0, canvas)
end

local lbl1 = widgets.Label.Create(frmPath, "lbl1")
lbl1.left = 2
lbl1.top = 9
lbl1.caption = expandVars(locale["16"])
lbl1.width = app.canvas.size.x - 2
lbl1.height = 1

local txtPath = widgets.Edit.Create(frmPath, "txtPath")
txtPath.width = app.canvas.size.x - 6
txtPath.left = 2
txtPath.top = 11
txtPath.text = expandVars("%PATH%")

local btnBrowse = widgets.Button.Create(frmPath, "btnBrowse")
btnBrowse.width = 2
btnBrowse.left = app.canvas.size.x - btnBrowse.width
btnBrowse.top = 11
btnBrowse.forecolor2 = btnBrowse.forecolor
btnBrowse.caption = ".."
btnBrowse.onClick = function(sender)
	openDialog:execute()
end

if setup.path.editable == "false" then
	btnBrowse.visible = false
	txtPath.editable = false
	txtPath.width = txtPath.width + 4
end

local btnNext = widgets.Button.Create(frmPath, "btnNext")
btnNext.width = 9
btnNext.left = app.canvas.size.x - btnNext.width
btnNext.top = app.canvas.size.y - 2
btnNext.caption = expandVars(locale["1"])

local btnBack = widgets.Button.Create(frmPath, "btnBack")
btnBack.width = 9
btnBack.left = 2
btnBack.top = app.canvas.size.y - 2
btnBack.caption = expandVars(locale["2"])

btnBack.onClick = function(sender)
	if setup.license.show == "true" then
		frmLicense:show()
	else
		frmStart:show()
	end
end

btnNext.onClick = function(sender)
	if setup.components.show == "true" then
		frmComponents:show()
	else
		frmReady:show()
	end
end




local picHeader1 = widgets.PaintBox.Create(frmComponents, "picHeader")
picHeader1.left = 0
picHeader1.top = 1
picHeader1.width = app.canvas.size.x + 1
picHeader1.height = 5
picHeader1:refresh()
if fs.exists("/Temp/" .. setup["application"].header) then
	local canvas = user.loadCanvas("home:/Temp/" .. setup.application.header):scale(picHeader1.width, picHeader1.height)
	picHeader1.canvas:draw(0, 0, canvas)
end

local lstComponents = widgets.ListBox.Create(frmComponents, "lstComponents", widgets)
lstComponents.left = 0
lstComponents.top = 7
lstComponents.height = app.canvas.size.y - 14
lstComponents.width = app.canvas.size.x + 1
lstComponents.checkBoxes = true




local picHeader1 = widgets.PaintBox.Create(frmReady, "picHeader")
picHeader1.left = 0
picHeader1.top = 1
picHeader1.width = app.canvas.size.x + 1
picHeader1.height = 5
picHeader1:refresh()
if fs.exists("/Temp/" .. setup["application"].header) then
	local canvas = user.loadCanvas("home:/Temp/" .. setup.application.header):scale(picHeader1.width, picHeader1.height)
	picHeader1.canvas:draw(0, 0, canvas)
end

local lbl1 = widgets.Label.Create(frmReady, "lbl1")
lbl1.left = 2
lbl1.top = 7
lbl1.caption = expandVars(locale["17"])
lbl1.width = app.canvas.size.x - 2
lbl1.height = 1

local lbl2 = widgets.Label.Create(frmReady, "lbl2")
lbl2.left = 2
lbl2.top = 9
lbl2.caption = expandVars(locale["19"])
lbl2.width = app.canvas.size.x - 2
lbl2.height = 1

local lbl3 = widgets.Label.Create(frmReady, "lbl3")
lbl3.left = 2
lbl3.top = 10
lbl3.caption = expandVars(locale["20"])
lbl3.width = app.canvas.size.x - 2
lbl3.height = 1

local lbl4 = widgets.Label.Create(frmReady, "lbl4")
lbl4.left = 2
lbl4.top = 12
lbl4.caption = expandVars(locale["18"])
lbl4.width = app.canvas.size.x - 2
lbl4.height = 1


--frmProgress.controlBox = false

local btnNext = widgets.Button.Create(frmReady, "btnNext")
btnNext.width = 9
btnNext.left = app.canvas.size.x - btnNext.width
btnNext.top = app.canvas.size.y - 2
btnNext.caption = expandVars(locale["1"])

local btnBack = widgets.Button.Create(frmReady, "btnBack")
btnBack.width = 9
btnBack.left = 2
btnBack.top = app.canvas.size.y - 2
btnBack.caption = expandVars(locale["2"])

btnBack.onClick = function(sender)
	if setup.components.show == "true" then
		frmComponents:show()
	else
		if setup.path.show == "true" then
			frmPath:show()
		else
			if setup.license.show == "true" then
				frmLicense:show()
			else
				frmStart:show()
			end
		end
	end
end


local picHeader1 = widgets.PaintBox.Create(frmProgress, "picHeader")
picHeader1.left = 0
picHeader1.top = 1
picHeader1.width = app.canvas.size.x + 1
picHeader1.height = 5
picHeader1:refresh()
if fs.exists("/Temp/" .. setup["application"].header) then
	local canvas = user.loadCanvas("home:/Temp/" .. setup.application.header):scale(picHeader1.width, picHeader1.height)
	picHeader1.canvas:draw(0, 0, canvas)
end









btnNext.onClick = function(sender)
	frmProgress:show()

	app:createThread(function()
		local function installPackage(name)
			local function countFiles(path)
				local result = 0
				local ls = fs.list(tostring(string.gsub(path, "home:/", "")))
				pbProgress.max = #ls
				pbProgress.position = 0
				coroutine.yield()

				for i, v in ipairs(ls) do
					if (v ~= ".") and (v ~= "..") then
						if fs.isDir(tostring(string.gsub(path, "home:/", "") .. "/" .. v)) then
							result = result + countFiles(path .. "/" .. v)
						else
							result = result + 1
							pbProgress.position = pbProgress.position + 1
							coroutine.yield()
						end
					end
				end
				return result
			end

			local function copyFiles(parent, path)
				local fullPath = tostring(string.gsub(parent .. "/" .. path, "home:/", ""))
				local ls = fs.list(fullPath)
				for k, v in pairs(ls) do
					if fs.isDir(fullPath .. "/" .. v) then
						copyFiles(parent, path .. "/" .. v)
					else
						local copyTo = tostring(string.gsub(expandVars("%PATH%"), "home:/", "/"))
						fs.makeDir(copyTo .. "/" .. path)

						local status, message = pcall(function()
							fs.copy(fullPath .. "/" .. v, copyTo .. "/" .. path .. "/" .. v)
						end)
						if not status then
							if string.find(message, "exist") and setup.application.override == "true" then
								fs.delete(copyTo .. "/" .. path .. "/" .. v)
								fs.copy(fullPath .. "/" .. v, copyTo .. "/" .. path .. "/" .. v)
							end
						end

						pbProgress.position = pbProgress.position + 1
						coroutine.yield()
					end
				end
			end

			lblStatus.caption = expandVars(locale["21"])
			
			local package = iniFiles.read("home:/Temp/" .. name .. "/package.ini")
			local total = countFiles("home:/Temp/" .. name .. "/data/")

			pbProgress.max = total
			pbProgress.position = 0
			lblStatus.caption = ""
			coroutine.yield()

			lblStatus.caption = expandVars(locale["22"])
			copyFiles("home:/Temp/" .. name .. "/data", "/")
			lblStatus.caption = ""
			coroutine.yield()

			pbProgress.position = 0
			lblStatus.caption = expandVars(locale["29"])
			coroutine.yield()

			local shortcuts = iniFiles.read("home:/Temp/" .. name .. "/shortcuts.ini")
			pbProgress.max = 0
			for k, v in pairs(shortcuts) do
				pbProgress.max = pbProgress.max + 1
			end

			for k, v in pairs(shortcuts) do
				local shortcut = {
					shortcut = {
						file = expandVars(v.path),
						icon = expandVars(v.icon),
					}
				}
				iniFiles.write(expandVars(v.location), shortcut)
				pbProgress.position = pbProgress.position + 1
				coroutine.yield()
			end

		end

		installing = true
		installPackage(setup.components.default)

		pbProgress.position = 0
		lblStatus.caption = ""
		coroutine.yield()

		for k, v in pairs(setup.extentions) do
			os.setRegistryKeyValue("extensions", k, v)
		end

		os.setRegistryKeyValue(
			"installed", setup.application.name .. " " .. setup.application.version, setup.run_installed.cmd
		)

		if setup.application.uninstall then
			local s = setup.application.name .. " " .. setup.application.version .. ".wpk"
			if fs.exists(tostring(string.gsub(os.getSystemPath() .. "/setup/" .. s, "home:/", ""))) then
				fs.delete(tostring(string.gsub(os.getSystemPath() .. "/setup/" .. s, "home:/", "")))
			end

			fs.copy(
				tostring(string.gsub(params[2], "home:/", "")),
				tostring(string.gsub(os.getSystemPath() .. "/setup/" .. s, "home:/", ""))
			)

			os.setRegistryKeyValue("uninstall", setup.application.name .. " " .. setup.application.version, s)
		end

		if setup.after.run == "true" then
			os.shell.run(setup.after.cmd)
		end

		frmSuccess:show()
		coroutine.yield()
		installing = false
	end)
end



local picHeader1 = widgets.PaintBox.Create(frmSuccess, "picHeader")
picHeader1.left = 0
picHeader1.top = 1
picHeader1.width = app.canvas.size.x + 1
picHeader1.height = 5
picHeader1:refresh()
if fs.exists("/Temp/" .. setup["application"].header) then
	local canvas = user.loadCanvas("home:/Temp/" .. setup.application.header):scale(picHeader1.width, picHeader1.height)
	picHeader1.canvas:draw(0, 0, canvas)
end

local lbl1 = widgets.Label.Create(frmSuccess, "lbl1")
lbl1.left = 2
lbl1.top = 7
lbl1.caption = expandVars(locale["24"])
lbl1.width = app.canvas.size.x - 2
lbl1.height = 1

local lbl2 = widgets.Label.Create(frmSuccess, "lbl2")
lbl2.left = 2
lbl2.top = 8
lbl2.caption = expandVars(locale["25"])
lbl2.width = app.canvas.size.x - 2
lbl2.height = 1

local chkRun = widgets.CheckBox.Create(frmSuccess, "chkRun")
chkRun.left = 2
chkRun.top = 11
chkRun.caption = expandVars(locale["27"])
chkRun.width = app.canvas.size.x - 2
chkRun.height = 1
chkRun.checked = setup.run_installed.checked == "true"

local chkReadme = widgets.CheckBox.Create(frmSuccess, "chkReadme")
chkReadme.left = 2
chkReadme.top = 13
chkReadme.caption = expandVars(locale["28"])
chkReadme.width = app.canvas.size.x - 2
chkReadme.height = 1
chkReadme.checked = setup.show_readme.checked == "true"

if setup.run_installed.show == "false" then
	chkRun.visible = false
	chkReadme.top = 11
end

if setup.show_readme.show == "false" then
	chkReadme.visible = false
end

if uninstalling then
	chkRun.visible = false
	chkReadme.visible = false
end



local btnNext = widgets.Button.Create(frmSuccess, "btnNext")
btnNext.width = 9
btnNext.left = app.canvas.size.x - btnNext.width
btnNext.top = app.canvas.size.y - 2
btnNext.caption = expandVars(locale["26"])

btnNext.onClick = function(sender)
	if chkRun.visible and chkRun.checked then
		os.shell.run(expandVars(setup.run_installed.cmd))
	end

	if chkReadme.visible and chkReadme.checked then
		os.shell.run(expandVars(setup.show_readme.cmd))
	end

	fs.delete("/temp/")
	app:terminate()
end




local frmFailure = form.Create("Installation Failed")
app:addForm(frmFailure, "Installation Failed")



os.startTimer(0.01, function() if installing then os.sendMessage(hwnd, {msg = "refresh"}) end end)


app.activeForm = frmStart
app:run()