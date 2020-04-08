import { RunService } from "@rbxts/services"

const BETA_FEATURES = {
	"Inventory2": true,
}

function UseBetaFeature(feature: keyof typeof BETA_FEATURES): boolean {
	return BETA_FEATURES[feature] || RunService.IsStudio()
}

export = UseBetaFeature
