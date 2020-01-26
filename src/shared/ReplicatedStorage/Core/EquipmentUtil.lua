local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Data = require(ReplicatedStorage.Core.Data)
local Memoize = require(ReplicatedStorage.Core.Memoize)

local Equipment = ReplicatedStorage.Equipment

local EquipmentUtil = {}

local equipmentMap = {
	Grenade = {},
	HealthPack = {},
}

for name, map in pairs(equipmentMap) do
	for _, equipmentScript in pairs(Equipment[name]:GetChildren()) do
		local equipment = require(equipmentScript)
		map[equipment.Index] = equipment
	end
end

local function equipmentGetter(name)
	return function(player)
		local equipped

		if RunService:IsServer() then
			assert(player ~= nil)
			equipped = Data.GetPlayerData(player, "Equipped" .. name)
		else
			equipped = Players.LocalPlayer:WaitForChild("PlayerData"):WaitForChild("Equipped" .. name).Value
		end

		return assert(equipmentMap[name][equipped])
	end
end

EquipmentUtil.GetHealthPack = equipmentGetter("HealthPack")
EquipmentUtil.GetGrenade = equipmentGetter("Grenade")

function EquipmentUtil.GetColor(type)
	if type == "Grenade" then
		return Color3.fromRGB(37, 107, 57)
	elseif type == "HealthPack" then
		return Color3.fromRGB(255, 118, 117)
	else
		error("unreachable code! type == " .. type)
	end
end

function EquipmentUtil.FromIndex(type, index)
	return assert(equipmentMap[type][index])
end

function EquipmentUtil.GetModel(type, index)
	local lootInstance = ReplicatedStorage.Items[type .. index]:Clone()

	local model

	if lootInstance:IsA("Model") then
		model = lootInstance
	else
		model = Instance.new("Model")

		local part = lootInstance
		part.Parent = model

		model.PrimaryPart = part
	end

	local uuid = Instance.new("StringValue")
	uuid.Name = "UUID"
	uuid.Value = type .. index
	uuid.Parent = model

	return model
end

EquipmentUtil.GetModel = Memoize(EquipmentUtil.GetModel)

return EquipmentUtil
