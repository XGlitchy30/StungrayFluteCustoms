--[[
Laval Pyrocaster
Card Author: ExaltedDawn
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--You can banish 1 FIRE monster from your GY; Special Summon this card from your hand.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:HOPT()
	e1:SetFunctions(
		nil,
		s.spcost,
		s.sptg,
		s.spop
	)
	c:RegisterEffect(e1)
	--If this card is sent to the GY: Place 1 "Laval" monster, or 1 monster that lists "Laval" in its text, from your GY on top of your Deck, except "Laval Pyrocaster".
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:HOPT()
	e2:SetSendtoFunctions(LOCATION_DECK,false,s.tdfilter,LOCATION_GRAVE,0,1,1,nil,SEQ_DECKTOP)
	c:RegisterEffect(e2)
end
s.listed_names={id}
s.listed_series={SET_LAVAL}

--E1
function s.spcostfilter(c,tp)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true) and Duel.GetMZoneCount(tp,c)>0
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.spcostfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,nil,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.spcostfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,1,nil,tp)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return
		(e:IsCostChecked() or Duel.GetLocationCount(tp,LOCATION_MZONE)>0) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

--E2
function s.tdfilter(c)
	return c:IsMonster() and (c:IsSetCard(SET_LAVAL) or c:ListsArchetype(SET_LAVAL)) and not c:IsCode(id) and c:IsAbleToDeck()
end