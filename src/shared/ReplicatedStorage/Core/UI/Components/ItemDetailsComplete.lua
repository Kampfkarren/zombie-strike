local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ItemDetails = require(ReplicatedStorage.Core.UI.Components.ItemDetails)
local Loot = require(ReplicatedStorage.Core.Loot)
local PerkDetails = require(ReplicatedStorage.Core.UI.Components.PerkDetails)
local Roact = require(ReplicatedStorage.Vendor.Roact)

local e = Roact.createElement

local function ItemDetailsComplete(props)
	if not Loot.HasPerks(props.Item) then
		return e(ItemDetails, {
			CompareTo = props.CompareTo,
			Item = props.Item,
			ShowGearScore = props.ShowGearScore,
		})
	else
		return e(PerkDetails, {
			IconSize = props.IconSize,
			Perks = props.Item.Perks or {},
			Seed = props.Item.Seed,

			RenderParent = function(element, size)
				return e("Frame", {
					BackgroundTransparency = 1,
					Size = UDim2.fromScale(1, 1),
				}, {
					ItemDetails = e("Frame", {
						BackgroundTransparency = 1,
						Size = UDim2.new(1, 0, 1, -size.Y.Offset),
					}, {
						Inner = e(ItemDetails, {
							CompareTo = props.CompareTo,
							Item = props.Item,
							ShowGearScore = props.ShowGearScore,
							StatsOffset = 15,
						}),
					}),

					PerkDetails = e("Frame", {
						AnchorPoint = Vector2.new(0, 1),
						BackgroundTransparency = 1,
						Position = UDim2.fromScale(0, 1),
						Size = UDim2.new(UDim.new(1, 0), size.Y),
					}, {
						Element = element,
					}),
				})
			end,
		})
	end
end

return ItemDetailsComplete
