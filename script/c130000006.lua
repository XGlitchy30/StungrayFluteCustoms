--[[
Art of Perfection
Card Author: Fishy
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--Target 1 card your opponent controls; destroy it, and if you do, each player draws 1 card. You must control a non-Effect Ritual Monster to activate and resolve this effect.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_DESTROY|CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRelevantTimings()
	e1:SetFunctions(s.condition,nil,s.target,s.activate)
	c:RegisterEffect(e1)
end

--E1
function s.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_RITUAL) and not c:IsType(TYPE_EFFECT)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExists(false,s.filter,tp,LOCATION_MZONE,0,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) end
	if chk==0 then
		return Duel.IsExists(true,nil,tp,0,LOCATION_ONFIELD,1,nil) and Duel.IsPlayerCanDraw(tp,1) and Duel.IsPlayerCanDraw(1-tp,1)
	end
	local g=Duel.Select(HINTMSG_DESTROY,true,tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetCardOperationInfo(g,CATEGORY_DESTROY)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,1)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not s.condition(e,tp,eg,ep,ev,re,r,rp) then return end
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and Duel.Destroy(tc,REASON_EFFECT)>0 then
		local turnp=Duel.GetTurnPlayer()
		for p=turnp,1-turnp,1-2*turnp do
			Duel.Draw(p,1,REASON_EFFECT)
		end
	end
end