local DefaultCombatLib = require(script.DefaultCombat) -- M1 and M2 Attacks

local Character = {}
local ClientWhitelist = {}

function addws(s) ClientWhitelist[s] = true end
function addwst(t) for _, s in ipairs(t) do addws(s) end end

addwst({
	'InputBegan',
	'InputEnded',
})

function Character.New(data)
	local self = setmetatable({Player = data.Player}, {__index = Character})
	return self
end

function Character.NewAI(data)
	local self = setmetatable({Mob = data.Mob, SpawnPoint = data.SpawnPoint, Master = data.Master}, {__index = Character})
	return self
end

-- Helpers
function Character:_connect(event, func)
	if not self.Connections then
		self.Connections = {}
	end
	
	local connection = event:Connect(func)
	table.insert(self.Connections, connection)
	
	return connection
end

function Character:_disconnectAll()
	if self.Connections then
		for _, connection in ipairs(self.Connections) do
			connection:Disconnect()
		end
	end
	self.Connections = {}
end

function Character:_addTag(tagsTable, tagName, value, timer, onEnd)
	self:_removeTag(tagsTable, tagName)

	local tag = {
		Value = value
	}

	if value == nil then
		tag.Value = true
	end

	if timer then
		tag.Thread = task.delay(timer, function()
			if tagsTable[tagName] == tag then
				tagsTable[tagName] = nil
				if onEnd then onEnd() end
			end
		end)
	end

	tagsTable[tagName] = tag
end

function Character:_removeTag(tagsTable, tagName)
	local tag = tagsTable[tagName]
	if not tag then return end

	if tag.Thread then
		task.cancel(tag.Thread)
	end

	tagsTable[tagName] = nil
end

function Character:Setup()
	self['_disconnectAll'](self)
	
	if self.Char and not self.Player then
		self.Char:Destroy()
	end
	
	if self.Player then
		self.Player:LoadCharacter()
		
		repeat task.wait() until self.Player.Character
	end
	
	self.Connections = {}
	
	self.Combat = {Combo = 0, M1LastTick = os.clock(), M2LastTick = os.clock(), Track = nil, IsHoldingM1 = false, M2Counter = 0}
	self.Block = {IsBlocking = false, Capacity = 60, Track = nil, IsHolding = false}
	self.Sprint = {IsSprinting = false}
	
	-- Tags
	self.Cooldowns = {}
	self.WalkSpeed = {Tags = { DefaultCombat = {Value = 16, Thread = nil} }}
	self.JumpPower = {Tags = { DefaultCombat = {Value = 50, Thread = nil} }}
	
	self.UsingMove = {Tags = {}, IsUsingMove = false}
	self.Stun = {Tags = {}, IsStunned = false}
	self.Ragdoll = {Tags = {}, IsRagdolled = false}
	
	self.Unconscious = false
	self.Dead = false
	
	self.Limbs = {
		['Left Arm'] = 'Normal', -- Amputated
		['Right Arm'] = 'Normal',
		['Left Leg'] = 'Normal',
		['Right Leg'] = 'Normal',
		
		LimbThreads = {}		-- Timers for limb reset 
	}
	
	self.Char = self.Player and self.Player.Character or self.Mob:Clone()
	self.Humanoid = self.Char.Humanoid
	self.Root = self.Char.HumanoidRootPart
	
	if self.Mob then
		self.Root.CFrame = self.SpawnPoint or CFrame.new(0, 0, 0)
	end
	
	self['_connect'](self, self.Humanoid.Died, function()
		task.wait(3)
		
		if self.Player then
			self['Activate'](self)
		else
			task.wait(math.random(2, 7))
			self['ActivateAI'](self)
		end
	end)
	
	-- Bindables --
	
	local BEvent = Instance.new('BindableEvent', self.Char); BEvent.Name = 'CharEvents'
	local BFunc = Instance.new('BindableFunction', self.Char); BFunc.Name = 'CharFunctions'
	
	self['_connect'](self, BEvent.Event, function(f, ...)
		if self[f] then
			self[f](self, ...)
		end
	end)
	
	BFunc.OnInvoke = function(f, ...)
		if self[f] then
			return self[f](self, ...)
		end
	end
	
	-- Remotes !CLIENT! --
	
	local REvent = Instance.new('RemoteEvent', self.Char); REvent.Name = 'CharRemoteEvents'
	local RFunc = Instance.new('RemoteFunction', self.Char); RFunc.Name = 'CharRemoteFunctions'
	
	self['_connect'](self, REvent.OnServerEvent, function(Player, f, ...)
		if Player == self.Player and ClientWhitelist[f] then
			if self[f] then
				self[f](self, ...)
			end
		else
			Player:Kick('gg bro gg')
		end
	end)
	
	RFunc.OnServerInvoke = function(Player, f, ...)
		if Player == self.Player and ClientWhitelist[f] then
			if self[f] then
				return self[f](self, ...)
			end
		else
			Player:Kick('gg bro gg')
		end
	end
	
	self.BindableFunction = BFunc
	self.BindableEvent = BEvent
	self.RemoteEvent = REvent
	self.RemoteFunction = RFunc
end

function Character:UpdateHumanoid()
	local WS, JP = 0, 0
	
	local StunWS = 1
	local BlockingWS = 8
	
	for k, tag in pairs(self.WalkSpeed.Tags) do
		WS += tag.Value
	end
	
	for k, tag in pairs(self.JumpPower.Tags) do
		JP += tag.Value
	end
	
	self.UsingMove.IsUsingMove = false
	for k, tag in pairs(self.UsingMove.Tags) do
		if tag.Value == true then
			self.UsingMove.IsUsingMove = true
			break
		end
	end
	
	self.Stun.IsStunned = false
	for k, tag in pairs(self.Stun.Tags) do
		if tag.Value == true then
			self.Stun.IsStunned = true
			break
		end
	end
	
	if self.Stun.IsStunned then
		WS = StunWS
		JP = 0
	elseif self.Block.IsBlocking then
		WS = BlockingWS
		JP = 0
	end
	
	self.Humanoid.WalkSpeed = WS
	self.Humanoid.JumpPower = JP
end

function Character:InputBegan(Data)
	if Data.UserInputType == Enum.UserInputType.MouseButton1 then
		self.Combat.IsHoldingM1 = true
		self['Attack'](self, 'm1')
		
		task.spawn(function()
			while self.Combat.IsHoldingM1 do
				self['Attack'](self, 'm1')
				task.wait()
			end
		end)
	elseif Data.UserInputType == Enum.UserInputType.MouseButton2 then
		if self.Combat.M2Counter > 1 then return end
		
		self.Combat.M2Counter += 1
		if self.Combat.M2Counter >= 2 then
			self['Attack'](self, 'm2')
			
			self.Combat.M2Counter = 0
		end
		
		task.delay(0.25, function()
			self.Combat.M2Counter -= 1
			
			if self.Combat.M2Counter < 0 then
				self.Combat.M2Counter = 0
			end
		end)
		
		
	elseif Data.KeyCode == Enum.KeyCode.LeftControl then
		if self.Sprint.IsSprinting then
			self['DisableSprint'](self)
		else
			self['EnableSprint'](self)
		end
		
	elseif Data.KeyCode == Enum.KeyCode.F then
		self.Block.IsHolding = true
		self['StartBlocking'](self)
		
		task.spawn(function()
			while self.Block.IsHolding do
				self['StartBlocking'](self)
				task.wait()
			end
			
			self['StopBlocking'](self)
		end)
		
	end
	
end

function Character:InputEnded(Data)
	if Data.UserInputType == Enum.UserInputType.MouseButton1 then
		self.Combat.IsHoldingM1 = false
		
	elseif Data.KeyCode == Enum.KeyCode.F then
		self.Block.IsHolding = false
		
	end
	
end

function Character:Attack(Type, extra)
	Type = Type:upper()
	
	if DefaultCombatLib[Type] then
		DefaultCombatLib[Type](self, extra)
	end
end

function Character:StartBlocking()
	local CantAttack = not self['ReturnCanAttack'](self)
	local UsingMove = self.UsingMove.IsUsingMove
	local OnCD = self['ReturnHasCD'](self, 'Block')
	
	if CantAttack or UsingMove or OnCD then return end
	if self.Block.IsBlocking then return end
	
	if self.Combat.Track then
		self.Combat.Track:Stop()
	end
	
	if self.Block.Track then
		self.Block.Track:Stop()
	end
	
	local Anim = game.ReplicatedStorage.Assets.Anims.DefaultCombat.Block
	local Track = self['LoadAnimation'](self, Anim)
	Track.Looped = true
	Track:Play()
	
	self.Block.Track = Track
	
	self.Block.IsBlocking = true
	self.Block.Capacity = 60
	
	self['AddCD'](self, {Name = 'Block', Timer = 0.18})
	
	local PerfectBlockTag = Instance.new('BoolValue', self.Char)
	PerfectBlockTag.Name = 'PerfectBlock'
	PerfectBlockTag.Value = true
	
	game.Debris:AddItem(PerfectBlockTag, 0.18)
	
	self['UpdateHumanoid'](self)
end

function Character:StopBlocking()
	if not self.Block.IsBlocking then return end
	
	if self.Block.Track then
		self.Block.Track:Stop()
	end
	
	self.Block.Track = nil
	self.Block.IsBlocking = false
	
	self['UpdateHumanoid'](self)
end

function Character:AddWalkSpeed(Data)
	self:_addTag(self.WalkSpeed.Tags, Data.Name, Data.Value, Data.Timer, function() self['UpdateHumanoid'](self) end)
	self['UpdateHumanoid'](self)
end

function Character:RemoveWalkSpeed(Data)
	self:_removeTag(self.WalkSpeed.Tags, Data.Name)
	self['UpdateHumanoid'](self)
end

function Character:AddJumpPower(Data)
	self:_addTag(self.JumpPower.Tags, Data.Name, Data.Value, Data.Timer, function() self['UpdateHumanoid'](self) end)
	self['UpdateHumanoid'](self)
end

function Character:RemoveJumpPower(Data)
	self:_removeTag(self.JumpPower.Tags, Data.Name)
	self['UpdateHumanoid'](self)
end

function Character:AddUsingMove(Data)
	self:_addTag(self.UsingMove.Tags, Data.Name, Data.Value, Data.Timer, function() self['UpdateHumanoid'](self) end)
	self['UpdateHumanoid'](self)
end

function Character:RemoveUsingMove(Data)
	self:_removeTag(self.UsingMove.Tags, Data.Name)
	self['UpdateHumanoid'](self)
end

function Character:AddStun(Data)
	self:_addTag(self.Stun.Tags, Data.Name, Data.Value, Data.Timer, function() self['UpdateHumanoid'](self) end)
	self['UpdateHumanoid'](self)
end

function Character:RemoveStun(Data)
	self:_removeTag(self.Stun.Tags, Data.Name)
	self['UpdateHumanoid'](self)
end

function Character:AddRagdoll(Data)
	self:_addTag(self.Ragdoll.Tags, Data.Name, Data.Value, Data.Timer, function() self['UpdateHumanoid'](self) end)
	self['UpdateHumanoid'](self)
end

function Character:RemoveRagdoll(Data)
	self:_removeTag(self.Ragdoll.Tags, Data.Name)
	self['UpdateHumanoid'](self)
end

function Character:AddCD(Data)
	self:_addTag(self.Cooldowns, Data.Name, true, Data.Timer)
end

function Character:RemoveCD(Data)
	self:_removeTag(self.Cooldowns, Data.Name)
end

function Character:ReturnHasCD(Name)
	return self.Cooldowns[Name] ~= nil
end

function Character:ReturnCanAttack()
	return self.Stun.IsStunned == false and
		self.Ragdoll.IsRagdolled == false and
		self.Block.IsBlocking == false
end

function Character:EnableSprint()
	local UsingMove = self.UsingMove.IsUsingMove
	local CantAttack = not self['ReturnCanAttack'](self)
	local OnCD = self['ReturnHasCD'](self, 'Sprint')

	if UsingMove or CantAttack or OnCD then return end	
	if self.Sprint.IsSprinting then return end
	
	self.Sprint.IsSprinting = true
	self['AddWalkSpeed'](self, {Name = 'Sprint', Value = 10})
	
	self['AddCD'](self, {Name = 'Sprint', Timer = 0.3})
end

function Character:DisableSprint(forced)
--[[
	local UsingMove = self.UsingMove.IsUsingMove
	local CantAttack = not self['ReturnCanAttack']()
	local OnCD = self['ReturnHasCD'](self, 'Sprint')

	if (UsingMove or CantAttack or OnCD or not self.Sprint.IsSprinting) and not forced then return end
]]
	
	self.Sprint.IsSprinting = false
	self['RemoveWalkSpeed'](self, {Name = 'Sprint'})
	self['AddCD'](self, {Name = 'Sprint', Timer = 0.3})
end

function Character:LoadAnimation(anim, animOrHum)
	local animator = animOrHum or self.Humanoid:FindFirstChildOfClass('Animator') or self.Humanoid
	local track = animator:LoadAnimation(anim)
	return track
end

function Character:Activate()
	self['Setup'](self)
	self.Char.Parent = workspace.Alive
	
	self['UpdateHumanoid'](self)
end

function Character:ActivateAI()
	self['Setup'](self)
	self.Char.Parent = workspace.Alive
	
	self['UpdateHumanoid'](self)
end

return Character
