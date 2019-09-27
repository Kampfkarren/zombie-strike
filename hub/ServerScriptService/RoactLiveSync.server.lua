local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

if not RunService:IsStudio() then return end

local liveSyncEvent = Instance.new("RemoteEvent")
liveSyncEvent.Name = "LiveSync"
liveSyncEvent.Parent = ReplicatedStorage

local rerenderPlanned = false

-- Prevents constant reconciliation
local function planRerender()
	if rerenderPlanned then return end
	rerenderPlanned = true
	RunService.Heartbeat:wait()
	liveSyncEvent:FireAllClients()
	rerenderPlanned = false
end

local function hookLiveSync(instance)
	instance.Changed:connect(planRerender)
	instance.ChildAdded:connect(planRerender)
	instance.ChildRemoved:connect(planRerender)

	for _, child in pairs(instance:GetChildren()) do
		hookLiveSync(child)
	end
end

hookLiveSync(StarterGui.MainGui.App)
hookLiveSync(ReplicatedStorage.Libraries.Friends)
