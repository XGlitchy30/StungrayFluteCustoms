--[[
Peace, at Last
Card Author: Sock
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--Banish the top 10 cards of your Deck, face-down, then target 1 Effect Monster you control; it gains the following effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(true)
	e1:SetRelevantTimings()
	e1:SetFunctions(nil,s.cost,s.target,s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={id}

--E1
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetDecktopGroup(tp,10)
	if chk==0 then return g:FilterCount(Card.IsAbleToRemoveAsCost,nil,POS_FACEDOWN)==10 end
	Duel.DisableShuffleCheck()
	Duel.Remove(g,POS_FACEDOWN,REASON_COST)
end
function s.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then
		return Duel.IsExists(true,s.filter,tp,LOCATION_MZONE,0,1,nil)
	end
	Duel.Select(HINTMSG_TARGET,true,tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and not tc:IsImmuneToEffect(e) then
		local c=e:GetHandler()
		--If this card would be destroyed by battle or card effect, you can banish 1 "Peace, at Last" from your field or GY, face-down, instead.
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_CONTINUOUS)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetCode(EFFECT_DESTROY_REPLACE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetTarget(s.reptg)
		e1:SetOperation(s.repop)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		if tc:RegisterEffect(e1) then
			aux.GainEffectType(tc,c)
			tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,0,0,aux.Stringid(id,2))
		end
	end
end
function s.repfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsCode(id) and c:IsAbleToRemove(tp,POS_FACEDOWN,REASON_EFFECT|REASON_REPLACE) and aux.SpElimFilter(c,true,true)
		and not c:IsImmuneToEffect(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return not c:IsReason(REASON_REPLACE) and c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and Duel.IsExists(false,s.repfilter,tp,LOCATION_ONFIELD|LOCATION_GRAVE,0,1,c,e,tp)
	end
	if Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)
		local g=Duel.Select(HINTMSG_DESREPLACE,false,tp,s.repfilter,tp,LOCATION_ONFIELD|LOCATION_GRAVE,0,1,1,c,e,tp)
		Duel.SetTargetCard(g:GetFirst())
		return true
	else
		return false
	end
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc then
		Duel.Remove(tc,POS_FACEDOWN,REASON_EFFECT|REASON_REPLACE)
	end
end