interface BossSequence {
	Assets: { [assetName: string]: Instance }
	Start: (this: void, boss: Model) => Promise<void>,
}
