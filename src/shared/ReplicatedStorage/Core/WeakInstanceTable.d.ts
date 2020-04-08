type WeakInstanceTable<K extends Instance, V> = Map<K, V>

interface WeakInstanceTableConstructor {
	<K extends Instance, V>(): WeakInstanceTable<K, V>
}

declare const WeakInstanceTable: WeakInstanceTableConstructor
export = WeakInstanceTable
