local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GamePassDictionary = require(ReplicatedStorage.Core.GamePassDictionary)
local GamePasses = require(ReplicatedStorage.Core.GamePasses)

for _, passId in pairs(GamePassDictionary) do
	GamePasses.ListenForPass(passId)
end
