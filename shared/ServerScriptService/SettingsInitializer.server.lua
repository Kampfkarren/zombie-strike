local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local DataStore2 = require(ServerScriptService.Vendor.DataStore2)
local Settings = require(ReplicatedStorage.Core.Settings)

Players.PlayerAdded:connect(function(player)
	local playerData = player:WaitForChild("PlayerData")

	local settingsFolder = Instance.new("Folder")
	settingsFolder.Name = "Settings"

	local settingsStore = DataStore2("Settings", player)

	for index, setting in pairs(Settings.Settings) do
		local value, new = Settings.GetSettingIndex(setting.Name, player)

		if new then
			local settings = settingsStore:Get()
			settings[index] = value
			settingsStore:Set(settings)
		end

		local settingObject = Instance.new("NumberValue")
		settingObject.Name = setting.Name
		settingObject.Value = value
		settingObject.Parent = settingsFolder
	end

	settingsStore:OnUpdate(function(newSettings)
		for settingIndex, setting in pairs(Settings.Settings) do
			settingsFolder[setting.Name].Value = newSettings[settingIndex]
		end
	end)

	settingsFolder.Parent = playerData
end)
