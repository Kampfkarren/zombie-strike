function GunSpray(mouseCFrame: CFrame, config: {
	ShotSize: number,
	Spread: number,
}): CFrame[] {
	const spread = config.Spread * 10
	const spray = []

	for (let _ = 0; _ < config.ShotSize; _++) {
		spray.push(mouseCFrame
			.mul(CFrame.Angles(
				math.rad(math.random(-spread, spread) / 50),
				math.rad(math.random(-spread, spread) / 50),
				0,
			))
		)
	}

	return spray
}

export = GunSpray
