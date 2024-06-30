--[[
Asceticism
Card Author: Sock
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--[[Target 1 Spell/Trap your opponent controls; reveal it, then return it to the hand, and if you do, your opponent draws 1 card.
	If you control a Normal Monster, your opponent cannot activate the targeted card in response to this card's activation.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_TOHAND|CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetFunctions(nil,nil,s.target,s.activate)
	c:RegisterEffect(e1)
end

--E1
function s.filter(c)
	return c:IsFacedown() and c:IsAbleToHand()
end
function s.chfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then
		return Duel.IsExists(true,s.filter,tp,0,LOCATION_SZONE,1,nil) and Duel.IsPlayerCanDraw(1-tp,1)
	end
	local g=Duel.Select(HINTMSG_RTOHAND,true,tp,s.filter,tp,0,LOCATION_SZONE,1,1,nil)
	Duel.SetCardOperationInfo(g,CATEGORY_TOHAND)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,1)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsExists(false,s.chfilter,tp,LOCATION_MZONE,0,1,nil) then
		Duel.SetChainLimit(s.limit(g:GetFirst()))
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() and tc:IsRelateToChain() then
		Duel.ConfirmCards(tp,Group.FromCards(tc))
		if tc:IsAbleToHand() then
			Duel.BreakEffect()
		end
		if Duel.SearchAndCheck(tc,nil,nil,true) then
			Duel.Draw(1-tp,1,REASON_EFFECT)
		end
	end
end
function s.limit(c)
	return	function (e,lp,tp)
				return lp==tp or e:GetHandler()~=c
			end
end