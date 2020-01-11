local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BattlePassMenu = require(script.BattlePassMenu)
local BattlePassRewards = require(script.BattlePassRewards)
local Roact = require(ReplicatedStorage.Vendor.Roact)

local e = Roact.createElement

local function BattlePass()
	return e("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
	}, {
		BattlePassMenu = e(BattlePassMenu),
		BattlePassRewards = e(BattlePassRewards),
	})
end

return BattlePass
