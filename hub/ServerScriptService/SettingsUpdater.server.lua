local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local DataStore2 = require(ServerScriptService.Vendor.DataStore2)
local Settings = require(ReplicatedStorage.Core.Settings)

local UpdateSetting = ReplicatedStorage.Remotes.UpdateSetting

UpdateSetting.OnServerEvent:connect(function(player, settingIndex, choice)
	local setting = Settings.Settings[settingIndex]
	if not setting then
		warn("UpdateSetting: setting not found")
		return
	end

	if not setting.Choices[choice] then
		warn("UpdateSetting: choice not found")
		return
	end

	local settingsStore = DataStore2("Settings", player)
	local settings = settingsStore:Get()
	settings[settingIndex] = choice
	settingsStore:Set(settings)
end)
