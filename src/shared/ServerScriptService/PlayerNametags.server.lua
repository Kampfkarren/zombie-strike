local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Data = require(ReplicatedStorage.Core.Data)
local FontsDictionary = require(ReplicatedStorage.Core.FontsDictionary)
local GamePassDictionary = require(ReplicatedStorage.Core.GamePassDictionary)
local GamePasses = require(ReplicatedStorage.Core.GamePasses)
local Nametag = require(ServerScriptService.Shared.Nametag)
local RealDelay = require(ReplicatedStorage.Core.RealDelay)
local TitlesDictionary = require(ReplicatedStorage.Core.TitlesDictionary)

local function makeVip(nametag)
	if not nametag.EnemyName.Text:match("[VIP]") then
		nametag.EnemyName.Text = "[VIP] " .. nametag.EnemyName.Text
		nametag.EnemyName.TextColor3 = Color3.new(1, 1, 0.5)
	end
end

local function maybeVip(player, nametag)
	if GamePasses.PlayerOwnsPass(player, GamePassDictionary.VIP) then
		makeVip(nametag)
	end
end

local function setupFont(player, nametag)
	local fonts, fontsStore = Data.GetPlayerData(player, "Fonts")
	local font = FontsDictionary[fonts.Equipped]
	font = font and font.Font or Enum.Font.GothamBold

	nametag.EnemyName.Font = font
	nametag.Level.Font = font
	nametag.Title.Font = font

	return fontsStore
end

local function setupTitle(player, nametag)
	local titles, titlesStore = Data.GetPlayerData(player, "Titles")
	local title = TitlesDictionary[titles.Equipped]

	if not title then
		nametag.Title.Visible = false
		return titlesStore
	end

	nametag.Title.Text = "[" .. title .. "]"
	nametag.Title.Visible = true

	return titlesStore
end

Players.PlayerAdded:connect(function(player)
	local playerData = player:WaitForChild("PlayerData")
	local level = playerData:WaitForChild("Level")

	local updateConnected
	local nametag

	local function characterAdded(character)
		nametag = Nametag(character, level.Value)

		RealDelay(0.03, function()
			maybeVip(player, nametag)
		end)

		GamePasses.BoughtPassUpdated(player).Event:connect(function()
			maybeVip(player, nametag)
		end)

		character.Humanoid.HealthChanged:connect(function()
			maybeVip(player, Nametag(character, level.Value))
		end)

		level.Changed:connect(function()
			maybeVip(player, Nametag(character, level.Value))
		end)

		local fontsStore = setupFont(player, nametag)
		local titlesStore = setupTitle(player, nametag)

		if not updateConnected then
			updateConnected = true

			fontsStore:OnUpdate(function()
				setupFont(player, nametag)
			end)

			titlesStore:OnUpdate(function()
				setupTitle(player, nametag)
			end)
		end
	end

	if player.Character then
		characterAdded(player.Character)
	end

	player.CharacterAdded:connect(characterAdded)
end)
