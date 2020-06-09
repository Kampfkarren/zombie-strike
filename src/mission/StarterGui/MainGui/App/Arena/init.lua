local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ArenaRewards = require(script.ArenaRewards)
local Dungeon = require(ReplicatedStorage.Libraries.Dungeon)
local EventConnection = require(ReplicatedStorage.Core.UI.Components.EventConnection)
local Loot = require(ReplicatedStorage.Core.Loot)
local PerkUtil = require(ReplicatedStorage.Core.Perks.PerkUtil)
local RealDelay = require(ReplicatedStorage.Core.RealDelay)
local Roact = require(ReplicatedStorage.Vendor.Roact)

local Arena = Roact.Component:extend("Arena")
local ArenaRemotes = ReplicatedStorage.Remotes.Arena

local e = Roact.createElement

local WAVE_NOTICE_LIFETIME = 3

function Arena:init()
	self:setState({
		currentWave = 0,
		waveOpen = false,
	})
end

function Arena:didUpdate(_, previousState)
	if self.state.waveOpen and self.state.currentWave > previousState.currentWave then
		local currentWave = self.state.currentWave

		RealDelay(WAVE_NOTICE_LIFETIME, function()
			if self.state.currentWave == currentWave then
				self:setState({
					waveOpen = false,
				})
			end
		end)
	end
end

function Arena:render()
	if Dungeon.GetDungeonData("Gamemode") ~= "Arena" then
		return nil
	end

	local children = {}

	children.NewWaveConnection = e(EventConnection, {
		callback = function(wave, loot)
			self:setState({
				currentWave = wave,
				loot = loot or Roact.None,
				waveOpen = true,
			})
		end,

		event = ArenaRemotes.NewWave.OnClientEvent,
	})

	if self.state.waveOpen then
		children.NewWaveText = e("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBlack,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 0.2),
			Text = "WAVE " .. self.state.currentWave,
			TextColor3 = Color3.new(1, 1, 1),
			TextScaled = true,
			TextTransparency = 0.2,
		})

		if self.state.loot then
			local loot = self.state.loot
			local rewardProps = {}

			if Loot.IsEquipment(loot) then
				rewardProps.EquipmentLoot = loot
			else
				if Loot.HasPerks(loot) then
					loot.Perks = PerkUtil.DeserializePerks(loot.Perks)
				end

				rewardProps.ItemLoot = loot
			end

			children.Rewards = e(ArenaRewards, rewardProps)
		end
	end

	return e("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
	}, children)
end

return Arena
