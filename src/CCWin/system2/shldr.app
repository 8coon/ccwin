if config.AUTORUN ~= nil then
	for k, v in pairs(config.AUTORUN) do
		os.shell.run(v)
	end
end