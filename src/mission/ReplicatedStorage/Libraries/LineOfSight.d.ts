declare function LineOfSight(
	origin: Instance | Vector3,
	character: Model,
	range: number,
	blacklist?: Instance[],
): LuaTuple<[boolean, Vector3]>

export = LineOfSight
