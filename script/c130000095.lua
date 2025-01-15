--[[
Sacred Queltz
Card Author: LimitlessSock
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	c:EnableReviveLimit()
	--[[(Quick Effect): You can target 1 of your banished cards and 1 of your opponent's banished cards; shuffle them into the Deck, then change 1 face-up monster on the field into face-down Defense
	Position.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_TODECK|CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:HOPT()
	e1:SetRelevantTimings()
	e1:SetFunctions(nil,nil,s.rmtg,s.rmop)
	c:RegisterEffect(e1)
	--[[During the End Phase: Banish the top 5 cards of each player's Deck, face-down.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE|PHASE_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SHOPT()
	e2:SetFunctions(nil,nil,s.rmtg2,s.rmop2)
	c:RegisterEffect(e2)
end
s.listed_series={SET_QUELTZ}

--E1
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then
		return Duel.IsExists(true,Card.IsAbleToDeck,tp,LOCATION_REMOVED,0,1,nil) and Duel.IsExists(true,Card.IsAbleToDeck,tp,0,LOCATION_REMOVED,1,nil)
			and Duel.IsExists(false,Card.IsCanTurnSet,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	end
	local tg1=Duel.Select(HINTMSG_TODECK,true,tp,Card.IsAbleToDeck,tp,LOCATION_REMOVED,0,1,1,nil)
	local tg2=Duel.Select(HINTMSG_TODECK,true,tp,Card.IsAbleToDeck,tp,0,LOCATION_REMOVED,1,1,nil)
	Duel.SetCardOperationInfo(tg1+tg2,CATEGORY_TODECK)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,PLAYER_EITHER,LOCATION_MZONE)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards()
	if #g>0 and Duel.ShuffleIntoDeck(g)>0 then
		local tg=Duel.Select(HINTMSG_POSITION,false,tp,Card.IsCanTurnSet,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
		if #tg>0 then
			Duel.HintSelection(tg)
			Duel.BreakEffect()
			Duel.ChangePosition(tg,POS_FACEDOWN_DEFENSE)
		end
	end
end

--E2
function s.rmtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,5,PLAYER_ALL,LOCATION_DECK)
end

function s.rmop2(c,e,tp)
	Duel.DisableShuffleCheck()
	local g=Duel.GetDecktopGroup(0,5)+Duel.GetDecktopGroup(1,5)
	if #g>0 then
		Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
	end
end