local RS = game.ReplicatedStorage
local RSMods = RS.Assets.Modules
local ClientFX = game.ReplicatedStorage.Remotes.ClientFX

local DefaultCombatLib = require(script.DefaultCombat) -- M1 and M2 Attacks
local Channel = require(RSMods.Channel)

local Character = {}
local ClientWhitelist = {}

function addws(s) ClientWhitelist[s] = true end
function addwst(t) for _, s in ipairs(t) do addws(s) end end

addwst({
	'InputBegan',
	'InputEnded',
})

local RagdollJoints = {
	Neck = {
		"BallSocket";
		Properties = {
			LimitsEnabled = true;
			TwistLimitsEnabled = true;
			MaxFrictionTorque = 0;

			UpperAngle = 25;
			TwistLowerAngle = -45;
			TwistUpperAngle = 45;

			Restitution = 0;
		};
	};

	RootJoint = {
		"BallSocket";
		Properties = {
			LimitsEnabled = true;
			TwistLimitsEnabled = true;
			MaxFrictionTorque = 0;

			UpperAngle = 10;
			TwistLowerAngle = -10;
			TwistUpperAngle = 10;

			Restitution = 0;
		};
	};

	LeftShoulder = {
		"BallSocket";
		Properties = {
			LimitsEnabled = true;
			TwistLimitsEnabled = true;
			MaxFrictionTorque = 0;

			UpperAngle = 85;
			TwistLowerAngle = -60;
			TwistUpperAngle = 60;

			Restitution = 0;
		};
	};

	RightShoulder = {
		"BallSocket";
		Properties = {
			LimitsEnabled = true;
			TwistLimitsEnabled = true;
			MaxFrictionTorque = 0;

			UpperAngle = 85;
			TwistLowerAngle = -60;
			TwistUpperAngle = 60;

			Restitution = 0;
		};
	};

	LeftHip = {
		"BallSocket";
		Properties = {
			LimitsEnabled = true;
			TwistLimitsEnabled = true;
			MaxFrictionTorque = 0;

			UpperAngle = 60;
			TwistLowerAngle = -40;
			TwistUpperAngle = 40;

			Restitution = 0;
		};
	};

	RightHip = {
		"BallSocket";
		Properties = {
			LimitsEnabled = true;
			TwistLimitsEnabled = true;
			MaxFrictionTorque = 0;

			UpperAngle = 60;
			TwistLowerAngle = -40;
			TwistUpperAngle = 40;

			Restitution = 0;
		};
	};
}

local RagdollJointR15 = {
	LeftAnkle = {
		"Hinge";
		Properties = {
			LimitsEnabled = true;
			UpperAngle = 0; --5
			LowerAngle = -45; --5
			Restitution = 0;
		};
	};
	RightAnkle = {
		"Hinge";
		Properties = {
			LimitsEnabled = true;
			UpperAngle = 0; --5
			LowerAngle = -45; --5
			Restitution = 0;
		};
	};
	LeftKnee = {
		"Hinge";
		Properties = {
			LimitsEnabled = true;
			UpperAngle = -10;
			LowerAngle = -135;
			Restitution = 0;
		};
	};
	RightKnee = {
		"Hinge";
		Properties = {
			LimitsEnabled = true;
			UpperAngle = -10;
			LowerAngle = -135;
			Restitution = 0;
		};
	};
	LeftHip = {
		"BallSocket";
		Properties = {
			LimitsEnabled = true;
			TwistLimitsEnabled = true;
			MaxFrictionTorque = 0;
			UpperAngle = 40;
			TwistLowerAngle = -3;
			TwistUpperAngle = 3;
			Restitution = 0;
		};
	};
	RightHip = {
		"BallSocket";
		Properties = {
			LimitsEnabled = true;
			TwistLimitsEnabled = true;
			MaxFrictionTorque = 0;
			UpperAngle = 40; --30
			TwistLowerAngle = -3;
			TwistUpperAngle = 3;
			Restitution = 0;
		};
	};
	Waist = {
		"BallSocket";
		Properties = {
			LimitsEnabled = true;
			TwistLimitsEnabled = true;
			MaxFrictionTorque = 0;
			UpperAngle = 15;
			TwistLowerAngle = -1;
			TwistUpperAngle = 1;
			Restitution = 0;
		};
	};
	LeftShoulder = {
		"BallSocket";
		Properties = {
			LimitsEnabled = true;
			TwistLimitsEnabled = true;
			MaxFrictionTorque = 0;
			UpperAngle = 30;
			TwistLowerAngle = -30;
			TwistUpperAngle = 30;
			Restitution = 0;
		};
	};
	RightShoulder = {
		"BallSocket";
		Properties = {
			LimitsEnabled = true;
			TwistLimitsEnabled = true;
			MaxFrictionTorque = 0;
			UpperAngle = 30;
			TwistLowerAngle = -30;
			TwistUpperAngle = 30;
			Restitution = 0;
		};
	};
	LeftElbow = {
		"Hinge";
		Properties = {
			LimitsEnabled = true;
			UpperAngle = 135;
			LowerAngle = 0;
			Restitution = 0;
		};
	};
	RightElbow = {
		"Hinge";
		Properties = {
			LimitsEnabled = true;
			UpperAngle = 135;
			LowerAngle = 0;
			Restitution = 0;
		};
	};
	LeftWrist = {
		"Hinge";
		Properties = {
			LimitsEnabled = true;
			UpperAngle = 20; --5
			LowerAngle = -20; --5
			Restitution = 0;
		};
	};
	RightWrist = {
		"Hinge";
		Properties = {
			LimitsEnabled = true;
			UpperAngle = 20; --5
			LowerAngle = -20; --5
			Restitution = 0;
		};
	};
	Neck = {
		"BallSocket";
		Properties = {
			LimitsEnabled = true;
			TwistLimitsEnabled = true;
			MaxFrictionTorque = 0;
			UpperAngle = 0;
			TwistLowerAngle = -45;
			TwistUpperAngle = 45;
			Restitution = 0;
		};
	};
}

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

function Character:_addTag(tagsTable, tagName, value, timer, onEnd, behaviour)
	behaviour = behaviour or 'Cancel' -- 'Return'

	local existingTag = tagsTable[tagName]

	-- Если тег уже есть
	if existingTag then
		if behaviour == 'Return' then
			return
		elseif behaviour == 'Cancel' then
			self:_removeTag(tagsTable, tagName)
		end
	end

	local tag = {
		Value = value ~= nil and value or true
	}

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
	
	if self.Player and self.Player.Character then
		self.Player.Character:Destroy()
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
	self.Knock = {Tags = {}, IsKnocked = false}
	
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
	
	self.Humanoid.BreakJointsOnDeath = false
	
	self['_connect'](self, self.Humanoid.Died, function()
		if self.Dead then return end	-- Fix
		
		self['Ragdoll'](self)
		self.Dead = true
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
	
	if self.Player then
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
		
		self.RemoteEvent = REvent
		self.RemoteFunction = RFunc
	end
	
	self.BindableFunction = BFunc
	self.BindableEvent = BEvent
	
	for _, charPart in pairs(self.Char:GetChildren()) do
		if charPart:IsA('BasePart') then
			charPart.CollisionGroup = self.Player and 'Player' or 'Mob'
		end
	end
	
	self.HurtTrack = nil
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
	
	if self.Stun.IsStunned then
		local StunnedBB = self.Char.Head:FindFirstChild('StunnedBB')
		if not StunnedBB then
			StunnedBB = game.ReplicatedStorage.Assets.Objects.StunnedBB:Clone()
			StunnedBB.Parent = self.Char.Head
		end
		
	else
		local StunnedBB = self.Char.Head:FindFirstChild('StunnedBB')
		if StunnedBB then
			StunnedBB:Destroy()
		end
	end
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
	
	local Skill = (extra and extra.InputType or 'InputBegan')..Type
	if DefaultCombatLib[Skill] then
		DefaultCombatLib[Skill](self, extra)
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

function Character:DamageBlock(Dmg)
	if not self.Block.IsBlocking then return end
	self.Block.Capacity -= Dmg
	
	if self.Block.Capacity <= 0 then
		self.Block.Capacity = 0
		self['BlockBreak'](self)
		return
	end
	
	ClientFX:FireAllClients('BlockHit', {Origin = self.Root})
end

function Character:BlockBreak()
	if not self.Block.IsBlocking then return end
	self['StopBlocking'](self)
	ClientFX:FireAllClients('BlockBreak', {Origin = self.Root})
	
	self['AddStun'](self, {Name = 'BlockBreakStun', Timer = 1.5})
end

function Character:PerfectBlock(data)
	local Attacker = data.Attacker
	local Victim = data.Victim
	
	if self.Char == Attacker then
		self['AddStun'](self, {Name = 'PerfectBlockStun', Timer = 1.5})
	end
	
	ClientFX:FireAllClients('BlockBreak', {Attacker = Attacker, Victim = Victim})
end

function Character:ReturnBlock()
	return self.Block
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
	self:_addTag(self.Stun.Tags, Data.Name, Data.Value, Data.Timer, function() self['UpdateHumanoid'](self) end, 'Return')
	self['UpdateHumanoid'](self)
end

function Character:RemoveStun(Data)
	self:_removeTag(self.Stun.Tags, Data.Name)
	self['UpdateHumanoid'](self)
end

function Character:AddCD(Data)
	self:_addTag(self.Cooldowns, Data.Name, true, Data.Timer)
end

function Character:RemoveCD(Data)
	self:_removeTag(self.Cooldowns, Data.Name)
end

function Character:Ragdoll()
	if self.Unconscious then return end
	self.Unconscious = true

	self.Humanoid.RequiresNeck = false
	self.Humanoid.AutoRotate = false
	self.Humanoid.PlatformStand = true
	self.Humanoid:ChangeState(Enum.HumanoidStateType.Physics)

	for _, v in pairs(self.Char:GetDescendants()) do
		if v:IsA("Motor6D") then
			local jointName = v.Name:gsub(" ", "")
			local jointData = RagdollJoints[jointName]

			local a0 = Instance.new("Attachment")
			local a1 = Instance.new("Attachment")

			a0.Name = "RagdollAttachment"
			a1.Name = "RagdollAttachment"

			a0.CFrame = v.C0
			a1.CFrame = v.C1

			a0.Parent = v.Part0
			a1.Parent = v.Part1

			local constraint

			if jointData then
				if jointData[1] == "BallSocket" then
					constraint = Instance.new("BallSocketConstraint")
				elseif jointData[1] == "Hinge" then
					constraint = Instance.new("HingeConstraint")
				end

				if constraint then
					constraint.Attachment0 = a0
					constraint.Attachment1 = a1

					-- Apply all properties dynamically
					for prop, val in pairs(jointData.Properties) do
						if constraint[prop] ~= nil then
							constraint[prop] = val
						end
					end

					constraint.Parent = v.Parent
				end
			else
				-- fallback (safe default)
				local socket = Instance.new("BallSocketConstraint")
				socket.Attachment0 = a0
				socket.Attachment1 = a1
				socket.LimitsEnabled = true
				socket.UpperAngle = 45
				socket.TwistLimitsEnabled = true
				socket.TwistLowerAngle = -45
				socket.TwistUpperAngle = 45
				socket.Parent = v.Parent
			end

			v.Enabled = false

		elseif v:IsA("BasePart") then
			v.CollisionGroup = "Ragdoll"

			if v.Name == "HumanoidRootPart" then
				v.CanCollide = false
			elseif v.Parent == self.Char then
				v.CanCollide = true
			end
			
		end
	end
	
	self['UpdateHumanoid'](self)
end

function Character:Unragdoll()
	if not self.Unconscious then return end
	self.Unconscious = false

	for _, v in pairs(self.Char:GetDescendants()) do
		if v:IsA("Motor6D") then
			v.Enabled = true

		elseif v:IsA("BallSocketConstraint") or v:IsA("HingeConstraint") then
			v:Destroy()

		elseif v:IsA("Attachment") and v.Name == "RagdollAttachment" then
			v:Destroy()

		elseif v:IsA("BasePart") then
			v.CollisionGroup = self.Player and "Player" or "Mob"

			if v.Name == "HumanoidRootPart" or v.Name == 'Head' or v.Name == 'Torso' then
				v.CanCollide = true
			else
				v.CanCollide = false
			end
		end
	end

	self.Humanoid.PlatformStand = false
	self.Humanoid.AutoRotate = true
	self.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)

	self['UpdateHumanoid'](self)
end

function Character:ReturnHasCD(Name)
	return self.Cooldowns[Name] ~= nil
end

function Character:ReturnCanAttack()
	return self.Stun.IsStunned == false and
		self.Unconscious == false and
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

function Character:PlayHurt()
	if self.HurtTrack then
		self.HurtTrack:Stop()
	end
	
	local R = math.random(1,3)
	local Anim = RS.Assets.Anims.Hurt:FindFirstChild(tostring(R))
	
	local Track = self['LoadAnimation'](self, Anim)
	Track.Priority = Enum.AnimationPriority.Action4
	Track:Play()
	Track:AdjustSpeed(0.7)
	
	self.HurtTrack = Track
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
