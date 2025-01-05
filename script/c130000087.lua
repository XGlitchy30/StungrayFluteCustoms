--[[
Visions of Clairvoyance
Card Author: Knightmare88
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--[[Excavate the top 2 cards of your Deck, then place them on top of the Deck in any order, and if you do, you can shuffle your Deck. Also, draw 1 card during the next Standby Phase. ]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(true)
	e1:SetFunctions(
		nil,
		nil,
		s.target,
		s.activate
	)
	c:RegisterEffect(e1)
end
--E1
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetDeckCount(tp)>=2 end
	Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetDeckCount(tp)>=2 then
		Duel.ConfirmDecktop(tp,2)
		Duel.BreakEffect()
		Duel.SortDecktop(tp,tp,2)
		if Duel.SelectYesNo(tp,STRING_ASK_SHUFFLE_DECK) then
			Duel.ShuffleDeck(tp)
		end
	end
	xgl.DelayedOperation(nil,PHASE_STANDBY,nil,e,tp,s.delayedop,nil,nil,Duel.GetNextPhaseCount(PHASE_STANDBY),nil,aux.Stringid(id,1))
end
function s.delayedop(ag,e,tp,eg,ep,ev,re,r,rp)
	Duel.Draw(tp,1,REASON_EFFECT)
end