declare function describe(description: string, callback: () => void): void
declare function it(description: string, callback: () => void): void

declare function expect(value: unknown): Expectation

declare class Expectation {
	// LINGUISTIC NO-OPS
	/** A linguistic no-op */
	public readonly to: Expectation;

	/** A linguistic no-op */
	public readonly be: Expectation;

	/** A linguistic no-op */
	public readonly been: Expectation;

	/** A linguistic no-op */
	public readonly have: Expectation;

	/** A linguistic no-op */
	public readonly was: Expectation;

	/** A linguistic no-op */
	public readonly at: Expectation;

	// LINGUISTIC OPS
	/** Applies a never operation to the expectation */
	public readonly never: Expectation;

	// CONSTRUCTOR
	public constructor(value: unknown);

	// METHODS

	/**
	 * Assert that the expectation value is the given type.
	 * @param typeName The given type
	 * @returns If the assertion passes, returns reference to itself
	 */
	public a(typeName: string): Expectation;

	/**
	 * Assert that the expectation value is the given type.
	 * @param typeName The given type
	 * @returns If the assertion passes, returns reference to itself
	 */
	public an(typeName: string): Expectation;

	/**
	 * Assert that our expectation value is truthy
	 * @returns If the assertion passes, returns reference to itself
	 */
	public ok(): Expectation;

	/**
	 * Assert that our expectation value is equal to another value
	 * @param otherValue The other value
	 * @returns If the assertion passes, returns reference to itself
	 */
	public equal(otherValue: unknown): Expectation;

	/**
	 * Assert that our expectation value is equal to another value within some
	 * inclusive limit.
	 * @param otherValue The other value
	 * @param limit The inclusive limit
	 * @returns If the assertion passes, returns reference to itself
	 */
	public near(otherValue: unknown, limit?: number): Expectation;

	/**
	 * Assert that our functoid expectation value throws an error when called
	 * @returns If the assertion passes, returns reference to itself
	 */
	public throw(): Expectation;
}

