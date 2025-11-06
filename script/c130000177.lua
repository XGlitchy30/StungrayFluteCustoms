--[[
Pisces, Purveyor of Death
Card Author: Knightmare88
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--[[Apply up to N+1 of the following effects in sequence, and in any order. (N = the number of "Ceria, Dancing Through Death" in your GY.)
	● Shuffle N cards from your GY into the Deck, then draw N cards, and if you do, discard N cards. If you have a card whose original name is "Ceria, Dancing Through Death" in your GY, discard N-1 cards instead.
	● Monsters you control gain N x 100 ATK/DEF until the end of the turn.
	● Gain N x 300 LP.
	]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_RECOVER|CATEGORIES_ATKDEF|CATEGORY_TODECK|CATEGORY_DRAW|CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRelevantTimings()
	e1:SetFunctions(
		nil,
		nil,
		s.target,
		s.activate
	)
	c:RegisterEffect(e1)
	--This card's name becomes "Ceria, Dancing Through Death" while in your GY.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_CHANGE_CODE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetValue(CARD_CERIA_DANCING_THROUGH_DEATH)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_CERIA_DANCING_THROUGH_DEATH}

--E1
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_GRAVE,0,nil,CARD_CERIA_DANCING_THROUGH_DEATH)
	local ct=#g
	if chk==0 then
		return ct>0
	end
	local atkg=Duel.GetMonsters(tp):Filter(Card.IsFaceup,nil)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,nil,math.max(ct,1),tp,LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,0,tp,math.max(ct,1))
	Duel.SetPossibleOperationInfo(0,CATEGORY_HANDES,nil,0,tp,math.max(Duel.IsExists(false,Card.IsOriginalCodeRule,tp,LOCATION_GRAVE,0,1,nil,CARD_CERIA_DANCING_THROUGH_DEATH) and ct-1 or ct,1))
	Duel.SetPossibleOperationInfo(0,CATEGORY_ATKCHANGE,atkg,math.max(#atkg,1),0,ct*100)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DEFCHANGE,atkg,math.max(#atkg,1),0,ct*100)
	Duel.SetPossibleOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,ct*300)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetMatchingGroupCount(Card.IsCode,tp,LOCATION_GRAVE,0,nil,CARD_CERIA_DANCING_THROUGH_DEATH)
	if ct<=0 then return end
	local c=e:GetHandler()
	if ct<=20 then
		c:SetTurnCounter(ct)
	else
		Duel.HintMessage(tp,aux.Stringid(id,4))
		Duel.AnnounceNumber(tp,ct)
	end
	local i=math.min(ct+1,3)
	local already_chosen=0
	local brk=false
	while i>0 and ct>0 do
		local gy=Duel.Group(Card.IsAbleToDeck,tp,LOCATION_GRAVE,0,nil)
		local atkg=Duel.GetMonsters(tp):Filter(Card.IsFaceup,nil)
		local b1=already_chosen&1==0 and #gy>=ct and Duel.IsPlayerCanDraw(tp,ct)
		local b2=already_chosen&2==0 and #atkg>0
		local b3=already_chosen&4==0
		if brk and (not (b1 or b2 or b3) or not Duel.SelectYesNo(tp,STRING_ASK_APPLY_ADDITIONAL)) then
			break
		end
		local op=xgl.Option(id,tp,1,b1,b2,b3)
		already_chosen=already_chosen|(1<<op)
		if brk then Duel.BreakEffect() end
		if op==0 then
			Duel.HintMessage(tp,HINTMSG_TODECK)
			local tdg=gy:Select(tp,ct,ct,nil)
			Duel.HintSelection(tdg)
			if Duel.ShuffleIntoDeck(tdg)==ct then
				Duel.BreakEffect()
				if Duel.Draw(tp,ct,REASON_EFFECT)==ct then
					Duel.ShuffleHand(tp)
					local d=Duel.IsExists(false,Card.IsOriginalCodeRule,tp,LOCATION_GRAVE,0,1,nil,CARD_CERIA_DANCING_THROUGH_DEATH) and ct-1 or ct
					Duel.DiscardHand(tp,nil,d,d,REASON_EFFECT|REASON_DISCARD)
				end
			end
		elseif op==1 then
			local v=ct*100
			for tc in atkg:Iter() do
				tc:UpdateATKDEF(v,v,RESET_PHASE|PHASE_END,{c,true})
			end
		elseif op==2 then
			Duel.Recover(tp,ct*300,REASON_EFFECT)
		end
		i=i-1
		brk=true
		local ct0=ct
		ct=Duel.GetMatchingGroupCount(Card.IsCode,tp,LOCATION_GRAVE,0,nil,CARD_CERIA_DANCING_THROUGH_DEATH)
		if ct>0 and ct~=ct0 then
			if ct<=20 then
				c:SetTurnCounter(ct)
			else
				Duel.HintMessage(tp,aux.Stringid(id,4))
				Duel.AnnounceNumber(tp,ct)
			end
		end
	end
end