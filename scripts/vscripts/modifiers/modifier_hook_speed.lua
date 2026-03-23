modifier_hookshot_speed = class({})

function modifier_hookshot_speed:IsHidden() return true end
function modifier_hookshot_speed:IsDebuff() return false end
function modifier_hookshot_speed:IsPurgable() return false end
function modifier_hookshot_speed:RemoveOnDeath() return false end
function modifier_hookshot_speed:IsPermanent() return true end

function modifier_hookshot_speed:DeclareFunctions()
    return { MODIFIER_PROPERTY_PROJECTILE_SPEED_BONUS }
end

-- Hookshot starts slow (HOOKSHOT_BASE_SPEED is negative), and gets faster per kill.
-- Meat hook projectile is also affected — both benefit from racking up kills.
function modifier_hookshot_speed:GetModifierProjectileSpeedBonus()
    local kills = self:GetParent()._hnr_kills or 0
    return HOOKSHOT_BASE_SPEED + (kills * HOOKSHOT_KILL_SPEED_BONUS)
end
