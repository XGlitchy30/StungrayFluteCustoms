--[[
Queltz Crowning
Card Author: LimitlessSock
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--[[Your opponent banishes 1 random card from your hand, face-down, then, you add 2 "Queltz" Ritual Monsters from your Deck to your hand with different Levels.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_REMOVE|CATEGORIES_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT()
	e1:SetFunctions(
		nil,
		nil,
		s.target,
		s.activate
	)
	c:RegisterEffect(e1)
	--[[If this card is in the GY: You can target 1 "Queltz" monster you control; banish this card from your GY, face-down, then that target gains 200 ATK for each face-down banished card.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_REMOVE|CATEGORY_ATKCHANGE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SHOPT()
	e2:SetFunctions(nil,nil,s.atktg,s.atkop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_QUELTZ}

--E1
function s.thfilter(c)
	return c:IsRitualMonster() and c:IsSetCard(SET_QUELTZ) and c:HasLevel() and c:IsAbleToHand()
end
function s.gcheck(g,e,tp,mg,c)
	return g:GetClassCount(Card.GetLevel)==#g
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		local exc=(c:IsLocation(LOCATION_HAND) and e:IsHasType(EFFECT_TYPE_ACTIVATE)) and c or nil
		local g=Duel.Group(s.thfilter,tp,LOCATION_DECK,0,nil)
		return Duel.IsExists(false,Card.IsAbleToRemove,tp,LOCATION_HAND,0,1,exc,1-tp,POS_FACEDOWN) and aux.SelectUnselectGroup(g,e,tp,2,2,s.gcheck,0)
	end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local hand=Duel.GetHand(tp)
	if not hand:IsExists(Card.IsAbleToRemove,1,nil,1-tp,POS_FACEDOWN) then return end
	local rg=hand:RandomSelect(1-tp,1)
	if Duel.Remove(rg,POS_FACEDOWN,REASON_EFFECT)>0 then
		local g=Duel.Group(s.thfilter,tp,LOCATION_DECK,0,nil)
		if aux.SelectUnselectGroup(g,e,tp,2,2,s.gcheck,0) then
			local sg=aux.SelectUnselectGroup(g,e,tp,2,2,s.gcheck,1,tp,HINTMSG_ATOHAND)
			if #sg==2 then
				Duel.BreakEffect()
				Duel.Search(sg)
			end
		end
	end
end

--E2
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(SET_QUELTZ)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	local c=e:GetHandler()
	if chk==0 then
		return c:IsAbleToRemove(tp,POS_FACEDOWN) and Duel.IsExists(true,s.filter,tp,LOCATION_MZONE,0,1,nil)
	end
	local g=Duel.Select(HINTMSG_TARGET,true,tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetCardOperationInfo(c,CATEGORY_REMOVE)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,1,0,(Duel.GetBanishment():FilterCount(Card.IsFacedown,nil)+1)*200)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.Remove(c,POS_FACEDOWN,REASON_EFFECT)>0 then
		local ct=Duel.GetBanishment():FilterCount(Card.IsFacedown,nil)*200
		if ct==0 then return end
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToChain() and s.filter(tc) then
			Duel.BreakEffect()
			tc:UpdateATK(ct,true,{c,true})
		end
	end
end