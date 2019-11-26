-- Not written by Ruddev
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

if ReplicatedStorage.HubWorld.Value then
	return { SetItemModule = function() end }
end

local Config = require(ReplicatedStorage.RuddevModules.Config)
local Maid = require(ReplicatedStorage.Core.Maid)
local Mouse = require(ReplicatedStorage.RuddevModules.Mouse)
local LineOfSight = require(ReplicatedStorage.Libraries.LineOfSight)

local CurrentCamera = Workspace.CurrentCamera
local Zombies = Workspace:WaitForChild("Zombies")

local AutoAim = {}

local AIM_ANGLE = math.rad(35)
local ROTATE_RATE = 20
local SIZE_MAX = 5
local SIZE_MIN = 2.5

local itemModule
local target, targetMaid

local hitmarker = Instance.new("BillboardGui")
hitmarker.AlwaysOnTop = true
hitmarker.ClipsDescendants = true
hitmarker.Enabled = false
hitmarker.Size = UDim2.new(SIZE_MAX, 0, SIZE_MAX, 0)

local label = Instance.new("TextLabel")
label.BackgroundTransparency = 1
label.Font = Enum.Font.GothamBold
label.Rotation = 45
label.Size = UDim2.new(1, 0, 1, 0)
label.Text = "+"
label.TextColor3 = Color3.fromRGB(185, 0, 0)
label.TextSize = 20
label.TextTransparency = 0.2
label.Parent = hitmarker

local selectionBox = Instance.new("SelectionBox")
selectionBox.Color3 = Color3.new(1, 0, 0)
selectionBox.Parent = Workspace

local tweenShrink = TweenService:Create(
	hitmarker,
	TweenInfo.new(0.7, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	{ Size = UDim2.new(SIZE_MAX, 0, SIZE_MIN, 0) }
)

RunService.Heartbeat:connect(function(delta)
	label.Rotation = label.Rotation + delta * ROTATE_RATE
end)

hitmarker.Parent = Workspace

function AutoAim.GetMaxRange()
	local config = Config:GetConfig(itemModule.Item)

	if config.Type == "Sniper" then
		return 100
	elseif config.Type == "Shotgun" then
		return 25
	else
		return 40
	end
end

function AutoAim.CanFocusTarget(target, skipRange)
	if not itemModule then
		return false
	end

	if target.Humanoid.Health <= 0 then
		return false
	end

	local range = skipRange and 1000 or AutoAim.GetMaxRange()
	local zombieBlacklist = { Workspace.Effects }

	for _, zombie in pairs(Zombies:GetChildren()) do
		if zombie ~= target then
			table.insert(zombieBlacklist, zombie)
		end
	end

	local cameraPosition = CurrentCamera.CFrame.Position

	if LineOfSight(cameraPosition, target, range, zombieBlacklist) then
		local angle = math.acos((target.PrimaryPart.Position - cameraPosition)
			.Unit:Dot(CurrentCamera.CFrame.LookVector))

		return math.abs(angle) < AIM_ANGLE
	end
end

function AutoAim.SetTarget(newTarget)
	target = newTarget

	if targetMaid then
		targetMaid:DoCleaning()
	end

	if newTarget == nil then
		return
	end

	if not itemModule then
		return
	end

	targetMaid = Maid.new()

	targetMaid:GiveTask(function()
		hitmarker.Adornee = nil
		hitmarker.Enabled = false
		selectionBox.Adornee = nil

		if itemModule then
			itemModule:Deactivate()
		end

		target = nil
	end)

	Mouse.WorldPosition = newTarget.PrimaryPart.Position

	targetMaid:GiveTask(newTarget.Humanoid.Died:connect(function()
		targetMaid:DoCleaning()
	end))

	targetMaid:GiveTask(RunService.Heartbeat:connect(function()
		if not AutoAim.CanFocusTarget(newTarget, true) then
			AutoAim.SetTarget(nil)
		else
			Mouse.WorldPosition = newTarget.PrimaryPart.Position
			coroutine.wrap(itemModule.Activate)()
		end
	end))

	hitmarker.Adornee = newTarget.PrimaryPart
	hitmarker.Enabled = true
	hitmarker.Size = UDim2.new(SIZE_MAX, 0, SIZE_MAX, 0)
	selectionBox.Adornee = newTarget.PrimaryPart
	tweenShrink:Play()
end

function AutoAim.SetItemModule(newModule)
	itemModule = newModule
end

-- Slightly modified Ruddev code
local function getHumanAtPosition(screenPos)
	local ignore = { Workspace.Effects }

	for _, player in pairs(Players:GetPlayers()) do
		table.insert(ignore, player.Character)
	end

	local h

	local ray = CurrentCamera:ViewportPointToRay(screenPos.X, screenPos.Y, 0)
	local mouseRay = Ray.new(CurrentCamera.CFrame.p, ray.Direction * 1000)

	while true do
		h = Workspace:FindPartOnRayWithIgnoreList(mouseRay, ignore)

		if h then
			if h.Parent:FindFirstChildOfClass("Humanoid") then
				return h.Parent
			elseif h.Transparency >= 0.5 then
				table.insert(ignore, h)
			else
				if h.CanCollide then
					return
				else
					table.insert(ignore, h)
				end
			end
		else
			return
		end
	end
end

-- TODO: Go back to explicitly tapped focus if there's no target left
RunService.Heartbeat:connect(function()
	if UserInputService.MouseEnabled
		or UserInputService.GamepadEnabled
	then
		return
	end

	if target == nil then
		local closest = { nil, math.huge }

		local cameraPosition = CurrentCamera.CFrame.Position

		for _, zombie in pairs(Zombies:GetChildren()) do
			local humanoid = zombie:FindFirstChild("Humanoid")
			if humanoid and humanoid.Health > 0 then
				if AutoAim.CanFocusTarget(zombie) then
					local range = (zombie.PrimaryPart.Position - cameraPosition).Magnitude
					if range < closest[2] then
						closest = { zombie, range }
					end
				end
			end
		end

		if closest[1] then
			AutoAim.SetTarget(closest[1])
		else
			local boss = CollectionService:GetTagged("Boss")[1]
			if boss and boss:WaitForChild("Humanoid").Health > 0 then
				AutoAim.SetTarget(boss)
			end
		end
	end
end)

UserInputService.TouchTapInWorld:connect(function(position, processed)
	if processed then return end

	local human = getHumanAtPosition(position)

	if human and human.Humanoid.Health > 0 then
		AutoAim.SetTarget(human)
	end
end)

return AutoAim
