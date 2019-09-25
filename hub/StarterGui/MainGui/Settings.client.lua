local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Settings = require(ReplicatedStorage.Core.Settings)

local SettingsUi = script.Parent.Main.Settings
local UpdateSetting = ReplicatedStorage.Remotes.UpdateSetting

local Contents = SettingsUi.Contents

local SettingTemplate = Contents.Template
local ValueTemplate = SettingTemplate.Value.Values.Template

local function button(button, callback)
	local tweenIn = TweenService:Create(
		button,
		TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
		{ BackgroundTransparency = 0.5 }
	)

	local tweenOut = TweenService:Create(
		button,
		TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
		{ BackgroundTransparency = 1 }
	)

	button.Button.MouseEnter:connect(function()
		tweenIn:Play()
	end)

	button.Button.MouseLeave:connect(function()
		tweenOut:Play()
	end)

	button.Button.MouseButton1Click:connect(callback)
end

for settingIndex, setting in pairs(Settings.Settings) do
	local template = SettingTemplate:Clone()
	template.LayoutOrder = settingIndex
	template.SettingName.Text = setting.Name:upper()

	local page = template.Value.Values.UIPageLayout
	local currentChoice = Settings.GetSettingIndex(setting.Name)

	for choiceIndex, choice in pairs(setting.Choices) do
		local valueTemplate = ValueTemplate:Clone()
		valueTemplate.LayoutOrder = choiceIndex
		valueTemplate.Name = choiceIndex
		valueTemplate.Text = choice
		valueTemplate.Visible = true
		valueTemplate.Parent = template.Value.Values
		if choiceIndex == currentChoice then
			page:JumpTo(valueTemplate)
		end
	end

	button(template.Value.Previous, function()
		page:Previous()
	end)

	button(template.Value.Next, function()
		page:Next()
	end)

	page:GetPropertyChangedSignal("CurrentPage"):connect(function()
		UpdateSetting:FireServer(settingIndex, tonumber(page.CurrentPage.Name))
	end)

	template.Parent = Contents
	template.Visible = true
end

-- TODO: Modularize this
local function automatedScrollingFrame(scrollingFrame)
	local layout = scrollingFrame:FindFirstChildWhichIsA("UIGridStyleLayout")

	local function updateFrame()
		scrollingFrame.CanvasSize = UDim2.new(0, layout.AbsoluteContentSize.X, 0, layout.AbsoluteContentSize.Y)
	end

	updateFrame()
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):connect(updateFrame)
end

automatedScrollingFrame(SettingsUi.Contents)

script.Parent.Main.Buttons.Settings.MouseButton1Click:connect(function()
	SettingsUi.Visible = not SettingsUi.Visible
end)

-- TODO: Gamepad
SettingsUi.Close.MouseButton1Click:connect(function()
	SettingsUi.Visible = false
end)
