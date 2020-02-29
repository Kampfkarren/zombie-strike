import { CollectionService } from "@rbxts/services"

function blacken(thing: Instance) {
	if (thing.IsA("BasePart")) {
		thing.Color = new Color3()
		thing.Material = Enum.Material.SmoothPlastic

		if (thing.IsA("MeshPart")) {
			thing.TextureID = ""
		}
	} else if (thing.IsA("Shirt") || thing.IsA("Pants")) {
		thing.Color3 = new Color3()
	} else if (thing.IsA("SpecialMesh")) {
		thing.TextureId = ""
	}
}

function SilhouetteModel(pvInstance: Instance) {
	CollectionService.RemoveTag(pvInstance, "AuroraGun")

	if (pvInstance.IsA("BasePart")) {
		blacken(pvInstance)
	} else if (pvInstance.FindFirstChildOfClass("Shirt")) {
		blacken(pvInstance.FindFirstChildOfClass("Shirt")!)
		blacken(pvInstance.FindFirstChildOfClass("Pants")!)
	} else {
		for (const child of pvInstance.GetDescendants()) {
			blacken(child)
		}
	}
}

export = SilhouetteModel
