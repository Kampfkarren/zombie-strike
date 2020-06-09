local CollectionService = game:GetService("CollectionService")
local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local AlternateMobileButton = require(ReplicatedStorage.Core.AlternateMobileButton)
local FastSpawn = require(ReplicatedStorage.Core.FastSpawn)
local LastInputTypeWatcher = require(ReplicatedStorage.Core.LastInputTypeWatcher)
local State = require(ReplicatedStorage.State)

local LocalPlayer = Players.LocalPlayer

-- TODO: Everything should probably use tooltips, so we can remove the boolean parameter
local killLastAction

return function(name, onTouch, usesTooltip, tooltipIcon)
	local range = CollectionService:GetTagged(name .. "Range")[1]
	local tooltip = range.Parent:FindFirstChild("ContextPrompt", true)
	local touching = false

	local actionName = name .. "Tooltip"
	local killInputTypeWatcher

	local function closeTouch()
		if not touching then return end
		touching = false

		if usesTooltip then
			killInputTypeWatcher()
			tooltip.Enabled = false

			if killLastAction ~= nil then
				killLastAction()
			end

			ContextActionService:UnbindAction(actionName)
		end

		State:dispatch({
			type = "Close" .. name,
		})
	end

	local function openTouch()
		if touching then return end
		touching = true

		if usesTooltip then
			killInputTypeWatcher = LastInputTypeWatcher({
				[Enum.UserInputType.Keyboard] = function()
					tooltip.Background.Keyboard.Visible = true
					tooltip.Background.Gamepad.Visible = false
				end,

				[Enum.UserInputType.Gamepad1] = function()
					tooltip.Background.Keyboard.Visible = false
					tooltip.Background.Gamepad.Visible = true
				end,
			})

			-- parker please don't break this
			tooltip.Enabled = UserInputService.KeyboardEnabled or UserInputService.GamepadEnabled

			killLastAction = AlternateMobileButton({
				Activate = function()
					State:dispatch({
						type = "Toggle" .. name,
					})
				end,

				Image = tooltipIcon,
			})

			ContextActionService:BindAction(actionName, function(_, inputState)
				if inputState == Enum.UserInputState.Begin then
					State:dispatch({
						type = "Toggle" .. name,
					})
				end
			end, false, Enum.KeyCode.ButtonX, Enum.KeyCode.F)
		else
			State:dispatch({
				type = "Open" .. name,
			})
		end

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
