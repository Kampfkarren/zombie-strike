local ServerStorage = game:GetService("ServerStorage")

return function(context)
	ServerStorage.Events.EndDungeon:Fire()
	return "Mission ended."
end
