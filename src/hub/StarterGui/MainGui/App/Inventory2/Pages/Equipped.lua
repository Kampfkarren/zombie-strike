local ReplicatedStorage = game:GetService("ReplicatedStorage")

local InventoryComponents = script.Parent.Parent.Components

local BackButton = require(InventoryComponents.BackButton)
local CalculateGearScore = require(ReplicatedStorage.Core.CalculateGearScore)
local CharacterPreview = require(InventoryComponents.CharacterPreview)
local Cosmetics = require(ReplicatedStorage.Core.Cosmetics)
local Data = require(ReplicatedStorage.Core.Data)
local FontsDictionary = require(ReplicatedStorage.Core.FontsDictionary)
local GradientButton = require(ReplicatedStorage.Core.UI.Components.GradientButton)
local ItemModel = require(InventoryComponents.ItemModel)
local ItemType = require(InventoryComponents.ItemType)
local Loot = require(ReplicatedStorage.Core.Loot)
local PerfectTextLabel = require(ReplicatedStorage.Core.UI.Components.PerfectTextLabel)
local Rarity = require(InventoryComponents.Rarity)
local RarityTintedGradientButton = require(InventoryComponents.RarityTintedGradientButton)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local RoactRodux = require(ReplicatedStorage.Vendor.RoactRodux)
local Scale = require(ReplicatedStorage.Core.UI.Components.Scale)
local SpraysDictionary = require(ReplicatedStorage.Core.SpraysDictionary)
local TitlesDictionary = require(ReplicatedStorage.Core.TitlesDictionary)

local ImageEquippedGun2 = require(ReplicatedStorage.Assets.Tarmac.UI.equipped_gun2)
local ImageFloat = require(ReplicatedStorage.Assets.Tarmac.UI.float)
local ImagePanel = require(ReplicatedStorage.Assets.Tarmac.UI.panel)
local ImagePanel2 = require(ReplicatedStorage.Assets.Tarmac.UI.panel2)
local ImagePuzzlePiece2 = require(ReplicatedStorage.Assets.Tarmac.UI.puzzle_piece2)
local ImagePuzzlePieceMiddle = require(ReplicatedStorage.Assets.Tarmac.UI.puzzle_piece_middle)
local ImageStats = require(ReplicatedStorage.Assets.Tarmac.UI.stats)

local e = Roact.createElement

local FACE_DEFAULT = {
	Name = "Default",
	Type = "Face",

	Instance = ReplicatedStorage.Dummy.Head.face,
}

local faceDummies = {}

local function getFaceDummy(face)
	if faceDummies[face] == nil then
		local dummy = ReplicatedStorage.Dummy:Clone()
		dummy.Head.face.Texture = face.Instance.Texture
		faceDummies[face] = dummy
	end

	return faceDummies[face]
end

local function SidewaysText(props)
	local anchorPoint, alignment, position, rotation

	if props.Side == "Left" then
		anchorPoint = Vector2.new(1, 0)
		alignment = Enum.TextXAlignment.Left
		position = UDim2.new(0, -16, 0, 0)
		rotation = 90
	elseif props.Side == "Right" then
		alignment = Enum.TextXAlignment.Right
		position = UDim2.new(1, 16, 0, 0)
		rotation = -90
	end

	return e("Frame", {
		AnchorPoint = anchorPoint,
		BackgroundTransparency = 1,
		Position = position,
		Size = UDim2.new(0, 14, 1, 0),
	}, {
		e("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBlack,
			Position = UDim2.fromScale(0.5, 0.5),
			Rotation = rotation,
			Size = UDim2.fromScale(1, 0),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Text = props.Text:gsub("(.)", "%1 "),
			TextColor3 = Color3.new(1, 1, 1),
			TextSize = 14,
			TextStrokeTransparency = 0.6,
			TextXAlignment = alignment,
		}),
	})
end

local function Missing(props)
	return e(GradientButton, {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Image = props.Image,
		Rotation = props.Rotation,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = props.SliceCenter,
		Size = UDim2.fromScale(1, 1),

		MinGradient = Color3.fromRGB(158, 158, 158),
		MaxGradient = Color3.fromRGB(158, 158, 158),
		GradientRotation = props.Rotation and -(props.Rotation / 2),

		[Roact.Event.Activated] = props.Activated,
	}, {
		TextLabel = e("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Rotation = props.Rotation,
			Text = "No " .. props.Name,
			TextColor3 = Color3.new(1, 1, 1),
			TextSize = 24,
			Size = UDim2.fromScale(1, 1),
		}),
	})
end

local function GunCosmetic(props)
	return e("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
	}, {
		Contents = props.Cosmetic
		and e(GradientButton, {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ClipsDescendants = false,
			Image = props.Image,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = props.SliceCenter,
			Size = UDim2.fromScale(1, 1),

			[Roact.Event.Activated] = props.SetPage(props.Key),
		}, {
			SkinImage = e("Frame", {
				AnchorPoint = Vector2.new(1, 0),
				BackgroundTransparency = 1,
				ClipsDescendants = false,
				Position = UDim2.fromScale(1, 0),
				Size = UDim2.new(0, 170, 1, 0),
			}, {
				Image = props[Roact.Children].Image,
			}),

			Caption = e("TextLabel", {
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBlack,
				Position = UDim2.fromOffset(22, 44),
				Size = UDim2.new(1, 0, 0, 14),
				Text = props.Text:gsub("(.)", "%1 "),
				TextColor3 = Color3.new(1, 1, 1),
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
			}),

			CosmeticName = e("TextLabel", {
				BackgroundTransparency = 1,
				Font = Enum.Font.Gotham,
				Position = UDim2.fromOffset(22, 67),
				Size = UDim2.new(1, -27, 0, 72),
				Text = props.Cosmetic.Name,
				TextColor3 = Color3.new(1, 1, 1),
				TextSize = 27,
				TextWrapped = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
			}),
		})
		or e(Missing, {
			Activated = props.SetPage(props.Key),
			LayoutOrder = 3,
			Name = props.MissingText,
			Image = props.Image,
			SliceCenter = props.SliceCenter,
		}),
	})
end

local function HelmetArmor(props)
	local cosmetic = Cosmetics.Cosmetics[props.Cosmetic]
	local cosmeticsChildren = {}

	if cosmetic ~= nil then
		cosmeticsChildren = {
			ItemType = e(ItemType, {
				Native = {
					Position = UDim2.fromOffset(19, 22),
				},
				Item = cosmetic,
				TextSize = 13,
			}),

			ItemNameLabel = e("TextLabel", {
				BackgroundTransparency = 1,
				Font = Enum.Font.Gotham,
				Position = UDim2.fromOffset(19, 38),
				Size = UDim2.new(1, -27, 0, 72),
				Text = cosmetic.Name,
				TextColor3 = Color3.new(1, 1, 1),
				TextSize = 22,
				TextWrapped = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
			}),

			ItemImage = e("Frame", {
				AnchorPoint = Vector2.new(1, 0),
				BackgroundTransparency = 1,
				Position = UDim2.new(1, -15, 0, 0),
				Rotation = 0,
				Size = UDim2.new(0, 90, 1, 0),
				ZIndex = 0,
			}, {
				Model = e(ItemModel, {
					Angle = Vector3.new(-1, 0.8, -1),
					Distance = 0.5,
					Model = Data.GetModel(cosmetic),
				}),
			}),
		}
	else
		cosmeticsChildren = {
			e(Missing, {
				Activated = props.CosmeticsActivated,
				Name = "cosmetic",
				Image = ImagePuzzlePiece2,
				SliceCenter = Rect.new(7, 13, 206, 46),
			}),
		}
	end

	return e("Frame", {
		BackgroundTransparency = 1,
		LayoutOrder = props.LayoutOrder,
		Size = UDim2.fromOffset(380, 198),
	}, {
		Item = e(RarityTintedGradientButton, {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Image = ImageEquippedGun2,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(0, 14, 203, 528),
			Size = UDim2.new(1, 0, 0, 130),

			MinGradient = Color3.fromRGB(57, 57, 57),
			Rarity = props.Item.Rarity,

			[Roact.Event.Activated] = props.Activated,
		}, {
			SidewaysText = e(SidewaysText, {
				Side = "Right",
				Text = props.Text,
			}),

			GearScore = e("Frame", {
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(26, 24),
				Size = UDim2.fromOffset(184, 34),
			}, {
				UIListLayout = e("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					Padding = UDim.new(0, 4),
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),

				ItemGearScore = e(PerfectTextLabel, {
					BackgroundTransparency = 1,
					Font = Enum.Font.GothamBold,
					Text = CalculateGearScore(props.Item),
					TextColor3 = Color3.new(1, 1, 1),
					TextSize = 40,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Center,
				}),

				GearScoreLabel = e("TextLabel", {
					BackgroundTransparency = 1,
					Font = Enum.Font.Gotham,
					LayoutOrder = 2,
					Size = UDim2.new(0, 47, 1, 0),
					Text = "Power",
					TextColor3 = Color3.new(1, 1, 1),
					TextSize = 24,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Bottom,
					TextTransparency = 0.01,
				}),
			}),

			ItemNameLabel = e("TextLabel", {
				BackgroundTransparency = 1,
				Font = Enum.Font.Gotham,
				Position = UDim2.fromOffset(29, 75),
				Size = UDim2.new(1, -27, 0, 72),
				Text = Loot.GetLootName(props.Item),
				TextColor3 = Color3.new(1, 1, 1),
				TextSize = 30,
				TextWrapped = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
			}),

			ItemImage = e("Frame", {
				AnchorPoint = Vector2.new(1, 0),
				BackgroundTransparency = 1,
				Position = UDim2.new(1, -36, 0, 20),
				Rotation = 0,
				Size = UDim2.new(0, 156, 1, -40),
				ZIndex = 0,
			}, {
				Model = e(ItemModel, {
					Angle = props.Angle,
					Distance = 0.6,
					Model = Data.GetModel(props.Item),
				}, {
					Gradient = e("UIGradient", {
						Transparency = NumberSequence.new({
							NumberSequenceKeypoint.new(0, 0.3),
							NumberSequenceKeypoint.new(0.9, 0.3),
							NumberSequenceKeypoint.new(1, 1),
						}),
					}),
				}),
			}),

			RarityAndLevel = e("Frame", {
				AnchorPoint = Vector2.new(1, 0),
				BackgroundTransparency = 1,
				Position = UDim2.new(1, 0, 0, 39),
				Size = UDim2.new(1, 0, 0, 32),
			}, {
				UIListLayout = e("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Right,
					SortOrder = Enum.SortOrder.LayoutOrder,
					VerticalAlignment = Enum.VerticalAlignment.Center,
				}),

				LevelLabel = e(PerfectTextLabel, {
					Font = Enum.Font.Gotham,
					LayoutOrder = 1,
					Text = "LV",
					TextColor3 = Color3.new(1, 1, 1),
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Left,
				}),

				Level = e(PerfectTextLabel, {
					Font = Enum.Font.GothamBold,
					LayoutOrder = 2,
					Text = props.Item.Level,
					TextColor3 = Color3.new(1, 1, 1),
					TextSize = 16,
					TextXAlignment = Enum.TextXAlignment.Right,
				}),

				Gap = e("Frame", {
					BackgroundTransparency = 1,
					LayoutOrder = 3,
					Size = UDim2.fromOffset(14, 0),
				}),

				Rarity = e(Rarity, {
					Rarity = props.Item.Rarity,
					Style = "Right",
					LayoutOrder = 4,

					Padding = {
						Left = 15,
						Right = 13,
					},
				}),
			}),
		}),

		Cosmetic = e(GradientButton, {
			AnchorPoint = Vector2.new(0, 1),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ClipsDescendants = false,
			Image = ImagePuzzlePiece2,
			LayoutOrder = 2,
			Position = UDim2.new(0, 0, 1, -12),
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(7, 13, 206, 46),
			Size = UDim2.new(1, 0, 0, 64),

			MinGradient = Color3.fromRGB(49, 152, 48),
			MaxGradient = Color3.fromRGB(88, 169, 86),
			HoveredMaxGradient = Color3.fromRGB(120, 238, 118),

			[Roact.Event.Activated] = props.CosmeticsActivated,
		}, cosmeticsChildren),
	})
end

local function Equipped(props)
	return e("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
	}, {
		Weapon = e("Frame", {
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundTransparency = 1,
			ClipsDescendants = false,
			Position = UDim2.fromScale(0.945, 0.5),
			Size = UDim2.fromOffset(280, 768),
		}, {
			Scale = e(Scale, {
				Scale = 0.95,
				Size = Vector2.new(280, 768),
			}),

			Gun = e(RarityTintedGradientButton, {
				BackgroundColor3 = Color3.new(1, 1, 1),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ClipsDescendants = false,
				LayoutOrder = 1,
				Image = ImageEquippedGun2,
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = Rect.new(203, 0, 203, 529),
				Size = UDim2.new(1, 0, 0, 435),

				MinGradient = Color3.fromRGB(57, 57, 57),
				Rarity = props.equippedWeapon.Rarity,

				[Roact.Event.Activated] = props.SetPage("Gun"),
			}, {
				SidewaysText = e(SidewaysText, {
					Side = "Left",
					Text = "EQUIPMENT",
				}),

				GunImage = e("Frame", {
					AnchorPoint = Vector2.new(1, 0),
					BackgroundTransparency = 1,
					ClipsDescendants = false,
					Position = UDim2.new(1, 0, 0, 100),
					Rotation = 10,
					Size = UDim2.fromOffset(350, 320),
					ZIndex = 0,
				}, {
					Model = e(ItemModel, {
						Model = Data.GetModel(props.equippedWeapon),
					}),
				}),

				GearScore = e("Frame", {
					BackgroundTransparency = 1,
					Position = UDim2.fromOffset(20, 24),
					Size = UDim2.fromOffset(152, 80),
				}, {
					UIListLayout = e("UIListLayout", {
						FillDirection = Enum.FillDirection.Horizontal,
						Padding = UDim.new(0, 4),
						SortOrder = Enum.SortOrder.LayoutOrder,
					}),

					WeaponGearScore = e(PerfectTextLabel, {
						BackgroundTransparency = 1,
						Font = Enum.Font.GothamBold,
						Position = UDim2.fromOffset(7, 9),
						Text = CalculateGearScore(props.equippedWeapon),
						TextColor3 = Color3.new(1, 1, 1),
						TextSize = 93,
						TextXAlignment = Enum.TextXAlignment.Left,
					}),

					GearScoreLabel = e("TextLabel", {
						BackgroundTransparency = 1,
						Font = Enum.Font.Gotham,
						LayoutOrder = 2,
						Position = UDim2.fromOffset(134, 75),
						Size = UDim2.new(0, 47, 1, 0),
						Text = "Power",
						TextColor3 = Color3.new(1, 1, 1),
						TextSize = 30,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextYAlignment = Enum.TextYAlignment.Bottom,
						TextTransparency = 0.01,
					}),
				}),

				GunTypeLabel = e(ItemType, {
					Native = {
						Position = UDim2.fromOffset(30, 300),
						ZIndex = 2,
					},
					Item = props.equippedWeapon,
					TextSize = 16,
				}),

				GunNameLabel = e("TextLabel", {
					BackgroundTransparency = 1,
					Font = Enum.Font.Gotham,
					Position = UDim2.fromOffset(27, 325),
					Size = UDim2.new(1, -27, 0, 72),
					Text = Loot.GetLootName(props.equippedWeapon),
					TextColor3 = Color3.new(1, 1, 1),
					TextSize = 36,
					TextWrapped = true,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Top,
				}),

				RarityAndLevel = e("Frame", {
					AnchorPoint = Vector2.new(0, 1),
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 0, 1, -10),
					Size = UDim2.new(1, 0, 0, 32),
				}, {
					UIListLayout = e("UIListLayout", {
						FillDirection = Enum.FillDirection.Horizontal,
						SortOrder = Enum.SortOrder.LayoutOrder,
						VerticalAlignment = Enum.VerticalAlignment.Center,
					}),

					Rarity = e(Rarity, {
						Rarity = props.equippedWeapon.Rarity,
						Style = "Left",

						Padding = {
							Left = 30,
							Right = 13,
						},
					}),

					Gap = e("Frame", {
						BackgroundTransparency = 1,
						LayoutOrder = 2,
						Size = UDim2.fromOffset(14, 0),
					}),

					LevelLabel = e(PerfectTextLabel, {
						Font = Enum.Font.Gotham,
						LayoutOrder = 3,
						Text = "LV",
						TextColor3 = Color3.new(1, 1, 1),
						TextSize = 14,
						TextXAlignment = Enum.TextXAlignment.Left,
					}),

					Level = e(PerfectTextLabel, {
						Font = Enum.Font.GothamBold,
						LayoutOrder = 4,
						Text = props.equippedWeapon.Level,
						TextColor3 = Color3.new(1, 1, 1),
						TextSize = 19,
						TextXAlignment = Enum.TextXAlignment.Right,
					}),
				}),
			}),

			Attachment = e("Frame", {
				BackgroundTransparency = 1,
				LayoutOrder = 2,
				Position = UDim2.fromOffset(0, 428),
				Size = UDim2.new(1, 0, 0, 110),
			}, {
				Contents = props.equippedAttachment
					and e(RarityTintedGradientButton, {
						BackgroundColor3 = Color3.new(1, 1, 1),
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						ClipsDescendants = false,
						Image = ImagePuzzlePieceMiddle,
						ScaleType = Enum.ScaleType.Slice,
						SliceCenter = Rect.new(0, 13, 205, 107),
						Size = UDim2.fromScale(1, 1),

						Rarity = props.equippedAttachment.Rarity,

						[Roact.Event.Activated] = props.SetPage("Attachment"),
					}, {
						AttachmentImage = e("Frame", {
							AnchorPoint = Vector2.new(1, 0),
							BackgroundTransparency = 1,
							ClipsDescendants = false,
							Rotation = 3,
							Position = UDim2.fromScale(1, 0),
							Size = UDim2.new(0, 170, 1, 0),
						}, {
							Model = e(ItemModel, {
								Angle = Vector3.new(-1, 0.8, -1),
								Model = Data.GetModel(props.equippedAttachment),
							}),
						}),

						AttachmentTypeLabel = e(ItemType, {
							Native = {
								Position = UDim2.fromOffset(22, 44),
								ZIndex = 2,
							},
							Item = props.equippedAttachment,
							TextSize = 13,
						}),

						AttachmentNameLabel = e("TextLabel", {
							BackgroundTransparency = 1,
							Font = Enum.Font.Gotham,
							Position = UDim2.fromOffset(22, 67),
							Size = UDim2.new(1, -27, 0, 72),
							Text = Loot.GetLootName(props.equippedAttachment),
							TextColor3 = Color3.new(1, 1, 1),
							TextSize = 27,
							TextWrapped = true,
							TextXAlignment = Enum.TextXAlignment.Left,
							TextYAlignment = Enum.TextYAlignment.Top,
						}),

						Rarity = props.equippedAttachment.Rarity and e(Rarity, {
							Rarity = props.equippedAttachment.Rarity,
							Style = "Float",
							Padding = {
								Left = 10,
								Right = 10,
							},

							Native = {
								AnchorPoint = Vector2.new(1, 0),
								Position = UDim2.new(1, -16, 0, 12),
							},
						}),
					})
					or e(Missing, {
						Activated = props.SetPage("Attachment"),
						Image = ImagePuzzlePieceMiddle,
						SliceCenter = Rect.new(0, 13, 205, 107),
						Name = "attachment",
					}),
			}),

			GunSkin = e("Frame", {
				BackgroundTransparency = 1,
				LayoutOrder = 3,
				Position = UDim2.fromOffset(0, 532),
				Size = UDim2.new(1, 0, 0, 110),
			}, {
				GunCosmetic = e(GunCosmetic, {
					Cosmetic = Cosmetics.Cosmetics[props.cosmetics.GunSkin],
					Key = "GunSkin",
					MissingText = "skin",
					SetPage = props.SetPage,
					Text = "SKIN",

					Image = ImagePuzzlePieceMiddle,
					SliceCenter = Rect.new(0, 13, 205, 107),
				}, {
					Image = Cosmetics.Cosmetics[props.cosmetics.GunSkin] and e("Frame", {
						BackgroundTransparency = 1,
						Rotation = 3,
						Size = UDim2.fromScale(1, 1),
					}, {
						Model = e(ItemModel, {
							Angle = Vector3.new(-1, 0.8, -1),
							Model = Data.GetModel(Cosmetics.Cosmetics[props.cosmetics.GunSkin]),
						}),
					}),
				}),
			}),

			Particle = e("Frame", {
				BackgroundTransparency = 1,
				LayoutOrder = 4,
				Position = UDim2.fromOffset(0, 635),
				Size = UDim2.new(1, 0, 0, 110),
			}, {
				GunCosmetic = e(GunCosmetic, {
					Cosmetic = Cosmetics.Cosmetics[props.cosmetics.Particle],
					Key = "Particle",
					LayoutOrder = 3,
					MissingText = "particle",
					SetPage = props.SetPage,
					Text = "PARTICLE",

					Image = ImagePuzzlePiece2,
					SliceCenter = Rect.new(7, 13, 206, 46),
				}, {
					Image = Cosmetics.Cosmetics[props.cosmetics.Particle] and e("ImageLabel", {
						BackgroundTransparency = 1,
						Image = Cosmetics.Cosmetics[props.cosmetics.Particle].Image.Texture,
						Size = UDim2.fromScale(1, 1),
					}),
				}),
			}),
		}),

		NotWeapon = e("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.0625, 0.5),
			Size = UDim2.fromOffset(388, 768),
		}, {
			UIListLayout = e("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),

			Scale = e(Scale, {
				Scale = 0.95,
				Size = Vector2.new(259, 768),
			}),

			Helmet = e(HelmetArmor, {
				Activated = props.SetPage("Helmet"),
				CosmeticsActivated = props.SetPage("CosmeticHelmet"),
				Text = "HELMET",
				Angle = Vector3.new(1, 0, 0),
				Cosmetic = props.cosmetics.Helmet,
				Item = props.equippedHelmet,
			}),

			Armor = e(HelmetArmor, {
				Activated = props.SetPage("Armor"),
				CosmeticsActivated = props.SetPage("CosmeticArmor"),
				LayoutOrder = 2,
				Text = "ARMOR",
				Angle = Vector3.new(-1, 0.5, -1),
				Cosmetic = props.cosmetics.Armor,
				Item = props.equippedArmor,
			}),

			Accessories = e("Frame", {
				BackgroundTransparency = 1,
				LayoutOrder = 3,
				Size = UDim2.fromOffset(380, 170),
			}, {
				FacePanel = e(GradientButton, {
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Image = ImagePanel,
					ScaleType = Enum.ScaleType.Slice,
					SliceCenter = Rect.new(13, 0, 187, 230),
					Size = UDim2.new(0, 180, 1, 0),

					MinGradient = Color3.fromRGB(57, 57, 57),

					[Roact.Event.Activated] = props.SetPage("Face"),
				}, {
					Caption = e("TextLabel", {
						BackgroundTransparency = 1,
						Font = Enum.Font.GothamBlack,
						Position = UDim2.new(0, 20, 1, -66),
						Size = UDim2.new(1, 0, 0, 14),
						Text = "F A C E",
						TextColor3 = Color3.new(1, 1, 1),
						TextSize = 14,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextYAlignment = Enum.TextYAlignment.Top,
					}),

					FaceImage = e("Frame", {
						BackgroundTransparency = 1,
						Position = UDim2.fromOffset(0, 20),
						Size = UDim2.new(1, 0, 0, 155),
						ZIndex = 0,
					}, {
						Model = e(ItemModel, {
							Angle = Vector3.new(0.5, 0.2, -1.5),
							Distance = 0.25,
							Model = getFaceDummy(props.equippedFace),
							Offset = Vector3.new(0, 1.2, 0),
						}, {
							UIGradient = e("UIGradient", {
								Transparency = NumberSequence.new({
									NumberSequenceKeypoint.new(0, 0),
									NumberSequenceKeypoint.new(0.7, 0),
									NumberSequenceKeypoint.new(1, 1)
								}),
								Rotation = 90,
							}),
						}),
					}),

					FaceNameLabel = e("TextLabel", {
						BackgroundTransparency = 1,
						Font = Enum.Font.Gotham,
						Position = UDim2.new(0, 20, 1, -45),
						Size = UDim2.new(1, -27, 0, 24),
						Text = props.equippedFace.Name,
						TextColor3 = Color3.new(1, 1, 1),
						TextSize = 24,
						TextWrapped = true,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextYAlignment = Enum.TextYAlignment.Top,
					}),
				}),

				EmotePanel = e(GradientButton, {
					AnchorPoint = Vector2.new(1, 0),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Image = ImagePanel,
					Position = UDim2.fromScale(1, 0),
					Rotation = 180,
					ScaleType = Enum.ScaleType.Slice,
					SliceCenter = Rect.new(13, 0, 187, 230),
					Size = UDim2.new(0, 180, 1, 0),

					MinGradient = Color3.fromRGB(57, 57, 57),
					GradientRotation = -90,

					[Roact.Event.Activated] = props.SetPage("Emote"),
				}, {
					-- Fix orientation
					Contents = e("Frame", {
						BackgroundTransparency = 1,
						Rotation = 180,
						Size = UDim2.fromScale(1, 1),
					}, props.emotes.equipped and {
						Caption = e("TextLabel", {
							BackgroundTransparency = 1,
							Font = Enum.Font.GothamBlack,
							Position = UDim2.fromOffset(20, 22),
							Size = UDim2.new(1, 0, 0, 14),
							Text = "E M O T E",
							TextColor3 = Color3.new(1, 1, 1),
							TextSize = 14,
							TextXAlignment = Enum.TextXAlignment.Left,
							TextYAlignment = Enum.TextYAlignment.Top,
						}),

						EmoteImage = e("ImageLabel", {
							AnchorPoint = Vector2.new(0.5, 1),
							BackgroundTransparency = 1,
							Image = SpraysDictionary[props.emotes.equipped].Image,
							Position = UDim2.new(0.5, 0, 1, 0),
							Size = UDim2.new(1, 0, 0, 160),
							ZIndex = 0,
						}, {
							UIAspectRatioConstraint = e("UIAspectRatioConstraint"),
						}),

						EmoteNameLabel = e("TextLabel", {
							BackgroundTransparency = 1,
							Font = Enum.Font.Gotham,
							Position = UDim2.new(0, 20, 0, 45),
							Size = UDim2.new(1, -27, 0, 24),
							Text = SpraysDictionary[props.emotes.equipped].Name,
							TextColor3 = Color3.new(1, 1, 1),
							TextSize = 24,
							TextWrapped = true,
							TextXAlignment = Enum.TextXAlignment.Left,
							TextYAlignment = Enum.TextYAlignment.Top,
						}),
					} or {
						Missing = e(Missing, {
							Activated = props.SetPage("Emote"),
							Image = ImagePanel,
							Name = "emote",
							SliceCenter = Rect.new(13, 0, 187, 230),
							Rotation = 180,
						}),
					}),
				}),

				SidewaysText = e(SidewaysText, {
					Side = "Right",
					Text = "ACCESSORIES",
				}),
			}),

			Gap1 = e("Frame", {
				BackgroundTransparency = 1,
				LayoutOrder = 4,
				Size = UDim2.new(1, 0, 0, 7),
			}),

			Nametag = e(GradientButton, {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Image = ImagePanel2,
				LayoutOrder = 5,
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = Rect.new(13, 10, 369, 82),
				Size = UDim2.fromOffset(380, 90),

				[Roact.Event.Activated] = props.SetPage("Nametag"),
			}, {
				SidewaysText = e(SidewaysText, {
					Side = "Right",
					Text = "NAME",
				}),

				Caption = e("TextLabel", {
					BackgroundTransparency = 1,
					Font = Enum.Font.GothamBlack,
					Position = UDim2.fromOffset(20, 22),
					Size = UDim2.new(1, 0, 0, 14),
					Text = "N A M E T A G",
					TextColor3 = Color3.new(1, 1, 1),
					TextSize = 14,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Top,
				}),

				Nametag = e("TextLabel", {
					AnchorPoint = Vector2.new(0, 1),
					BackgroundTransparency = 1,
					Font = props.equippedFont,
					Position = UDim2.new(0, 20, 1, -15),
					Size = UDim2.new(0.95, 0, 0, 28),
					Text = props.equippedTitle,
					TextColor3 = Color3.new(1, 1, 1),
					TextSize = 28,
					TextXAlignment = Enum.TextXAlignment.Left,
				}),
			}),

			Gap2 = e("Frame", {
				BackgroundTransparency = 1,
				LayoutOrder = 6,
				Size = UDim2.new(1, 0, 0, 7),
			}),

			Pet = e(RarityTintedGradientButton, {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Image = ImagePanel2,
				LayoutOrder = 7,
				Rarity = props.equippedPet and props.equippedPet.Rarity,
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = Rect.new(13, 10, 369, 82),
				Size = UDim2.fromOffset(380, 90),

				[Roact.Event.Activated] = props.SetPage("Pet"),
			}, {
				SidewaysText = e(SidewaysText, {
					Side = "Right",
					Text = "PET",
				}),

				Contents = props.equippedPet and e("Frame", {
					BackgroundTransparency = 1,
					Size = UDim2.fromScale(1, 1),
				}, {
					PetImage = e("Frame", {
						AnchorPoint = Vector2.new(1, 0),
						BackgroundTransparency = 1,
						Position = UDim2.new(1, -25, 0, 0),
						Size = UDim2.new(0, 120, 1, 0),
						ZIndex = 0,
					}, {
						Model = e(ItemModel, {
							Angle = Vector3.new(-1, 0, -1),
							Model = Data.GetModel(props.equippedPet),
						}),
					}),

					PetName = e("TextLabel", {
						BackgroundTransparency = 1,
						Font = Enum.Font.Gotham,
						Position = UDim2.fromOffset(24, 12),
						Size = UDim2.fromOffset(150, 30),
						Text = Loot.GetLootName(props.equippedPet),
						TextColor3 = Color3.new(1, 1, 1),
						TextSize = 30,
						TextWrapped = true,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextYAlignment = Enum.TextYAlignment.Top,
					}),

					Rarity = e(Rarity, {
						Position = UDim2.fromOffset(24, 50),
						Rarity = props.equippedPet.Rarity,
						Style = "Float",

						Padding = {
							Left = 9,
							Right = 9,
						},
					})
				}) or e(Missing, {
					Activated = props.SetPage("Pet"),
					Image = ImagePanel2,
					Name = "pet",
					SliceCenter = Rect.new(13, 10, 369, 82),
				}),
			}),
		}),

		CharacterPreviewFrame = e("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(500, 768),
		}, {
			Scale = e(Scale, {
				Scale = 0.95,
				Size = Vector2.new(500, 768),
			}),

			CharacterPreview = e(CharacterPreview),

			BackButton = e(BackButton, {
				Position = UDim2.fromScale(0, 1),
				GoBack = props.close,
			}),

			StatsButton = e(GradientButton, {
				AnchorPoint = Vector2.new(0, 1),
				BackgroundColor3 = Color3.new(1, 1, 1),
				BackgroundTransparency = 1,
				Image = ImageFloat,
				Position = props.Position or UDim2.new(0, 0, 1, -60),
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = Rect.new(6, 4, 86, 20),
				Size = UDim2.fromOffset(145, 54),

				AnimateSpeed = 14,

				[Roact.Event.Activated] = props.SetPage("Stats"),
			}, {
				GoBackLabel = e("TextLabel", {
					AnchorPoint = Vector2.new(0, 0.5),
					BackgroundTransparency = 1,
					Font = Enum.Font.GothamSemibold,
					Position = UDim2.new(0, 70, 0.5, 0),
					Size = UDim2.fromOffset(105, 28),
					Text = "Stats",
					TextColor3 = Color3.new(1, 1, 1),
					TextSize = 24,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Center,
				}),

				ArrowImage = e("ImageLabel", {
					AnchorPoint = Vector2.new(0, 0.5),
					BackgroundTransparency = 1,
					Image = ImageStats,
					Position = UDim2.new(0, 30, 0.5, 0),
					Size = UDim2.fromOffset(24, 24),
				}),
			}),

			GearScore = e("Frame", {
				AnchorPoint = Vector2.new(0, 1),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0, 1),
				Size = UDim2.new(1, 0, 0, 60),
			}, {
				UIListLayout = e("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Right,
					Padding = UDim.new(0, 4),
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),

				TotalGearScore = e(PerfectTextLabel, {
					BackgroundTransparency = 1,
					Font = Enum.Font.GothamBold,
					Text = CalculateGearScore(props.equippedHelmet)
						+ CalculateGearScore(props.equippedArmor)
						+ CalculateGearScore(props.equippedWeapon),
					TextColor3 = Color3.new(1, 1, 1),
					TextSize = 72,
					TextXAlignment = Enum.TextXAlignment.Right,
					TextYAlignment = Enum.TextYAlignment.Bottom,
				}),

				GearScoreLabel = e("TextLabel", {
					BackgroundTransparency = 1,
					Font = Enum.Font.Gotham,
					LayoutOrder = 2,
					Size = UDim2.new(0, 47, 1, 0),
					Text = "Total\nPower",
					TextColor3 = Color3.new(1, 1, 1),
					TextSize = 24,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Bottom,
					TextTransparency = 0.01,
				}),
			}),
		}),
	})
end

return RoactRodux.connect(function(state)
	local equippedFont = FontsDictionary[state.nametags.fonts.equipped]

	return {
		equippedArmor = state.equipment.equippedArmor,
		equippedAttachment = state.equipment.equippedAttachment,
		equippedHelmet = state.equipment.equippedHelmet,
		equippedPet = state.equipment.equippedPet,
		equippedWeapon = state.equipment.equippedWeapon,

		cosmetics = state.store.equipped,
		emotes = state.sprays,

		equippedFace = Cosmetics.Cosmetics[state.store.equipped.Face] or FACE_DEFAULT,
		equippedFont = equippedFont and equippedFont.Font or Enum.Font.Gotham,
		equippedTitle = TitlesDictionary[state.nametags.titles.equipped] or "No title",
	}
end, function(dispatch)
	return {
		close = function()
			dispatch({
				type = "CloseInventory",
			})
		end,
	}
end)(Equipped)
