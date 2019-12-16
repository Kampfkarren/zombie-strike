local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local assign = require(ReplicatedStorage.Core.assign)

local DEFAULT_END_TRANSPARENCY = 0.5
local DEFAULT_VISUAL_LIFETIME = 0.12
local ROTATION = CFrame.Angles(0, 0, math.pi / 2)

local CircleEffect = {}

CircleEffect.Presets = {
	BIG_ROBO_ZOMBIE = 1,
	TANK_BUFF = 2,
	BOMBER_ZOMBIE = 3,
	KATANA = 4,
}

CircleEffect.PresetOptions = {
	[CircleEffect.Presets.BIG_ROBO_ZOMBIE] = {
		Color = Color3.fromRGB(255, 124, 124),
		Range = 25,
	},

	[CircleEffect.Presets.TANK_BUFF] = {
		Color = Color3.fromRGB(85, 128, 247),
		Range = 25,
	},

	[CircleEffect.Presets.BOMBER_ZOMBIE] = {
		Color = Color3.fromRGB(255, 143, 79),
		Range = 30,
	},

	[CircleEffect.Presets.KATANA] = {
		Color = Color3.new(0.7, 0.7, 0.7),
		Range = 25,
	},
}

function CircleEffect.Run(properties)
	assert(properties.CFrame, "No CFrame")
	assert(properties.Range, "No Range")

	local endTransparency = properties.EndTransparency or DEFAULT_END_TRANSPARENCY
	local visualLifetime = properties.VisualLifetime or DEFAULT_VISUAL_LIFETIME

	local tweens = {
		Size = TweenInfo.new(visualLifetime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),

		Transparency = {
			TweenInfo.new(visualLifetime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true),
			{
				Transparency = endTransparency
			},
		},
	}

	local effect = script.Part:Clone()
	effect.Color = properties.Color or effect.Color
	effect.CFrame = properties.CFrame * ROTATION
	effect.Parent = workspace

	TweenService:Create(effect, tweens.Size, {
		Size = Vector3.new(script.Part.Size.X, properties.Range * 2, properties.Range)
	}):Play()

	TweenService:Create(effect, unpack(tweens.Transparency)):Play()
end

function CircleEffect.FromPreset(cframe, presetId)
	CircleEffect.Run(assign(
		assert(CircleEffect.PresetOptions[presetId], "no preset"),
		{ CFrame = cframe }
	))
end

return CircleEffect
