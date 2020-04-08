---	Manages the cleaning of events and other things.
-- Useful for encapsulating state and make deconstructors easy
-- @classmod Maid
-- @see Signal
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local OnDied = require(ReplicatedStorage.Core.OnDied)

local Maid = {}
Maid.ClassName = "Maid"

--- Returns a new Maid object
-- @constructor Maid.new()
-- @treturn Maid
function Maid.new(once)
	local self = {}

	self._once = once
	self._tasks = {}
	self._tripped = false

	-- Fix #366
	if _G.__TESTEZ_RUNNING_TEST__ then
		local proxy = newproxy(true)
		getmetatable(proxy).__gc = function()
			self:DoCleaning()
		end
		self._proxy = proxy
	end

	return setmetatable(self, Maid)
end

--- Returns Maid[key] if not part of Maid metatable
-- @return Maid[key] value
function Maid:__index(index)
	if Maid[index] then
		return Maid[index]
	else
		return self._tasks[index]
	end
end

--- Add a task to clean up
-- @usage
-- Maid[key] = (function)         Adds a task to perform
-- Maid[key] = (event connection) Manages an event connection
-- Maid[key] = (Maid)             Maids can act as an event connection, allowing a Maid to have other maids to clean up.
-- Maid[key] = (Object)           Maids can cleanup objects with a `Destroy` method
-- Maid[key] = nil                Removes a named task. If the task is an event, it is disconnected. If it is an object, it is destroyed.
function Maid:__newindex(index, newTask)
	if Maid[index] ~= nil then
		error(("'%s' is reserved"):format(tostring(index)), 2)
	end

	local tasks = self._tasks
	local oldTask = tasks[index]
	tasks[index] = newTask

	if oldTask then
		if type(oldTask) == "function" then
			oldTask()
		elseif typeof(oldTask) == "RBXScriptConnection" then
			oldTask:Disconnect()
		elseif oldTask.Destroy then
			oldTask:Destroy()
		end
	end

	if self._once and self._tripped then
		self:DoCleaning()
	end
end

--- Same as indexing, but uses an incremented number as a key.
-- @param task An item to clean
-- @treturn number taskId
function Maid:GiveTask(task)
	assert(task)
	local taskId = #self._tasks+1
	self[taskId] = task
	return taskId
end

--- Cleans up all tasks.
-- @alias Destroy
function Maid:DoCleaning()
	self._tripped = true
	local tasks = self._tasks

	-- Disconnect all events first as we know this is safe
	for index, task in pairs(tasks) do
		if typeof(task) == "RBXScriptConnection" then
			tasks[index] = nil
			task:Disconnect()
		end
	end

	-- Clear out tasks table completely, even if clean up tasks add more tasks to the maid
	local index, task = next(tasks)
	while task ~= nil do
		tasks[index] = nil
		if type(task) == "function" then
			task()
		elseif typeof(task) == "RBXScriptConnection" then
			task:Disconnect()
		elseif task.Destroy then
			task:Destroy()
		end
		index, task = next(tasks)
	end
end

--- Alias for DoCleaning()
-- @function Destroy
Maid.Destroy = Maid.DoCleaning

-- BATTLE HATS CODE
function Maid:GiveTaskCoroutine(thread, ...)
	self:GiveTask(function()
		if thread then
			coroutine.yield(thread)
			thread = nil
		end
	end)

	local success, problem = coroutine.resume(thread, ...)
	if not success then
		error(problem)
	end
end

function Maid:GiveTaskParticleEffect(effect, timer)
	timer = timer or 10
	self:GiveTask({
		Destroy = function()
			effect.Enabled = false
			delay(timer, function() effect:Destroy() end)
		end
	})
end

function Maid:GiveTaskAnimation(animation)
	self:GiveTask({
		Destroy = function()
			animation:Stop()
			animation:Destroy()
		end
	})
end

function Maid:DieWith(humanoid)
	self:GiveTask(OnDied(humanoid):connect(function()
		self:DoCleaning()
	end))
end

return Maid
