// types for Quenty's Maid class

declare namespace Maid {
	export interface Destroyable {
		Destroy(): void;
	}

	export type Task = (() => any) | RBXScriptConnection | Maid | Maid.Destroyable;
}

interface Maid {
	/**
	 * Adds a task to perform.
	 * Tasks can be:
	 * - a function
	 * - a RBXScriptConnection
	 * - a Maid
	 * - an object with a Destroy() method
	 * @param task An item to clean
	 */
	GiveTask(task: Maid.Task): number;

	/**
	 * Cleans up all tasks
	 * @alias Destroy
	 */
	DoCleaning(): void;

	/**
	 * Alias for Maid:DoCleaning()
	 * @alias DoCleaning
	 */
	Destroy(): void;
}

interface MaidConstructor {
	readonly ClassName: "Maid";
	new(): Maid;
}
declare const Maid: MaidConstructor;

export = Maid;
