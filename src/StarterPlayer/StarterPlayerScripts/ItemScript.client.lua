-- services

local UserInputService	= game:GetService("UserInputService")
local ReplicatedStorage	= game:GetService("ReplicatedStorage")
local RunService		= game:GetService("RunService")
local Workspace			= game:GetService("Workspace")
local Players			= game:GetService("Players")
local GuiService = game:GetService("GuiService")

-- constants

local PLAYER		= Players.LocalPlayer
local GUN_MODULE	= require(ReplicatedStorage.ItemModules.Gun)
local MODULES		= ReplicatedStorage:WaitForChild("RuddevModules")
	local INPUT			= require(MODULES:WaitForChild("Input"))
	local MOUSE = require(MODULES.Mouse)

local itemModule

-- functions

local function HandleItem(item)
	local config	= require(item:WaitForChild("Config"))

	itemModule = GUN_MODULE:Create(item)
	itemModule:Connect()
end

local function HandleCharacter(character)
	if character then
		if itemModule then
			itemModule:Disconnect()
		end

		local gun = character:WaitForChild("Gun")

		repeat RunService.Stepped:wait() until character:IsDescendantOf(Workspace)

		HandleItem(gun)
		itemModule:Equip()
	end
end

-- initiate

HandleCharacter(PLAYER.Character)

-- events

INPUT.ActionBegan:connect(function(action, processed)
	if not processed then
		if action == "Primary" then
			if UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter then
				local character	= PLAYER.Character
				if character then
					itemModule:Activate()
				end
			end
		end
	end
end)

INPUT.ActionEnded:connect(function(action, processed)
	if not processed then
		if action == "Primary" then
			local character	= PLAYER.Character
			if character then
				itemModule:Deactivate()
			end
		end
	end
end)

UserInputService.TouchTap:connect(function(touchPositions, processed)
	if processed then return end
	if itemModule then
		local screenPos = touchPositions[#touchPositions]
		local lastScreen, lastWorld = MOUSE.ScreenPosition, MOUSE.WorldPosition

		MOUSE.ScreenPosition = Vector2.new(screenPos.X, screenPos.Y)

		-- Ruddev Code
		local ignore = { workspace.Effects, PLAYER.Character }
		local h, pos
		local ray		= workspace.CurrentCamera:ScreenPointToRay(screenPos.X, screenPos.Y, 0)
		local mouseRay	= Ray.new(workspace.CurrentCamera.CFrame.p, ray.Direction * 1000)

		local finished	= false

		repeat
			h, pos	= Workspace:FindPartOnRayWithIgnoreList(mouseRay, ignore)

			if h then
				if h.Parent:FindFirstChildOfClass("Humanoid") then
					finished	= true
				elseif h.Transparency >= 0.5 then
					table.insert(ignore, h)
				else
					if h.CanCollide then
						finished	= true
					else
						table.insert(ignore, h)
					end
				end
			else
				finished	= true
			end
		until finished
		-- End

		MOUSE.ScreenPosition = screenPos
		MOUSE.WorldPosition = pos

		coroutine.wrap(itemModule.Activate)()
		itemModule:Deactivate()

		MOUSE.ScreenPosition = lastScreen
		MOUSE.WorldPosition = lastWorld
	end
end)

PLAYER.CharacterAdded:connect(HandleCharacter)