-- This is bad code, but LootInfo wasn't turned into a Roact component until later
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LootInfo = require(ReplicatedStorage.Core.UI.Components.LootInfo)
local Maid = require(ReplicatedStorage.Core.Maid)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local RoactRodux = require(ReplicatedStorage.Vendor.RoactRodux)
local State = require(ReplicatedStorage.State)

local e = Roact.createElement

local lootInfoStacks = {}

return function(lootButton, lootInfoUi, loot, callback)
	lootInfoUi:ClearAllChildren()

	local maid = Maid.new()
	callback = callback or function() end

	local mounted

	local function lootInfo()
		if mounted then
			Roact.unmount(mounted)
		end

		mounted = Roact.mount(e(RoactRodux.StoreProvider, {
			store = State,
		}, {
			e(LootInfo, {
				Native = {
					Size = UDim2.new(1, 0, 1, 0),
				},

				Loot = loot,
			})
		}), lootInfoUi)
	end

	local stack = lootInfoStacks[lootInfoUi]

	if not stack then
		stack = {}
		lootInfoStacks[lootInfoUi] = stack
	end

	local function hover()
		stack[lootButton] = true
		lootInfo()
		lootInfoUi.Visible = true
		callback(true)
	end

	local function unhover()
		stack[lootButton] = nil
		callback(false)
		if mounted then
			Roact.unmount(mounted)
		end

		if next(stack) == nil then
			lootInfoUi.Visible = false
		end
	end

	maid:GiveTask(lootButton.MouseEnter:connect(hover))
	maid:GiveTask(lootButton.MouseLeave:connect(unhover))

	maid:GiveTask(lootButton:GetPropertyChangedSignal("Visible"):connect(function()
		if not lootButton.Visible then
			unhover()
		end
	end))

	maid:GiveTask(lootButton.SelectionGained:connect(hover))
	maid:GiveTask(lootButton.SelectionLost:connect(unhover))
	maid:GiveTask(unhover)

	return maid, hover
end
