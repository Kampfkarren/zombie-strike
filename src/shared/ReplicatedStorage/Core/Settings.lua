local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Data = require(ReplicatedStorage.Core.Data)
local Promise = require(ReplicatedStorage.Core.Promise)

local LocalPlayer = Players.LocalPlayer

local Settings = {}

Settings.Settings = {
	{
		Name = "Skin Tone",
		Default = {
			Type = "Random",
			Range = { 1, 6 },
		},

		Choices = {
			"Light",
			"Tan",
			"Fair",
			"Brown",
			"Dark",
			"Very Dark",
			"Homer",
			"Zombie",
			"Purple",
		},

		Values = {
			Color3.fromRGB(244, 219, 172),
			Color3.fromRGB(241, 194, 125),
			Color3.fromRGB(224, 172, 105),
			Color3.fromRGB(198, 134, 66),
			Color3.fromRGB(141, 85, 36),
			Color3.fromRGB(75, 46, 21),
			Color3.fromRGB(245, 208, 48),
			Color3.fromRGB(138, 171, 133),
			Color3.fromRGB(149, 87, 170),
		},
	},

	{
		Name = "Music",
		Default = 1,

		Choices = {
			"On",
			"Off",
		},

		Values = {
			1,
			0,
		},
	},

	{
		Name = "Gold Guns",
		Default = 1,

		Choices = {
			"Off",
			"On",
		},

		Values = {
			false,
			true,
		},
	},

	{
		Name = "Trade Requests",
		Default = 1,

		Choices = {
			"Allow",
			"Allow near level",
			"Off",
		},

		Values = {
			1,
			2,
			3,
		},
	},

	{
		Name = "First Person",
		Default = 1,

		Choices = {
			"Off",
			"On",
		},

		Values = {
			false,
			true,
		}
	},
}

function Settings.GetSettingIndex(settingName, player)
	if RunService:IsServer() then
		for settingIndex, setting in pairs(Settings.Settings) do
			if setting.Name == settingName then
				local value = Data.GetPlayerData(player, "Settings")[settingIndex]

				if value ~= nil then
					return value, false
				elseif type(setting.Default) == "table" and setting.Default.Type == "Random" then
					return Random.new(player.UserId):NextInteger(unpack(setting.Default.Range)), true
				else
					return setting.Default, true
				end
			end
		end

		error("unknown setting " .. settingName)
	else
		return LocalPlayer
			:WaitForChild("PlayerData", math.huge)
			:WaitForChild("Settings")
			:WaitForChild(settingName)
			.Value
	end
end

function Settings.GetSetting(settingName, player)
	local index = Settings.GetSettingIndex(settingName, player)

	for _, setting in pairs(Settings.Settings) do
		if setting.Name == settingName then
			return setting.Values[index]
		end
	end

	error("unknown setting " .. settingName)
end

function Settings.HookSetting(settingName, callback, player)
	player = player or LocalPlayer

	local setting = Settings.GetSetting(settingName, player)
	callback(setting)

	Settings.HookSettingAsync(settingName, callback, player)
end

function Settings.HookSettingAsync(settingName, callback, player)
	player = player or LocalPlayer

	return Promise.async(function()
		player
			:WaitForChild("PlayerData")
			:WaitForChild("Settings")
			:WaitForChild(settingName)
				.Changed:connect(function(index)
					callback(Settings.GetSetting(settingName, player), index)
				end)
	end)
end

return Settings
