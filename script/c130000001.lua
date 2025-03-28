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
	e1:SetTargetRange(LOCATION_HAND|LOCATION_MZONE,LOCATION_HAND|LOCATION_MZONE)
	e1:SetTarget(s.extg)
	c:RegisterEffect(e1)
    
    --mandatory attack drain
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_FZONE)
    e2:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e2:SetCountLimit(1)
	e2:SetCondition(s.atkcon)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
    
    --re-activate
    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_LEAVE_GRAVE)
	e3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY,EFFECT_FLAG2_CHECK_SIMULTANEOUS)
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
	local a,d=Duel.GetAttacker(),Duel.GetAttackTarget()
	if not d then return false end
    -- only 1 spirit involved in battle
	return a:IsType(TYPE_SPIRIT)~=d:IsType(TYPE_SPIRIT)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return true
	end
	local g=Group.FromCards(Duel.GetAttacker(),Duel.GetAttackTarget())
	local tc=g:Filter(aux.NOT(Card.IsType),nil,TYPE_SPIRIT):GetFirst()
	Duel.SetTargetCard(tc)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,tc,1,tc:GetControler(),tc:GetLocation())	
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain(0) and tc:IsFaceup() and not tc:IsType(TYPE_SPIRIT) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-1000)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_DAMAGE)
		tc:RegisterEffect(e1)
	end
end

-- recursion
function s.refilter(c)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousTypeOnField(TYPE_SPIRIT) and c:IsPreviousPosition(POS_FACEUP)
end
function s.recon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.refilter,1,nil)
end
function s.retg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		if not c:IsFieldSpell() or c:IsForbidden() then return false end
		for p=tp,1-tp,1-2*tp do
			if c:CheckUniqueOnField(p,LOCATION_FZONE) and (p==tp or c:IsAbleToChangeControler()) then
				return true
			end
		end
		return false
	end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,tp,0)
end
function s.reop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	if c:IsRelateToChain(0) and c:IsFieldSpell() and not c:IsForbidden() then
		local b1=c:CheckUniqueOnField(tp,LOCATION_FZONE)
		local b2=c:CheckUniqueOnField(1-tp,LOCATION_FZONE) and c:IsAbleToChangeControler()
        -- which field?
        local op=xgl.Option(tp,id,3,b1,b2)
		if not op then return end
        local target_p = op==0 and tp or 1-tp
        
        local fc=Duel.GetFieldCard(target_p,LOCATION_FZONE,0)
        if fc then
            Duel.SendtoGrave(fc,REASON_RULE)
            Duel.BreakEffect()
        end
        Duel.MoveToField(c,tp,target_p,LOCATION_FZONE,POS_FACEUP,true)
	end
end

