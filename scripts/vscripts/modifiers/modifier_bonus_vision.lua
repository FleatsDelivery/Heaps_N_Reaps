modifier_bonus_vision = class({})

function modifier_bonus_vision:IsHidden() return true end
function modifier_bonus_vision:IsPurgable() return false end
function modifier_bonus_vision:RemoveOnDeath() return false end
function modifier_bonus_vision:IsPermanent() return true end

function modifier_bonus_vision:OnCreated(params)
    -- Vision bonus can be set via params or hardcoded
    self.vision_bonus = params.vision_bonus or BONUS_VISION
    if IsServer() then
        self:UpdateVision()
    end
end

function modifier_bonus_vision:OnRefresh(params)
    self.vision_bonus = params.vision_bonus or self.vision_bonus
    if IsServer() then
        self:UpdateVision()
    end
end

function modifier_bonus_vision:UpdateVision()
    local parent = self:GetParent()
    if parent and IsValidEntity(parent) then
        local baseDay = parent:GetBaseDayTimeVisionRange() or 1800
        local baseNight = parent:GetBaseNightTimeVisionRange() or 800

        parent:SetDayTimeVisionRange(baseDay + self.vision_bonus)
        parent:SetNightTimeVisionRange(baseNight + self.vision_bonus)
    end
end
