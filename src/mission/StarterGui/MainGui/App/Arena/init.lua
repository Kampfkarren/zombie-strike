local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Dungeon = require(ReplicatedStorage.Libraries.Dungeon)
local EquipmentInfo = require(ReplicatedStorage.Core.UI.Components.EquipmentInfo)
local EquipmentUtil = require(ReplicatedStorage.Core.EquipmentUtil)
local EventConnection = require(ReplicatedStorage.Core.UI.Components.EventConnection)
local GunScaling = require(ReplicatedStorage.Core.GunScaling)
local Loot = require(ReplicatedStorage.Core.Loot)
local LootInfo = require(ReplicatedStorage.Core.UI.Components.LootInfo)
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

			if Loot.IsWeapon(loot) then
				for key, value in pairs(GunScaling.BaseStats(loot.Type, loot.Level, loot.Rarity)) do
					if loot[key] == nil then
						loot[key] = value
					end
				end
			end

			local aspectRatio, lootInfo

			local frameProps = {
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundTransparency = 0.35,
				BorderSizePixel = 0,
				Position = UDim2.fromScale(0.07, 0.5),
			}

			if Loot.IsEquipment(loot) then
				frameProps.BackgroundColor3 = EquipmentUtil.GetColor(loot.Type)
				frameProps.Size = UDim2.fromScale(1, 0.5)

				aspectRatio = 0.8
				lootInfo = e(EquipmentInfo, {
					Loot = loot,
				})
			else
				frameProps.BackgroundColor3 = Loot.Rarities[loot.Rarity].Color
				frameProps.Size = UDim2.fromScale(1, 0.8)

				aspectRatio = 0.6
				lootInfo = e(LootInfo, {
					Native = {
						Size = UDim2.fromScale(1, 1),
					},

					Loot = loot,
				})
			end

			children.Loot = e("Frame", frameProps, {
				UIAspectRatioConstraint = e("UIAspectRatioConstraint", {
					AspectRatio = aspectRatio,
					AspectType = Enum.AspectType.ScaleWithParentSize,
					DominantAxis = Enum.DominantAxis.Height,
				}),

				Label = e("TextLabel", {
					AnchorPoint = Vector2.new(0, 1),
					BackgroundTransparency = 1,
					Font = Enum.Font.Gotham,
					Size = UDim2.fromScale(1, 0.15),
					Text = "YOU UNLOCKED...",
					TextColor3 = Color3.new(1, 1, 1),
					TextScaled = true,
				}),

				LootInfo = lootInfo,
			})
		end
	end

	return e("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
	}, children)
end

return Arena
