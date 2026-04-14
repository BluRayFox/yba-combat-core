--[[

	Character Controller Module
	Responsible for handling player character and humanoid

]]

local Character = {}
local ClientWhitelist = {}

local function addclientws(name)
	ClientWhitelist[name] = true
end

local function addclientwstbl(tbl)
	for _, name in ipairs(tbl) do
		addclientws(name)
	end
end

addclientwstbl({
	'InputBegan',
	'InputEnded',
	'Attack',
	'PressedPlay',
})


function Character.new(data)
	local self = setmetatable({Player = data.Player}, {__index = Character})
	return self
end

function Character.newAI(data)
	local self = setmetatable({Mob = data.Mob, SpawnPoint = data.SpawnPoint, Master = data.Master}, {__index = Character})
	return self
end

function Character:_connect(event, callback)
	if not self.Connections then
		self.Connections = {}
	end
	
	local connection = event:Connect(callback)
	table.insert(self.Connections, connection)
	
	return connection
end

function Character:_clearConnections()
	if self.Connections then
		for _, connection in self.Connections do
			connection:Disconnect()
		end
	end
	
	self.Connections = {}
end

function Character:SetUp()
	
	if self.Player and not self.Char then
		self.Player:LoadCharacter()
	end
	
	-- States
	self.UsingMove = {Tags = {}, IsUsingMove = false}
	self.WalkSpeed = {Tags = { {Name = 'DefaultSpeed', Value = 16}} }
	self.JumpPower = {Tags = {}}
	self.Stun = {Tags = {}, IsStunned = false}
	self.Ragdoll = {Tags = {}, IsRagdolled = false}
	self.Cooldowns = {}
	self.Combat = {Combo = 0, Track = nil, M1Cooldown = false, M2Cooldown = false, M2Counter = 0, LastClock = os.clock(), M2LastClock = os.clock() - 4}
	self.Block = {IsBlocking = false, Capacity = 58, Track = nil, OnCooldown = false, LastClock = os.clock(), BlockHeld = false}
	
	self.Sprint = {IsSprinting = false, OnCooldown = false}
	self.Dead = false
	
	self.Limbs = {
		LeftLeg = 'Normal',	-- Amputated
		RightLeg = 'Normal',
		LeftArm = 'Normal',
		RightArm = 'Normal',
		TimerThreads = {}
	}
	
	local RemoteEvent, RemoteFunction, BindableEvent, BindableFunction = Instance.new('RemoteEvent', self.Char), Instance.new('RemoteFunction', self.Char), Instance.new('BindableEvent', self.Char), Instance.new('BindableFunction', self.Char)
	BindableEvent.Name = 'BindableEvent'
	BindableFunction.Name = 'BindableFunction'
	RemoteEvent.Name = 'RemoteEvent'
	RemoteFunction.Name = 'RemoteFunction'
	
	self.RemoteEvent = RemoteEvent
	self.RemoteFunction = RemoteFunction
	self.BindableEvent = BindableEvent
	self.BindableFunction = BindableFunction
	
	self:_clearConnections()
	
	-- remote event 
	self:_connect(RemoteEvent.OnServerEvent, function(player, f, ...)
		if self[f] and ClientWhitelist[f] and player == self.Player then
			self[f](self, ...)
		else
			self.Player:Kick('gg bro gg')
		end
	end)
	
	-- bindable event
	self:_connect(BindableEvent.Event, function(f, ...)
		if self[f] then
			self[f](self, ...)
		end
	end)
	
	BindableFunction.OnInvoke = function(f, ...)
		if self[f] then
			return self[f](self, ...)
		end
	end
	
	RemoteFunction.OnServerInvoke = function(player, f, ...)
		if self[f] and ClientWhitelist[f] and player == self.Player then
			return self[f](self, ...)
		else
			self.Player:Kick('gg bro gg')
		end
	end
	
	self:_connect(self.Humanoid.Died, function()
		self.Dead = true
		task.wait(3)
		
		if self.Char:FindFirstChild('AI') and self.Char['AI'].Value == true then
			self:ActivateAI()
		else
			self:Activate()
		end
		
	end)
	
	if self.Player then
		self:_connect(self.Player.CharacterRemoving, function()
			self:_clearConnections()
		end)
	end
	
	if self.Player then
		if not self.Player:GetAttribute('PressedPlay') then
			for k, v in pairs(self.Char:GetChildren()) do
				if v:IsA('BasePart') then
					v.Anchored = true
				end
			end
		end
	end
	
	self:UpdateHumanoid()
end

function Character:UpdateHumanoid()
	local WS = 0
	local JP = 50
	
	local BlockingSpeed = 8
	local StunnedSpeed = 1
	
	for i, tag in pairs(self.WalkSpeed.Tags) do
		WS += tag.Value
	end
	
	for i, tag in pairs(self.JumpPower.Tags) do
		JP += tag.Value
	end
	
	if self.Stun.IsStunned then
		WS = StunnedSpeed
	elseif self.Block.IsBlocking then
		WS = BlockingSpeed
	end
	
	self.Humanoid.WalkSpeed = WS
	self.Humanoid.JumpPower = JP
end

function Character:UpdateUsingMove()
	local isUsing = false

	for _, tag in pairs(self.UsingMove.Tags) do
		if tag.Value == true then
			isUsing = true
			break
		end
	end

	self.UsingMove.IsUsingMove = isUsing
end

function Character:Activate()	
	self.Player:LoadCharacter()
	
	self.Char = self.Player.Character
	self.Humanoid = self.Char.Humanoid
	self.Root = self.Char.HumanoidRootPart
	
	self.Char.Parent = workspace.Living
	self:SetUp()
end

function Character:ActivateAI()
	
	self.Char = self.Mob:Clone()
	self.Humanoid = self.Char.Humanoid
	self.Root = self.Char.HumanoidRootPart
	
	self.Char.Parent = workspace.Living
	
	local MasterVal = Instance.new('ObjectValue', self.Char)
	MasterVal.Value = self.Master
	MasterVal.Name = 'Master'
	
	local AiBool = Instance.new('BoolValue', self.Char)
	AiBool.Value = true
	AiBool.Name = 'AI'
	
	self.Root.CFrame = self.SpawnPoint
	self:SetUp()
end

function Character:PressedPlay()
	self.Player:SetAttribute('PressedPlay', true)
	
	for k, v in pairs(self.Char:GetChildren()) do
		if v:IsA('BasePart') then
			v.Anchored = false
		end
	end
end

function Character:InputBegan(data)
	
	if data.KeyCode == Enum.KeyCode.LeftControl then
		if self.Sprint.IsSprinting then
			self['DisableSprint'](self)
		else
			self['EnableSprint'](self)
		end
		
	elseif data.UserInputType == Enum.UserInputType.MouseButton1 then
		if self.Combat.M1Held then return end 
		self.Combat.M1Held = true
		self['Attack'](self, 'm1')
		
		task.spawn(function()
			while self.Combat.M1Held do
				self['Attack'](self, 'm1')
				task.wait()
			end
			
		end)
		
	elseif data.UserInputType == Enum.UserInputType.MouseButton2 then
		self['Attack'](self, 'm2')
		
	elseif data.KeyCode == Enum.KeyCode.F then
		self['StartBlocking'](self)
		self.Block.BlockHeld = true
		
		task.spawn(function()
			while self.Block.BlockHeld do
				self['StartBlocking'](self)
				task.wait()
			end
			
			self['StopBlocking'](self)
		end)
		
	end
	
end

function Character:InputEnded(data)
	if data.UserInputType == Enum.UserInputType.MouseButton1 then
		self.Combat.M1Held = false
		
	elseif data.KeyCode == 	Enum.KeyCode.F then
		self.Block.BlockHeld = false
		self['StopBlocking'](self)
	end
end

-- TODO!!
function Character:Attack(attackType, data)
	
	if attackType == 'm1' then						
		if self.Combat.M1Cooldown then return end
		if not self:ReturnCanAttack() then return end
		
		local Combo = self.Combat.Combo or 0
		local MaxCombo = 5
		
		if os.clock() - self.Combat.LastClock >= 1.25 then
			Combo = 0
			print('Reset!')
		elseif os.clock() - self.Combat.LastClock >= 0.75 and Combo < 4 then
			Combo = 0
			print('Early Reset!')
		end
		
		if Combo == 5 then return end
		Combo += 1
		
		if self.Combat.Track then
			self.Combat.Track:Stop()
		end
		
		local Anim = game.ReplicatedStorage.Assets.Anims.DefaultCombat['Combo'..Combo]
		self.Combat.Track = self['LoadAnimation'](self, Anim)
		self.Combat.Track:Play()
		
		
		self.Combat.Combo = Combo
		self['AddUsingMove'](self, {Name = 'DefaultCombat', Value = true, Timer = (Combo == 5 and 1.25 or 0.35)})
		self['AddWalkSpeed'](self, {Name = 'DefaultCombat', Value = -6, Timer = (Combo == 5 and 1.25 or 0.35)})
		
		print('Combat M1! ' .. Combo)
		self['DisableSprint'](self)
		
		self.Combat.LastClock = os.clock()

	elseif attackType == 'm2' then
		self.Combat.M2Counter += 1
		
		task.delay(0.25, function()
			self.Combat.M2Counter -= 1
			if self.Combat.M2Counter < 0 then
				self.Combat.M2Counter = 0
			end
		end)
		
		if self.Combat.M2Counter < 2 then return end
		if self.Combat.M2Cooldown then return end
		if not self:ReturnCanAttack() then return end
		if os.clock() - self.Combat.M2LastClock < 4 then return end
		
		if self.Combat.Track then
			self.Combat.Track:Stop()
		end

		local Anim = game.ReplicatedStorage.Assets.Anims.DefaultCombat.Heavy
		self.Combat.Track = self['LoadAnimation'](self, Anim)
		self.Combat.Track:Play()
		
		self['AddUsingMove'](self, {Name = 'DefaultCombat', Value = true, Timer = 0.55})
		self['AddWalkSpeed'](self, {Name = 'DefaultCombat', Value = -10, Timer = 0.55})
		
		self.Combat.M2LastClock = os.clock()
		
	end
	
end

function Character:EnableSprint()
	if not self['ReturnCanAttack'](self) then return end
	if self.Sprint.OnCooldown then return end
	
	self.Sprint.IsSprinting = true
	self.Sprint.OnCooldown = true
	
	if self.Sprint.Thread then
		task.cancel(self.Sprint.Thread)
	end
	
	local t = task.delay(0.3, function()
		self.Sprint.OnCooldown = false
	end)
	
	self.Sprint.Thread = t
	
	self['AddWalkSpeed'](self, {Name = 'Run', Value = 8})
end

function Character:DisableSprint()
	-- if not self['ReturnCanAttack'](self) then return end
	self.Sprint.IsSprinting = false
	self.Sprint.OnCooldown = true
	
	if self.Sprint.Thread then
		task.cancel(self.Sprint.Thread)
	end
	
	local t = task.delay(0.3, function()
		self.Sprint.OnCooldown = false
	end)
	
	self.Sprint.Thread = t
	
	self['RemoveWalkSpeed'](self, {Name = 'Run'})
end

function Character:StartBlocking()
	local CanAttack = self['ReturnCanAttack'](self)
	if not CanAttack then return end
	if self.Block.IsBlocking then return end
	if os.clock() - self.Block.LastClock < 0.18 then return end
	
	self.Block.IsBlocking = true
	self.Block.Capacity = 58
	
	if self.Block.Track then
		self.Block.Track:Stop()
	end
	
	if self.Combat.Track then
		self.Combat.Track:Stop()
	end
	
	local Anim = game.ReplicatedStorage.Assets.Anims.DefaultCombat.Block
	self.Block.Track = self['LoadAnimation'](self, Anim)
	self.Block.Track:Play()
	
	self.Block.LastClock = os.clock()
	
	self['DisableSprint'](self)
	self['UpdateHumanoid'](self)
end

function Character:StopBlocking()
	self.Block.IsBlocking = false
	
	if self.Block.Track then
		self.Block.Track:Stop()
	end
	
	self['UpdateHumanoid'](self)
end

function Character:DamageBlock(Dmg)
	if not Dmg then Dmg = 0 end
	if not self.Block.IsBlocking then return end
	
	self.Block.Capacity -= Dmg
	
	if self.Block.Capacity <= 0 then
		self['BlockBreak'](self)
	end
end

function Character:BlockBreak()
	self['StopBlocking'](self)
	self.Block.Capacity = 0 
	
	-- Effects
	
	-- AddStun
	
end

function Character:PerfectBlock(data) -- Victim, Attacker
	if data.Victim ~= self.Char then return end
	
	-- Effects
	
	-- AddStun
	
end


-- States
function Character:AddWalkSpeed(data)
	local Tag = {Name = data.Name or 'WalkSpeed_'..os.clock(), Value = data.Value or 0}
	table.insert(self.WalkSpeed.Tags, Tag)
	self:UpdateHumanoid()
	
	if data.Timer then
		task.delay(data.Timer, function()
			for i, tag in pairs(self.WalkSpeed.Tags) do
				if tag.Name == Tag.Name and tag.Value == Tag.Value then
					table.remove(self.WalkSpeed.Tags, i)
					self:UpdateHumanoid()
					break
				end
			end
		end)
	end
end

function Character:RemoveWalkSpeed(data)
	for i, tag in pairs(self.WalkSpeed.Tags) do
		if tag.Name == data.Name then
			table.remove(self.WalkSpeed.Tags, i)
			self:UpdateHumanoid()
			break
		end
	end
	
end

function Character:AddJumpPower(data)
	local Tag = {Name = data.Name or 'JumpPower_'..os.clock(), Value = data.Value or 0}
	table.insert(self.JumpPower.Tags, Tag)
	self:UpdateHumanoid()
	
	if data.Timer then
		task.delay(data.Timer, function()
			for i, tag in pairs(self.JumpPower.Tags) do
				if tag.Name == Tag.Name and tag.Value == Tag.Value then
					table.remove(self.JumpPower.Tags, i)
					self:UpdateHumanoid()
					break
				end
			end
		end)
	end
end

function Character:RemoveJumpPower(data)
	for i, tag in pairs(self.JumpPower.Tags) do
		if tag.Name == data.Name then
			table.remove(self.JumpPower.Tags, i)
			self:UpdateHumanoid()
			break
		end
	end
end

function Character:AddUsingMove(data)
	local Tag = {Name = data.Name or 'UsingMove_'..os.clock(), Value = data.Value or false}
	table.insert(self.UsingMove.Tags, Tag)
	self:UpdateUsingMove()
	
	if data.Timer then
		task.delay(data.Timer, function()
			for i, tag in pairs(self.UsingMove.Tags) do
				if tag.Name == Tag.Name and tag.Value == Tag.Value then
					table.remove(self.UsingMove.Tags, i)
					self:UpdateUsingMove()
					break
				end
			end
		end)
	end
end

function Character:RemoveUsingMove(data)
	for i, tag in pairs(self.UsingMove.Tags) do
		if tag.Name == data.Name then
			table.remove(self.UsingMove.Tags, i)
			self:UpdateUsingMove()
			break
		end
	end
	
end

function Character:AddCD(data)
	self.Cooldowns[data.Name] = {Enabled = true, Thread = nil}
	
	local thread = task.delay(data.Timer, function()
		self.Cooldowns[data.Name] = nil
	end)
	
	self.Cooldowns[data.Name].Thread = thread
end

function Character:RemoveCD(data)
	if self.Cooldowns[data.Name] then
		if self.Cooldowns[data.Name].Thread then
			task.cancel(self.Cooldowns[data.Name].Thread)
		end
		self.Cooldowns[data.Name] = nil
	end
end

function Character:ReturnHasCD(name)
	return self.Cooldowns[name] ~= nil and self.Cooldowns[name].Enabled == true
end

function Character:ReturnCanAttack()
	return self.Ragdoll.IsRagdolled == false and
		self.UsingMove.IsUsingMove == false and
		self.Block.IsBlocking == false and
		self.Stun.IsStunned == false
	
end

function Character:LoadAnimation(anim, humOrAnim)
	local Animator = humOrAnim or self.Humanoid:FindFirstChild('Animator') or self.Humanoid
	local Track = Animator:LoadAnimation(anim)
	
	return Track
end

return Character
