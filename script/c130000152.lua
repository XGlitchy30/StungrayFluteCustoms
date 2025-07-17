--[[
Lady Luck Miss Fortuna
Card Author: AuroraUline
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--[[If this card is Normal or Special Summoned: You can target 1 "Lady Luck" monster in your GY; Special Summon it.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:HOPT()
	e1:SetSpecialSummonFunctions(nil,TGCHECK_IT,xgl.ArchetypeFilter(SET_LADY_LUCK),LOCATION_GRAVE,0,1,1,nil)
	c:RegisterEffect(e1)
	e1:SpecialSummonEventClone(c)
	--[[During your opponent's turn (Quick Effect): You can target 1 face-up card on the field; roll a six-sided die, then apply the appropriate effect based on the result
	● 1, 2 or 3: Return that target to its owner's hand.
	● 4, 5 or 6: Draw 1 card, also, if that target is a monster, it cannot attack this turn.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_DICE|CATEGORY_TOHAND|CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetRelevantTimings()
	e2:HOPT()
	e2:SetFunctions(
		xgl.TurnPlayerCond(1),
		nil,
		xgl.Target{
			f		= s.filter,
			loc1	= LOCATION_ONFIELD,
			loc2	= LOCATION_ONFIELD,
			min		= 1,
			extratg	= s.opinfo,
			extraparams = s.filterparams
		},
		s.diceop
	)
	c:RegisterEffect(e2)
end
s.listed_series={SET_LADY_LUCK}
s.roll_dice=true

--E2
function s.filter(c,_,_,drawchk)
	return c:IsFaceup() and (drawchk or c:IsAbleToHand())
end
function s.opinfo(g,e,tp,eg,ep,ev,re,r,rp)
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.filterparams(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.IsPlayerCanDraw(tp,1)
end

function s.diceop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local d=Duel.TossDice(tp,1)
	if d>=1 and d<=3 then
		Duel.Hint(HINT_OPSELECTED,tp,aux.Stringid(id,2))
		Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,2))
		if tc:IsRelateToChain() and tc:IsFaceup() then
			Duel.BreakEffect()
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
	elseif d>3 and d<=6 then
		Duel.Hint(HINT_OPSELECTED,tp,aux.Stringid(id,3))
		Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,3))
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
		if tc:IsRelateToChain() and tc:IsFaceup() and tc:IsLocation(LOCATION_MZONE) then
			xgl.CannotAttack(tc,nil,RESET_PHASE|PHASE_END,e:GetHandler())
		end
	end
end