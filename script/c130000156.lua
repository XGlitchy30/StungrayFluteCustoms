--[[
Lady Luck Ribbonroll
Card Author: AuroraUline
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
Duel.LoadScript("glitchymods_synchro.lua")
function s.initial_effect(c)
	--If this card is Normal or Special Summoned: You can send 1 "Lady Luck" card from your Deck to the GY.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:HOPT()
	e1:SetSendtoFunctions(LOCATION_GRAVE,false,xgl.ArchetypeFilter(SET_LADY_LUCK),LOCATION_DECK,0,1,1,nil)
	c:RegisterEffect(e1)
	e1:SpecialSummonEventClone(c)
	--[[During your Main Phase (Quick Effect): You can roll a six-sided die, then apply the appropriate effect based on the result. You can only use each effect of "Lady Luck Ribbonroll" once per turn.
	● 1, 2 or 3: Discard 1 card, and if you do, draw 2 cards.
	● 4, 5 or 6: "Lady Luck" monsters can attack your opponent directly this turn, also this card can be treated as a Tuner for the Synchro Summon of a "Lady Luck" Synchro Monster until the end of the turn*.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_DICE|CATEGORY_HANDES|CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetFunctions(
		xgl.MainPhaseCond(0),
		nil,
		s.dicetg,
		s.diceop
	)
	c:RegisterEffect(e2)
end
s.listed_series={SET_LADY_LUCK}
s.roll_dice=true

--E2
function s.setfilter(c)
	return c:IsSetCard(SET_LADY_LUCK) and c:IsSpellTrap() and c:IsSSetable()
end
function s.gychkfilter(c)
	return c:IsInGY() and c:IsMonster() and c:IsSetCard(SET_LADY_LUCK)
end
function s.dicetg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function s.diceop(e,tp,eg,ep,ev,re,r,rp)
	local d=Duel.TossDice(tp,1)
	if d>=1 and d<=3 then
		Duel.Hint(HINT_OPSELECTED,tp,aux.Stringid(id,2))
		Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,2))
		if Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil,REASON_EFFECT) then
			Duel.BreakEffect()
			if Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_EFFECT|REASON_DISCARD,nil,REASON_EFFECT)>0 then
				Duel.Draw(tp,2,REASON_EFFECT)
			end
		end
		
	elseif d>3 and d<=6 then
		Duel.Hint(HINT_OPSELECTED,tp,aux.Stringid(id,3))
		Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,3))
		Duel.BreakEffect()
		local c=e:GetHandler()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_DIRECT_ATTACK)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_LADY_LUCK))
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
		aux.RegisterClientHint(c,nil,tp,1,0,aux.Stringid(id,5))
		if c:IsRelateToChain() then
			local e2=Effect.CreateEffect(c)
			e2:SetDescription(id,4)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_CLIENT_HINT)
			e2:SetCode(EFFECT_CAN_BE_TUNER_GLITCHY)
			e2:SetValue(s.tunerval)
			e2:SetReset(RESETS_STANDARD_PHASE_END)
			c:RegisterEffect(e2)
		end
	end
end
function s.tunerval(e,c,sync,tp)
	return sync:IsSetCard(SET_LADY_LUCK)
end