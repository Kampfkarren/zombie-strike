interface DataStore2<T> {
	/**
	 * Will return the value cached in the data store, if it exists. If it does not exist, will then attempt to get the value from Roblox data stores. This function will only yield if there is no value in the data store.
	 * .Get() returns a deep copy of whatever the data is, thus if the value is a table, then dataStore.Get() ~= dataStore.Get(). This may be lifted in the future for "pure" data stores.
	 * @param defaultValue The value will be used if the player has no data.
	 * @param dontAttemptGet When dontAttemptGet is true, will return the cached value and will not attempt to get it from Roblox if it does not exist. Ignores the value of defaultValue.
	 * @return The value in the data store if there is no cached result. The cached result otherwise.
	 */
	Get(defaultValue: T, dontAttemptGet?: boolean): T;
	Get(defaultValue?: T, dontAttemptGet?: boolean): T | undefined;

	/**
	 * Will set the cached value in the data store to newValue. Does not make any data store calls, and so will never yield.
	 * @param newValue The value to set in the DataStore
	 */
	Set(newValue: T): void;

	/**
	 * Saves the data in the current data store to Roblox. This function yields.
	 * Currently, Save() does not attempt to retry if it fails the first time. Save() can error if data stores are down or your data is invalid.
	 */
	Save(): void;

	/**
	 * Will set the data store value to the return of updateCallback when passed with the current value.
	 * You may see people talk about how UpdateAsync is more reliable than SetAsync in normal Roblox data stores. In DataStore2, this doesn't matter since neither actually call Roblox data store methods, so use .Set when you don't need the old value.
	 * Update currently does not attempt to get the value from the Roblox data store. This will be fixed in a [future update](https://github.com/Kampfkarren/Roblox/issues/57).
	 * @param updateCallback The function
	 */
	Update(updateCallback: (oldValue: T) => T): void;

	/**
	 * The same as .Get only it'll check to make sure all keys in the default data provided
	 * exist. If not, will pass in the default value only for that key.
	 * This is recommended for tables in case you want to add new entries to the table.
	 * Note this is not necessary to use tables with DataStore2. You can save/retrieve tables just like any other piece of data.
	 * @param defaultValue A table that will have its keys compared to that of the actual data received.
	 * @return The value in the data store will all keys from the default value provided.
	 */
	GetTable(defaultValue: object): T;

	/**
	 * Will increment the current value (cached or from Roblox data stores) with the value provided in add. If a value does not exist, will use defaultValue, then add.
	 * @param add The value to increment by.
	 * @param defaultValue If there is no cached result, set it to this before incrementing.
	 */
	Increment(add: number, defaultValue?: number): void;

	/**
	 * Will call the callback provided whenever the cached value is updated. Is not called on the initial get.
	 * @param callback The function to call.
	 */
	OnUpdate(callback: (value: T) => void): void;

	/**
	 * Will set the number of retries for `.Get()` to attempt to retrieve a Roblox data store value before giving up and marking the data store as a backup. If `alternativeDefaultValue` is provided, then that value will be given to `.Get()`, otherwise normal rules apply while assuming the player actually doesn't have any data. Learn more on the [backups page](https://kampfkarren.github.io/Roblox/advanced/backups/).
	 * @param retries Number of retries before the backup will be used.
	 * @param alternativeDefaultValue The value to return to `.Get()` in the case of a failure.
	 * You can keep this blank and the default value you provided with `.Get()` will be used instead.
	 */
	SetBackup(retries: number, alternativeDefaultValue?: T): void;

	/**
	 * Returns whether the current data store is a backup data store or not. Learn more on the [backups page](https://kampfkarren.github.io/Roblox/advanced/backups/).
	 * Tip: you don't need to know if a data store is a backup when saving. Backup data stores will never save.
	 */
	IsBackup(): boolean;

	/**
	 * Unmarks the current data store as a backup data store. The next time `.Get()` is called, it'll attempt to get the value inside Roblox data stores again. Learn more on the [backups page](https://kampfkarren.github.io/Roblox/advanced/backups/).
	 */
	ClearBackup(): void;

	/**
	 * Called after a value is received from Roblox data stores. The value returned is what `.Get()` will receive. Primarily used for deserialization. Learn more on the [serialization page](https://kampfkarren.github.io/Roblox/advanced/serde/).
	 * BeforeInitialGet is known to cause issues with combined data stores. If you can reproduce these issues, please [file an issue on GitHub](https://github.com/Kampfkarren/Roblox/issues)!
	 * @param modifier The modifier function.
	 */
	BeforeInitialGet<U>(modifier: (value: U) => T): void;

	/**
	 * Called before a value is saved into Roblox data stores. The value returned is what will be saved. Primarily used for serialization. Learn more on the [serialization page](https://kampfkarren.github.io/Roblox/advanced/serde/).
	 * @param modifier The modifier function.
	 */
	BeforeSave<U>(modifier: (dataValue: T) => U): void;

	/**
	 * Will call the callback after data is successfully saved into Roblox data stores.
	 * @param callback The callback function.
	 */
	AfterSave(callback: (savedValue: T) => void): void;

	/**
	 * Same as `.Get()`, but will instead return a Promise instead of yielding.
	 * @param defaultValue The value will be used if the player has no data.
	 * @param dontAttemptGet When dontAttemptGet is true, will return the cached value and will not attempt to get it from Roblox if it does not exist. Ignores the value of defaultValue.
	 */
	GetAsync(defaultValue?: T, dontAttemptGet?: boolean): Promise<T>

	/**
	 *
	 * @param defaultTable The default value to use
	 */
	GetTableAsync(defaultTable: T): Promise<T>

	/**
	 * Same as `.Increment()`, but will instead return a Promise instead of yielding.
	 * @param add The value to increment by.
	 * @param defaultValue If there is no cached result, set it to this before incrementing.
	 */
	IncrementAsync(add: number, defaultValue?: number): Promise<void>
}

interface IPatchGlobalSettings {
	/**
	 * Controls how the data should be saved. Read more in the [saving methods](https://kampfkarren.github.io/Roblox/advanced/saving_methods) page.
	 * @default OrderedBackups
	 */
	SavingMethod?: "Standard" | "OrderedBackups"
}

interface DataStore2Constructor {
	/**
	 * Will create a DataStore instance for the player with that specific name. If one already exists, will retrieve that one.
	 * Do not use the master key that you use in combined data stores, this behavior is not defined!
	 * @param dataStoreName The name of the DataStore2
	 * @param player The player to create the DataStore2 for
	 */
	<T>(dataStoreName: string, player: Player): DataStore2<T>;

	/**
	 * Combines all the keys under keysToCombine under the masterKey. Internally, will save all data under those keys into the masterKey as one large dictionary. You can learn more about combined data stores and why you should use them in the [gotchas](https://kampfkarren.github.io/Roblox/guide/gotchas/) page. Can be called multiple times without overriding previously combined keys.
	 * You should never use data stores without combining them or at the very least, replicating the behavior by creating one large dictionary yourself! Combined data stores will soon be the default way to use DataStore2.
	 * @param masterKey The key that will be used to house the table.
	 * @param keysToCombine All the keys to combine under one table.
	 */
	Combine: (masterKey: string, ...keysToCombine: Array<string>) => void;

	/**
	 * Clears the DataStore2 cache, so using DataStore2 again will give you fresh data stores. This is mostly for internal use or for unit testing.
	 */
	ClearCache: () => void;

	/**
	 * Will override the global settings by patching it with ones you provide. This means if you do not specify a setting, it will not be changed.
	 * @param settings The settings to patch into the global settings
	 */
	PatchGlobalSettings: (settings: IPatchGlobalSettings) => void;

	/**
	 * Will save all the data stores of the player. This is the recommended way to save combined data stores.
	 */
	SaveAll: (player: Player) => void
}
