local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Alert = require(ReplicatedStorage.Core.UI.Components.Alert)
local AutomatedScrollingFrameComponent = require(ReplicatedStorage.Core.UI.Components.AutomatedScrollingFrameComponent)
local Close = require(script.Parent.Close)
local FastSpawn = require(ReplicatedStorage.Core.FastSpawn)
local FollowConstants = require(ReplicatedStorage.FollowConstants)
local PlaceIds = require(ReplicatedStorage.Core.PlaceIds)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local RoactRodux = require(ReplicatedStorage.Vendor.RoactRodux)
local StyledButton = require(ReplicatedStorage.Core.UI.Components.StyledButton)
local UserThumbnail = require(ReplicatedStorage.Core.UI.Components.UserThumbnail)

local e = Roact.createElement
local LocalPlayer = Players.LocalPlayer

local Friend = Roact.PureComponent:extend("Friend")
local Friends = Roact.PureComponent:extend("Friends")

local COLOR_ACTIVE = Color3.fromRGB(32, 146, 81)
local COLOR_DISABLED = Color3.new(0.4, 0.4, 0.4)
local DELAY_TIME = 5
local DEBUG_FRIENDS_ONLINE = true

local function getFriendsOnline()
	if DEBUG_FRIENDS_ONLINE and RunService:IsStudio() then
		return {
			{
				VisitorId = 1,
				UserName = "InHub",
				GameId = game.GameId,
				PlaceId = PlaceIds.GetHubPlace(),
			},

			{
				VisitorId = 1,
				UserName = "InMission",
				GameId = game.GameId,
				PlaceId = PlaceIds.GetMissionPlace(),
			},

			{
				VisitorId = 1,
				UserName = "LongList",
				GameId = game.GameId,
				PlaceId = PlaceIds.GetMissionPlace(),
			},

			{
				VisitorId = 1,
				UserName = "LongList",
				GameId = game.GameId,
				PlaceId = PlaceIds.GetMissionPlace(),
			},

			{
				VisitorId = 1,
				UserName = "LongList",
				GameId = game.GameId,
				PlaceId = PlaceIds.GetMissionPlace(),
			},

			{
				VisitorId = 1,
				UserName = "LongList",
				GameId = game.GameId,
				PlaceId = PlaceIds.GetMissionPlace(),
			},

			{
				VisitorId = 1,
				UserName = "LongList",
				GameId = game.GameId,
				PlaceId = PlaceIds.GetMissionPlace(),
			},

			{
				VisitorId = 1,
				UserName = "LongList",
				GameId = game.GameId,
				PlaceId = PlaceIds.GetMissionPlace(),
			},

			{
				VisitorId = 1,
				UserName = "LongList",
				GameId = game.GameId,
				PlaceId = PlaceIds.GetMissionPlace(),
			},
		}
	else
		return LocalPlayer:GetFriendsOnline()
	end
end

function Friend:init()
	self.join = function()
		FastSpawn(function()
			self:setState({
				loading = true,
			})

			local friend = self.props.Friend
			local problem, text = ReplicatedStorage.Remotes.FollowFriend:InvokeServer(friend.VisitorId)

			if problem then
				self:setState({
					alertOpen = true,
					problem = problem,
					text = text or friend.UserName,
				})
			end

			self:setState({
				loading = false,
			})
		end)
	end

	self.onCloseAlert = function()
		self:setState({
			alertOpen = false,
		})
	end
end

function Friend:render()
	local props = self.props
	local inMission = props.Friend.PlaceId == PlaceIds.GetMissionPlace()
	local disabled = inMission or self.state.loading

	local joinButton = e(StyledButton, {
		BackgroundColor3 = disabled and COLOR_DISABLED or COLOR_ACTIVE,
		LayoutOrder = 3,
		Size = UDim2.fromScale(0.3, 1),
		[Roact.Event.Activated] = (not disabled or nil) and self.join,
	}, {
		Label = e("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.9, 0.75),
			Text = self.state.loading and "FOLLOWING..." or "FOLLOW",
			TextColor3 = Color3.new(1, 1, 1),
			TextScaled = true,
		}),
	})

	return e(StyledButton, {
		BackgroundColor3 = Color3.fromRGB(163, 163, 163),
		Size = UDim2.fromScale(0.98, 0.15),
	}, {
		UIAspectRatioConstraint = e("UIAspectRatioConstraint", {
			AspectRatio = 8,
		}),

		Inner = e("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.98, 0.8),
		}, {
			UIListLayout = e("UIListLayout", {
				Padding = UDim.new(0.01, 0),
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),

			Avatar = e(UserThumbnail, {
				Player = props.Friend.VisitorId,

				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
			}, {
				UIAspectRatioConstraint = e("UIAspectRatioConstraint"),
			}),

			Username = e("TextLabel", {
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				LayoutOrder = 1,
				Size = UDim2.fromScale(0.3, 1),
				Text = props.Friend.UserName,
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true,
			}),

			WhereLabel = e("TextLabel", {
				BackgroundTransparency = 1,
				Font = Enum.Font.Gotham,
				LayoutOrder = 2,
				Size = UDim2.fromScale(0.2, 0.7),
				Text = inMission and "Mission" or "Hub",
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true,
			}),

			JoinButton = joinButton,

			Alert = (self.state.alertOpen or nil) and e(Alert, {
				OnClose = self.onCloseAlert,
				Open = self.state.alertOpen,
				Text = FollowConstants.Messages[self.state.problem]:format(self.state.text),
			}),
		}),
	})
end

function Friends:init()
	self:setState({
		friends = {},
	})

	FastSpawn(function()
		while true do
			self:CheckFriendsOnline()
			wait(DELAY_TIME)
		end
	end)
end

function Friends:didUpdate(prevProps)
	if not prevProps.open and self.props.open then
		self:CheckFriendsOnline()
	end
end

function Friends:CheckFriendsOnline()
	FastSpawn(function()
		local friends = {}

		for _, friend in pairs(getFriendsOnline()) do
			if friend.PlaceId == PlaceIds.GetHubPlace() or friend.PlaceId == PlaceIds.GetMissionPlace() then
				table.insert(friends, friend)
			end
		end

		self:setState({
			friends = friends,
		})
	end)
end

function Friends:render()
	local children = {}

	children.UIAspectRatioConstraint = e("UIAspectRatioConstraint", {
		AspectRatio = 0.9,
		AspectType = Enum.AspectType.ScaleWithParentSize,
		DominantAxis = Enum.DominantAxis.Height,
	})

	children.Close = e(Close, {
		onClose = self.props.close,
	})

	children.Label = e("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamSemibold,
		Position = UDim2.fromScale(0.5, 0.01),
		Size = UDim2.fromScale(0.95, 0.1),
		Text = "FRIENDS",
		TextColor3 = Color3.new(1, 1, 1),
		TextScaled = true,
		ZIndex = 0,
	})

	if #self.state.friends > 0 then
		local friends = {}

		friends.UIListLayout = e("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Top,
		})

		for _, friend in pairs(self.state.friends) do
			table.insert(friends, e(Friend, {
				Friend = friend,
			}))
		end

		children.Friends = e(AutomatedScrollingFrameComponent, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.98, 0.8),
		}, friends)
	else
		children.NoFriendsWarning = e("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamSemibold,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.95, 0.1),
			Text = "No friends online!",
			TextColor3 = Color3.new(1, 1, 1),
			TextScaled = true,
			ZIndex = 0,
		})
	end

	return e("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(116, 185, 255),
		BackgroundTransparency = 0.5,
		BorderSizePixel = 0,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.3, 0.8),
		Visible = self.props.open,
	}, children)
end

return RoactRodux.connect(function(state)
	return {
		open = state.page.current == "Friends",
	}
end, function(dispatch)
	return {
		close = function()
			dispatch({
				type = "CloseFriends",
			})
		end,
	}
end)(Friends)
