-- services

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

-- constants

local CAMERA = Workspace.CurrentCamera
local PLAYER = Players.LocalPlayer

local MODULES = ReplicatedStorage:WaitForChild("RuddevModules")
	local INPUT = require(MODULES:WaitForChild("Input"))

local PlayerModule = require(PLAYER.PlayerScripts:WaitForChild("PlayerModule"))
local controls = PlayerModule:GetControls()

local GAMEPAD_DEAD = 0.15
local ZERO_VECTOR = Vector3.new()

-- variables

local character, humanoid, rootPart, stance
local waist, waistC0, neck, neckC0
local rShoulder, rShoulderC0
local lShoulder, lShoulderC0

local rotation = CFrame.new()
local lastLookUpdate = 0

-- functions

local function HandleCharacter(newCharacter)
	if newCharacter then
		character = nil

		rootPart = newCharacter:WaitForChild("HumanoidRootPart")
		humanoid = newCharacter:WaitForChild("Humanoid")
		stance = humanoid:WaitForChild("Stance")

		waist = newCharacter:WaitForChild("UpperTorso"):WaitForChild("Waist")
		waistC0 = waist.C0
		neck = newCharacter:WaitForChild("Head"):WaitForChild("Neck")
		neckC0 = neck.C0

		rShoulder = newCharacter:WaitForChild("RightUpperArm"):WaitForChild("RightShoulder")
		rShoulderC0 = rShoulder.C0
		lShoulder = newCharacter:WaitForChild("LeftUpperArm"):WaitForChild("LeftShoulder")
		lShoulderC0 = lShoulder.C0

		humanoid.AutoRotate = false

		character = newCharacter
	end
end

-- initiate

repeat local success = pcall(function() StarterGui:SetCore("ResetButtonCallback", false) end) wait() until success

HandleCharacter(PLAYER.Character)

local lastVector

RunService:BindToRenderStep("Control", Enum.RenderPriority.Input.Value - 1, function(deltaTime)
	if character and humanoid.Health > 0 then
		local lerp = math.min(deltaTime * 20, 1)
		-- rotation
		local lookVector = CAMERA.CFrame.lookVector
		rotation = rotation:Lerp(CFrame.new(Vector3.new(), Vector3.new(lookVector.X, 0, lookVector.Z)), lerp)

		-- input
		local input = Vector3.new()

		if not UserInputService:GetFocusedTextBox() then
			if UserInputService:IsKeyDown(Enum.KeyCode.W) or UserInputService:IsKeyDown(Enum.KeyCode.Up) then
				input = input + Vector3.new(0, 0, -1)
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) or UserInputService:IsKeyDown(Enum.KeyCode.Down) then
				input = input + Vector3.new(0, 0, 1)
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) or UserInputService:IsKeyDown(Enum.KeyCode.Left) then
				input = input + Vector3.new(-1, 0, 0)
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) or UserInputService:IsKeyDown(Enum.KeyCode.Right) then
				input = input + Vector3.new(1, 0, 0)
			end

			for _, inputObject in pairs(UserInputService:GetGamepadState(Enum.UserInputType.Gamepad1)) do
				if inputObject.KeyCode == Enum.KeyCode.Thumbstick1 then
					if inputObject.Position.Magnitude > GAMEPAD_DEAD then
						input = Vector3.new(inputObject.Position.X, 0, -inputObject.Position.Y)
					end
				end
			end

			if input.Magnitude > 0 then
				input = input.Unit
			end
		end

		if not rootPart:FindFirstChild("SpaceshipWeld") then
			rootPart.CFrame = CFrame.new(rootPart.Position) * rotation
		end

		humanoid:Move(input, true)
		if input ~= lastVector then
			lastVector = input
			pcall(function()
				controls:GetActiveController().moveVector = input
			end)
		end

		stance.Value = "Walk"

		-- leaning
		local camOffset = rootPart.CFrame:vectorToObjectSpace(Vector3.new(CAMERA.CFrame.lookVector.X, 0, CAMERA.CFrame.lookVector.Z).Unit)
		local hipOffset = rootPart.CFrame:vectorToObjectSpace(character.LowerTorso.CFrame.lookVector)

		local twist = -math.asin(camOffset.X) + math.asin(hipOffset.X)
		local angle = math.asin(lookVector.Y) - math.asin(character.UpperTorso.CFrame.lookVector.Y) * 0.5

		if tick() - lastLookUpdate >= 0.2 then
			--REMOTES.LookAngle:FireServer(angle, twist)
			lastLookUpdate = tick()
		end

		waist.C0 = waist.C0:Lerp(waistC0 * CFrame.Angles(angle * 0.3, twist, 0), math.min(deltaTime * 10, 1))
		neck.C0 = neck.C0:Lerp(neckC0 * CFrame.Angles(angle * 0.6, 0, 0), math.min(deltaTime * 10, 1))
		rShoulder.C0 = rShoulder.C0:Lerp(rShoulderC0 * CFrame.Angles((angle * 0.7), 0, 0), lerp)
		lShoulder.C0 = lShoulder.C0:Lerp(lShoulderC0 * CFrame.Angles((angle * 0.7), 0, 0), lerp)
	end
end)

-- events

local jumping = true

INPUT.ActionBegan:connect(function(action, processed)
	if not processed then
		if action == "Jump" then
			if character and humanoid.Health > 0 then
				-- if humanoid.FloorMaterial ~= Enum.Material.Air then
				-- 	humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
				-- end
				coroutine.wrap(function()
					jumping = true
					while jumping do
						humanoid.Jump = true
						wait(0.1)
					end
				end)()
				humanoid.Jump = true
			end
		end
	end
end)

INPUT.ActionEnded:connect(function(action, processed)
	if not processed then
		if action == "Jump" then
			jumping = false
		end
	end
end)

PLAYER.CharacterAdded:connect(HandleCharacter)