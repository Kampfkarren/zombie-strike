local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local Roact = require(ReplicatedStorage.Vendor.Roact)

local existingTree

Roact.setGlobalConfig({
	elementTracing = true,
	propValidation = RunService:IsStudio(),
})

local function render()
	if existingTree then
		Roact.unmount(existingTree)
	end

	local app = require(StarterGui.MainGui.App:Clone())

	existingTree = Roact.mount(app, script.Parent.Main)
end

if RunService:IsStudio() then
	ReplicatedStorage:WaitForChild("LiveSync").OnClientEvent:connect(render)
end

render()
