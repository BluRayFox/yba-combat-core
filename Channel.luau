local Channel = {}

function Channel.new(InterruptLevel)
	local self = setmetatable({}, {__index = Channel})
	
	self.OnFinish = function() end
	self.OnCancel = function() end
	self.Main     = function() end
	self.Duration = function() end
	self.DurationTimer = 1
	
	self.Running = false
	self.Cancelled = false
	
	self.MainThread = nil
	self.DurationThread = nil
	self.InterruptLevel = 1	
	return self
end

function Channel:Start()
	self.Running = true
	self.Cancelled = false

	self.MainThread = nil
	self.DurationThread = nil
	
	self.MainThread = task.spawn(function()
		self.Main()
		
		if self.Running and not self.Cancelled then self.OnFinish() end
	end)
	
	self.DurationThread = task.spawn(function()
		self.StartTick = os.clock()
		
		while (os.clock() - self.StartTick < self.DurationTimer) and (self.Running and not self.Cancelled) do
			self.Duration()
			task.wait()
		end

	end)
end

function Channel:StopShort()
	self.Running = false
	self.Cancelled = false
	
	if self.MainThread then
		task.cancel(self.MainThread)
	end
	
	if self.DurationThread then
		task.cancel(self.DurationThread)
	end
end

return Channel
