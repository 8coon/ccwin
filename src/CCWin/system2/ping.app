local app = application.Create(os.getProcessInfo(os.getCurrentProcess()), os)
local mainForm = form.Create("Ping")

app:addForm(mainForm, "Ping")
mainForm:show()



function onSuccess(url, handle)
	local response = handle.readAll()
	handle.close()

	--mainForm.widgets.txtArea.text = response
	os.sendMessage(hwnd, {msg = "refresh"})
	app:showMessage(response)
end

function onFail(url)
	app:showMessage("Fail")
	--mainForm.widgets.txtArea.text = url
	os.sendMessage(hwnd, {msg = "refresh"})
end




local txtCmd = widgets.Edit.Create(mainForm, "txtCmd")
txtCmd.left = 2
txtCmd.top = 2
txtCmd.width = app.canvas.size.x - 2 - 10
txtCmd.text = ""


local btnCmd = widgets.Button.Create(mainForm, "btnCmd")
btnCmd.width = 9
btnCmd.left = app.canvas.size.x - btnCmd.width
btnCmd.top = 2
btnCmd.caption = " Run"


local txtArea = widgets.TextArea.Create(mainForm, "txtArea")
txtArea.left = 2
txtArea.top = 4
txtArea.width = app.canvas.size.x - 2
txtArea.height = app.canvas.size.y - txtArea.top - 1
--txtArea.visible = false



btnCmd.onClick = function(sender)
	if (txtCmd.text == nil) or (txtCmd.text == "") then
		os.messageBox("message", "Please specify any URL.", "Error", 
		{ 
			{caption = "OK", 
				onClick = function(sender)
					os.hideMessageBox()
				end
			},
		}, "defText")
	else
		local http = os.findWindowByTitle("http service")

		if http ~= nil then
			os.sendMessage(http, {msg = "request", url = txtCmd.text, postData = nil, headers = nil, onSuccess = onSuccess, onFail = onFail})
		else
			app:showMessage("Http service not found.\nPlease, reboot your computer.")
		end
	end
end

app:run()