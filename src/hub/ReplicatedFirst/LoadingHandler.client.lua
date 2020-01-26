local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")

local LocalPlayer = Players.LocalPlayer

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

ReplicatedFirst:RemoveDefaultLoadingScreen()

local blur = ReplicatedFirst.Blur
blur.Parent = Lighting

local gui = ReplicatedFirst.LoadingGui
gui.Parent = PlayerGui

local loaded = false

coroutine.wrap(function()
	local dotCount = 3

	while not loaded do
		dotCount = (dotCount % 3) + 1
		gui.Label.Text = "LOADING DATA" .. ("."):rep(dotCount)
		wait(0.1)
	end
end)()

LocalPlayer.CharacterAdded:wait()

loaded = true
gui:Destroy()
blur:Destroy()
