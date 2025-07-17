--[[
Lady Luck Random Paladin
Card Author: AuroraUline
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--If this card is Normal or Special Summoned: You can add 1 "Lady Luck" Spell/Trap from your Deck to your hand.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORIES_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:HOPT()
	e1:SetSearchFunctions(xgl.SpellTrapFilter(Card.IsSetCard,SET_LADY_LUCK))
	c:RegisterEffect(e1)
	e1:SpecialSummonEventClone(c)
	--[[During your opponent's turn (Quick Effect): You can roll a six-sided die, then apply the appropriate effect based on the result. You can only use each effect of "Lady Luck Random Paladin" once per turn.
	● 1, 2 or 3: Destroy 1 Spell/Trap Card on the field.
	● 4, 5 or 6: "Lady Luck" monsters you control cannot be destroyed by battle this turn, also "Lady Luck" monsters you control gain 600 ATK until the end of the next turn (even if this card leaves the field).]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_DICE|CATEGORY_DESTROY|CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetRelevantTimings()
	e2:HOPT()
	e2:SetFunctions(
		xgl.TurnPlayerCond(1),
		nil,
		s.dicetg,
		s.diceop
	)
	c:RegisterEffect(e2)
end
s.listed_series={SET_LADY_LUCK}
s.roll_dice=true

--E2
function s.dicetg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local dg=Duel.Group(Card.IsSpellTrapOnField,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,xgl.GetSelfTargetExceptionForSpellTrap(e))
	local ag=Duel.Group(aux.FaceupFilter(Card.IsSetCard,SET_LADY_LUCK),tp,LOCATION_MZONE,0,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,dg,1,PLAYER_EITHER,LOCATION_ONFIELD)
	Duel.SetPossibleOperationInfo(0,CATEGORY_ATKCHANGE,ag,#ag,tp,600)
end
function s.diceop(e,tp,eg,ep,ev,re,r,rp)
	local d=Duel.TossDice(tp,1)
	if d>=1 and d<=3 then
		Duel.Hint(HINT_OPSELECTED,tp,aux.Stringid(id,2))
		Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,2))
		local g=Duel.Select(HINTMSG_DESTROY,false,tp,Card.IsSpellTrapOnField,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,xgl.GetSelfTargetExceptionForSpellTrap(e))
		if Duel.Highlight(g) then
			Duel.BreakEffect()
			Duel.Destroy(g,REASON_EFFECT)
		end
		
	elseif d>3 and d<=6 then
		Duel.Hint(HINT_OPSELECTED,tp,aux.Stringid(id,3))
		Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,3))
		Duel.BreakEffect()
		local c=e:GetHandler()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetReset(RESET_PHASE|PHASE_END)
		e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_LADY_LUCK))
		e1:SetValue(1)
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(600)
		e2:SetReset(RESET_PHASE|PHASE_END,2)
		Duel.RegisterEffect(e2,tp)
		aux.RegisterClientHint(c,nil,tp,1,0,aux.Stringid(id,4),nil,2)
	end
end