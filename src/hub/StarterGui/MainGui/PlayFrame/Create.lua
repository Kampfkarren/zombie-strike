local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local AutomatedScrollingFrameComponent = require(ReplicatedStorage.Core.UI.Components.AutomatedScrollingFrameComponent)
local Data = require(ReplicatedStorage.Core.Data)
local FastSpawn = require(ReplicatedStorage.Core.FastSpawn)
local Gamemodes = require(script.Parent.Gamemodes)
local Memoize = require(ReplicatedStorage.Core.Memoize)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local StyledButton = require(ReplicatedStorage.Core.UI.Components.StyledButton)

local e = Roact.createElement
local LocalPlayer = Players.LocalPlayer

local Create = Roact.Component:extend("Create")

local DISABLED_COLOR = Color3.fromRGB(107, 107, 107)

local function Arrow(props)
	return e(StyledButton, {
		BackgroundColor3 = Color3.fromRGB(133, 133, 133),
		LayoutOrder = props.LayoutOrder,
		Size = UDim2.fromScale(1, 1),
		Square = true,
		[Roact.Event.Activated] = props.OnClick,
	}, {
		UIAspectRatioConstraint = e("UIAspectRatioConstraint"),
		Label = e("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.9, 0.75),
			Text = props.Text,
			TextColor3 = Color3.new(1, 1, 1),
			TextScaled = true,
		}),
	})
end

local function Checkbox(props)
	return e("Frame", {
		BackgroundTransparency = 1,
		LayoutOrder = props.LayoutOrder,
		Size = UDim2.fromScale(0.7, 0.08),
	}, {
		UIListLayout = e("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Padding = UDim.new(0.02, 0),
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),

		Button = e(StyledButton, {
			BackgroundColor3 = props.Color,
			Size = UDim2.fromScale(1, 1),
			Square = true,
			[Roact.Event.Activated] = props.OnClick,
		}, {
			UIAspectRatioConstraint = e("UIAspectRatioConstraint"),
			Label = e("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.75, 0.75),
				Text = props.Checked and "X" or "",
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true,
			}),
		}),

		Label = e("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamSemibold,
			LayoutOrder = 2,
			Size = UDim2.fromScale(0.7, 1),
			Text = props.Text,
			TextColor3 = Color3.new(1, 1, 1),
			TextScaled = true,
			TextStrokeTransparency = 0.2,
		}),
	})
end

local function BigButton(props)
	local color = props.Disabled and DISABLED_COLOR or props.Color
	if props.Selected then
		local h, s, v = Color3.toHSV(color)
		color = Color3.fromHSV(h, s, v * 0.7)
	end

	local newLabel

	if props.New then
		newLabel = e("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.2),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Rotation = -20,
			Size = UDim2.fromScale(0.3, 0.5),
			Text = "NEW",
			TextColor3 = Color3.new(1, 1, 1),
			TextScaled = true,
			TextStrokeColor3 = Color3.fromRGB(214, 48, 49),
			TextStrokeTransparency = 0,
		})
	end

	return e(StyledButton, {
		ImageColor3 = color,
		LayoutOrder = props.LayoutOrder,
		Size = UDim2.new(0.9, 0, 0, 100),
		[Roact.Event.Activated] = props.OnClick,
	}, {
		UIAspectRatioConstraint = e("UIAspectRatioConstraint", {
			AspectRatio = 3,
		}),

		Label = e("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.9, 0.75),
			Text = props.Name,
			TextColor3 = Color3.new(1, 1, 1),
			TextScaled = true,
		}),

		New = newLabel,
	})
end

local function MissionButton(props)
	return e(BigButton, {
		Color = Color3.fromRGB(247, 159, 31),
		Name = props.Name,
		LayoutOrder = props.LayoutOrder,
		Selected = props.Selected.Name == props.Name,
		OnClick = props.SelectGamemode(props.Name),
		New = props.New,
	})
end

function Create:init()
	self:setState({
		hardcore = false,
		gamemode = Gamemodes.Mission,
		public = true,
	})

	FastSpawn(function()
		local level = self.props.FakeLevel
			or LocalPlayer:WaitForChild("PlayerData"):WaitForChild("Level").Value

		Data.GetLocalPlayerData("CampaignsPlayed")

		self:setState({
			level = level,
		})

		local latestCampaign

		for campaignIndex, campaign in ipairs(Gamemodes.Mission.Locations) do
			local minLevel = campaign.Difficulties[1].MinLevel

			if minLevel ~= nil then
				if level >= minLevel then
					latestCampaign = campaignIndex
				else
					break
				end
			end
		end

		self:SelectLocation(assert(latestCampaign))
	end)

	self.toggleHardcore = function()
		self:setState({
			hardcore = not self.state.hardcore,
		})
	end

	self.togglePublic = function()
		self:setState({
			public = not self.state.public,
		})
	end

	self.nextDifficulty = function()
		self:setState({
			difficulty = (self.state.difficulty % #self.state.campaign.Difficulties) + 1,
		})
	end

	self.previousDifficulty = function()
		self:setState({
			difficulty = self.state.difficulty == 1
				and #self.state.campaign.Difficulties
				or self.state.difficulty - 1,
		})
	end

	self.selectLocation = Memoize(function(campaignIndex)
		return function()
			self:SelectLocation(campaignIndex)
		end
	end)

	self.selectGamemode = Memoize(function(gamemode)
		return function()
			local gamemode = Gamemodes[gamemode]
			local selectedLocation

			for locationIndex, location in pairs(gamemode.Locations) do
				if location.Name == self.state.campaign.Name then
					selectedLocation = locationIndex
					break
				end
			end

			if not selectedLocation then
				selectedLocation = 1
			end

			self:SelectLocation(selectedLocation, gamemode)
		end
	end)

	self.submit = function()
		local state = self.state
		local properties = state.gamemode.Submit(state)

		properties.Gamemode = state.gamemode.Name
		properties.Public = state.public

		if state.gamemode.HardcoreEnabled then
			properties.Hardcore = state.hardcore
		end

		self.props.OnSubmit(properties)
	end
end

function Create:SelectLocation(campaignIndex, newGamemode)
	local gamemode = newGamemode or self.state.gamemode
	local campaign = gamemode.Locations[campaignIndex]

	local latestDifficulty

	for difficultyIndex, difficulty in ipairs(campaign.Difficulties or {}) do
		if gamemode.IsPlayable(campaignIndex, difficultyIndex, difficulty) then
			latestDifficulty = difficultyIndex
		else
			break
		end
	end

	self:setState({
		campaign = campaign,
		campaignIndex = campaignIndex,
		gamemode = newGamemode,
		difficulty = latestDifficulty or 1,
	})
end

function Create:render()
	local state = self.state

	if not state.level or not state.campaignIndex then
		return Roact.createFragment()
	end

	local mapsChildren = {}
	mapsChildren.UIListLayout = e("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		Padding = UDim.new(0.01, 0),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	for locationIndex, location in ipairs(self.state.gamemode.Locations) do
		local campaignDisabled = false

		if location.Difficulties then
			campaignDisabled = self.state.level < (location.Difficulties[1].MinLevel or 0)
		end

		table.insert(mapsChildren, e(BigButton, {
			Color = Color3.fromRGB(36, 171, 157),
			Disabled = campaignDisabled,
			Name = location.Name,
			LayoutOrder = locationIndex,
			Selected = location == self.state.campaign,
			OnClick = self.selectLocation(locationIndex),
		}))
	end

	local difficulty = (self.state.campaign.Difficulties or {})[self.state.difficulty]
	local difficultyText
	local playable, reason

	if difficulty ~= nil then
		playable, reason = state.gamemode.IsPlayable(self.state.campaignIndex, self.state.difficulty, difficulty)
	else
		playable = true
	end

	if difficulty then
		local difficultyTextProps = {
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamSemibold,
			LayoutOrder = 2,
			Size = UDim2.fromScale(0.4, 1),
			TextColor3 = Color3.new(1, 1, 1),
			TextScaled = true,
			TextStrokeTransparency = 0.2,
		}

		difficultyTextProps.Text = difficulty.Style.Name
		difficultyTextProps.TextStrokeColor3 = difficulty.Style.Color

		difficultyText = e("TextLabel", difficultyTextProps)
	end

	local hardcoreCheckbox

	if self.state.gamemode.HardcoreEnabled then
		hardcoreCheckbox = e(Checkbox, {
			Checked = state.hardcore,
			Color = Color3.fromRGB(195, 54, 20),
			LayoutOrder = 4,
			OnClick = self.toggleHardcore,
			Text = "HARDCORE",
		})
	end

	local submit
	if playable then
		submit = self.submit
	end

	local warning

	if self.state.gamemode.HardcoreEnabled and state.hardcore and playable then
		warning = e("TextLabel", {
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBlack,
			Position = UDim2.fromScale(0, 0.5),
			Size = UDim2.fromScale(1, 0.4),
			Text = "You only get ONE life...but receive double loot.",
			TextColor3 = Color3.fromRGB(194, 54, 22),
			TextScaled = true,
			TextStrokeTransparency = 0.2,
		})
	elseif not playable then
		local text

		if reason == 1 then
			text = ("You must be level %d to play on %s."):format(
				difficulty.MinLevel,
				difficulty.Style.Name
			)
		elseif reason == 2 then
			local amount = difficulty.TimesPlayed
				- (Data.GetLocalPlayerData("CampaignsPlayed")[tostring(self.state.campaignIndex)] or 0)

			text = ("You must play %d more time%s to play on %s."):format(
				amount,
				amount == 1 and "" or "s",
				difficulty.Style.Name
			)
		end

		warning = e("TextLabel", {
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			Position = UDim2.fromScale(0, 0.5),
			Size = UDim2.fromScale(1, 0.4),
			Text = text,
			TextColor3 = Color3.fromRGB(220, 221, 225),
			TextScaled = true,
			TextStrokeTransparency = 0.2,
		})
	end

	local difficultyFrame
	if self.state.campaign.Difficulties ~= nil then
		difficultyFrame = e("Frame", {
			BackgroundTransparency = 1,
			LayoutOrder = 2,
			Size = UDim2.fromScale(0.7, 0.08),
		}, {
			UIListLayout = e("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				Padding = UDim.new(0.02, 0),
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),

			Previous = e(Arrow, {
				LayoutOrder = 1,
				OnClick = self.previousDifficulty,
				Text = "<",
			}),

			DifficultyText = difficultyText,

			Next = e(Arrow, {
				LayoutOrder = 3,
				OnClick = self.nextDifficulty,
				Text = ">",
			}),
		})
	end

	return e("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
	}, {
		UIListLayout = e("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),

		Gamemodes = e(AutomatedScrollingFrameComponent, {
			BackgroundTransparency = 1,
			LayoutOrder = 1,
			Size = UDim2.fromScale(0.2, 0.95),
		}, {
			UIListLayout = mapsChildren.UIListLayout,

			Mission = e(MissionButton, {
				Name = "Mission",
				LayoutOrder = 1,
				Selected = state.gamemode,
				SelectGamemode = self.selectGamemode,
			}),

			Arena = e(MissionButton, {
				Name = "Arena",
				LayoutOrder = 2,
				Selected = state.gamemode,
				SelectGamemode = self.selectGamemode,
			}),

			Boss = e(MissionButton, {
				Name = "Boss",
				LayoutOrder = 3,
				Selected = state.gamemode,
				SelectGamemode = self.selectGamemode,
			}),
		}),

		Info = e("Frame", {
			BackgroundTransparency = 1,
			LayoutOrder = 2,
			Size = UDim2.fromScale(0.4, 0.95),
		}, {
			UIListLayout = e("UIListLayout", {
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				Padding = UDim.new(0.01, 0),
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),

			MapName = e("TextLabel", {
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				LayoutOrder = 0,
				Size = UDim2.fromScale(0.8, 0.1),
				Text = state.campaign.Name,
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true,
			}),

			MapImage = e("ImageLabel", {
				BackgroundTransparency = 1,
				Image = state.campaign.Image,
				LayoutOrder = 1,
				Size = UDim2.fromScale(1, 0.5),
			}, {
				UIAspectRatioConstraint = e("UIAspectRatioConstraint"),
				Warning = warning,

				Overlay = state.gamemode.ImageOverlay and e("Frame", {
					BackgroundTransparency = 1,
					Size = UDim2.fromScale(1, 1),
				}, state.gamemode.ImageOverlay(e)),
			}),

			Difficulty = difficultyFrame,

			Public = e(Checkbox, {
				Checked = state.public,
				Color = Color3.fromRGB(0, 141, 215),
				LayoutOrder = 3,
				OnClick = self.togglePublic,
				Text = "PUBLIC",
			}),

			Hardcore = hardcoreCheckbox,

			Create = e(StyledButton, {
				BackgroundColor3 = playable and Color3.fromRGB(32, 187, 108) or DISABLED_COLOR,
				LayoutOrder = 5,
				Size = UDim2.fromScale(1, 0.1),
				[Roact.Event.Activated] = submit,
			}, {
				UIListLayout = e("UIAspectRatioConstraint", {
					AspectRatio = 5,
				}),

				Label = e("TextLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Font = Enum.Font.GothamBold,
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(0.9, 0.75),
					Text = "CREATE",
					TextColor3 = Color3.new(1, 1, 1),
					TextScaled = true,
				}),
			}),
		}),

		Map = e(AutomatedScrollingFrameComponent, {
			BackgroundTransparency = 1,
			LayoutOrder = 3,
			Size = UDim2.fromScale(0.3, 0.95),
		}, mapsChildren),
	})
end

return Create
