--[[
Inversion of Nature
Card Author: Knightmare88
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--When this card is activated: Add 1 "of Nature" card from your Deck to your hand, except "Inversion of Nature".
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORIES_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Once per turn: You can target 1 monster you control and declare 1 card type (Monster, Spell, or Trap); excavate the top card of your opponent's Deck, and if it is the declared card type, that targeted monster gains 1000 ATK until the end of the turn, also place the excavated card on the top of the Deck.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_FZONE)
	e2:OPT()
	e2:SetFunctions(nil,nil,s.atktg,s.atkop)
	c:RegisterEffect(e2)
	--Replace official cards
	aux.GlobalCheck(s,xgl.ReplaceOfficialCards(s.modcodes))
end
s.listed_names={id}
s.listed_series={SET_OF_NATURE}
s.modcodes = {[62966332]=62966333}

--E1
function s.filter(c)
	return c:IsSetCard(SET_OF_NATURE) and not c:IsCode(id) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.Search(g)
	end
end

--E2
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	if chk==0 then return Duel.GetDeckCount(1-tp)>0 and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	local g=Duel.Select(HINTMSG_FACEUP,true,tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CARDTYPE)
	local op=Duel.SelectEffect(tp,
		{true,DECLTYPE_MONSTER},
		{true,DECLTYPE_SPELL},
		{true,DECLTYPE_TRAP})
	local typ=1<<(op-1)
	Duel.SetTargetParam(typ)
	
	local convulsion=Duel.IsPlayerAffectedByEffect(1-tp,EFFECT_REVERSE_DECK)
	if convulsion then
		local top_card=Duel.GetDecktopGroup(1-tp,1):GetFirst()
		Duel.SetConditionalOperationInfo(top_card:IsType(typ),0,CATEGORY_ATKCHANGE,g,#g,0,1000)
	else
		Duel.SetPossibleOperationInfo(0,CATEGORY_ATKCHANGE,g,#g,0,1000)
	end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetDeckCount(1-tp)<=0 then return end
	Duel.ConfirmDecktop(1-tp,1)
	local top_card=Duel.GetDecktopGroup(1-tp,1):GetFirst()
	local typ=Duel.GetTargetParam()
	if top_card:IsType(typ) then
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToChain() and tc:IsFaceup() then 
			tc:UpdateATK(1000,RESET_PHASE|PHASE_END,{e:GetHandler(),true})
		end
	end
end