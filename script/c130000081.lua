--[[
Melting Footsteps Behind Us
Card Author: AuroraUline
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--[[If you control a Psychic monster: Gain LP equal to the number of cards in your opponent's hand x 300, then, if you control a "Linaan" card, you can add 1 Psychic monster from your GY to your
	hand.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_RECOVER|CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_MAIN_END|TIMING_ATTACK|TIMING_END_PHASE)
	e1:HOPT(true)
	e1:SetFunctions(
		xgl.LocationGroupCond(aux.FaceupFilter(Card.IsRace,RACE_PSYCHIC),LOCATION_MZONE,0,1),
		nil,
		s.target,
		s.activate
	)
	c:RegisterEffect(e1)
end
s.listed_series={SET_LINAAN}

--E1
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetHandCount(1-tp)
	if chk==0 then return ct>0 end
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,ct*300)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetHandCount(1-tp)
	if ct>0 and Duel.Recover(tp,ct*300,REASON_EFFECT)>0 and Duel.IsExists(false,aux.FaceupFilter(Card.IsSetCard,SET_LINAAN),tp,LOCATION_ONFIELD,0,1,nil)
		and Duel.IsExists(false,aux.Necro(s.thfilter),tp,LOCATION_GRAVE,0,1,nil) and Duel.SelectYesNo(tp,STRING_ASK_TO_HAND) then
		local g=Duel.Select(HINTMSG_ATOHAND,false,tp,aux.Necro(s.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
		Duel.BreakEffect()
		Duel.Search(g)
	end
end
function s.thfilter(c)
	return c:IsMonsterType() and c:IsRace(RACE_PSYCHIC) and c:IsAbleToHand()
end