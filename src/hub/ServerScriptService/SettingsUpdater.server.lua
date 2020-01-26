local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local DataStore2 = require(ServerScriptService.Vendor.DataStore2)
local GamePassDictionary = require(ReplicatedStorage.Core.GamePassDictionary)
local Settings = require(ReplicatedStorage.Core.Settings)

local UpdateSetting = ReplicatedStorage.Remotes.UpdateSetting

local function updateSetting(player, settingIndex, choice)
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

	for previous = 1, settingIndex do
		if settings[previous] == nil then
			settings[previous] = Settings.GetSettingIndex(
				Settings.Settings[previous].Name,
				player
			)
		end
	end

	settings[settingIndex] = choice
	settingsStore:Set(settings)
end

UpdateSetting.OnServerEvent:connect(updateSetting)

MarketplaceService.PromptGamePassPurchaseFinished:connect(function(player, gamePassId, purchased)
	if not purchased then return end
	if gamePassId == GamePassDictionary.GoldGuns then
		updateSetting(player, 3, 2)
	end
end)
