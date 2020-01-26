export default interface ZombieClass {
	InitializeAI?: () => void
	InitializeBossAI?: (room: Model) => void
}
