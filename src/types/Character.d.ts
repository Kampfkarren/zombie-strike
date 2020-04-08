interface Character extends Model {
	Head: BasePart & {
		FaceCenterAttachment: Attachment,
		HatAttachment: Attachment,
	},

	Humanoid: Humanoid,
	PrimaryPart: BasePart,

	UpperTorso: BasePart & {
		BodyFrontAttachment: Attachment,
	},
}
