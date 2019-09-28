local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local resetBindable = Instance.new("BindableEvent")
resetBindable.Event:connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
		-- re-enable death state
		LocalPlayer.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
		LocalPlayer.Character:BreakJoints()
		-- force death
	end
end)

local function onCharacterAdded(character)
	if character == nil then
		return
	end
	if character.Parent == nil then
		character.AncestryChanged:wait()
	end
	local humanoid = character:WaitForChild("Humanoid")
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
end

LocalPlayer.CharacterAdded:connect(onCharacterAdded)
onCharacterAdded(LocalPlayer.Character)

repeat
	local success = pcall(function()
		game:GetService("StarterGui"):SetCore("ResetButtonCallback", resetBindable)
	end)

	RunService.Heartbeat:wait()
until success
