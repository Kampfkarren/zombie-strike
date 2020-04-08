local ReplicatedStorage = game:GetService("ReplicatedStorage")

local assign = require(ReplicatedStorage.Core.assign)
local Loot = require(ReplicatedStorage.Core.Loot)
local Roact = require(ReplicatedStorage.Vendor.Roact)

local e = Roact.createElement

local function ItemType(props)
	local item = props.Item
	local itemType = item.Type

	if Loot.IsAttachment(item) then
		itemType = "Attachment"
	elseif Loot.IsGunSkin(item) then
		itemType = "Gun Skin"
	elseif Loot.IsCosmetic(item) then
		itemType = "Cosmetic"
	elseif Loot.IsAurora(item) then
		itemType = "Aurora " .. itemType
	end

	return e("TextLabel", assign({
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBlack,
		Size = UDim2.fromScale(1, props.TextSize),
		Text = itemType:upper():gsub("(.)", "%1 "),
		TextColor3 = Color3.new(1, 1, 1),
		TextSize = props.TextSize,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
	}, props.Native or {}))
end

return ItemType
