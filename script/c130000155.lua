--[[
Lady Luck Rest and Dicelaxation
Card Author: AuroraUline
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--If you control a "Lady Luck" card: You can Special Summon this card from your hand. 
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:HOPT()
	e1:SetCondition(xgl.LocationGroupCond(aux.FaceupFilter(Card.IsSetCard,SET_LADY_LUCK),LOCATION_ONFIELD,0,1))
	e1:SetSpecialSummonSelfFunctions()
	c:RegisterEffect(e1)
	--[[During your Main Phase (Quick Effect): You can roll a six-sided die, then apply the appropriate effect based on the result. You can only use each effect of "Lady Luck Rest and Dicelaxation" once per turn.
	● 1, 2 or 3: Set 1 "Lady Luck" Spell/Trap from your GY, but banish it when it leaves the field.
	● 4, 5 or 6: Send the top 3 cards of your Deck to the GY, and if you do, inflict 600 damage to your opponent for each "Lady Luck" monster sent to the GY this way]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_DICE|CATEGORY_DECKDES|CATEGORY_DAMAGE)
	e2:SetCustomCategory(CATEGORY_SET_SPELLTRAP)
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
	return c:IsInGY() and c:IsMonsterType() and c:IsSetCard(SET_LADY_LUCK)
end
function s.dicetg(e,tp,eg,ep,ev,re,r,rp,chk)
	local setg=Duel.Group(s.setfilter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then
		return #setg>0 or Duel.IsPlayerCanDiscardDeck(tp,3)
	end
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
	Duel.SetPossibleOperationInfo(0,CATEGORY_LEAVE_GRAVE,setg,1,tp,0)
	Duel.SetPossibleCustomOperationInfo(0,CATEGORY_SET_SPELLTRAP,setg,1,tp,LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,3)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,600)
end
function s.diceop(e,tp,eg,ep,ev,re,r,rp)
	local d=Duel.TossDice(tp,1)
	if d>=1 and d<=3 then
		Duel.Hint(HINT_OPSELECTED,tp,aux.Stringid(id,2))
		Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,2))
		local g=Duel.Select(HINTMSG_SET,false,tp,aux.Necro(s.setfilter),tp,LOCATION_GRAVE,0,1,1,nil)
		if Duel.Highlight(g) then
			Duel.BreakEffect()
			Duel.SSetAndRedirect(tp,g,e)
		end
		
	elseif d>3 and d<=6 then
		Duel.Hint(HINT_OPSELECTED,tp,aux.Stringid(id,3))
		Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,3))
		Duel.BreakEffect()
		if Duel.DiscardDeck(tp,3,REASON_EFFECT)>0 then
			local ct=Duel.GetGroupOperatedByThisEffect(e):FilterCount(s.gychkfilter,nil)
			if ct>0 then
				Duel.Damage(1-tp,ct*600,REASON_EFFECT)
			end
		end
	end
end