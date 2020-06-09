import GunScaling from "shared/ReplicatedStorage/Core/GunScaling"
import ShowOfSkill from "./ShowOfSkill"

const DAMAGE = 30
const RELOAD_TIME = 1

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
	function makeShowOfSkill(upgrades: number): ShowOfSkill {
		return new ShowOfSkill(
			undefined as unknown as Player,
			0,
			upgrades,
			gun,
		)
	}

	it("should decrease reload time, increase damage", () => {
		const showOfSkill = makeShowOfSkill(0)

		expect(showOfSkill.ModifyDamage(DAMAGE)).to.equal(DAMAGE)
		expect(showOfSkill.ModifyReloadTime(RELOAD_TIME)).to.be.near(RELOAD_TIME)

		showOfSkill.Critted()

		assert(showOfSkill.ModifyDamage(DAMAGE) > DAMAGE, "Show of Skill did not buff damage")
		assert(showOfSkill.ModifyReloadTime(RELOAD_TIME) < RELOAD_TIME, "Show of Skill did not decrease reload time")
	})

	it("should decrease reload time more, increase damage more when upgraded", () => {
		const showOfSkillBase = makeShowOfSkill(0)
		const showOfSkillUpgraded = makeShowOfSkill(1)

		showOfSkillBase.Critted()
		showOfSkillUpgraded.Critted()

		const upgradedDamage = showOfSkillUpgraded.ModifyDamage(DAMAGE)
		const baseDamage = showOfSkillBase.ModifyDamage(DAMAGE)
		assert(
			upgradedDamage > baseDamage,
			`Show of Skill did not buff damage more when upgraded: ${baseDamage} -> ${upgradedDamage}`,
		)

		assert(
			showOfSkillUpgraded.ModifyReloadTime(RELOAD_TIME) < showOfSkillBase.ModifyReloadTime(RELOAD_TIME),
			"Show of Skill did not decrease reload time more when upgraded",
		)
	})
}
