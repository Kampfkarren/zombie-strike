import { RunService } from "@rbxts/services"
import WeakInstanceTable from "shared/ReplicatedStorage/Core/WeakInstanceTable"

type LookAtData = {
	responsiveness?: number,
	target: Model,
}

let connection: RBXScriptConnection | undefined
const lookingAt: WeakInstanceTable<Model, LookAtData> = WeakInstanceTable<Model, LookAtData>()

function lerp(a: number, b: number, t: number): number {
	return a + (b - a) * t
}

function lookAtLoop(delta: number) {
	for (const [actor, { target, responsiveness }] of lookingAt.entries()) {
		if (actor.PrimaryPart !== undefined && target.PrimaryPart !== undefined) {
			const actorPosition = actor.PrimaryPart.Position
			const targetPosition = target.PrimaryPart.Position

			let cframe = new CFrame(
				actorPosition,
				new Vector3(
					targetPosition.X,
					actorPosition.Y,
					targetPosition.Z,
				),
			)

			if (responsiveness !== undefined) {
				const [currentX, currentY, currentZ] = actor.PrimaryPart.CFrame.ToEulerAnglesXYZ()
				const [x, y, z] = cframe.ToEulerAnglesXYZ()

				cframe = new CFrame(actorPosition)
					.mul(CFrame.Angles(
						lerp(currentX, x, responsiveness * delta),
						lerp(currentY, y, responsiveness * delta),
						lerp(currentZ, z, responsiveness * delta),
					))
			}

			actor.SetPrimaryPartCFrame(cframe)
		}
	}
}

function LookAt(actor: Model, target: Model, responsiveness?: number): () => void {
	if (connection === undefined) {
		connection = RunService.Heartbeat.Connect(lookAtLoop)
	}

	lookingAt.set(actor, {
		target,
		responsiveness,
	})

	return () => {
		lookingAt.delete(actor)
		if (lookingAt.isEmpty() && connection !== undefined) {
			connection.Disconnect()
			connection = undefined
		}
	}
}

export = LookAt
