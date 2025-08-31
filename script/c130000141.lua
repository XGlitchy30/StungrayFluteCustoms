--[[
Ancestagon Thundertops
Card Author: ExaltedDawn
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	Pendulum.AddProcedure(c)
	--[[You can shuffle this card from your Pendulum Zone into your Deck; add 1 Level 8 or higher "Ancestagon" monster from your Deck to your face-up Extra Deck.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetOriginalCategory(CATEGORY_TOEXTRA)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:HOPT()
	e1:SetFunctions(
		nil,
		s.tecost,
		s.tetg,
		s.teop
	)
	c:RegisterEffect(e1)
	--[[If an "Ancestagon" monster(s) is Tributed (except during the Damage Step): You can Special Summon this card from your hand.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_RELEASE)
	e2:SetRange(LOCATION_HAND)
	e2:HOPT()
	e2:SetCondition(xgl.EventGroupCond(s.cfilter))
	e2:SetSpecialSummonSelfFunctions()
	c:RegisterEffect(e2)
	--[[If this card is Pendulum Summoned: You can add 1 Level 8 or higher "Ancestagon" from your Deck to your face-up Extra Deck.]]
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,2)
	e3:SetCategory(CATEGORY_TOEXTRA)
	e3:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:HOPT()
	e3:SetCondition(xgl.PendulumSummonedCond)
	e3:SetSendtoFunctions(LOCATION_EXTRA,false,s.tefilter0,LOCATION_DECK,0,1,1,nil)
	c:RegisterEffect(e3)
	--[[If this card is Tributed: Add this card to your hand.]]
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(id,3)
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_RELEASE)
	e4:HOPT()
	e4:SetToHandSelfFunctions()
	c:RegisterEffect(e4)
end
s.listed_series={SET_ANCESTAGON}

--E1
function s.tefilter0(c)
	return c:IsSetCard(SET_ANCESTAGON) and c:IsLevelAbove(8)
end
function s.tefilter(c,e,tp)
	return s.tefilter0(c) and c:IsAbleToExtraFaceupAsCost(e,tp)
end
function s.tefilter_og(c)
	return c:IsOriginalType(TYPE_PENDULUM) and c:IsOriginalSetCard(SET_ANCESTAGON) and c:GetOriginalLevel()>=8 
end
function s.tecost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeckAsCost()
		and (Duel.IsExists(false,s.tefilter,tp,LOCATION_DECK,0,1,nil,e,tp) or (not Duel.IsPlayerAffectedByEffect(tp,EFFECT_CANNOT_TO_EXTRA_P) and s.tefilter_og(c)))
	end
	Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
function s.tetg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local isCostChecked=e:GetLabel()==1
		e:SetLabel(0)
		return isCostChecked or Duel.IsExists(false,s.tefilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	end
	e:SetLabel(0)
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,nil,1,tp,LOCATION_DECK)
end
function s.teop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Select(HINTMSG_TOEXTRA,false,tp,s.tefilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SendtoExtraP(g,tp,REASON_EFFECT)
	end
end


--E2
function s.cfilter(c)
	local current_state = not c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsMonsterType() and c:IsSetCard(SET_ANCESTAGON)
	local previous_state = c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousSetCard(SET_ANCESTAGON)
	return current_state or previous_state
end