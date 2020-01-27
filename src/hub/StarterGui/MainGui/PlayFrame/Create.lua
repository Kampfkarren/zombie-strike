local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local ArenaConstants = require(ReplicatedStorage.Core.ArenaConstants)
local ArenaDifficulty = require(ReplicatedStorage.Libraries.ArenaDifficulty)
local AutomatedScrollingFrameComponent = require(ReplicatedStorage.Core.UI.Components.AutomatedScrollingFrameComponent)
local Campaigns = require(ReplicatedStorage.Core.Campaigns)
local FastSpawn = require(ReplicatedStorage.Core.FastSpawn)
local GetCurrentBoss = require(ReplicatedStorage.Libraries.GetCurrentBoss)
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
	})
end

local function MissionButton(props)
	return e(BigButton, {
		Color = Color3.fromRGB(247, 159, 31),
		Name = props.Name,
		LayoutOrder = props.LayoutOrder,
		Selected = props.Selected == props.Name,
		OnClick = props.SelectGamemode(props.Name),
	})
end

local function roundArenaLevel(level)
	if level == 1 then
		return 0
	else
		return level
	end
end

function Create:init()
	self:setState({
		hardcore = false,
		gamemode = "Mission",
		public = true,
	})

	FastSpawn(function()
		local level = LocalPlayer:WaitForChild("PlayerData"):WaitForChild("Level").Value

		self:setState({
			level = level,
			arenaLevel = math.min(
				ArenaConstants.MaxLevel,
				math.max(1, math.floor(level / ArenaConstants.LevelStep) * ArenaConstants.LevelStep)
			),
		})

		local latestCampaign

		for campaignIndex, campaign in ipairs(Campaigns) do
			if level >= campaign.Difficulties[1].MinLevel then
				latestCampaign = campaignIndex
			else
				break
			end
		end

		self:SelectCampaign(assert(latestCampaign))
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
		if self.state.gamemode == "Arena" then
			local level = roundArenaLevel(self.state.arenaLevel) + 20
			if level > ArenaConstants.MaxLevel then
				level = 1
			end

			self:setState({
				arenaLevel = level,
			})
		else
			self:setState({
				difficulty = (self.state.difficulty % #self.state.campaign.Difficulties) + 1,
			})
		end
	end

	self.previousDifficulty = function()
		if self.state.gamemode == "Arena" then
			local level = roundArenaLevel(self.state.arenaLevel) - 20
			if level == 0 then
				level = 1
			elseif level < 0 then
				level = ArenaConstants.MaxLevel
			end

			self:setState({
				arenaLevel = level,
			})
		else
			self:setState({
				difficulty = self.state.difficulty == 1
					and #self.state.campaign.Difficulties
					or self.state.difficulty - 1,
			})
		end
	end

	self.selectCampaign = Memoize(function(campaignIndex)
		return function()
			self:SelectCampaign(campaignIndex)
		end
	end)

	self.selectGamemode = Memoize(function(gamemode)
		return function()
			self:setState({
				gamemode = gamemode,
			})
		end
	end)

	self.submit = function()
		local state = self.state
		local properties = {
			Campaign = state.campaignIndex,
			Gamemode = state.gamemode,
			Public = state.public,
		}

		if state.gamemode == "Arena" then
			properties.Level = state.arenaLevel
		else
			properties.Difficulty = state.difficulty
			properties.Hardcore = state.hardcore
		end

		self.props.OnSubmit(properties)
	end
end

function Create:SelectCampaign(campaignIndex)
	local campaign = Campaigns[campaignIndex]

	local latestDifficulty

	for difficultyIndex, difficulty in ipairs(campaign.Difficulties) do
		if self.state.level >= difficulty.MinLevel then
			latestDifficulty = difficultyIndex
		else
			break
		end
	end

	self:setState({
		campaign = campaign,
		campaignIndex = campaignIndex,
		difficulty = latestDifficulty or 1,
	})
end

function Create:render()
	local state = self.state

	if not state.level then
		return Roact.createFragment()
	end

	local isArena = self.state.gamemode == "Arena"
	local isBoss = self.state.gamemode == "Boss"

	local mapsChildren = {}
	mapsChildren.UIListLayout = e("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		Padding = UDim.new(0.01, 0),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	if not isBoss then
		for campaignIndex, campaign in ipairs(Campaigns) do
			local campaignDisabled

			if isArena then
				campaignDisabled = campaign.LockedArena
			else
				campaignDisabled = self.state.level < campaign.Difficulties[1].MinLevel
			end

			table.insert(mapsChildren, e(BigButton, {
				Color = Color3.fromRGB(36, 171, 157),
				Disabled = campaignDisabled,
				Name = campaign.Name,
				LayoutOrder = campaignIndex,
				Selected = campaign == self.state.campaign,
				OnClick = self.selectCampaign(campaignIndex),
			}))
		end
	end

	local difficulty
	local difficultyTextProps = {
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamSemibold,
		LayoutOrder = 2,
		Size = UDim2.fromScale(0.4, 1),
		TextColor3 = Color3.new(1, 1, 1),
		TextScaled = true,
		TextStrokeTransparency = 0.2,
	}

	if isArena then
		difficulty = ArenaDifficulty(self.state.arenaLevel)
	else
		difficulty = self.state.campaign.Difficulties[self.state.difficulty]
	end

	difficultyTextProps.Text = difficulty.Style.Name
	difficultyTextProps.TextStrokeColor3 = difficulty.Style.Color

	local disabled = self.state.level < difficulty.MinLevel or (isArena and self.state.campaign.LockedArena)
	local difficultyText = e("TextLabel", difficultyTextProps)

	local hardcoreCheckbox

	if not isArena then
		hardcoreCheckbox = e(Checkbox, {
			Checked = state.hardcore,
			Color = Color3.fromRGB(195, 54, 20),
			LayoutOrder = 4,
			OnClick = self.toggleHardcore,
			Text = "HARDCORE",
		})
	end

	local submit
	if not disabled then
		submit = self.submit
	end

	local warning

	if not isArena and state.hardcore and not disabled then
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
	elseif disabled then
		local text

		if isArena then
			text = "Coming Soon!"
		else
			text = ("You must be level %d to play on %s."):format(
				difficulty.MinLevel,
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
	if not isBoss then
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

	local currentBoss = GetCurrentBoss().Info

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
				Text = isBoss and currentBoss.Name or state.campaign.Name,
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true,
			}),

			MapImage = e("ImageLabel", {
				BackgroundTransparency = 1,
				Image = isBoss and currentBoss.Image or state.campaign.Image,
				LayoutOrder = 1,
				Size = UDim2.fromScale(1, 0.5),
			}, {
				UIAspectRatioConstraint = e("UIAspectRatioConstraint"),
				Warning = warning,
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
				BackgroundColor3 = disabled and DISABLED_COLOR or Color3.fromRGB(32, 187, 108),
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
