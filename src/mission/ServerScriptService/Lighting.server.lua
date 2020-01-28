local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local GetCodeName = require(ReplicatedStorage.Libraries.GetCodeName)

local lightingMod = ServerStorage.Campaigns[GetCodeName()].Lighting

for _, property in pairs(lightingMod.Properties:GetChildren()) do
	Lighting[property.Name] = property.Value
end

for _, child in pairs(lightingMod.Children:GetChildren()) do
	child.Parent = Lighting
end
