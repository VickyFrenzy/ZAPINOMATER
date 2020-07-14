--[[---------------------------------------------------------
		"ZAPINOMATER" SWEP for Garry's Mod
				by VictorienXP (2015)
-----------------------------------------------------------]]

AddCSLuaFile()

SWEP.PrintName		= "ZAPINOMATER"
SWEP.Author			= "VictorienXP"
SWEP.Category		= "Other"
SWEP.Purpose		= "Kill all the things"

SWEP.Spawnable		= true
SWEP.AdminOnly		= true

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo			= "none"

SWEP.Weight				= 10
SWEP.AutoSwitchTo		= true
SWEP.AutoSwitchFrom		= false

SWEP.ViewModelFOV	= 54
SWEP.Slot			= 2
SWEP.SlotPos		= 3
SWEP.DrawAmmo		= false
SWEP.DrawCrosshair	= true

SWEP.ViewModel		= Model("models/weapons/c_arms.mdl")
SWEP.WorldModel		= ""
SWEP.UseHands		= true

if CLIENT then

	SWEP.Instructions	=	language.GetPhrase("#Valve_Primary_Attack") .. ": Kill\n\n" ..
							language.GetPhrase("#Valve_Secondary_Attack") .. ": Kill everything near you\n\n" ..
							"Everything that makes contact with you shall die!\n\n" ..
							"Health regeneration up to 999 and armor to 255!"
	SWEP.BounceWeaponIcon = false
	SWEP.WepSelectIcon = surface.GetTextureID("xp_zapinomater/zapinomater_wep")

end

local bonelist = {"ValveBiped.Bip01_R_Hand", "ValveBiped.Bip01_Head1", "LrigScull", "ValveBiped.Bip01_Pelvis", "LrigPelvis"}

function SWEP:getthebone()

	local owner = self:GetOwner()

	if not owner or not IsValid(owner) then
		return
	end

	self.thebone = nil

	for _, v in pairs(bonelist) do

		local bone = owner:LookupBone(v)

		if bone then

			self.thebone = bone

			break

		end

	end

	if not self.thebone then
		self.thebone = 0
	end

	self.lastpm = owner:GetModel()

	return self.thebone

end

function SWEP:Initialize()

	self:SetHoldType("magic")

end

function SWEP:Think()

	local owner = self:GetOwner()

	if not owner or not IsValid(owner) or not owner:Alive() then
		return
	end

	if self.thebone == nil or self.lastpm ~= owner:GetModel() then
		self:getthebone()
	end

	if SERVER then

		if owner:Health() < 999 then
			owner:SetHealth( owner:Health() + 1 )
		end

		if owner:Armor() < 255 then
			owner:SetArmor( owner:Armor() + 1 )
		end

		for _, v in pairs(ents.FindInSphere(owner:GetPos() + Vector(0, 0, 30), 32.2)) do

			if IsValid(v) and v:Health() > 0 and v ~= owner then

				local d = DamageInfo()
				d:SetDamage(512)
				d:SetDamageType(DMG_DIRECT)
				d:SetAttacker(owner)
				d:SetInflictor(self)
				d:SetDamageForce(Vector(0, 0, 10000000))
				d:SetDamagePosition(v:GetPos())
				d:SetReportedPosition(owner:GetPos())
				d:SetMaxDamage(2147483647)
				v:TakeDamageInfo(d)

			end

		end

	end

end

function SWEP:PrimaryAttack()

	if not IsFirstTimePredicted() then return end

	local owner = self:GetOwner()

	local tr = util.GetPlayerTrace(owner)

	local trace = util.TraceLine(tr)

	if not trace.Hit then return end

	local effectdata = EffectData()
		effectdata:SetOrigin(trace.HitPos)
		effectdata:SetStart(owner:GetBonePosition(self.thebone or self:getthebone()))
		effectdata:SetAttachment(0)
		effectdata:SetEntity(owner:GetViewModel())
	util.Effect("ToolTracer", effectdata)

	if SERVER then

		if not trace.HitNonWorld then return end

		if IsValid(trace.Entity) and trace.Entity:Health() > 0 then

			local d = DamageInfo()
			d:SetDamage(128)
			d:SetDamageType(DMG_ENERGYBEAM + DMG_DISSOLVE)
			d:SetAttacker(owner)
			d:SetInflictor(self)
			d:SetDamageForce(owner:GetAimVector() * 10000000)
			d:SetDamagePosition(trace.Entity:GetPos())
			d:SetReportedPosition(owner:GetPos())
			d:SetMaxDamage(2147483647)
			trace.Entity:TakeDamageInfo(d)

		end

	end

end

function SWEP:SecondaryAttack()

	if not IsFirstTimePredicted() then return end

	local owner = self:GetOwner()

	if SERVER then

		for _, v in pairs( ents.FindInSphere(owner:GetPos(), 750) ) do
			if IsValid(v) and v:Health() > 0 and v ~= owner then

				local d = DamageInfo()
				d:SetDamage(64)
				d:SetDamageType(DMG_DIRECT)
				d:SetAttacker(owner)
				d:SetInflictor(self)
				d:SetDamageForce(Vector(0, 0, 10000000))
				d:SetDamagePosition(v:GetPos())
				d:SetReportedPosition(owner:GetPos())
				d:SetMaxDamage(2147483647)
				v:TakeDamageInfo(d)

			end
		end

	end

end

function SWEP:Reload()
end

function SWEP:ShouldDropOnDie()
	return false
end

function SWEP:OnDrop()
	self:Remove()
end
