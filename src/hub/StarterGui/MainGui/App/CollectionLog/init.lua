local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CollectionLogContents = require(script.CollectionLogContents)
local CollectionLogFilters = require(script.CollectionLogFilters)
local Context = require(script.Context)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local RoactRodux = require(ReplicatedStorage.Vendor.RoactRodux)
local Scale = require(ReplicatedStorage.Core.UI.Components.Scale)

local e = Roact.createElement

local CollectionLog = Roact.Component:extend("CollectionLog")

function CollectionLog:init()
	self:setState({
		selectedFilter = {
			Name = self.props.initialPage or "All",
			Filter = function()
				return true
			end,
		},

		updateSelectedFilter = function(newFilter)
			self:setState({
				selectedFilter = newFilter,
			})
		end,
	})
end

function CollectionLog:render()
	return e(Context.Provider, {
		value = self.state,
	}, {
		e("TextButton", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			AutoButtonColor = false,
			BackgroundColor3 = Color3.new(0.1, 0.1, 0.1),
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(1380, 600),
			Text = "",
			Visible = self.props.open,
		}, {
			UIPadding = e("UIPadding", {
				PaddingLeft = UDim.new(0.01, 0),
				PaddingRight = UDim.new(0.01, 0),
				PaddingTop = UDim.new(0.01, 0),
				PaddingBottom = UDim.new(0.01, 0),
			}),

			Scale = e(Scale, {
				Scale = 0.75,
				Size = Vector2.new(1380, 600),
			}),

			Filters = e("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(0.18, 1),
			}, {
				e(CollectionLogFilters),
			}),

			Contents = e("Frame", {
				AnchorPoint = Vector2.new(1, 0),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(1, 0),
				Size = UDim2.fromScale(0.8, 1),
			}, {
				Contents = e(CollectionLogContents),
			}),
		}),
	})
end

return RoactRodux.connect(function(state)
	return {
		open = state.page.current == "CollectionLog",
	}
end)(CollectionLog)
