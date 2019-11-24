local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Close = require(script.Parent.Close)
local GamePassDictionary = require(ReplicatedStorage.Core.GamePassDictionary)
local GamePasses = require(ReplicatedStorage.Core.GamePasses)
local Memoize = require(ReplicatedStorage.Core.Memoize)
local Modalifier = require(ReplicatedStorage.Core.UI.Components.Modalifier)
local Promise = require(ReplicatedStorage.Core.Promise)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local RoactRodux = require(ReplicatedStorage.Vendor.RoactRodux)
local Settings = require(ReplicatedStorage.Core.Settings)

local e = Roact.createElement
local LocalPlayer = Players.LocalPlayer
local UpdateSetting = ReplicatedStorage.Remotes.UpdateSetting

local SettingsMenu = Roact.PureComponent:extend("Settings")

local COLOR_GREEN = Color3.fromRGB(0, 148, 50)
local COLOR_RED = Color3.fromRGB(215, 90, 90)

local IMAGE_BUTTON = "rbxassetid://3973353234"
local IMAGE_LOCK = "rbxassetid://2826726111"

local function copy(list)
	local copy = {}
	for index, value in pairs(list) do
		copy[index] = value
	end
	return copy
end

local function unlockedPremiumPasses()
	return GamePasses.PlayerOwnsPass(LocalPlayer, GamePassDictionary.MoreSkinTones)
end

local skinToneButton = Memoize(function(props)
	return function()
		if props.Premium and not unlockedPremiumPasses() then
			MarketplaceService:PromptGamePassPurchase(LocalPlayer, GamePassDictionary.MoreSkinTones)
			return
		end

		props.Change()
		props.Close()
	end
end)

local function SkinTone(props)
	local children = {}

	if props.Premium and not unlockedPremiumPasses() then
		children.Lock = e("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = IMAGE_LOCK,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.85, 0.85),
		})
	end

	return e("TextButton", {
		BackgroundColor3 = props.Color,
		BorderColor3 = Color3.fromRGB(0, 168, 255),
		BorderMode = Enum.BorderMode.Inset,
		BorderSizePixel = props.Selected and 3 or 0,
		Text = "",
		[Roact.Event.MouseButton1Click] = skinToneButton(props),
	}, children)
end

local function SettingsValue(props)
	return e("Frame", {
		BackgroundTransparency = 1,
		LayoutOrder = props.LayoutOrder,
		Size = UDim2.fromScale(1, 0.2),
	}, {
		Label = e("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Size = UDim2.fromScale(0.45, 1),
			Text = props.Text,
			TextColor3 = Color3.new(1, 1, 1),
			TextScaled = true,
		}),

		Value = e("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0.8, 0.5),
			Size = UDim2.fromScale(0.3, 0.9),
		}, props[Roact.Children]),
	})
end

local updateSkinToneSetting = Memoize(function(settingsMenu, name)
	return function()
		settingsMenu:SetSetting("Skin Tone", name)
	end
end)

function SettingsMenu:init()
	self.ref = Roact.createRef()
	self.skinToneButtonRef = Roact.createRef()

	local promises = {}

	for _, setting in ipairs(Settings.Settings) do
		table.insert(promises, Promise.promisify(function()
			return setting.Choices[Settings.GetSettingIndex(setting.Name, LocalPlayer)]
		end)())
	end

	Promise.all(promises):andThen(function(values)
		local settings = {}

		for index, setting in ipairs(Settings.Settings) do
			settings[setting.Name] = values[index]
		end

		self:setState({
			settings = settings,
		})
	end)

	self.closeSkinTone = function()
		self:setState({
			skinToneDropdownPosition = Roact.None,
		})
	end

	GamePasses.BoughtPassUpdated(LocalPlayer).Event:connect(function()
		if unlockedPremiumPasses() then
			-- Force a re-render
			self:setState({
				unlockedPremiumPasses = true,
			})
		end
	end)
end

function SettingsMenu:SetSetting(settingName, value)
	local settings = copy(self.state.settings)

	settings[settingName] = value

	self:setState({
		settings = settings,
	})

	local setting, settingIndex, choiceIndex

	for index, thisSetting in pairs(Settings.Settings) do
		if thisSetting.Name == settingName then
			setting = thisSetting
			settingIndex = index
			break
		end
	end

	assert(settingIndex ~= nil)

	for index, choice in pairs(setting.Choices) do
		if choice == value then
			choiceIndex = index
			break
		end
	end

	assert(choiceIndex ~= nil)

	UpdateSetting:FireServer(settingIndex, choiceIndex)
end

function SettingsMenu:render()
	local children = {}

	if self.state.settings then
		local skinToneDropdown

		if self.state.skinToneDropdownPosition then
			local skinTones = {}

			skinTones.UIGridLayout = e("UIGridLayout", {
				CellPadding = UDim2.new(0.01, 0, 0.01, 0),
				CellSize = UDim2.new(0.31, 0, 0.3, 0),
				FillDirection = Enum.FillDirection.Horizontal,
				FillDirectionMaxCells = 3,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}, {
				e("UIAspectRatioConstraint"),
			})

			local skinToneSettings = Settings.Settings[1]
			for index, skinTone in pairs(skinToneSettings.Values) do
				local choice = skinToneSettings.Choices[index]
				table.insert(skinTones, e(SkinTone, {
					Color = skinTone,
					Index = index,
					Selected = self.state.settings["Skin Tone"] == choice,
					Close = self.closeSkinTone,
					Change = updateSkinToneSetting(self, choice),
					Premium = index > 6,
				}))
			end

			local position = self.state.skinToneDropdownPosition - self.ref:getValue().AbsolutePosition

			skinToneDropdown = e(Modalifier, {
				OnClosed = self.closeSkinTone,
				Window = self.ref:getValue(),

				Render = function()
					return e("Frame", {
						AnchorPoint = Vector2.new(1, 0),
						BackgroundColor3 = Color3.fromRGB(220, 221, 225),
						BorderSizePixel = 0,
						Position = UDim2.new(0.3, position.X, 0.2, position.Y),
						Size = UDim2.fromScale(0.33, 0.6),
					}, skinTones)
				end,
			})
		end

		children = {
			SkinToneDropdown = skinToneDropdown,

			Settings = e("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.95, 0.95),
			}, {
				UIListLayout = e("UIListLayout", {
					FillDirection = Enum.FillDirection.Vertical,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),

				Music = e(SettingsValue, {
					LayoutOrder = 1,
					Text = "MUSIC",
				}, {
					Button = e("ImageButton", {
						BackgroundTransparency = 1,
						Image = IMAGE_BUTTON,
						ImageColor3 = self.state.settings.Music == "On" and COLOR_GREEN or COLOR_RED,
						Size = UDim2.fromScale(1, 1),

						[Roact.Event.MouseButton1Click] = function()
							self:SetSetting("Music", self.state.settings.Music == "On" and "Off" or "On")
						end,
					}, {
						Label = e("TextLabel", {
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundTransparency = 1,
							Font = Enum.Font.GothamBold,
							Position = UDim2.fromScale(0.5, 0.5),
							Size = UDim2.fromScale(0.95, 0.95),
							Text = self.state.settings.Music:upper(),
							TextColor3 = Color3.new(1, 1, 1),
							TextScaled = true,
						}),
					}),
				}),

				SkinTone = e(SettingsValue, {
					LayoutOrder = 2,
					Text = "SKIN TONE",
				}, {
					Button = e("ImageButton", {
						BackgroundTransparency = 1,
						Image = IMAGE_BUTTON,
						ImageColor3 = Color3.new(0.5, 0.5, 0.5),
						Size = UDim2.fromScale(1, 1),

						[Roact.Event.MouseButton1Click] = function()
							self:setState({
								skinToneDropdownPosition = self.skinToneButtonRef:getValue().AbsolutePosition,
							})
						end,

						[Roact.Ref] = self.skinToneButtonRef,
					}, {
						Label = e("TextLabel", {
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundTransparency = 1,
							Font = Enum.Font.GothamBold,
							Position = UDim2.fromScale(0.5, 0.5),
							Size = UDim2.fromScale(0.9, 0.9),
							Text = self.state.settings["Skin Tone"],
							TextColor3 = Color3.new(1, 1, 1),
							TextScaled = true,
						}),
					}),
				}),
			}),
		}
	end

	return e("ImageButton", {
		Active = true,
		AnchorPoint = Vector2.new(0.5, 0.5),
		AutoButtonColor = false,
		BackgroundColor3 = Color3.fromRGB(149, 165, 166),
		BackgroundTransparency = 0.5,
		BorderSizePixel = 0,
		Image = "",
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.5, 0.5),
		Visible = self.props.open,
		[Roact.Ref] = self.ref,
	}, {
		UIAspectRatioConstraint = e("UIAspectRatioConstraint", {
			AspectRatio = 2.3,
			AspectType = Enum.AspectType.ScaleWithParentSize,
			DominantAxis = Enum.DominantAxis.Height,
		}),

		Close = e(Close, {
			onClose = self.props.close,
		}),

		Children = e("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
		}, children),
	})
end

return RoactRodux.connect(function(state)
	return {
		open = state.page.current == "Settings",
	}
end, function(dispatch)
	return {
		close = function()
			dispatch({
				type = "CloseSettings",
			})
		end,
	}
end)(SettingsMenu)
