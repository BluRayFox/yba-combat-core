local RS = game.ReplicatedStorage
local SS = game.ServerStorage
local SSS = game.ServerScriptService

local SSSMods = SSS.Modules
local RSMods = RS.Assets.Modules
local SSMods = SS.Assets.Modules

local Channel = require(RSMods.Channel)
local HitboxMod = require(SSMods.HitboxMod)
local SFuncs = require(SSSMods.SFuncs)
local CombatStyleLib = require(SSMods.CombatStyleLib)

local DefaultCombat = {}

local Skill = 'M1'
DefaultCombat['InputBegan'..Skill] = function(self, extra)
	
	local Tool = nil
	local Config = CombatStyleLib['DefaultCombat']('ReturnConfig')
	
	local CantAttack = not self['ReturnCanAttack'](self)
	local IsUsingMove = self.UsingMove.IsUsingMove
	
	local Speed = Config.Speed
	
	if IsUsingMove or CantAttack then return end
	
	local Combo = self.Combat.Combo
	local now = os.clock()
	local lastTick = self.Combat.M1LastTick
	
	if now - lastTick > Config.Cooldown and Combo == Config.MaxCombo then
		Combo = 0
	elseif now - lastTick > 0.75 and Combo < Config.MaxCombo then
		Combo = 0
	end

	Combo += 1
	if Combo > Config.MaxCombo then return end
	
	self['DisableSprint'](self)
	
	if self.Combat.Track then
		self.Combat.Track:Stop()
	end
	
	local Anim = game.ReplicatedStorage.Assets.Anims.DefaultCombat['Combo'..Combo]
	self.Combat.Track = self['LoadAnimation'](self, Anim)
	self.Combat.Track:Play()
	
	local Hb = HitboxMod.new()
	Hb.Size = Vector3.new(5, 6, 4.5)
	Hb.Origin = self.Root
	Hb.Visualiser = true
	Hb.VisualiseTo = self.Player
	Hb.Offset = CFrame.new(0, 0, -1)
	
	local DamageChannel = Channel.new()
	DamageChannel.DurationTimer = Speed * 0.85
	
	DamageChannel.Duration = function()
		if self.Stun.IsStunned then 
			DamageChannel:StopShort()
			return
		end
		
		local Chars = Hb:Cast({self.Char})
		for _, char in pairs(Chars) do
			local DamageInfo = CombatStyleLib['DefaultCombat']('ReturnDamage_Info', 
				{Origin = self.Root, Hit = char.HumanoidRootPart, Combo = Combo}
			)
			
			SFuncs.Damage(self.Char, char, DamageInfo)
		end
	end
	
	task.delay(0.2, function()
		if self.Stun.IsStunned then return end 
		DamageChannel:Start()
	end)
	
	self.Combat.M1LastTick = now
	self.Combat.Combo = Combo
	
	self['AddUsingMove'](self, {Name = 'M1', Value = true, Timer = Speed})
	self['AddWalkSpeed'](self, {Name = 'M1', Value = -6, Timer = (Combo < 4 and Speed or Speed + 0.85)})
end

DefaultCombat['InputEnded'..Skill] = function(self, extra)
	
end

DefaultCombat['M2'] = function(self, extra)

end

return DefaultCombat
