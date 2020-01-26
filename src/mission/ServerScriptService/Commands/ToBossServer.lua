local ServerStorage = game:GetService("ServerStorage")

return function(_, showCutscene)
	ServerStorage.Events.ToBoss:Fire(showCutscene)
	return "Teleported to the boss."
end
