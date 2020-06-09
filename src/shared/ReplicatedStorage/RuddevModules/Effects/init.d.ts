declare namespace Effects {
	enum EffectIDs {
		Shoot,
		Reload,
		Explosion,
		Shatter,
		MinorExplosion,
	}

	function Effect(
		this: unknown,
		effect: "Explosion",
		position: Vector3,
		radius: number,
		better?: boolean,
		meteors?: Partial<{
			FireEmission: number,
			Meteors: number,
			SmokeEmission: number,
		}>,
	): void

	function Effect(
		this: unknown,
		effect: "MinorExplosion",
		position: Vector3,
		radius: number,
	): void
}

export = Effects
