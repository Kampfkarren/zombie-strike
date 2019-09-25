local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local DataStore2 = require(ServerScriptService.Vendor.DataStore2)
local Settings = require(ReplicatedStorage.Core.Settings)

Players.PlayerAdded:connect(function(player)
	local playerData = player:WaitForChild("PlayerData")

	local settingsFolder = Instance.new("Folder")
	settingsFolder.Name = "Settings"

	for _, setting in pairs(Settings.Settings) do
		local value = Settings.GetSettingIndex(setting.Name, player)

		local settingObject = Instance.new("NumberValue")
		settingObject.Name = setting.Name
		settingObject.Value = value
		settingObject.Parent = settingsFolder
	end

	DataStore2("Settings", player):OnUpdate(function(newSettings)
		for settingIndex, setting in pairs(Settings.Settings) do
			settingsFolder[setting.Name].Value = newSettings[settingIndex]
		end
	end)

	settingsFolder.Parent = playerData
end)
