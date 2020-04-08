local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SelectScreen = require(script.Parent.SelectScreen)
local Roact = require(ReplicatedStorage.Vendor.Roact)

local e = Roact.createElement

return function(target)
	local inventory = {
		{
			Name = "Default",
			Type = "Face",

			Instance = ReplicatedStorage.Dummy.Head.face,
		},

		{
			Name = ":3",
			Type = "Face",

			Instance = ReplicatedStorage.Items.Face_Cat.Face,
		},
	}

	local handle = Roact.mount(
		e("Frame", {
			BackgroundColor3 = Color3.new(1, 1, 1),
			Size = UDim2.fromScale(1, 1),
		}, {
			e(SelectScreen, {
				Angle = Vector3.new(-1, 0.8, -1),
				Equipped = inventory[2],
				Inventory = inventory,
				ShowGearScore = false,
				Text = "a face",

				GetName = function(item)
					return item.Name
				end,

				GoBack = function() end,
				Equip = function() end,
			})
		}), target, "SelectScreen"
	)

	return function()
		Roact.unmount(handle)
	end
end
