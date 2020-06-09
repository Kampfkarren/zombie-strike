local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Promise = require(ReplicatedStorage.Core.Promise)
local State = require(ReplicatedStorage.State)

local RedeemVoucher = ReplicatedStorage.Remotes.RedeemVoucher

local resolveVoucher

local function redeemVoucher()
	return Promise.new(function(resolve)
		resolveVoucher = resolve
		RedeemVoucher:FireServer()
	end)
end

RedeemVoucher.OnClientEvent:connect(function(uuid)
	State:flush() -- Guarantee inventory has been set

	for _, item in ipairs(State:getState().inventory) do
		if item.UUID == uuid then
			resolveVoucher(item)
			return
		end
	end
end)

return redeemVoucher
