modifier_max_health_cap = class({})

function modifier_max_health_cap:IsHidden() return true end
function modifier_max_health_cap:IsDebuff() return false end
function modifier_max_health_cap:IsPurgable() return false end
function modifier_max_health_cap:RemoveOnDeath() return false end
function modifier_max_health_cap:IsPermanent() return true end

function modifier_max_health_cap:DeclareFunctions()
    return { MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS }
end

function modifier_max_health_cap:GetModifierExtraHealthBonus()
    local parent = self:GetParent()
    local maxHealthCap = MAX_HEALTH_CAP
    local baseMax = parent:GetBaseMaxHealth()

    if baseMax > maxHealthCap then
        return maxHealthCap - baseMax
    end
    return 0
end
