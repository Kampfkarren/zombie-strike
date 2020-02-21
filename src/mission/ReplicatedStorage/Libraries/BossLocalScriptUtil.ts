import { CollectionService, Players, ReplicatedStorage, RunService, TweenService, Workspace } from "@rbxts/services"
import Interval from "shared/ReplicatedStorage/Core/Interval"
import PlayQuickSound from "shared/ReplicatedStorage/Core/PlayQuickSound"
import RealDelay from "shared/ReplicatedStorage/Core/RealDelay"
import WarningRange from "mission/ReplicatedStorage/Libraries/WarningRange"

type ProjectileInfo = {
	initial: Vector3,
	lifetime: number,
	goal: Vector3,
	speed: number,

	onTouched: RemoteEvent | (() => void),
}

type RingInfo = {
	initial: Vector3,
	height?: number,
	tweenInfo: TweenInfo,

	onTouched: RemoteEvent | (() => void),
}

export function FireRing(info: RingInfo) {
	const ring = ReplicatedStorage.Assets.Campaign.Campaign4.Boss.Ring.Clone() // i'm evil
	ring.Position = info.initial

	let touched = false

	ring.Touched.Connect((part) => {
		if (!touched && part.IsDescendantOf(Players.LocalPlayer.Character!)) {
			touched = true
			if (typeIs(info.onTouched, "function")) {
				info.onTouched()
			} else {
				info.onTouched.FireServer()
			}
		}
	})

	ring.Color = new Color3(1, 0, 0)
	ring.Parent = Workspace.Effects

	const tween = TweenService.Create(ring, info.tweenInfo, {
		Size: new Vector3(500, info.height || 0.25, 500),
	})

	tween.Completed.Connect(() => {
		ring.Destroy()
	})

	tween.Play()
}

export function Projectile(template: BasePart, info: ProjectileInfo): BasePart {
	const projectile = template.Clone()
	projectile.Anchored = false
	projectile.CFrame = new CFrame(info.initial, info.goal)

	projectile.CFrame = projectile.CFrame.mul(CFrame.fromOrientation(
		math.rad(template.Orientation.X),
		math.rad(template.Orientation.Y),
		math.rad(template.Orientation.Z),
	))

	const bodyVelocity = new Instance("BodyVelocity")
	bodyVelocity.MaxForce = new Vector3(math.huge, math.huge, math.huge)
	bodyVelocity.P = 80
	bodyVelocity.Velocity = projectile.CFrame.LookVector.mul(info.speed)
	bodyVelocity.Parent = projectile

	const antiGravity = new Instance("BodyForce")
	antiGravity.Force = new Vector3(0, projectile.GetMass() * Workspace.Gravity, 0)
	antiGravity.Parent = projectile

	let touched = false

	projectile.Touched.Connect((part) => {
		if (!touched && part.IsDescendantOf(Players.LocalPlayer.Character!)) {
			touched = true
			if (typeIs(info.onTouched, "function")) {
				info.onTouched()
			} else {
				info.onTouched.FireServer()
			}
		}
	})

	projectile.Parent = Workspace

	RealDelay(info.lifetime, () => {
		projectile.Destroy()
	})

	return projectile
}

export function SludgeBalls(config: {
	assets: Folder & { SludgeBall: BasePart, SludgeFire: Animation, SludgePrime: Animation },
	duration: number,
	positionOffset?: number,
	range: number,
	rateOfFire: number,
	toTargetTime: number,
	windUpTime: number,

	remote: RemoteEvent,

	soundHit: Sound | Folder,
	soundThrowBall: Sound | Folder,
}) {
	const { assets, duration, range, rateOfFire, toTargetTime, windUpTime } = config
	const positionOffset = config.positionOffset || 0

	const boss = CollectionService.GetTagged("Boss")[0] as Model & {
		Head: BasePart,
		Humanoid: Humanoid,
	}

	boss.Humanoid.LoadAnimation(assets.SludgePrime).Play()
	const fireAnimation = boss.Humanoid.LoadAnimation(assets.SludgeFire)

	RealDelay(windUpTime, () => {
		const time = tick()

		Interval(1 / rateOfFire, () => {
			if (boss.Humanoid.Health <= 0) {
				return
			}

			if (tick() - time >= duration) {
				return false
			}

			PlayQuickSound(config.soundThrowBall, boss.PrimaryPart)

			fireAnimation.Play()

			const characters = []
			for (const player of Players.GetPlayers()) {
				if (player.Character !== undefined && player.Character.PrimaryPart !== undefined) {
					characters.push(player.Character)
				}
			}

			if (characters.size() > 0) {
				const character = characters[math.random(0, characters.size() - 1)]
				const warningRange = WarningRange(character.PrimaryPart!.Position.add(
					new Vector3(
						math.random(-positionOffset, positionOffset),
						0,
						math.random(-positionOffset, positionOffset),
					),
				), range)

				const ball = assets.SludgeBall.Clone()

				// Animation
				const start = boss.Head.Position
				const goal = warningRange.Position

				ball.Position = start
				ball.Parent = Workspace

				let total = 0
				const connection = RunService.Heartbeat.Connect((delta) => {
					total = math.min(toTargetTime, total + delta)
					const newPosition = start.Lerp(goal, math.sin(total / toTargetTime))
					ball.Position = newPosition

					if (total >= toTargetTime) {
						const hitSounds = config.soundHit.GetChildren()
						const hitSound = hitSounds[math.random(0, hitSounds.size() - 1)].Clone() as Sound
						hitSound.PlayOnRemove = true
						hitSound.Parent = ball

						ball.Destroy()
						warningRange.Destroy()
						connection.Disconnect()

						if (Players.LocalPlayer.Character!.PrimaryPart!.Position.sub(warningRange.Position).Magnitude
							<= range
						) {
							config.remote.FireServer()
						}
					}
				})
			}
		})
	})
}

export function WaitForBossRemote(remoteName: string): RemoteEvent {
	return ReplicatedStorage.Remotes.RotatingBoss.WaitForChild(remoteName) as RemoteEvent
}
