local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AutomatedScrollingFrameComponent = require(script.Parent.Parent.AutomatedScrollingFrameComponent)
local CosmeticButton = require(script.Parent.Parent.Store.CosmeticButton)
local Cosmetics = require(ReplicatedStorage.Core.Cosmetics)
local ItemButton = require(script.Parent.ItemButton)
local Loot = require(ReplicatedStorage.Core.Loot)
local MergeTables = require(ReplicatedStorage.Core.MergeTables)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local RoactRodux = require(ReplicatedStorage.Vendor.RoactRodux)
local SpraysDictionary = require(ReplicatedStorage.Core.SpraysDictionary)

local e = Roact.createElement

local function couldNoop(callback)
	return callback or function() end
end

local function filtered(item, filters)
	if Loot.IsWeapon(item) and filters.Weapons == false then
		return true
	end

	if item.Type == "Armor" and filters.Armor == false then
		return true
	end

	if item.Type == "Helmet" and filters.Helmets == false then
		return true
	end

	if Loot.IsAttachment(item) and filters.Attachments == false then
		return true
	end

	if Loot.IsCosmetic(item) and filters.Cosmetics == false then
		return true
	end

	if Loot.IsPet(item) and filters.Pets == false then
		return true
	end

	if item.Rarity and filters[Loot.Rarities[item.Rarity].Name] == false then
		return true
	end

	return false
end

local function InventoryContents(props)
	local filters = props.filters and props.filters:getValue() or {}

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

		if not filtered(item, filters) then
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
	end

	if props.showCosmetics then
		local function makeCosmeticButton(id, item, index)
			if not filtered(item, filters) then
				inventory[id] = e(CosmeticButton, {
					Item = item,
					PreviewSize = UDim2.fromScale(1, 1),

					Native = {
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Image = "http://www.roblox.com/asset/?id=3973353646",
						LayoutOrder = id,

						[Roact.Event.Activated] = function()
							couldNoop(props.onClickCosmetic)(index, id)
						end,
					}
				})
			end
		end

		for id, item in pairs(props.cosmeticsInventory) do
			makeCosmeticButton("Cosmetic" .. id, Cosmetics.Cosmetics[item], item)
		end

		for _, sprayIndex in pairs(props.spraysInventory) do
			makeCosmeticButton("Spray" .. sprayIndex, SpraysDictionary[sprayIndex], sprayIndex)
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
		spraysInventory = state.sprays.owned,
	}
end)(InventoryContents)
