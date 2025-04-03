--[[
Anura the Star Liege
Card Author: LimitlessSocks
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--[[During your Standby Phase: You can reveal 1 monster in your hand with 2400 or 2800 ATK; you cannot Special Summon monsters from the Extra Deck for the rest of this turn, also Special Summon
	this card from your GY.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE|PHASE_STANDBY)
	e1:SetRange(LOCATION_GRAVE)
	e1:HOPT()
	e1:SetFunctions(
		xgl.TurnPlayerCond(0),
		xgl.RevealCost(aux.FilterBoolFunction(Card.IsAttack,2400,2800)),
		xgl.SpecialSummonSelfTarget(),
		s.spop
	)
	c:RegisterEffect(e1)
	--[[If this card is Tributed for a Tribute Summon: You can target 1 banished card; shuffle it into the Deck.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,2)
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET|EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_RELEASE)
	e2:HOPT()
	e2:SetCondition(s.thcon)
	e2:SetSendtoFunctions(LOCATION_DECK,TGCHECK_IT,aux.TRUE,LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil)
	c:RegisterEffect(e2)
end

--E1
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,1)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsLocation,LOCATION_EXTRA))
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	aux.addTempLizardCheck(e:GetHandler(),tp)
end

--E2
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_SUMMON)
end