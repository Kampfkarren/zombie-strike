local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FastSpawn = require(ReplicatedStorage.Core.FastSpawn)
local State = require(ReplicatedStorage.State)

local LocalPlayer = Players.LocalPlayer

return function(name, onTouch)
	local range = CollectionService:GetTagged(name .. "Range")[1]
	local touching = false

	local function closeTouch()
		if not touching then return end
		touching = false
		State:dispatch({
			type = "Close" .. name,
		})
	end

	local function openTouch()
		if touching then return end
		touching = true
		State:dispatch({
			type = "Open" .. name,
		})

		if onTouch then
			onTouch()
		end
	end

	range.Touched:connect(function() end)

	FastSpawn(function()
		while true do
			local character = LocalPlayer.Character

			if character then
				local characterIsTouching = false

				for _, touchingPart in pairs(range:GetTouchingParts()) do
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
	end)
end
