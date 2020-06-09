import DoubleBarrel from "./DoubleBarrel"
import GunScaling from "shared/ReplicatedStorage/Core/GunScaling"

const gun = GunScaling.StatsFor({
	Type: "Pistol",
	Level: 20,
	Rarity: 1,

	Bonus: 0,
	Favorited: false,
	Seed: 0,

	Perks: {},

	Model: 1,
	UUID: "TEST",
})

export = () => {
	it("should decrease reload time on upgrade", () => {
		const baseReload = DoubleBarrel.ModifyStats(gun, 0).ReloadTime
		const upgradedReload = DoubleBarrel.ModifyStats(gun, 1).ReloadTime
		assert(upgradedReload < baseReload, `Upgraded reload time wasn't shorter than base (${baseReload} -> ${upgradedReload})`)
	})

	it("shouldn't have a negative reload time", () => {
		const reloadTime = DoubleBarrel.ModifyStats(gun, 0).ReloadTime
		assert(reloadTime > 0, `Reload time is less than 0: ${reloadTime}`)
	})
}
