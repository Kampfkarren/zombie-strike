local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local Roact = require(ReplicatedStorage.Vendor.Roact)

local existingTree

Roact.setGlobalConfig({
	elementTracing = true,
})

local function render()
	if existingTree then
		Roact.unmount(existingTree)
	end

	local app = require(StarterGui.MainGui.App:Clone())

	existingTree = Roact.mount(app, script.Parent.Main)
end

render()
