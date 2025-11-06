--[[
Lady Luck Post-It Result
Card Author: AuroraUline
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--[[You can discard this card; add 1 "Lady Luck" monster from your Deck to your hand.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORIES_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:HOPT()
	e1:SetCost(Cost.SelfDiscard)
	e1:SetSearchFunctions(xgl.MonsterFilter(Card.IsSetCard,SET_LADY_LUCK))
	c:RegisterEffect(e1)
	--[[During your opponent's Main Phase (Quick Effect): You can target 1 face-up monster on the field; roll a six-sided die, then apply the appropriate effect based on the result. You can only use each effect of "Lady Luck Post-It Result" once per turn.
	● 1, 2 or 3: Destroy that monster, then, if you control 3 or more "Lady Luck" monsters with different names, you can banish it.
	● 4, 5 or 6: Negate its effects (if any), and if you do, return this card to your hand.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_DICE|CATEGORY_DESTROY|CATEGORY_REMOVE|CATEGORY_DISABLE|CATEGORY_TOHAND)
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
			f		= Card.IsFaceup,
			loc1	= LOCATION_MZONE,
			loc2	= LOCATION_MZONE,
			extratg	= s.opinfo,
		},
		s.diceop
	)
	c:RegisterEffect(e2)
end
s.listed_series={SET_LADY_LUCK}
s.roll_dice=true

--E2
function s.opinfo(g,e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DISABLE,g,#g,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end

function s.diceop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local d=Duel.TossDice(tp,1)
	if d>=1 and d<=3 then
		Duel.Hint(HINT_OPSELECTED,tp,aux.Stringid(id,2))
		Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,2))
		if tc:IsRelateToChain() then
			Duel.BreakEffect()
			if Duel.Destroy(tc,REASON_EFFECT)>0 and not tc:IsLocation(LOCATION_DECK|LOCATION_REMOVED) and tc:IsPublic() and tc:IsAbleToRemove()
				and Duel.Group(aux.FaceupFilter(Card.IsSetCard,SET_LADY_LUCK),tp,LOCATION_MZONE,0,nil):GetClassCount(Card.GetCode)>=3 and Duel.SelectYesNo(tp,STRING_ASK_BANISH) then
				Duel.BreakEffect()
				Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
			end
		end
	elseif d>3 and d<=6 then
		Duel.Hint(HINT_OPSELECTED,tp,aux.Stringid(id,3))
		Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,3))
		Duel.BreakEffect()
		if tc:IsRelateToChain() and tc:IsFaceup() then
			if tc:IsType(TYPE_EFFECT) then
				if not tc:IsCanBeDisabledByEffect(e) then return end
				local _,_,res=Duel.Negate(tc,e,nil,false,false,TYPE_MONSTER) 
				if not res then return end
			end
			local c=e:GetHandler()
			if c:IsRelateToChain() then
				if xgl.GetSelfTargetExceptionForSpellTrap(e)==c then
					c:CancelToGrave()
				end
				Duel.SendtoHand(c,nil,REASON_EFFECT)
			end
		end
	end
end