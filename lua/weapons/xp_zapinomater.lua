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

if CLIENT then

	local function CheckBind(cmd)
		if input.LookupBinding(cmd, true) then
			return string.upper(input.LookupBinding(cmd, true))
		end
		return "N/A"
	end

	SWEP.Instructions	=	language.GetPhrase("#Valve_Primary_Attack") .. ": Kill\n\n" ..
							language.GetPhrase("#Valve_Secondary_Attack") .. ": Kill everything near you\n\n" ..
							"Everything that makes contact with you shall die!\n\n" ..
							"Health regeneration up to 999 and armor to 255!"
	SWEP.BounceWeaponIcon = false
	SWEP.WepSelectIcon = surface.GetTextureID("xp_zapinomater/zapinomater_wep")

end

function SWEP:Initialize()

	self:SetHoldType("magic")

end

function SWEP:Think()

	if SERVER then

		if !self.Owner or !IsValid(self.Owner) or !self.Owner:Alive() then
			return
		end

		if self.Owner:Health() < 999 then
			self.Owner:SetHealth( self.Owner:Health() + 1 )
		end

		if self.Owner:Armor() < 255 then
			self.Owner:SetArmor( self.Owner:Armor() + 1 )
		end

		for k, v in pairs(ents.FindInSphere(self.Owner:GetPos() + Vector(0, 0, 30), 32.2)) do

			if IsValid(v) and v:Health() > 0 and v != self.Owner then

				local d = DamageInfo()
				d:SetDamage(512)
				d:SetDamageType(DMG_DIRECT)
				d:SetAttacker(self.Owner)
				d:SetInflictor(self)
				d:SetDamageForce(Vector(0, 0, 10000000))
				d:SetDamagePosition(v:GetPos())
				d:SetReportedPosition(self.Owner:GetPos())
				d:SetMaxDamage(2147483647)
				v:TakeDamageInfo(d)

			end

		end

	end

end

function SWEP:PrimaryAttack()

	if !IsFirstTimePredicted() then return end

	local tr = util.GetPlayerTrace(self.Owner)

	local trace = util.TraceLine(tr)

	if !trace.Hit then return end

	local effectdata = EffectData()
		effectdata:SetOrigin(trace.HitPos)
		effectdata:SetStart(self.Owner:GetBonePosition(self.Owner:LookupBone("ValveBiped.Bip01_R_Hand")))
		effectdata:SetAttachment(0)
		effectdata:SetEntity(self.Owner:GetViewModel())
	util.Effect("ToolTracer", effectdata)

	if SERVER then

		if !trace.HitNonWorld then return end

		if IsValid(trace.Entity) and trace.Entity:Health() > 0 then

			local d = DamageInfo()
			d:SetDamage(128)
			d:SetDamageType(DMG_ENERGYBEAM + DMG_DISSOLVE)
			d:SetAttacker(self.Owner)
			d:SetInflictor(self)
			d:SetDamageForce(self.Owner:GetAimVector() * 10000000)
			d:SetDamagePosition(trace.Entity:GetPos())
			d:SetReportedPosition(self.Owner:GetPos())
			d:SetMaxDamage(2147483647)
			trace.Entity:TakeDamageInfo(d)

		end

	end

end

function SWEP:SecondaryAttack()

	if !IsFirstTimePredicted() then return end

	if SERVER then

		for k, v in pairs( ents.FindInSphere(self.Owner:GetPos(), 750) ) do
			if IsValid(v) and v:Health() > 0 and v != self.Owner then

				local d = DamageInfo()
				d:SetDamage(64)
				d:SetDamageType(DMG_DIRECT)
				d:SetAttacker(self.Owner)
				d:SetInflictor(self)
				d:SetDamageForce(Vector(0, 0, 10000000))
				d:SetDamagePosition(v:GetPos())
				d:SetReportedPosition(self.Owner:GetPos())
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
