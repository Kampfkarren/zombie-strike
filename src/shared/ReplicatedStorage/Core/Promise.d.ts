declare interface Promise<T> {
	then<TResult1 = T, TResult2 = never>(
		this: Promise<T>,
		onResolved?: ((...values: PromiseResolveArguments<T>) => TResult1 | PromiseLike<TResult1>) | void,
		onRejected?: ((reason: any) => TResult2 | PromiseLike<TResult2>) | void,
	): Promise<TResult1 | TResult2>

	catch<TResult = never>(
		this: Promise<T>,
		onRejected?: ((reason: unknown) => TResult | PromiseLike<TResult>) | void,
	): Promise<T | TResult>

	finally<TResult = never>(
		this: Promise<T>,
		onSettled?: (() => TResult | PromiseLike<TResult>) | void,
	): Promise<T | TResult>
}

declare interface PromiseConstructor {
	async: <T>(
		executor: (
			resolve: (...values: PromiseResolveArguments<T> | [T] | [PromiseLike<T>] | []) => void,
			reject: (reason?: any) => void,
			onCancel: (cancellationHook: () => void) => void,
		) => void,
	) => Promise<T>
}

declare const Promise: PromiseConstructor
export = Promise
