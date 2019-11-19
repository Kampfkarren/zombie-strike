local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AutomatedScrollingFrameComponent = require(script.Parent.Parent.AutomatedScrollingFrameComponent)
local CosmeticButton = require(script.Parent.Parent.Store.CosmeticButton)
local Cosmetics = require(ReplicatedStorage.Core.Cosmetics)
local ItemButton = require(script.Parent.ItemButton)
local MergeTables = require(ReplicatedStorage.Core.MergeTables)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local RoactRodux = require(ReplicatedStorage.Vendor.RoactRodux)

local e = Roact.createElement

local function InventoryContents(props)
	local inventory = {}
	inventory.UIGridLayout = e("UIGridLayout", {
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	for id, item in pairs(props.inventory or {}) do
		inventory["Item" .. item.UUID] = e(ItemButton, {
			LayoutOrder = -id,
			Loot = item,

			onHover = props.onHover,
			onUnhover = props.onUnhover,
			equip = function()
				props.onClickInventory(id)
			end,
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
						props.onClickCosmetic(item)
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

return RoactRodux.connect(function(state)
	return {
		cosmeticsInventory = state.store.contents,
		inventory = state.inventory,
	}
end)(InventoryContents)
