-- Needed so LastInputTypeWatcher can watch for input changes before anything is requested
local ReplicatedStorage = game:GetService("ReplicatedStorage")

require(ReplicatedStorage.Core.LastInputTypeWatcher)
