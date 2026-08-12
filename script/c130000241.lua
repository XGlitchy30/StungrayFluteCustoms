--[[
Bestia Cristallo Drago Arcobaleno Oscuro 
Card Author: AuroraUline
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--You can discard this card; add 1 "Advanced Dark" from your Deck to your hand.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORIES_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:HOPT()
	e1:SetCost(Cost.SelfDiscard)
	e1:SetSearchFunctions(aux.FilterBoolFunction(Card.IsCode,CARD_ADVANCED_DARK))
	c:RegisterEffect(e1)
	--If another "Crystal Beast" card(s) is sent to the GY, even during the Damage Step: You can place this card from your GY into your Spell & Trap Zone as a Continuous Spell, and if you do, add 1 "Crystal Miracle" from your Deck to your hand. You cannot Special Summon monsters, except by the effect of "Crystal Miracle", until you have activated "Crystal Miracle" or until the end of your next turn.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORIES_SEARCH)
	e2:SetCustomCategory(CATEGORY_PLACE_IN_STZONE)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_DAMAGE_STEP,EFFECT_FLAG2_CHECK_SIMULTANEOUS)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_GRAVE)
	e2:HOPT()
	e2:SetCondition(s.stcon)
	e2:SetTarget(s.sttg)
	e2:SetOperation(s.stop)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_ADVANCED_DARK,CARD_CRYSTAL_MIRACLE}
s.listed_series={SET_CRYSTAL_BEAST}


--E2
function s.stcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSetCard,1,e:GetHandler(),SET_CRYSTAL_BEAST)
end
function s.thfilter(c)
	return c:IsCode(CARD_CRYSTAL_MIRACLE) and c:IsAbleToHand()
end
function s.sttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsCanBePlacedInBackrow(TYPE_SPELL|TYPE_CONTINUOUS,tp,re,r,rp,false) and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,tp,0)
	Duel.SetCustomOperationInfo(0,CATEGORY_PLACE_IN_STZONE,c,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.stop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and not c:IsImmuneToEffect(e) and aux.NecroValleyFilter(aux.TRUE)(c) and Duel.PlaceAsContinuousCard(c,tp,tp,c,TYPE_SPELL,nil)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.Search(g)
		end
	end
	local ct=Duel.GetNextPhaseCount(nil,tp)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE|PHASE_END|RESET_TURN_SELF,ct)
	Duel.RegisterEffect(e1,tp)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetLabelObject(e1)
	e2:SetCondition(s.resetcon)
	e2:SetOperation(s.resetop)
	e2:SetReset(RESET_PHASE|PHASE_END|RESET_TURN_SELF,ct)
	Duel.RegisterEffect(e2,tp)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not se or not se:GetHandler():IsCode(CARD_CRYSTAL_MIRACLE)
end
function s.resetcon(e,tp,eg,ep,ev,re,r,rp)
	if not (re:IsHasType(EFFECT_TYPE_ACTIVATE) and rp==tp) then return false end
	local trig_code1,trig_code2=Duel.GetChainInfo(Duel.GetCurrentChain(),CHAININFO_TRIGGERING_CODE,CHAININFO_TRIGGERING_CODE2)
	return trig_code1==CARD_CRYSTAL_MIRACLE or trig_code2==CARD_CRYSTAL_MIRACLE
end
function s.resetop(e,tp,eg,ep,ev,re,r,rp)
	local e1=e:GetLabelObject()
	if e1 then
		e1:Reset()
	end
	e:Reset()
end