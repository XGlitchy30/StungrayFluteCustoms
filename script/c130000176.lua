--[[
Ceria, Dancing Through Death
Card Author: Knightmare88
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--[[If this card is Summoned: Apply up to N of these effects in sequence, and in any order (N = the number of "Ceria, Dancing Through Death" in your GY).
	● Gain N x 400 LP.
	● This card gains N x 400 ATK/DEF.
	● Draw N/3 cards (rounded down).]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_RECOVER|CATEGORIES_ATKDEF|CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetFunctions(nil,nil,s.target,s.operation)
	c:RegisterEffect(e1)
	e1:SpecialSummonEventClone(c)
	e1:FlipSummonEventClone(c)
end
s.listed_names={id}

--E1
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return true
	end
	local ct=Duel.GetMatchingGroupCount(Card.IsCode,tp,LOCATION_GRAVE,0,nil,id)
	local c=e:GetHandler()
	local v=ct*400
	Duel.SetPossibleOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,v)
	Duel.SetPossibleOperationInfo(0,CATEGORY_ATKCHANGE,c,1,0,v)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DEFCHANGE,c,1,0,v)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,0,tp,math.max(math.floor(ct/3),1))
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetMatchingGroupCount(Card.IsCode,tp,LOCATION_GRAVE,0,nil,id)
	if ct<=0 then return end
	local c=e:GetHandler()
	if ct<=20 then
		c:SetTurnCounter(ct)
	else
		Duel.HintMessage(tp,aux.Stringid(id,4))
		Duel.AnnounceNumber(tp,ct)
	end
	local i=math.min(ct,3)
	local already_chosen=0
	local brk=false
	while i>0 and ct>0 do
		local v,drawct=ct*400,math.floor(ct/3)
		local b1=already_chosen&1==0
		local b2=already_chosen&2==0 and c:IsRelateToChain() and c:IsFaceup()
		local b3=already_chosen&4==0 and drawct>0 and Duel.IsPlayerCanDraw(tp,drawct)
		if brk and (not (b1 or b2 or b3) or Duel.SelectYesNo(tp,STRING_ASK_APPLY_ADDITIONAL)) then
			break
		end
		local op=xgl.Option(id,tp,1,b1,b2,b3)
		already_chosen=already_chosen|(1<<op)
		if brk then Duel.BreakEffect() end
		if op==0 then
			Duel.Recover(tp,v,REASON_EFFECT)
		elseif op==1 then
			c:UpdateATKDEF(v,v,true,c)
		elseif op==2 then
			if Duel.Draw(tp,drawct,REASON_EFFECT)>0 then
				Duel.ShuffleHand(tp)
			end
		end
		i=i-1
		brk=true
		local ct0=ct
		ct=Duel.GetMatchingGroupCount(Card.IsCode,tp,LOCATION_GRAVE,0,nil,id)
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