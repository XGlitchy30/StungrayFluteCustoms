--[[
Hallowed Queltz
Card Author: LimitlessSock
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	c:EnableReviveLimit()
	--[[(Quick Effect): You can target 3 of your opponent's face-down banished cards, then target 1 card in this card's column; shuffle those first targets into the Deck, and if you do, banish that
	target on the field face-down, then banish this card until your next Standby Phase]]
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
function s.tdfilter(c)
	return c:IsFacedown() and c:IsAbleToDeck()
end
function s.rmfilter(c,tp,g)
	return c:IsAbleToRemove(tp,POS_FACEDOWN) and g:IsContains(c)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local c=e:GetHandler()
	if chk==0 then
		return Duel.IsExists(true,s.tdfilter,tp,0,LOCATION_REMOVED,3,nil) and Duel.IsExists(true,s.rmfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c,tp,c:GetColumnGroup())
			and c:IsAbleToRemoveTemp(tp)
	end
	local tg=Duel.Select(HINTMSG_TODECK,true,tp,s.tdfilter,tp,0,LOCATION_REMOVED,3,3,nil)
	local rg=Duel.Select(HINTMSG_REMOVE,true,tp,s.rmfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c,tp,c:GetColumnGroup())
	rg:GetFirst():RegisterFlagEffect(id,RESET_CHAIN,0,1,Duel.GetCurrentChain())
	Duel.SetCardOperationInfo(tg,CATEGORY_TODECK)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,rg+c,#rg+1,0,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards()
	local rc=g:Filter(Card.HasFlagEffectLabel,nil,id,Duel.GetCurrentChain()):GetFirst()
	if rc then
		g:RemoveCard(rc)
	end
	g:Match(Card.IsFacedown,nil)
	if #g>0 and Duel.ShuffleIntoDeck(g)>0 and rc then
		local c=e:GetHandler()
		if c:IsRelateToChain() and c:GetColumnGroup():IsContains(rc) and Duel.Remove(rc,POS_FACEDOWN,REASON_EFFECT)>0 and c:IsRelateToChain() then
			Duel.BreakEffect()
			if Duel.Remove(c,c:GetPosition(),REASON_EFFECT|REASON_TEMPORARY)>0 and c:IsLocation(LOCATION_REMOVED) and xgl.BecauseOfThisEffect(e)(c) then
				xgl.DelayedOperation(c,PHASE_STANDBY,id+1,e,tp,s.delayedop,s.delayedcon,RESET_PHASE|PHASE_STANDBY|RESET_SELF_TURN,Duel.GetNextPhaseCount(PHASE_STANDBY,tp),aux.Stringid(id,2),aux.Stringid(id,3))
			end
		end
	end
end
function s.delayedcon(g,e,tp,eg,ep,ev,re,r,rp,turncount)
	return Duel.GetTurnPlayer()==tp and Duel.GetTurnCount()~=turncount
end
function s.delayedop(g,e,tp,eg,ep,ev,re,r,rp)
	local c=g:GetFirst()
	Duel.ReturnToField(c)
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