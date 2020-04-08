local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local SoundService = game:GetService("SoundService")

local Dungeon = require(ReplicatedStorage.Libraries.Dungeon)

return function(_, showCutscene)
	ServerStorage.Events.ToBoss:Fire(showCutscene)
	SoundService.Music[Dungeon.GetDungeonData("Campaign")].Main.Volume = 0
	return "Teleported to the boss."
end
