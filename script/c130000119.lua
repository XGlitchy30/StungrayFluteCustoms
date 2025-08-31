--[[
Percussion Performer Drum-Step
Card Author: AuroraUline
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	c:EnableReviveLimit()
	--2 Level 4 "Percussion Beetle" monsters
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_PERCUSSION_BEETLE),4,2)
	--[[Once per turn: You can detach 1 material from this card; draw 1 card and reveal it, then this card gains 500 ATK until the end of this turn if it was a LIGHT monster.]]
	local e1=Effect.CreateEffect(c)
    e1:SetDescription(id,0)
    e1:SetCategory(CATEGORY_DRAW|CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:OPT()
    e1:SetFunctions(
		nil,
		Cost.Detach(1,1,nil),
		s.drawtg,
		s.drawop
	)
    c:RegisterEffect(e1,false,REGISTER_FLAG_DETACH_XMAT)
	--[[You can banish this card from your GY; add 1 "Percussion Beetle" Spell/Trap from your Deck to your hand, then discard 1 card.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORIES_SEARCH|CATEGORY_HANDES)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:HOPT()
	e2:SetFunctions(nil,aux.bfgcost,s.thtg,s.thop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_PERCUSSION_BEETLE}

--E1
function s.drawtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drawop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.Draw(tp,1,REASON_EFFECT)
	if ct==0 then return end
	local dc=Duel.GetOperatedGroup():GetFirst()
	Duel.ConfirmCards(1-tp,dc)
	local c=e:GetHandler()
	if c:IsRelateToChain() and c:IsFaceup() and dc:IsMonsterType() and dc:IsAttribute(ATTRIBUTE_LIGHT) then
		Duel.BreakEffect()
		c:UpdateATK(500,RESET_PHASE|PHASE_END,c)
	end
	Duel.ShuffleHand(tp)
end

--E2
function s.thfilter(c)
	return c:IsSetCard(SET_PERCUSSION_BEETLE) and c:IsSpellTrap() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) and Duel.IsPlayerCanDiscardHand(tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SearchAndCheck(g) then
		Duel.ShuffleHand(tp)
		Duel.BreakEffect()
		Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT|REASON_DISCARD,nil)
	end
end