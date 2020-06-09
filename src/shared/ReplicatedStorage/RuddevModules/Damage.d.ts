declare namespace Damage {
	function Damage(
		this: unknown,
		humanoid: Humanoid,
		damage: number,
		player: Player | undefined,
		shouldCrit: boolean,
		critMultiplier?: number,
		lyingDamage?: number,
	): void
}

export = Damage
