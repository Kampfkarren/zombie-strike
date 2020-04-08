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

	DieWith(humanoid: Humanoid): void
	GiveTaskAnimation(animation: AnimationTrack): void
	GiveTaskParticleEffect(particle: ParticleEmitter): void
}

interface MaidConstructor {
	readonly ClassName: "Maid";
	new(cleanNewOnes?: boolean): Maid;
}
declare const Maid: MaidConstructor;

export = Maid;
