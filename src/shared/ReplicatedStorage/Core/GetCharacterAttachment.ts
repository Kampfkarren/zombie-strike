export function GetCenter(model: Model & { PrimaryPart: defined }): Attachment {
	const rootRigAttachment = model.PrimaryPart.FindFirstChild("RootRigAttachment")

	if (rootRigAttachment !== undefined) {
		return rootRigAttachment as Attachment
	} else {
		const newAttachment = new Instance("Attachment")
		newAttachment.Name = "RootRigAttachment"
		newAttachment.Parent = model.PrimaryPart
		return newAttachment
	}
}
