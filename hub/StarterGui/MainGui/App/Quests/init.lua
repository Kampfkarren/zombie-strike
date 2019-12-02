local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DayTimer = require(ReplicatedStorage.Core.UI.Components.DayTimer)
local QuestsDictionary = require(ReplicatedStorage.Core.QuestsDictionary)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local RoactRodux = require(ReplicatedStorage.Vendor.RoactRodux)

local e = Roact.createElement

local FILL_IMAGE = "rbxassetid://4480314028"

local COLOR_FILLED = Color3.fromRGB(204, 142, 53)
local COLOR_UNFILLED = Color3.fromRGB(255, 177, 66)

local function Quest(props)
	local progress = props.Quest.Progress
	local goal = props.Quest.Args[1]

	local text = QuestsDictionary.Quests[props.Quest.Type].Text:format(unpack(props.Quest.Args))
		.. " - " .. QuestsDictionary.Reward .. "🧠"
	local progressText = math.min(goal, progress) .. "/" .. goal

	if progress / goal >= 1 then
		text = QuestsDictionary.Reward .. "🧠✅"
		progressText = "Finished!"
	end

	return e("Frame", {
		BackgroundTransparency = 1,
		LayoutOrder = props.LayoutOrder,
		Size = UDim2.fromScale(1, 0.2),
	}, {
		QuestName = e("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			Size = UDim2.fromScale(1, 0.5),
			Text = text,
			TextColor3 = Color3.new(1, 1, 1),
			TextScaled = true,
			TextXAlignment = Enum.TextXAlignment.Left,
		}),

		Progress = e("ImageLabel", {
			AnchorPoint = Vector2.new(0, 1),
			BackgroundTransparency = 1,
			Image = FILL_IMAGE,
			ImageColor3 = COLOR_UNFILLED,
			Position = UDim2.fromScale(0, 1),
			Size = UDim2.fromScale(1, 0.5),
		}, {
			Fill = e("ImageLabel", {
				BackgroundTransparency = 1,
				Image = FILL_IMAGE,
				ImageColor3 = COLOR_FILLED,
				Size = UDim2.fromScale(math.min(1, progress / goal), 1),
			}),

			ProgressText = e("TextLabel", {
				AnchorPoint = Vector2.new(1, 0),
				BackgroundTransparency = 1,
				Font = Enum.Font.Gotham,
				Position = UDim2.fromScale(1, 0),
				Size = UDim2.fromScale(0.95, 1),
				Text = progressText,
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 2,
			}),
		}),
	})
end

local function Quests(props)
	local children = {
		UIAspectRatioConstraint = e("UIAspectRatioConstraint", {
			AspectRatio = 0.5,
			AspectType = Enum.AspectType.ScaleWithParentSize,
			DominantAxis = Enum.DominantAxis.Height,
		}),

		UIListLayout = e("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			Padding = UDim.new(0.01, 0),
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),

		QuestsLabel = e("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			LayoutOrder = 0,
			Size = UDim2.fromScale(1, 0.15),
			Text = "QUESTS",
			TextColor3 = Color3.new(1, 1, 0.5),
			TextScaled = true,
		}),
	}

	for layoutOrder, quest in ipairs(props.quests) do
		table.insert(children, e(Quest, {
			LayoutOrder = layoutOrder,
			Quest = quest,
		}))
	end

	children.TimerFrame = e("Frame", {
		BackgroundTransparency = 1,
		LayoutOrder = #props.quests + 1,
		Size = UDim2.fromScale(1, 0.1),
	}, {
		Timer = e(DayTimer, {
			Overflow = false,
			Native = {
				Font = Enum.Font.Gotham,
				TextXAlignment = Enum.TextXAlignment.Left,
			},
		}),
	})

	return e("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.01, 0.4),
		Size = UDim2.fromScale(0.1, 0.6),
	}, children)
end

return RoactRodux.connect(function(state)
	return {
		quests = state.quests.quests,
	}
end)(Quests)
