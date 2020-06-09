local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CreateMockState = require(ReplicatedStorage.Libraries.CreateMockState)
local Perks = require(ReplicatedStorage.Core.Perks)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local RoactRodux = require(ReplicatedStorage.Vendor.RoactRodux)
local TradeScreen2 = require(script.Parent.TradeScreen2)
local Scale = require(ReplicatedStorage.Core.UI.Components.Scale)

local e = Roact.createElement

local function item()
	return {
		Type = "Pistol",
		Level = math.random(1, 100),
		Rarity = math.random(1, 5),

		Bonus = 0,
		Favorited = false,
		Seed = 0,

		Perks = {
			{
				Perk = Perks.Perks[1],
				Upgrades = 0,
			},
		},

		Model = math.random(1, 5),
		UUID = HttpService:GenerateGUID(false):gsub("-", ""),
	}
end

return function(target)
	local theirInventory = { item(), item(), item(), item(), item(), item(), item() }

	local handle = Roact.mount(
		e(RoactRodux.StoreProvider, {
			store = CreateMockState.Normal("Trading", {
				trading = {
					trading = true,
					theirEquipment = { theirInventory[1].UUID },
					theirInventory = theirInventory,
					theirOffer = { theirInventory[2].UUID },
					yourOffer = { },
				},
			}),
		}, {
			Frame = e("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromOffset(1920, 800),
			}, {
				Scale = e(Scale, {
					Size = Vector2.new(1920, 800),
				}),

				TradeScreen2 = e(TradeScreen2, {
					offerItem = function()
						return print
					end,

					weAccept = print,
				}),
			}),
		}), target, "TradeScreen2"
	)

	return function()
		Roact.unmount(handle)
	end
end
