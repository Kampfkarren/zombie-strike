local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local CoreData = require(ReplicatedStorage.Core.CoreData)

local Data = {}

Data.GetModel = CoreData.GetModel
Data.LocalPlayerData = {}

local dataSet = Instance.new("BindableEvent")

function Data.SetLocalPlayerData(key, value)
	Data.LocalPlayerData[key] = value
	dataSet:Fire()
end

function Data.GetLocalPlayerData(key)
	local data = Data.LocalPlayerData[key]

	while not data do
		dataSet.Event:wait()
		data = Data.LocalPlayerData[key]
	end

	return data
end

if RunService:IsServer() then
	for key, value in pairs(require(ServerScriptService.Libraries.Data)) do
		Data[key] = value
	end
end

return Data
