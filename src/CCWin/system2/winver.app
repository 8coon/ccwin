function CreateEffect(speed)
	local effect = {
		getbgcolor = function(self, x, y, bgcolor, forecolor, char)
			if bgcolor == colors.purple then
				return colors.white
			else
				return bgcolor
			end
		end,

		getforecolor = function(self, x, y, bgcolor, forecolor, char)
			return forecolor
		end,

		getchar = function(self, x, y, bgcolor, forecolor, char)
			return char
		end,
	}

	return effect
end




local app = application.Create(os.getProcessInfo(os.getCurrentProcess()), os)
local frmMain = form.Create("About CCWin...")
local sys_ver = os.getVersion()

app:addForm(frmMain, "About CCWin...")
frmMain:show()



local logo = widgets.PaintBox.Create(frmMain, "logo")
local logoImg = user.loadCanvas(os.getSystemPath() .. "/logo.pic")  --assets/Miku/idle.pic
logo.height = logoImg.size.y
logo.width = logoImg.size.x
logo.top = 2
logo.left = math.ceil(app.canvas.size.x / 2) - math.floor(logo.width / 2)
logo.canvas = logoImg
--logo.canvas.effect = CreateEffect()


local lbl = widgets.Label.Create(frmMain, "lbl1")
lbl.top = 3 + logo.height
lbl.width = app.canvas.size.x
lbl.align = "center"
lbl.caption = " CCWIN " .. sys_ver.value .. " (build " .. tostring(sys_ver.build) .. ")"

local lbl = widgets.Label.Create(frmMain, "lbl2")
lbl.top = 3 + logo.height + 2
lbl.width = app.canvas.size.x
lbl.align = "center"
lbl.caption = "(c) Puzzletime (8coon), 2014-2015"


local btn = widgets.Button.Create(frmMain, "btn")
btn.top = app.canvas.size.y - 2
btn.caption = " Close"
btn.onClick = function(sender) app:terminate() end
btn.width = 9
btn.left = math.floor(app.canvas.size.x / 2 - btn.width / 2) + 1




local magic = widgets.Panel.Create(frmMain, "magic")
magic.height = 1
magic.width = app.canvas.size.x
magic.top = app.canvas.size.y - 4
magic.left = 0

magic.onRefresh = function(sender)
	if sender.canvas ~= nil and sender.canvas.effect == nil then
		--sender.canvas.effect = CreateEffect(100000)
	end
end

local lbl = widgets.Label.Create(magic, "lbl")
lbl.width = app.canvas.size.x
lbl.align = "center"
lbl.caption = " "

lbl.onClick = function(sender)
	--[[if os.getMagic() == nil then
		os.applyMagic(user.CreateEffect_Acid())
	else
		os.applyMagic(nil)
	end]]
end




--os.startTimer(0.1, function() os.sendMessage(hwnd, {msg = "refresh"}) end )
app:run()
