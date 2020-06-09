local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BuyCaps = require(script.Parent.BuyCaps)
local CreateMockRemote = require(ReplicatedStorage.Core.CreateMockRemote)
local CreateMockState = require(ReplicatedStorage.Libraries.CreateMockState)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local RoactRodux = require(ReplicatedStorage.Vendor.RoactRodux)

local e = Roact.createElement

return function(target)
	local ref = Roact.createRef()
	local remote = CreateMockRemote()

	remote.OnServerEvent:connect(function(nonce)
		remote:FireClient(nonce)
	end)

	local handle = Roact.mount(
		e(RoactRodux.StoreProvider, {
			store = CreateMockState.Normal("Store"),
		}, {
			Frame = e("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.6, 0.7),
			}, {
				UIAspectRatioConstraint = e("UIAspectRatioConstraint", {
					AspectRatio = 2,
				}),

				BuyCaps = e(BuyCaps, {
					[Roact.Ref] = ref,
					remote = remote,
				}),
			}),
		}), target, "BuyCaps"
	)

	return function()
		Roact.unmount(handle)
	end
end
