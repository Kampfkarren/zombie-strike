local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Vendor.Roact)

local EggOpen = require(script.EggOpen)
local EggPrompt = require(script.EggPrompt)

local e = Roact.createElement

local Pets = Roact.Component:extend("Pets")

function Pets:init()
	self.eggOpen, self.updateEggOpen = Roact.createBinding(false)
end

function Pets:render()
	return e("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
	}, {
		EggOpen = e(EggOpen, {
			updateEggOpen = self.updateEggOpen,
		}),

		EggPrompt = e(EggPrompt, {
			eggOpen = self.eggOpen,
		}),
	})
end

return Pets
