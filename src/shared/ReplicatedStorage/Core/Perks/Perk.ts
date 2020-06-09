import { Gun, GunConfig, GunItem } from "shared/ReplicatedStorage/Core/Loot"
import Maid from "shared/ReplicatedStorage/Core/Maid"

function getRandom(seed: number, range: number[]): number {
	return new Random(seed).NextInteger(range[0] * 100, range[1] * 100) / 100
}

const DEFAULT_OPTIONS = {
	UpgradePercent: [1, 1.15, 1.3, 1.45],
}

export const DOESNT_UPGRADE = [1, 1, 1, 1]

export enum CritDecision {
	ForceCrit,
	ForceNoCrit,
	Default,
}

export enum CritMethod {
	Natural,
	Forced,
}

export enum Scope {
	Client,
	Server,
	Both,
}

export type PerkValue = {
	Range: number[],
} & Partial<typeof DEFAULT_OPTIONS>

export class Perk {
	static Name: string
	static Icon: string = "rbxassetid://4920794854" // TODO: This is a Tarmac URL
	static LegendaryPerk: boolean = false
	static PowerBuff: number = 1
	static Scope: Scope = Scope.Server

	static Values: PerkValue[] = []

	maid: Maid = new Maid()
	player: Player
	seed: number
	upgrades: number

	constructor(player: Player, seed: number, upgrades: number) {
		this.player = player
		this.seed = seed
		this.upgrades = upgrades
	}

	static GetValue(
		this: void,
		seed: number,
		upgrades: number,
		value: PerkValue & {
			Offset: number,
		},
	): number {
		return getRandom(seed + value.Offset, value.Range)
			* (value.UpgradePercent || DEFAULT_OPTIONS.UpgradePercent)[upgrades]
	}

	Destroy() {
		this.maid.DoCleaning()
	}

	ModifyDamageTaken(damage: number): number {
		return damage
	}

	Value(valueIndex: number): number {
		return Perk.GetValue(
			this.seed,
			this.upgrades,
			{
				...assert(
					(getmetatable(this) as unknown as typeof Perk).Values[valueIndex],
					`Couldn't find value ${valueIndex}`,
				),
				Offset: valueIndex,
			},
		)
	}
}

export interface AnimationLike {
	Play(this: AnimationLike, fadeTime?: number, weight?: number, speed?: number): void | Attachment
	Stop(this: AnimationLike): void
}

export class WeaponPerk extends Perk {
	gun: Readonly<Gun>

	constructor(player: Player, seed: number, upgrades: number, gun: Readonly<Gun>) {
		super(player, seed, upgrades)
		this.gun = gun
	}

	static ModifyWeaponAnimations(
		this: void,
		animations: Map<string, AnimationLike>,
		humanoid: Humanoid,
	): Map<string, AnimationLike> {
		return animations
	}

	static ModifyConfig(this: void, gun: Readonly<GunConfig>, upgrades: number): GunConfig {
		return gun
	}

	static ModifyStats(this: void, gun: Readonly<Gun>, upgrades: number): Gun {
		return gun
	}

	static ShouldApply(this: void, gun: Readonly<GunItem>): boolean {
		return true
	}

	AmmoInfo(): {
		AmmoLeft: number,
		Magazine: number,
	} {
		error("AmmoInfo not implemented, this is the responsibility of the scope!")
	}

	ShouldCrit(): CritDecision {
		return CritDecision.Default
	}

	UpdateStats(gun: Readonly<Partial<Omit<Gun, "Type" | "Seed" | "UUID">>>) {
		print("TODO: UpdateStats")
	}

	ModifyAmmoCost(ammoCost: number): number {
		return ammoCost
	}

	ModifyDamage(damage: number, zombie: Humanoid): number {
		return damage
	}

	ModifyFireRate(fireRate: number): number {
		return fireRate
	}

	ModifyReloadTime(reloadTime: number): number {
		return reloadTime
	}

	Critted(critMethod: CritMethod) { }
	DamageDealt(damage: number, zombie: Humanoid) { }
	DamageDealtClient(zombie: Humanoid) { }
	Reloaded(reloadedAt: number) { }
	TeammateShot(teammate: Humanoid) { }
	ZombieKilled(zombie: Humanoid) { }
}
