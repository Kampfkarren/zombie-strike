local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Data = require(ReplicatedStorage.Core.Data)
local InventorySpace = require(ReplicatedStorage.Core.InventorySpace)
local Loot = require(ReplicatedStorage.Core.Loot)
local LootInfoButton = require(ReplicatedStorage.Core.UI.LootInfoButton)
local PreventNoobPlay = require(ReplicatedStorage.Libraries.PreventNoobPlay)
local State = require(ReplicatedStorage.State)
local ViewportFramePreview = require(ReplicatedStorage.Core.UI.ViewportFramePreview)

local Inventory = script.Parent.Main.Inventory
local LocalPlayer = Players.LocalPlayer

local Loadout = Inventory.Loadout

local UpdateEquipment = ReplicatedStorage.Remotes.UpdateEquipment

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

local function fastSpawn(callback)
	local event = Instance.new("BindableEvent")
	event.Event:connect(callback)
	event:Fire()
end

local function resetSelectable()
	for _, card in pairs(cards) do
		card.Selectable = inventoryToggled
	end
end

local function toggle(open)
	inventoryToggled = open
	resetSelectable()

	if open then
		if PreventNoobPlay() then
			inventoryTweenIn:Play()
			if UserInputService.GamepadEnabled then
				GuiService.SelectedObject = Inventory.Contents:FindFirstChild("Template")
			end
		end
	else
		local selected = GuiService.SelectedObject
		if selected and selected.Selectable then
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
		if cards[newId] then
			cards[newId].ImageColor3 = color
		end
	end

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

local function updateInventory(inventory)
	currentInventory = inventory

	for _, card in pairs(cards) do
		card:Destroy()
	end

	cards = {}

	for id, item in pairs(currentInventory) do
		local color = Loot.Rarities[item.Rarity].Color

		local card = ReplicatedStorage.ItemTemplate:Clone()
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
				if item.Level > LocalPlayer.PlayerData.Level.Value then
					StarterGui:SetCore("ChatMakeSystemMessage", {
						Text = "You're not a high enough level to equip that!",
						Color = Color3.fromRGB(252, 92, 101),
						Font = Enum.Font.GothamSemibold,
					})
				else
					UpdateEquipment:FireServer(id)
				end
			end
		end)

		card.ImageColor3 = color

		card.Parent = Inventory.Contents
		cards[id] = card
	end

	InventorySpace(LocalPlayer):andThen(function(space)
		Inventory.InventorySpace.Text = #currentInventory .. "/" .. space
	end)

	updateEquipped()
	resetSelectable()
end

currentInventory = State:getState().inventory
if currentInventory then
	fastSpawn(function()
		updateInventory(currentInventory)
	end)
end

State.changed:connect(function(new, old)
	local inventory = new.inventory

	if inventory ~= old.inventory or new.equipment ~= old.equipment then
		assert(inventory ~= nil, "Inventory changed, but somehow still nil?")
		fastSpawn(function()
			updateInventory(inventory)
		end)
	end
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
