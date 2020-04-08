import { CollectionService, Players, ReplicatedStorage, SoundService } from "@rbxts/services"
import * as BossLocalScriptUtil from "mission/ReplicatedStorage/Libraries/BossLocalScriptUtil"
import Dungeon from "mission/ReplicatedStorage/Libraries/Dungeon"
import LookAt from "shared/ReplicatedStorage/Core/LookAt"
import Maid from "shared/ReplicatedStorage/Core/Maid"
import PlayQuickSound from "shared/ReplicatedStorage/Core/PlayQuickSound"
import RealDelay from "shared/ReplicatedStorage/Core/RealDelay"

const Assets = ReplicatedStorage.Assets.Campaign.Campaign4.MegaSnowball

const MegaSnowballZombieEffect = ReplicatedStorage.Remotes.Zombies.MegaSnowballZombieEffect

const CUBE_SIZE = new Vector3(4.75, 5.75, 2.75)
const ROTATION_VELOCITY = new Vector3(5, 0, 0)
const SPEED = 45
const STUN = [ 1, 1, 1.5, 1.5, 2 ]

const LIFETIME = 80 / SPEED

function snowballEffect(character: Model & { Humanoid: Humanoid }): Maid {
	const maid = new Maid()
	maid.DieWith(character.Humanoid)

	RealDelay(
		Dungeon.GetDungeonData("Gamemode") === "Mission"
		? STUN[Dungeon.GetDungeonData("Difficulty") - 1]
		: STUN[1],
	() => {
		maid.DoCleaning()
	})

	if (character.PrimaryPart !== undefined) {
		const iceCube = Assets.IceCube.Clone()
		iceCube.CFrame = character.PrimaryPart.CFrame
		iceCube.SpecialMesh.Scale = CUBE_SIZE

		const weld = new Instance("WeldConstraint")
		weld.Part0 = iceCube
		weld.Part1 = character.PrimaryPart
		weld.Parent = iceCube

		PlayQuickSound(SoundService.ZombieSounds["4"].MegaSnowball.Frozen, iceCube)

		maid.GiveTask(iceCube)

		iceCube.Parent = character
	}

	return maid
}

if (Dungeon.GetDungeonData("Campaign") === 4) {
	MegaSnowballZombieEffect.OnClientEvent.Connect((actor: Model & { Humanoid: Humanoid }, focus?: Character) => {
		if (CollectionService.HasTag(actor, "Zombie")) {
			const maid = new Maid()
			maid.DieWith(actor.Humanoid)
			let lookAt

			if (focus !== undefined) {
				lookAt = LookAt(actor, focus)
				maid.GiveTask(lookAt)
			}

			PlayQuickSound(SoundService.ZombieSounds["4"].MegaSnowball.Pickup, actor.PrimaryPart)

			const animation = actor.Humanoid.LoadAnimation(Assets.Animation)
			animation.KeyframeReached.Connect(() => {
				if (actor.Humanoid.Health > 0) {
					const origin = actor.PrimaryPart!.CFrame

					const projectile = BossLocalScriptUtil.Projectile(Assets.Snowball, {
						initial: origin.Position,
						lifetime: LIFETIME,
						goal: origin.Position.add(origin.LookVector.mul(100)),
						speed: SPEED,
						onTouched: () => {
							MegaSnowballZombieEffect.FireServer()
							const effect = snowballEffect(Players.LocalPlayer.Character as Character)

							const stun = new Instance("Model")
							stun.Name = "Stunned"
							stun.Parent = Players.LocalPlayer.WaitForChild("SpeedMultiplier")
							effect.GiveTask(stun)
						},
					})

					projectile.RotVelocity = ROTATION_VELOCITY
				}
			})
			animation.Play()

			maid.GiveTaskAnimation(animation)

			actor.Humanoid.GetPropertyChangedSignal("WalkSpeed").Connect(() => {
				maid.DoCleaning()
			})
		} else {
			snowballEffect(actor)
		}
	})
}

if (Players.LocalPlayer.Character === undefined) {
	Players.LocalPlayer.CharacterAdded.Wait()
}
