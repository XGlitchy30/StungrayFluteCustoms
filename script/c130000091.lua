--[[
Divine Queltz
Card Author: LimitlessSock
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	c:EnableReviveLimit()
	--[[(Quick Effect): You can target 1 of your banished cards and 2 of your opponent's banished cards; shuffle them into the Deck, then your opponent banishes 3 cards from their GY, face-down]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_TODECK|CATEGORY_REMOVE)
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
function s.gcheck(g,e,tp,mg,c)
    local gp1=g:Filter(Card.IsControler,nil,tp)
    local gp2=g:Filter(Card.IsControler,nil,1-tp)

    local valid = #gp1 == 1 and #gp2 == 2

    local razor = nil
    if c:IsControler(tp) then
        razor = {aux.NOT(Card.IsControler),tp}
    elseif c:IsControler(1-tp) and #gp2==2 then
        razor = {aux.NOT(Card.IsControler),1-tp} 
    end

    return valid,false,razor
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.Group(Card.IsAbleToDeck,tp,LOCATION_REMOVED,LOCATION_REMOVED,0,nil):Filter(Card.IsCanBeEffectTarget,nil,e)
	if chk==0 then
		return Duel.IsExists(false,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,3,nil,1-tp,POS_FACEDOWN) and xgl.SelectUnselectGroup(g,e,tp,3,3,s.gcheck,0)
	end
	local tg=xgl.SelectUnselectGroup(g,e,tp,3,3,s.gcheck,1,tp,HINTMSG_REMOVE)
	Duel.SetTargetCard(tg)
	Duel.SetCardOperationInfo(tg,CATEGORY_TODECK)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,3,1-tp,LOCATION_GRAVE)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards()
	if #g>0 and Duel.ShuffleIntoDeck(g)>0 then
		local rg=Duel.Select(HINTMSG_REMOVE,false,1-tp,aux.Necro(Card.IsAbleToRemove),tp,0,LOCATION_GRAVE,3,3,nil,1-tp,POS_FACEDOWN)
		if #rg==3 then
			Duel.HintSelection(rg)
			Duel.BreakEffect()
			Duel.Remove(rg,POS_FACEDOWN,REASON_EFFECT,1-tp)
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