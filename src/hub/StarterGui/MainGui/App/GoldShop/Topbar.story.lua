local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CreateMockState = require(ReplicatedStorage.Libraries.CreateMockState)
local Topbar = require(script.Parent.Topbar)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local RoactRodux = require(ReplicatedStorage.Vendor.RoactRodux)

local e = Roact.createElement

return function(target)
	local handle = Roact.mount(
		e(RoactRodux.StoreProvider, {
			store = CreateMockState.Normal("Topbar"),
		}, {
			Contents = e("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromOffset(900, 50),
			}, {
				Topbar = e(Topbar, {
					CurrentPage = "Weapons",
					SelectPage = function(page)
						return function()
							print(page)
						end
					end,
				}),
			}),
		}), target, "Topbar"
	)

	return function()
		Roact.unmount(handle)
	end
end
