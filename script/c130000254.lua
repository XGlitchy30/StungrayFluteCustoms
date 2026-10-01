--[[
Frequenza dei Coleotteri a Percussione 
Card Author: AuroraUline
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
    --During your Battle Phase, if a "Percussion Beetle" monster you control destroys an opponent's monster by battle while you control 3 "Percussion Beetle" monsters with different names: Conduct an additional Battle Phase after this one.
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCustomCategory(CATEGORY_ADD_BATTLE_PHASE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:HOPT()
	e1:SetCondition(s.damcon)
	e1:SetTarget(s.damtg)
	e1:SetOperation(s.damop)
	c:RegisterEffect(e1)
	--If a "Percussion Beetle" monster(s) would be destroyed by battle, you can banish this card from your GY instead.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,2)
	e2:SetType(EFFECT_TYPE_CONTINUOUS|EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:HOPT()
	e2:SetTarget(s.reptg)
	e2:SetValue(s.repval)
	e2:SetOperation(s.repop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_PERCUSSION_BEETLE}

--E1
function s.cfilter(c,tp)
	local bc=c:GetBattleTarget()
	if not bc:IsPreviousControler(1-tp) then return false end
	if c:IsRelateToBattle() then
		return c:IsFaceup() and c:IsSetCard(SET_PERCUSSION_BEETLE) and c:IsControler(tp)
	else
		return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousSetCard(SET_PERCUSSION_BEETLE)
			and c:IsPreviousControler(tp)
	end
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsSetCard,SET_PERCUSSION_BEETLE),tp,LOCATION_MZONE,0,nil)
	return g:GetClassCount(Card.GetCode)>=3 and eg:IsExists(s.cfilter,1,nil,tp)
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsBattlePhase(tp) end
	Duel.SetCustomOperationInfo(0,CATEGORY_ADD_BATTLE_PHASE,nil,0,tp,1)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsBattlePhase(tp) then return end
	if Duel.AddBattlePhase() then
		local _,n=Duel.GetAdditionalBattlePhaseCount()
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_BATTLE,EFFECT_FLAG_CLIENT_HINT,n,0,aux.Stringid(id,1))
	end
end

--E2
function s.repfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and c:IsSetCard(SET_PERCUSSION_BEETLE)
		and c:IsReason(REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemove() and eg:IsExists(s.repfilter,1,nil,tp) end
	return Duel.SelectEffectYesNo(tp,c,96)
end
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT|REASON_REPLACE)
end