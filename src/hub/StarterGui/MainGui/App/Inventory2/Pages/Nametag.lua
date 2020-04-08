local ReplicatedStorage = game:GetService("ReplicatedStorage")

local InventoryComponents = script.Parent.Parent.Components

local Alert = require(ReplicatedStorage.Core.UI.Components.Alert)
local BackButton = require(InventoryComponents.BackButton)
local FontsDictionary = require(ReplicatedStorage.Core.FontsDictionary)
local GradientButton = require(ReplicatedStorage.Core.UI.Components.GradientButton)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local RoactRodux = require(ReplicatedStorage.Vendor.RoactRodux)
local Scale = require(ReplicatedStorage.Core.UI.Components.Scale)
local TitlesDictionary = require(ReplicatedStorage.Core.TitlesDictionary)

local ImageItemButton = require(ReplicatedStorage.Assets.Tarmac.UI.item_button)
local ImageSelected2 = require(ReplicatedStorage.Assets.Tarmac.UI.selected2)

local e = Roact.createElement
local UpdateFonts = ReplicatedStorage.Remotes.UpdateFonts
local UpdateTitles = ReplicatedStorage.Remotes.UpdateTitles

local BUTTON_SIZE = 64
local LIST_PADDING = 5

local Nametag = Roact.Component:extend("Nametag")

local function Button(props)
	local minGradient, maxGradient, hoveredMaxGradient

	if not props.Owned then
		minGradient = Color3.fromRGB(100, 100, 100)
		maxGradient = Color3.fromRGB(120, 120, 120)
		hoveredMaxGradient = Color3.fromRGB(255, 86, 86)
	end

	return e(GradientButton, {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 1,
		Image = ImageItemButton,
		LayoutOrder = props.Owned and props.Index or props.Max + props.Index,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(0, 10, 419, 149),
		Size = UDim2.new(1, 0, 0, BUTTON_SIZE),

		HoveredMaxGradient = hoveredMaxGradient,
		MaxGradient = maxGradient,
		MinGradient = minGradient,

		[Roact.Event.Activated] = function()
			props.Activated(props.Index)
		end,
	}, {
		Selected = props.Equipped and e("ImageLabel", {
			BackgroundTransparency = 1,
			Image = ImageSelected2,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(18, 39, 389, 150),
			Size = UDim2.fromScale(1, 1),
			ZIndex = 1,
		}),

		TitleLabel = e("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Font = props.Font or Enum.Font.Gotham,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.95, 0.95),
			TextColor3 = Color3.new(1, 1, 1),
			Text = props.Name,
			TextSize = 50,
		}),
	})
end

function Nametag:init()
	self.frameRef = Roact.createRef()

	self.closeAlert = function()
		self:setState({
			showAlert = false,
		})
	end

	self.equipFont = function(index)
		if table.find(self.props.fonts.owned, index) then
			UpdateFonts:FireServer(index)
		else
			self:setState({
				showAlert = true,
			})
		end
	end

	self.equipTitle = function(index)
		if table.find(self.props.titles.owned, index) then
			UpdateTitles:FireServer(index)
		else
			self:setState({
				showAlert = true,
			})
		end
	end
end

function Nametag:render()
	local props = self.props

	local titleButtons = {}
	titleButtons.UIListLayout = e("UIListLayout", {
		Padding = UDim.new(0, LIST_PADDING),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	for index, title in ipairs(TitlesDictionary) do
		titleButtons[title] = e(Button, {
			Index = index,
			Max = #TitlesDictionary,
			Name = title,
			Equipped = props.titles.equipped == index,
			Owned = table.find(props.titles.owned, index) ~= nil,
			Activated = self.equipTitle,
		})
	end

	local fontButtons = {}
	fontButtons.UIListLayout = e("UIListLayout", {
		Padding = UDim.new(0, LIST_PADDING),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	for index, font in ipairs(FontsDictionary) do
		fontButtons[font.Name] = e(Button, {
			Index = index,
			Max = #TitlesDictionary,
			Font = font.Font,
			Name = font.Name,
			Equipped = props.fonts.equipped == index,
			Owned = table.find(props.fonts.owned, index) ~= nil,
			Activated = self.equipFont,
		})
	end

	return e("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(1300, 800),

		[Roact.Ref] = self.frameRef,
	}, {
		Scale = e(Scale, {
			Size = Vector2.new(1300, 800),
		}),

		Alert = self.state.showAlert and e(Alert, {
			OnClose = self.closeAlert,
			Open = self.state.showAlert,
			Text = "Level up with the Zombie Pass to unlock this!",
			Window = self.frameRef:getValue(),
		}),

		Titles = e("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 490, 1, -78),
		}, {
			TitlesLabel = e("TextLabel", {
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				Size = UDim2.new(1, 0, 0, 46),
				Text = "Titles",
				TextSize = 42,
			}),

			Titles = e("ScrollingFrame", {
				Active = true,
				AnchorPoint = Vector2.new(0, 1),
				BackgroundTransparency = 0,
				BorderSizePixel = 0,
				CanvasSize = UDim2.fromOffset(0, #TitlesDictionary * BUTTON_SIZE + #TitlesDictionary * LIST_PADDING),
				Position = UDim2.fromScale(0, 1),
				Size = UDim2.new(1, 0, 1, -80),
			}, titleButtons),
		}),

		Fonts = e("Frame", {
			AnchorPoint = Vector2.new(1, 0),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(1, 0),
			Size = UDim2.new(0, 490, 1, -78),
		}, {
			FontsLabel = e("TextLabel", {
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				Size = UDim2.new(1, 0, 0, 46),
				Text = "Fonts",
				TextSize = 42,
			}),

			Fonts = e("ScrollingFrame", {
				Active = true,
				AnchorPoint = Vector2.new(0, 1),
				BackgroundTransparency = 0,
				BorderSizePixel = 0,
				CanvasSize = UDim2.fromOffset(0, #FontsDictionary * BUTTON_SIZE + #TitlesDictionary * LIST_PADDING),
				Position = UDim2.fromScale(0, 1),
				Size = UDim2.new(1, 0, 1, -80),
			}, fontButtons),
		}),

		BackButton = e(BackButton, {
			GoBack = props.GoBack,
		}),
	})
end

return RoactRodux.connect(function(state)
	return {
		fonts = state.nametags.fonts,
		titles = state.nametags.titles,
	}
end)(Nametag)
