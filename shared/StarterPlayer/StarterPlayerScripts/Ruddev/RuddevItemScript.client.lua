-- services

local UserInputService	= game:GetService("UserInputService")
local ReplicatedStorage	= game:GetService("ReplicatedStorage")
local RunService		= game:GetService("RunService")
local Workspace			= game:GetService("Workspace")
local Players			= game:GetService("Players")

-- constants

local PLAYER		= Players.LocalPlayer
local GUN_MODULE	= require(ReplicatedStorage.ItemModules.Gun)
local MODULES		= ReplicatedStorage:WaitForChild("RuddevModules")
	local INPUT			= require(MODULES:WaitForChild("Input"))

local AutoAim = require(script.Parent.AutoAim)

local hubWorld = ReplicatedStorage.HubWorld.Value
local itemModule

-- functions

local function HandleItem(item)
	itemModule = GUN_MODULE:Create(item)
	itemModule:Connect()
	AutoAim.SetItemModule(itemModule)
end

local function HandleCharacter(character)
	if character then
		if itemModule then
			itemModule:Disconnect()
		end

		repeat RunService.Stepped:wait() until character:IsDescendantOf(Workspace)

		local function equipGun(gun)
			if itemModule then
				itemModule:Unequip()
				itemModule:Disconnect()
			end

			HandleItem(gun)
			itemModule:Equip()
		end

		local gun = character:FindFirstChild("Gun")
		if gun then
			equipGun(gun)
		end

		character.ChildAdded:connect(function(gun)
			if gun.Name == "Gun" then
				equipGun(gun)
			end
		end)
	end
end

-- initiate

HandleCharacter(PLAYER.Character)

-- events
INPUT.ActionBegan:connect(function(action, processed)
	if not processed then
		if action == "Primary" then
			if UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter or hubWorld then
				local character	= PLAYER.Character
				if character and itemModule then
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
			if character and itemModule then
				itemModule:Deactivate()
			end
		end
	end
end)

PLAYER.CharacterAdded:connect(HandleCharacter)