--[[
Cradle Queltz
Card Author: LimitlessSock
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	c:EnableReviveLimit()
	--[[You can discard this card; add 1 "Queltz" card from your Deck to your hand.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORIES_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:HOPT()
	e1:SetCost(xgl.DiscardSelfCost)
	e1:SetSearchFunctions(aux.FilterBoolFunction(Card.IsSetCard,SET_QUELTZ))
	c:RegisterEffect(e1)
	--[[During the Main Phase (Quick Effect): You can Ritual Summon 1 "Queltz" monster from your hand or GY, by Tributing this card as the entire Tribute.]]
	local e2=Ritual.CreateProc({
		handler=c,
		filter=aux.FilterBoolFunction(Card.IsSetCard,SET_QUELTZ),
		location=LOCATION_HAND|LOCATION_GRAVE,
		lv=-1,
		matfilter=s.matfilter
	})
	e2:SetDescription(id,1)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(TIMINGS_CHECK_MONSTER|TIMING_MAIN_END)
	e2:SHOPT()
	e2:SetCondition(xgl.MainPhaseCond())
	local op=e2:GetOperation()
	e2:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		if not c:IsRelateToChain() then return end
		op(e,tp,eg,ep,ev,re,r,rp)
	end)
	c:RegisterEffect(e2)
end
s.listed_series={SET_QUELTZ}

--E2
function s.matfilter(c,e,tp)
	return c==e:GetHandler()
end