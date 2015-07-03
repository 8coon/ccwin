if params[2] ~= nil then
	local lnkdata = iniFiles.read(params[2])

	if lnkdata ~= nil then
		os.shell.run(lnkdata.shortcut.file)
	end
end