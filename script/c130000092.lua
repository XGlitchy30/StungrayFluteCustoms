--[[
Fury Queltz
Card Author: LimitlessSock
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	c:EnableReviveLimit()
	--[[(Quick Effect): You can make your opponent shuffle 2 of their banished cards into the Deck, then look at your opponent's hand, choose 2 cards, and make your opponent banish 1 of the chosen cards face-down and draw 1 card]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_TODECK|CATEGORY_REMOVE|CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_QUICK_O)
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
function s.tdfilter(c,p)
	return not c:IsStatus(STATUS_LEAVE_CONFIRMED) and not c:IsHasEffect(EFFECT_CANNOT_TO_DECK) and Duel.IsPlayerCanSendtoDeck(p,c)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExists(false,s.tdfilter,tp,0,LOCATION_REMOVED,2,nil,1-tp) and Duel.GetHandCount(1-tp)>=2 and Duel.IsExists(false,Card.IsAbleToRemove,tp,0,LOCATION_HAND,1,nil,1-tp,POS_FACEDOWN)
			and Duel.IsPlayerCanDraw(1-tp,1)
	end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,2,1-tp,LOCATION_REMOVED)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,1)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.Select(HINTMSG_TODECK,false,1-tp,s.tdfilter,tp,0,LOCATION_REMOVED,2,2,nil,1-tp)
	if #tg==2 and Duel.ShuffleIntoDeck(tg,nil,nil,nil,nil,nil,1-tp)==2 and Duel.IsPlayerCanDraw(1-tp,1) then
		local hand=Duel.GetHand(1-tp)
		if #hand>=2 and hand:IsExists(Card.IsAbleToRemove,1,nil,1-tp,POS_FACEDOWN) then
			Duel.BreakEffect()
			Duel.ConfirmCards(tp,hand)
			local sg=xgl.SelectUnselectGroup(hand,e,tp,2,2,s.gcheck,1,tp,HINTMSG_REMOVE)
			local rg=sg:FilterSelect(1-tp,Card.IsAbleToRemove,1,1,nil,1-tp,POS_FACEDOWN)
			if #rg>0 and Duel.Remove(rg,POS_FACEDOWN,REASON_EFFECT,1-tp)>0 then
				Duel.Draw(1-tp,1,REASON_EFFECT)
			end
			Duel.ShuffleHand(1-tp)
		end
	end
end
function s.gcheck(g,e,tp,mg,c)
	local valid=g:IsExists(Card.IsAbleToRemove,1,nil,1-tp,POS_FACEDOWN)
	
	local razor = nil
    if not c:IsAbleToRemove(1-tp,POS_FACEDOWN) then
        razor = {aux.NOT(Card.IsAbleToRemove),1-tp,POS_FACEDOWN}
    end

    return valid,false,razor
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