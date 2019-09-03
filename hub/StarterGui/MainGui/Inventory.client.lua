local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Data = require(ReplicatedStorage.Libraries.Data)
local Loot = require(ReplicatedStorage.Core.Loot)
local LootInfoButton = require(ReplicatedStorage.Core.UI.LootInfoButton)
local ViewportFramePreview = require(ReplicatedStorage.Core.UI.ViewportFramePreview)

local Inventory = script.Parent.Main.Inventory

local Loadout = Inventory.Loadout

local UpdateEquipment = ReplicatedStorage.Remotes.UpdateEquipment
local UpdateInventory = ReplicatedStorage.Remotes.UpdateInventory

local inventoryTweenIn = TweenService:Create(
	Inventory,
	TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	{ Position = UDim2.new(0.5, 0, 0.5, 0) }
)

local inventoryTweenOut = TweenService:Create(
	Inventory,
	TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	{ Position = UDim2.new(0.5, 0, 1.5, 0) }
)

local inventoryToggled = false
local cards = {}
local currentInventory
local equipped = {}

local function resetSelectable()
	for _, card in pairs(cards) do
		card.Selectable = inventoryToggled
	end
end

local function toggle(open)
	inventoryToggled = open
	resetSelectable()

	if open then
		inventoryTweenIn:Play()
		GuiService.SelectedObject = cards[#cards]
	else
		local selected = GuiService.SelectedObject
		if not selected.Selectable then
			GuiService.SelectedObject = nil
		end
		inventoryTweenOut:Play()
	end
end

local function updateEquip(gui, data)
	local equipped = currentInventory[Data.GetLocalPlayerData(data)]
	gui.ImageColor3 = Loot.Rarities[equipped.Rarity].Color
	ViewportFramePreview(gui.ViewportFrame, Data.GetModel(equipped))
end

local function updateEquipped()
	for oldId in pairs(equipped) do
		cards[oldId].ImageColor3 = Loot.Rarities[currentInventory[oldId].Rarity].Color
	end

	equipped = {}

	for _, key in pairs({
		Data.GetLocalPlayerData("EquippedArmor"),
		Data.GetLocalPlayerData("EquippedHelmet"),
		Data.GetLocalPlayerData("EquippedWeapon"),
	}) do
		equipped[key] = true
	end

	for newId in pairs(equipped) do
		local color = Loot.Rarities[currentInventory[newId].Rarity].Color
		local h, s, v = Color3.toHSV(color)
		color = Color3.fromHSV(h, s, v * 0.8)
		cards[newId].ImageColor3 = color
	end

	-- TODO: Cosmetics here
	updateEquip(Loadout.Armor.Armor, "EquippedArmor")
	updateEquip(Loadout.Helmet.Helmet, "EquippedHelmet")
	updateEquip(Loadout.Weapon, "EquippedWeapon")
end

script.Parent.Main.Buttons.Inventory.MouseButton1Click:connect(function()
	toggle(not inventoryToggled)
end)

Inventory.Close.MouseButton1Click:connect(function()
	toggle(false)
end)

UpdateInventory.OnClientEvent:connect(function(inventory)
	currentInventory = Loot.DeserializeTable(inventory)

	for _, card in pairs(cards) do
		card:Destroy()
	end

	cards = {}

	for id, item in pairs(currentInventory) do
		local color = Loot.Rarities[item.Rarity].Color

		local card = script.Template:Clone()
		card.LayoutOrder = -id
		ViewportFramePreview(card.ViewportFrame, Data.GetModel(item))

		LootInfoButton(card, Inventory.LootInfo.Inner, item, function(hovered)
			if not equipped[id] then
				if hovered then
					local h, s, v = Color3.toHSV(color)
					card.ImageColor3 = Color3.fromHSV(h, s, v * 0.8)
				else
					card.ImageColor3 = color
				end
			end
		end)

		card.MouseButton1Click:connect(function()
			if not equipped[id] then
				UpdateEquipment:FireServer(id)
			end
		end)

		card.ImageColor3 = color

		card.Parent = Inventory.Contents
		cards[id] = card
	end

	updateEquipped()
	resetSelectable()
end)

UpdateEquipment.OnClientEvent:connect(function(armor, helmet, weapon)
	assert(currentInventory)

	Data.SetLocalPlayerData("EquippedArmor", armor)
	Data.SetLocalPlayerData("EquippedHelmet", helmet)
	Data.SetLocalPlayerData("EquippedWeapon", weapon)

	Data.SetLocalPlayerData("Armor", currentInventory[armor])
	Data.SetLocalPlayerData("Helmet", currentInventory[helmet])
	Data.SetLocalPlayerData("Weapon", currentInventory[weapon])

	updateEquipped()
end)

local contentsGrid = Inventory.Contents.UIGridLayout
contentsGrid:GetPropertyChangedSignal("AbsoluteContentSize"):connect(function()
	local size = contentsGrid.AbsoluteContentSize
	Inventory.Contents.CanvasSize = UDim2.new(0, size.X, 0, size.Y)
end)

UserInputService.InputBegan:connect(function(inputObject, processed)
	if not processed then
		if inputObject.KeyCode == Enum.KeyCode.ButtonB then
			toggle(false)
		end
	end
end)
