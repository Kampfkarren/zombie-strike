local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local Alert = require(ReplicatedStorage.Core.UI.Components.Alert)
local EventConnection = require(ReplicatedStorage.Core.UI.Components.EventConnection)
local FontsDictionary = require(ReplicatedStorage.Core.FontsDictionary)
local Memoize = require(ReplicatedStorage.Core.Memoize)
local PlaySound = require(ReplicatedStorage.Core.PlaySound)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local TitlesDictionary = require(ReplicatedStorage.Core.TitlesDictionary)

local e = Roact.createElement
local UpdateFonts = ReplicatedStorage.Remotes.UpdateFonts
local UpdateTitles = ReplicatedStorage.Remotes.UpdateTitles

local Button = Roact.PureComponent:extend("Button")
local TitlesPage = Roact.Component:extend("TitlesPage")

local COLOR_DISABLED = Color3.fromRGB(107, 107, 107)
local COLOR_EQUIPPED = Color3.fromRGB(32, 187, 108)
local COLOR_OWNED = Color3.fromRGB(255, 177, 66)
local PADDING_Y = 0.01
local SIZE_Y = 0.1

function Button:init()
	self.activate = function()
		if self.props.equipped then
			PlaySound(SoundService.SFX.TagChange:FindFirstChild("Remove"))
		else
			PlaySound(self.props.soundFolder)
		end

		self.props.activate()
	end
end

function Button:render()
	local props = self.props

	local index = props.index
	local owned = props.owned

	return e("TextButton", {
		BackgroundColor3 = owned
			and (props.equipped and COLOR_EQUIPPED or COLOR_OWNED)
			or COLOR_DISABLED,
		BorderSizePixel = 0,
		LayoutOrder = owned and index or (props.max + index),
		Size = UDim2.fromScale(0.95, math.min(SIZE_Y, (1 / props.max) - PADDING_Y)),
		Text = "",

		[Roact.Event.Activated] = self.activate,
	}, {
		TitleText = e("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Font = props.font or Enum.Font.GothamBold,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.9, 0.9),
			Text = '"' .. props.title .. '"',
			TextColor3 = Color3.new(1, 1, 1),
			TextScaled = true,
		}),
	})
end

function TitlesPage:init()
	self:setState({
		alertOpen = false,

		equippedFont = nil,
		ownedFonts = {},

		equippedTitle = nil,
		ownedTitles = {},
	})

	self.closeAlert = function()
		self:setState({
			alertOpen = false,
		})
	end

	self.updateFonts = function(equipped, owned)
		self:setState({
			equippedFont = equipped or Roact.None,
			ownedFonts = owned,
		})
	end

	self.updateTitles = function(equipped, owned)
		self:setState({
			equippedTitle = equipped or Roact.None,
			ownedTitles = owned,
		})
	end

	self.activate = Memoize(function(index, remote)
		return function()
			if table.find(self.state.ownedTitles, index) then
				remote:FireServer(index)
			else
				self:setState({
					alertOpen = true,
				})
			end
		end
	end)
end

function TitlesPage:render()
	local titlesContents = {}
	titlesContents.UIListLayout = e("UIListLayout", {
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		Padding = UDim.new(PADDING_Y, 0),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	for index, title in pairs(TitlesDictionary) do
		local owned = table.find(self.state.ownedTitles, index)

		table.insert(titlesContents, e(Button, {
			activate = self.activate(index, UpdateTitles),
			equipped = self.state.equippedTitle == index,
			index = index,
			max = #TitlesDictionary,
			owned = owned,
			soundFolder = SoundService.SFX.TagChange.Nametag,

			title = title,
		}))
	end

	local fontsContents = {}
	fontsContents.UIListLayout = titlesContents.UIListLayout

	for index, font in pairs(FontsDictionary) do
		local owned = table.find(self.state.ownedFonts, index)

		table.insert(fontsContents, e(Button, {
			activate = self.activate(index, UpdateFonts),
			equipped = self.state.equippedFont == index,
			index = index,
			max = #FontsDictionary,
			owned = owned,
			soundFolder = SoundService.SFX.TagChange.Font,

			font = font.Font,
			title = font.Name,
		}))
	end

	return e("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 0.98),
	}, {
		UpdateFonts = e(EventConnection, {
			event = UpdateFonts.OnClientEvent,
			callback = self.updateFonts,
		}),

		UpdateTitles = e(EventConnection, {
			event = UpdateTitles.OnClientEvent,
			callback = self.updateTitles,
		}),

		Titles = e("ScrollingFrame", {
			BackgroundTransparency = 1,
			CanvasSize = UDim2.fromScale(0, (SIZE_Y * #TitlesDictionary) + (PADDING_Y * #TitlesDictionary)),
			Size = UDim2.fromScale(0.49, 1),
		}, titlesContents),

		Fonts = e("ScrollingFrame", {
			AnchorPoint = Vector2.new(1, 0),
			BackgroundTransparency = 1,
			CanvasSize = UDim2.fromScale(0, (SIZE_Y * #FontsDictionary) + (PADDING_Y * #FontsDictionary)),
			Position = UDim2.fromScale(1, 0),
			Size = UDim2.fromScale(0.49, 1),
		}, fontsContents),

		Alert = (self.state.alertOpen or nil) and e(Alert, {
			OnClose = self.closeAlert,
			Open = self.state.alertOpen,
			Text = "Level up with the Zombie Pass to unlock this!",
		}),
	})
end

return TitlesPage
