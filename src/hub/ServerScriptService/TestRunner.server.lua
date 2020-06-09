local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local TestEZ = require(ReplicatedStorage.Vendor.TestEZ)

if RunService:IsStudio() then
	TestEZ.TestBootstrap:run({ ReplicatedStorage.Core })
end
