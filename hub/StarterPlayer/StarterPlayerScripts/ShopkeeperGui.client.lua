local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local State = require(ReplicatedStorage.State)

local LocalPlayer = Players.LocalPlayer
local ShopkeeperRange = CollectionService:GetTagged("ShopkeeperRange")[1]

local touching = false

local function closeTouch()
	if not touching then return end
	touching = false
	State:dispatch({
		type = "CloseShopkeeper",
	})
end

local function openTouch()
	if touching then return end
	touching = true
	State:dispatch({
		type = "OpenShopkeeper",
	})
end

ShopkeeperRange.Touched:connect(function() end)

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
