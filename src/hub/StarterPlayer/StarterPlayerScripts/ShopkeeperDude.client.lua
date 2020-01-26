local CollectionService = game:GetService("CollectionService")

local Shopkeeper = CollectionService:GetTagged("ShopkeeperDude")[1]

Shopkeeper.AnimationController:LoadAnimation(Shopkeeper.WipeAnimation):Play()
