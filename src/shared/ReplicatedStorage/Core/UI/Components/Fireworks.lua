local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Counter = require(ReplicatedStorage.Core.UI.Components.Counter)
local Roact = require(ReplicatedStorage.Vendor.Roact)

local ImageStar = require(ReplicatedStorage.Assets.Tarmac.UI.star)

local e = Roact.createElement

local Fireworks = Roact.PureComponent:extend("Fireworks")

Fireworks.defaultProps = {
	MinPeak = 0.6,
	MaxPeak = 1.1,
	Particles = 20,
	ParticleImage = ImageStar,
	ParticleSpeed = 0.6,
	ParticleSize = UDim2.fromScale(0.05, 0.05),
	TransparencyFadeTime = 0.2,
}

function Fireworks:init()
	local particlePositions = {}

	for _ = 1, self.props.Particles do
		table.insert(particlePositions, {
			direction = math.random() >= 0.5 and 1 or -1,
			peak = Random.new():NextNumber(self.props.MinPeak, self.props.MaxPeak),
			x = math.random(),
			y = math.random(),
		})
	end

	self.particlePositions = particlePositions
end

function Fireworks:render()
	return e(Counter, {
		Render = function(counter)
			local particles = {}

			for index, particlePositions in ipairs(self.particlePositions) do
				particles["Particle" .. index] = e("ImageLabel", {
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Image = self.props.ParticleImage,
					ImageColor3 = self.props.ParticleColor,
					ImageTransparency = counter:map(function(t)
						if t <= self.props.TransparencyFadeTime then
							return 1 - (t / self.props.TransparencyFadeTime)
						end
					end),
					Position = counter:map(function(t)
						return UDim2.fromScale(particlePositions.x, particlePositions.y)
							+ UDim2.fromScale(
								t * self.props.ParticleSpeed * particlePositions.direction,
								(
									-(-((2 * t - 1) ^ 2) + 1) * particlePositions.peak
								) * particlePositions.peak
							)
					end),
					Size = self.props.ParticleSize,
				}, {
					e("UIAspectRatioConstraint"),
				})
			end

			return e("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
			}, particles)
		end,
	})
end

return Fireworks
