type ExtractTypes<T> = T extends (infer U)[] ? U : never
type KeysWithValue<T, U> = { [K in keyof T]: T[K] extends U ? K : never }[keyof T]
type ValueOf<T extends { [key: number]: unknown }> = T[number]