--[[
Belligerent Pyroclast
Card Author: LimitlessSocks
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	c:EnableReviveLimit()
	--2 Effect Monsters
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_EFFECT),2,2)
	--If this card is destroyed by battle or card effect: You can send the top 2 cards of each player's Deck to the GY.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e) return e:GetHandler():IsReason(REASON_BATTLE|REASON_EFFECT) end)
	e1:SetTarget(s.smltg)
	e1:SetOperation(s.smlop)
	c:RegisterEffect(e1)
end

--E1
function s.smltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,2) and Duel.IsPlayerCanDiscardDeck(1-tp,2) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,PLAYER_ALL,2)
end
function s.smlop(e,tp,eg,ep,ev,re,r,rp)
	for p in aux.TurnPlayers() do
		Duel.DiscardDeck(p,2,REASON_EFFECT)
	end
end