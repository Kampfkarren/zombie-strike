declare function Raycast(position: Vector3, direction: Vector3, ignore: Instance[]):
	LuaTuple<[BasePart | undefined, Vector3, Vector3, Humanoid | undefined]>

export = Raycast
