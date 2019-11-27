local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AutomatedScrollingFrameComponent = require(script.Parent.Parent.AutomatedScrollingFrameComponent)
local CosmeticButton = require(script.Parent.Parent.Store.CosmeticButton)
local Cosmetics = require(ReplicatedStorage.Core.Cosmetics)
local ItemButton = require(script.Parent.ItemButton)
local MergeTables = require(ReplicatedStorage.Core.MergeTables)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local RoactRodux = require(ReplicatedStorage.Vendor.RoactRodux)

local e = Roact.createElement

local function couldNoop(callback)
	return callback or function() end
end

local function InventoryContents(props)
	local inventory = {}
	inventory.UIGridLayout = e("UIGridLayout", {
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	local itemButtonChildren = props.itemButtonChildren or {}

	for id, item in pairs(props.inventory or {}) do
		local function callback(original)
			return function()
				couldNoop(original)(item, id)
			end
		end

		inventory["Item" .. item.UUID] = e(ItemButton, {
			LayoutOrder = -id,
			Loot = item,
			HideFavorites = props.hideFavorites,
			NoInteractiveFavorites = props.noInteractiveFavorites,

			onHover = callback(props.onHover),
			onUnhover = callback(props.onUnhover),
			onClickEquipped = callback(props.onClickInventoryEquipped),
			onClickUnequipped = callback(props.onClickInventoryUnequipped),

			[Roact.Children] = itemButtonChildren[item.UUID],
		})
	end

	if props.showCosmetics then
		for id, item in pairs(props.cosmeticsInventory) do
			inventory["Cosmetic" .. id] = e(CosmeticButton, {
				Item = Cosmetics.Cosmetics[item],
				PreviewSize = UDim2.fromScale(1, 1),

				Native = {
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Image = "http://www.roblox.com/asset/?id=3973353646",
					LayoutOrder = id,

					[Roact.Event.Activated] = function()
						couldNoop(props.onClickCosmetic)(item, id)
					end,
				}
			})
		end
	end

	local mergedProps = MergeTables(props.Native, {
		[Roact.Children] = inventory,
	})

	return e(AutomatedScrollingFrameComponent, mergedProps)
end

return RoactRodux.connect(function(state, ownProps)
	return {
		cosmeticsInventory = state.store.contents,
		inventory = ownProps.inventory or state.inventory,
	}
end)(InventoryContents)
