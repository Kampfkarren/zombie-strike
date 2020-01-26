type SequenceUtilArgs = LuaTuple<[Model, Camera]>
type SequencePromise = Promise<SequenceUtilArgs>

declare namespace SequenceUtil {
	export const Init: (this: void, boss: Model) => SequencePromise
	export const Finish: (this: void, args: SequenceUtilArgs) => Promise<void>
}

export = SequenceUtil
