import { CollectionService, Players, ReplicatedStorage, SoundService } from "@rbxts/services"
import * as BossLocalScriptUtil from "mission/ReplicatedStorage/Libraries/BossLocalScriptUtil"
import PlayQuickSound from "shared/ReplicatedStorage/Core/PlayQuickSound"

const PROJECTILES_THROWN = 2
const PROJECTILE_Y = 3 // ooohh GOOOOD
const RANDOM_RANGE = 25

const ShurikenFrenzy = BossLocalScriptUtil.WaitForBossRemote("ShurikenFrenzy")

ShurikenFrenzy.OnClientEvent.Connect(() => {
	const boss = CollectionService.GetTagged("Boss")[0] as Model

	const initial = new Vector3(boss.PrimaryPart!.Position.X, PROJECTILE_Y, boss.PrimaryPart!.Position.Z)

	for (const player of Players.GetPlayers()) {
		const character = player.Character
		if (character !== undefined) {
			const primaryPart = character.PrimaryPart
			if (primaryPart !== undefined) {
				const characterPoint = new Vector3(
					primaryPart.Position.X,
					PROJECTILE_Y,
					primaryPart.Position.Z,
				)

				const unit = characterPoint.sub(initial).Unit

				for (let _ = 0; _ < PROJECTILES_THROWN; _++) {
					PlayQuickSound(SoundService.ZombieSounds.Samurai.Boss.Attack, boss.PrimaryPart)

					BossLocalScriptUtil.Projectile(
						ReplicatedStorage.Assets.Bosses.Samurai.Boss.Shuriken,
						{
							initial,
							lifetime: 3,
							goal: characterPoint.add(unit.mul(characterPoint.Magnitude)).add(
								new Vector3(
									math.random(-RANDOM_RANGE, RANDOM_RANGE),
									0,
									math.random(-RANDOM_RANGE, RANDOM_RANGE),
								),
							),
							speed: 90,
							onTouched: ShurikenFrenzy,
						},
					)
				}
			}
		}
	}
})
