local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Vendor.Roact)

local e = Roact.createElement

local ImageSearch = require(ReplicatedStorage.Assets.Tarmac.UI.search)

-- This isn't the best way to do this, since TextBox is already managed by Roact
-- But I don't want to create an entire class component.
-- Hooks when?
local function captureFocus(rbx)
	local textBox = rbx:FindFirstChildOfClass("TextBox")
	if textBox then
		textBox:CaptureFocus()
	end
end

local function SearchBar(props)
	return e("ImageButton", {
		BackgroundTransparency = 1,
		Image = ImageSearch,
		Position = UDim2.fromOffset(0, 8),
		ScaleType = Enum.ScaleType.Crop,
		Size = UDim2.fromOffset(368, 54),
		[Roact.Event.Activated] = captureFocus,
	}, {
		TextBox = e("TextBox", {
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			PlaceholderText = "Search for something...",
			Position = UDim2.new(0, 78, 0.5,0 ),
			Size = UDim2.fromOffset(270, 22),
			Text = props.Search,
			TextColor3 = Color3.new(1, 1, 1),
			TextSize = 22,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,

			[Roact.Change.Text] = props.SearchChanged,
		}),
	})
end

return SearchBar
