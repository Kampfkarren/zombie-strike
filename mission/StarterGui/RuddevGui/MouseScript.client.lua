-- services

local UserInputService	= game:GetService("UserInputService")
local ReplicatedStorage	= game:GetService("ReplicatedStorage")
local TweenService		= game:GetService("TweenService")
local RunService		= game:GetService("RunService")
local Workspace			= game:GetService("Workspace")
local Players			= game:GetService("Players")
local Lighting			= game:GetService("Lighting")
local Debris			= game:GetService("Debris")

-- constants

local PLAYER	= Players.LocalPlayer
local CAMERA	= Workspace.CurrentCamera
local EFFECTS	= Workspace:WaitForChild("Effects")
local EVENTS	= ReplicatedStorage:WaitForChild("RuddevEvents")
local REMOTES	= ReplicatedStorage:WaitForChild("RuddevRemotes")
local MODULES	= ReplicatedStorage:WaitForChild("RuddevModules")
	local MOUSE		= require(MODULES:WaitForChild("Mouse"))
	local SPRING	= require(MODULES:WaitForChild("Spring"))

local GUI		= script.Parent
local MOUSE_GUI	= GUI:WaitForChild("Mouse")

local hubWorld = ReplicatedStorage.HubWorld.Value

-- variables

local reticleSize		= 0.1
local currentReticle	= ""

local aiming	= false

MOUSE_GUI.Visible = true

-- functions

local function Lerp(a, b, d) return a + (b - a) * d end

local function UpdateReticle()
	for _, reticle in pairs(MOUSE_GUI:GetChildren()) do
		reticle.Visible	= reticle.Name == MOUSE.Reticle and UserInputService.MouseEnabled
	end
end

local function Hitmarker(headshot, position)
	local hitmarker	= script.Hitmarker:Clone()
	if UserInputService.MouseEnabled then
		hitmarker.AnchorPoint = Vector2.new(0.5, 0.5)
		hitmarker.Position	= UDim2.new(0.5, 0, 0.5, 0)
		hitmarker.Size		= UDim2.new(0.05, 0, 0.05, 0)
		hitmarker.Parent	= GUI
	else
		local position = workspace.CurrentCamera:WorldToScreenPoint(position)
		hitmarker.Position = UDim2.new(0, position.X, 0, position.Y)
		hitmarker.Size = UDim2.new(0.05, 0, 0.05, 0)
		hitmarker.Parent = GUI
	end

	if headshot then
		for _, frame in pairs(hitmarker:GetChildren()) do
			if frame.Name ~= "Shadow" then
				frame.BackgroundColor3	= Color3.new(1, 0.2, 0.2)
			end
		end
	end

	local infoB		= TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
	local tweenB	= TweenService:Create(hitmarker, infoB, {Size = UDim2.new(0.015, 0, 0.015, 0)})

	tweenB:Play()
	Debris:AddItem(hitmarker, 0.1)

	script.HitmarkerSound:Play()

	if armor then
		script.ArmorSound:Play()
	end
	if headshot then
		script.HeadshotSound:Play()
	end
end

-- initiate

local lastScreenPos

if hubWorld then
	local mouse = PLAYER:GetMouse()
	lastScreenPos = Vector2.new(mouse.X, mouse.Y)

	UserInputService.InputChanged:connect(function(inputObject)
		if inputObject.UserInputType == Enum.UserInputType.MouseMovement then
			MOUSE_GUI.AnchorPoint = Vector2.new(0, 0)
			lastScreenPos = Vector2.new(inputObject.Position.X, inputObject.Position.Y)
			MOUSE_GUI.Position = UDim2.new(0, inputObject.Position.X - 12, 0, inputObject.Position.Y - 12)
		elseif inputObject.KeyCode == Enum.KeyCode.Thumbstick2 then
			MOUSE_GUI.AnchorPoint = Vector2.new(0.5, 0.5)
			MOUSE_GUI.Position = UDim2.new(0.5, 0, 0.5, 0)
		end
	end)
end

RunService:BindToRenderStep("Mouse", 5, function(deltaTime)
	if MOUSE.Reticle ~= currentReticle then
		currentReticle	= MOUSE.Reticle
		UpdateReticle()
	end

	-- MOUSE_GUI.Position	= UDim2.new(0.5, 0, 0.5, 0)

	local ignore	= {EFFECTS}
	if PLAYER.Character then
		table.insert(ignore, PLAYER.Character)
	end

	local h, pos
	local screenPos
	if hubWorld then
		screenPos = lastScreenPos
	else
		screenPos = MOUSE_GUI.AbsolutePosition + MOUSE_GUI.AbsoluteSize / 2
	end
	local ray		= CAMERA:ScreenPointToRay(screenPos.X, screenPos.Y, 0)
	local mouseRay	= Ray.new(CAMERA.CFrame.p, ray.Direction * 1000)

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

	MOUSE.ScreenPosition	= screenPos
	MOUSE.WorldPosition		= pos
end)

-- events

REMOTES.Finished.OnClientEvent:connect(function()
	MOUSE_GUI.Visible	= false

	script.Disabled	= true
end)

EVENTS.Aim.Event:connect(function(a)
	aiming	= a
end)

EVENTS.Hitmarker.Event:connect(Hitmarker)

REMOTES.Hitmarker.OnClientEvent:connect(Hitmarker)