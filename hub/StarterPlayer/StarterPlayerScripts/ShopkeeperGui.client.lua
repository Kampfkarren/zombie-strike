local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Data = require(ReplicatedStorage.Core.Data)
local EnglishNumbers = require(ReplicatedStorage.Core.EnglishNumbers)
local Loot = require(ReplicatedStorage.Core.Loot)
local LootInfoButton = require(ReplicatedStorage.Core.UI.LootInfoButton)
local Maid = require(ReplicatedStorage.Core.Maid)
local SellCost = require(ReplicatedStorage.Libraries.SellCost)
local State = require(ReplicatedStorage.State)
local ViewportFramePreview = require(ReplicatedStorage.Core.UI.ViewportFramePreview)

local ItemTemplate = ReplicatedStorage.ItemTemplate
local LocalPlayer = Players.LocalPlayer
local ShopkeeperRange = CollectionService:GetTagged("ShopkeeperRange")[1]

local Shopkeeper = LocalPlayer
	:WaitForChild("PlayerGui")
	:WaitForChild("MainGui")
	:WaitForChild("Main")
	:WaitForChild("Shopkeeper")

local TWEEN_TIME = 0.5

local touching = false

local tweenClose = TweenService:Create(
	Shopkeeper,
	TweenInfo.new(TWEEN_TIME, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	{ Position = UDim2.new(0.5, 0, 1.5, 0) }
)

local tweenOpen = TweenService:Create(
	Shopkeeper,
	TweenInfo.new(TWEEN_TIME, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	{ Position = UDim2.new(0.5, 0, 0.5, 0) }
)

local function closeTouch()
	if not touching then return end
	touching = false
	tweenClose:Play()
end

local function openTouch()
	if touching then return end
	Shopkeeper.Visible = true
	touching = true
	tweenOpen:Play()
end

tweenClose.Completed:connect(function()
	Shopkeeper.Visible = false
end)

ShopkeeperRange.Touched:connect(function() end)

local contents = Maid.new()

local function updateInventory(inventory)
	if inventory == nil then return end
	Shopkeeper.LootInfo.Buttons.Visible = false

	contents:DoCleaning()

	local equipped = {}

	for _, key in pairs({
		Data.GetLocalPlayerData("EquippedArmor"),
		Data.GetLocalPlayerData("EquippedHelmet"),
		Data.GetLocalPlayerData("EquippedWeapon"),
	}) do
		equipped[key] = true
	end

	local currentlySelected, currentLootInfo
	local hoverStack = {}

	contents:GiveTask(Shopkeeper.LootInfo.Buttons.Sell.MouseButton1Click:connect(function()
		if currentlySelected then
			ReplicatedStorage.Remotes.Sell:FireServer(currentlySelected)
		end
	end))

	for index, item in pairs(inventory) do
		local button = ItemTemplate:Clone()
		local color = Loot.Rarities[item.Rarity].Color
		button.ImageColor3 = color
		ViewportFramePreview(button.ViewportFrame, Data.GetModel(item))
		contents:GiveTask(LootInfoButton(button, Shopkeeper.LootInfo.Inner, item, function(hovered)
			if hovered then
				hoverStack[item] = true

				if currentLootInfo then
					currentLootInfo.Visible = false
					Shopkeeper.LootInfo.Buttons.Visible = false
				end

				local h, s, v = Color3.toHSV(color)
				button.ImageColor3 = Color3.fromHSV(h, s, v * 0.8)
			else
				hoverStack[item] = nil
				button.ImageColor3 = color

				if next(hoverStack) == nil and currentLootInfo then
					currentLootInfo.Visible = true
					Shopkeeper.LootInfo.Buttons.Visible = true
				end
			end
		end))

		local isEquipped = equipped[index] == true

		button.MouseButton1Click:connect(function()
			-- TODO: Remove this entirely for gamepad, instead just press buttons
			-- TODO: "Are you sure?" for selling
			currentlySelected = index

			if currentLootInfo then
				currentLootInfo:Destroy()
			end

			currentLootInfo = Shopkeeper.LootInfo.Inner:Clone()
			currentLootInfo.Parent = Shopkeeper.LootInfo

			Shopkeeper.LootInfo.Inner.Visible = false

			if not isEquipped then
				Shopkeeper.LootInfo.Buttons.Sell.Label.Text = "SELL (" .. EnglishNumbers(SellCost(item)) .. "G)"
			end

			Shopkeeper.LootInfo.Buttons.Sell.Visible = not isEquipped
			Shopkeeper.LootInfo.Buttons.Upgrade.Visible = isEquipped

			Shopkeeper.LootInfo.Buttons.Visible = true

			contents.CurrentLootInfo = currentLootInfo
		end)

		if isEquipped then
			button.LayoutOrder = -index
		else
			button.LayoutOrder = index
		end

		contents:GiveTask(button)
		button.Parent = Shopkeeper.Contents
	end
end

local contentsGrid = Shopkeeper.Contents.UIGridLayout
contentsGrid:GetPropertyChangedSignal("AbsoluteContentSize"):connect(function()
	local size = contentsGrid.AbsoluteContentSize
	Shopkeeper.Contents.CanvasSize = UDim2.new(0, size.X, 0, size.Y)
end)

updateInventory(State:getState().inventory)

local function fastSpawn(callback)
	local fastSpawn = Instance.new("BindableEvent")
	fastSpawn.Event:connect(callback)
	fastSpawn:Fire()
end

State.changed:connect(function(new, old)
	if new.inventory ~= old.inventory or new.equipment ~= old.equipment then
		fastSpawn(function()
			updateInventory(new.inventory)
		end)
	end
end)

while true do
	local character = LocalPlayer.Character

	if character then
		local characterIsTouching = false

		for _, touchingPart in pairs(ShopkeeperRange:GetTouchingParts()) do
			if touchingPart:IsDescendantOf(character) then
				characterIsTouching = true
				if not touching then
					-- We weren't touching, now we are
					openTouch()
				end

				break
			end
		end

		if not characterIsTouching and touching then
			closeTouch()
		end
	elseif touching then
		closeTouch()
	end

	wait(0.1)
end
