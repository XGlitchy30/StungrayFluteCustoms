--[[
Queltz Dominance
Card Author: LimitlessSocks
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	c:Activation()
	--You can only control 1 "Queltz Dominance"
	c:SetUniqueOnField(1,0,id)
	--[[Once per turn, during the End Phase: You can make each player banish 1 card they control, face-down, if possible, except "Queltz Dominance".]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_SZONE)
	e1:SetHintTiming(TIMING_END_PHASE)
	e1:OPT()
	e1:SetFunctions(xgl.EndPhaseCond(),nil,s.rmtg,s.rmop)
	c:RegisterEffect(e1)
	--Once per turn, during the Standby Phase, you must banish the top 5 cards of your Deck, face-down (this is not optional), or this card is destroyed.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EVENT_PHASE|PHASE_STANDBY)
	e2:SetRange(LOCATION_SZONE)
	e2:OPT()
	e2:SetOperation(s.mtop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_QUELTZ}

--E1
function s.rmfilter(c,p)
	return c:IsAbleToRemove(p,POS_FACEDOWN,REASON_RULE) and not c:IsCode(id)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExists(false,s.rmfilter,tp,LOCATION_ONFIELD,0,1,nil,tp) or Duel.IsExists(false,s.rmfilter,tp,0,LOCATION_ONFIELD,1,nil,1-tp)
	end
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local groups={Group.CreateGroup(),Group.CreateGroup()}
	for step=1,2 do
		for p in aux.TurnPlayers() do
			if step==1 then
				groups[p+1]=Duel.Select(HINTMSG_REMOVE,false,p,s.rmfilter,p,LOCATION_ONFIELD,0,1,1,nil,p)
			else
				if #groups[p+1]>0 then
					Duel.Remove(groups[p+1],POS_FACEDOWN,REASON_RULE,PLAYER_NONE,p)
				end
			end
		end
	end
end

--E2
function s.mtop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)
	local g=Duel.GetDecktopGroup(tp,5)
	if g:FilterCount(Card.IsAbleToRemoveAsCost,nil,POS_FACEDOWN)==5 then
		Duel.DisableShuffleCheck()
		Duel.Remove(g,POS_FACEDOWN,REASON_COST)
	else
		Duel.Destroy(e:GetHandler(),REASON_COST)
	end
end