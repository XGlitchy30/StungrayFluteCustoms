--[[
Ignore the Pain
Card Author: Sock
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--When you take battle damage from a direct attack: Target 1 Spell in either GY; add 1 Spell from your Deck to your hand with the same name, then gain 500 LP.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORIES_SEARCH|CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetFunctions(s.condition,nil,s.target,s.activate)
	c:RegisterEffect(e1)
end

--E1
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and Duel.GetAttackTarget()==nil
end
function s.filter(c,tp)
	return c:IsSpellType() and Duel.IsExists(false,s.thfilter,tp,LOCATION_DECK,0,1,c,{c:GetCode()})
end
function s.thfilter(c,codes)
	return c:IsSpellType() and c:IsRealCode(table.unpack(codes)) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.filter(chkc,tp) end
	if chk==0 then
		return Duel.IsExists(true,s.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,tp)
	end
	local g=Duel.Select(HINTMSG_TARGET,true,tp,s.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,500)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		local codes={tc:GetCode()}
		local g=Duel.Select(HINTMSG_ATOHAND,false,tp,s.thfilter,tp,LOCATION_DECK,0,1,1,tc,codes)
		if #g>0 and Duel.SearchAndCheck(g) then
			Duel.BreakEffect()
			Duel.Recover(tp,500,REASON_EFFECT)
		end
	end
end