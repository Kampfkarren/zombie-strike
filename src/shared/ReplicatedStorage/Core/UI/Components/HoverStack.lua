local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Vendor.Roact)

local HoverStack = Roact.PureComponent:extend("HoverStack")

function HoverStack:init()
	self:setState({
		hoverStack = {},
	})

	self.hoverFunctions = {}
	self.unhoverFunctions = {}

	self.hover = function(data)
		if self.hoverFunctions[data] == nil then
			self.hoverFunctions[data] = function()
				if table.find(self.state.hoverStack, data) then return end

				local newHoverStack = {}

				for _, hovered in ipairs(self.state.hoverStack) do
					table.insert(newHoverStack, hovered)
				end

				table.insert(newHoverStack, data)

				self:setState({
					hoverStack = newHoverStack,
				})
			end
		end

		return self.hoverFunctions[data]
	end

	self.unhover = function(data)
		if self.unhoverFunctions[data] == nil then
			self.unhoverFunctions[data] = function()
				if not table.find(self.state.hoverStack, data) then return end

				local newHoverStack = {}

				for _, hovered in ipairs(self.state.hoverStack) do
					if hovered ~= data then
						table.insert(newHoverStack, hovered)
					end
				end

				self:setState({
					hoverStack = newHoverStack,
				})
			end
		end

		return self.unhoverFunctions[data]
	end
end

function HoverStack:render()
	return self.props.Render(self.state.hoverStack[#self.state.hoverStack], self.hover, self.unhover)
end

return HoverStack
