--[[
Mount Fuji
Card Author: Sock
Scripted by: Sock
]]

local s,id,o=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	c:Activation() -- from glitchylib
	--extra summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,LOCATION_HAND+LOCATION_MZONE)
	e1:SetTarget(s.extg)
	c:RegisterEffect(e1)
    
    --mandatory attack drain
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_FZONE)
    e2:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e2:SetCondition(s.atkcon)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
    
    --re-activate
    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_LEAVE_GRAVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id,EFFECT_COUNT_CODE_DUEL)
	e3:SetCode(EVENT_TO_HAND)
	e3:SetCondition(s.recon)
	e3:SetTarget(s.retg)
	e3:SetOperation(s.reop)
	c:RegisterEffect(e3)
end
s.listed_card_types={TYPE_SPIRIT}

-- extra summon
function s.extg(e,c)
	return c:IsType(TYPE_SPIRIT)
end

-- attack drain
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
    -- only 1 spirit involved in battle
	return Duel.GetAttacker():IsType(TYPE_SPIRIT) ~= Duel.GetAttackTarget():IsType(TYPE_SPIRIT)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
        and Duel.IsExistingTarget(Card.IsFaceup,1-tp,0,LOCATION_MZONE,1,nil) end
	e:SetLabel(1000)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
    
    local ns=Duel.GetAttacker()
    if ns:IsType(TYPE_SPIRIT) then ns=Duel.GetAttackTarget() end
    -- oops, all spirits, somehow
    if ns:IsType(TYPE_SPIRIT) then return end
    
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(-e:GetLabel())
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    ns:RegisterEffect(e1)
end

-- recursion
function s.refilter(c)
	return c:IsPreviousLocation(LOCATION_MZONE)
        and c:IsType(TYPE_SPIRIT)
		and c:IsPreviousPosition(POS_FACEUP)
end
function s.recon(e,tp,eg,ep,ev,re,r,rp)
    if eg then
        return eg:IsExists(s.refilter,1,nil)
    end
end
function s.retg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
function s.reop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
        -- which field?
        local op=Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4))
        local target_p=op==0 and tp or 1-tp
        
        local fc=Duel.GetFieldCard(target_p,LOCATION_FZONE,0)
        if fc then
            Duel.SendtoGrave(fc,REASON_RULE)
            Duel.BreakEffect()
        end
        Duel.MoveToField(c,tp,target_p,LOCATION_FZONE,POS_FACEUP,true)
	end
end

