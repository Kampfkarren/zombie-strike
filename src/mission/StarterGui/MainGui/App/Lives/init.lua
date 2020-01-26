local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Dungeon = require(ReplicatedStorage.Libraries.Dungeon)
local FastSpawn = require(ReplicatedStorage.Core.FastSpawn)
local LivesText = require(ReplicatedStorage.Libraries.LivesText)
local Roact = require(ReplicatedStorage.Vendor.Roact)

local Lives = Roact.Component:extend("Lives")

local e = Roact.createElement

function Lives:init()
	FastSpawn(function()
		if Dungeon.GetGamemodeInfo().Lives ~= nil then
			local livesObject = ReplicatedStorage:WaitForChild("Lives")

			self:setState({
				lives = livesObject.Value,
			})

			livesObject.Changed:Connect(function(lives)
				self:setState({
					lives = lives,
				})
			end)
		end
	end)
end

function Lives:render()
	return self.state.lives and e("TextLabel", {
		AnchorPoint = Vector2.new(0, 1),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Position = UDim2.fromScale(0.01, 0.99),
		Size = UDim2.fromScale(0.4, 0.1),
		Text = LivesText(self.state.lives),
		TextColor3 = Color3.new(1, 0.6, 1),
		TextScaled = true,
		TextXAlignment = Enum.TextXAlignment.Left,
	})
end

return Lives
