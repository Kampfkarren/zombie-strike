import { Players, ReplicatedStorage, Workspace } from "@rbxts/services";
import RealDelay = require("shared/ReplicatedStorage/Core/RealDelay");

type ProjectileInfo = {
	initial: Vector3,
	lifetime: number,
	goal: Vector3,
	speed: number,

	onTouched: RemoteEvent | (() => void),
}

export function Projectile(template: BasePart, info: ProjectileInfo): BasePart {
	const projectile = template.Clone()
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

export function WaitForBossRemote(remoteName: string): RemoteEvent {
	return ReplicatedStorage.Remotes.RotatingBoss.WaitForChild(remoteName) as RemoteEvent
}
