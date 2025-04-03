--[[
Demonisu Subordination
Card Author: AuroraUline
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--[[Target 1 "Demonisu" monster you control; it gains 500 ATK until the end of this turn.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET|EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:HOPT()
	e1:SetFunctions(aux.StatChangeDamageStepCondition,nil,s.target,s.activate)
	c:RegisterEffect(e1)
	--[[If a "Demonisu" monster(s) is returned to your hand (except during the Damage Step): You can banish this card from your GY; immediately after this effect resolves, Normal Summon 1 Level 4 or lower "Demonisu" monster.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY,EFFECT_FLAG2_CHECK_SIMULTANEOUS)
	e2:SetCode(EVENT_TO_HAND)
	e2:SetRange(LOCATION_GRAVE)
	e2:HOPT()
	e2:SetFunctions(
		xgl.EventGroupCond(s.cfilter),
		aux.bfgcost,
		s.nstg,
		s.nsop
	)
	c:RegisterEffect(e2)
end
s.listed_series={SET_DEMONISU}

--E1
function s.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_DEMONISU)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.atkfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATKDEF)
	local g=Duel.SelectTarget(tp,s.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,#g,tp,500)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsFaceup() then
		tc:UpdateATK(500,RESET_PHASE|PHASE_END,e:GetHandler(),true)
	end
end

--E2
function s.cfilter(c,_,tp)
	return c:IsMonster() and c:IsSetCard(SET_DEMONISU) and c:IsControler(tp) and not c:IsPreviousLocation(LOCATION_DECK)
end
function s.nsfilter(c)
	return c:IsSetCard(SET_DEMONISU) and c:IsLevelBelow(4) and c:IsSummonable(true,nil)
end
function s.nstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.nsfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,exc)
	end
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
function s.nsop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local g=Duel.SelectMatchingCard(tp,s.nsfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		Duel.Summon(tp,tc,true,nil)
	end
end