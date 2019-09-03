local ServerStorage = game:GetService("ServerStorage")

return function()
	ServerStorage.Events.EndDungeon:Fire()
	return "Mission ended."
end
