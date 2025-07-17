--[[
Lady Luck 6-Face Mistress
Card Author: AuroraUline
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--1 Fairy Tuner + 1+ non-Tuner "Lady Luck" monsters
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_FAIRY),1,1,Synchro.NonTunerEx(Card.IsSetCard,SET_LADY_LUCK),1,99)
	--Other face-up cards you control that require a die roll cannot be destroyed by your opponent's card effects.
	c:CannotBeDestroyedByEffectsField(aux.indoval,LOCATION_MZONE,LOCATION_ONFIELD,0,s.efilter)
	--When you activate a "Lady Luck" monster's effect that requires a die roll (Quick Effect): You can declare a number between 1 and 6; shuffle that many "Lady Luck" cards from your GY into your Deck, and if you do, until the end of this turn, you can treat 1 die result from a "Lady Luck" monster effect as that number. 
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,0)
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetFunctions(s.tdcon,nil,s.tdtg,s.tdop)
	c:RegisterEffect(e2)
	--[[When your opponent activates a card or effect (Quick Effect): You can roll a six-sided die, then apply the appropriate effect based on the result.
	● 1, 2 or 3: Negate the activation.
	● 4, 5 or 6: Banish it.]]
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,3)
	e3:SetCategory(CATEGORY_DICE|CATEGORY_NEGATE|CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP|EFFECT_FLAG_DAMAGE_CAL)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:HOPT()
	e3:SetFunctions(s.discon,nil,s.distg,s.disop)
	c:RegisterEffect(e3)
	aux.DoubleSnareValidity(c,LOCATION_MZONE)
end
s.listed_series={SET_LADY_LUCK}
s.roll_dice=true

--E1
function s.efilter(e,c)
	return c.roll_dice and c~=e:GetHandler()
end

--E2
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	if not (re:IsMonsterEffect() and rp==tp and re:IsHasCategory(CATEGORY_DICE)) then return false end
	local setcodes=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_SETCODES)
	for _,set in ipairs(setcodes) do
		if (SET_LADY_LUCK&0xfff)==(set&0xfff) and (SET_LADY_LUCK&set)==SET_LADY_LUCK then return true end
	end
	return false
end
function s.tdfilter(c)
	return c:IsSetCard(SET_LADY_LUCK) and c:IsAbleToDeck()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.Group(s.tdfilter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return #g>0 end
	Duel.Hint(HINT_SELECTMSG,tp,STRING_SELECT_DIE_RESULT)
	local ct=Duel.AnnounceNumberRange(tp,1,math.min(6,#g))
	Duel.SetTargetParam(ct)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,ct,0,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetTargetParam()
	if not ct then return end
	local g=Duel.Select(HINTMSG_TODECK,false,tp,aux.Necro(s.tdfilter),tp,LOCATION_GRAVE,0,ct,ct,nil)
	if Duel.Highlight(g) and Duel.ShuffleIntoDeck(g)==ct then
		local c=e:GetHandler()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_TOSS_DICE_NEGATE)
		e1:SetLabel(ct)
		e1:SetCondition(s.dicecon)
		e1:SetOperation(s.diceop)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
		aux.RegisterClientHint(c,nil,tp,1,0,aux.Stringid(id,1))
	end
end
function s.dicecon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsMonsterEffect() and not Duel.PlayerHasFlagEffect(tp,id) and re:HasReasonArchetype(SET_LADY_LUCK)
end
function s.diceop(e,tp,eg,ep,ev,re,r,rp)
	local v=e:GetLabel()
	local cc=Duel.GetCurrentChain()
	local cid=Duel.GetChainInfo(cc,CHAININFO_CHAIN_ID)
	if s[0]~=cid then
		local dc={Duel.GetDiceResult()}
		local check=false
		for _,res in ipairs(dc) do
			if res~=v then
				check=true
				break
			end
		end
		if check and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			local ac=1
			local ct=(ev&0xff)+(ev>>16)
			Duel.Hint(HINT_CARD,0,id)
			if ct>1 then
				Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
				local val,idx=Duel.AnnounceNumber(tp,table.unpack(dc,1,ct))
				ac=idx+1
			end
			dc[ac]=v
			Duel.SetDiceResult(table.unpack(dc))
			s[0]=cid
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
		end
	end
end

--E3
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	local rc=re:GetHandler()
	local relation=rc:IsRelateToEffect(re)
	if chk==0 then
		return Duel.IsChainNegatable(ev) or (rc:IsAbleToRemove(tp) or (not relation and Duel.IsPlayerCanRemove(tp)))
	end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if relation then
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,rc,1,rc:GetControler(),rc:GetLocation())
	else
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,0,rc:GetPreviousLocation())
	end
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local d=Duel.TossDice(tp,1)
	if d>=1 and d<=3 then
		Duel.Hint(HINT_OPSELECTED,tp,aux.Stringid(id,3))
		Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,3))
		if Duel.IsChainNegatable(ev) then
			Duel.BreakEffect()
			Duel.NegateActivation(ev)
		end
		
	elseif d>3 and d<=6 then
		Duel.Hint(HINT_OPSELECTED,tp,aux.Stringid(id,4))
		Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,4))
		Duel.BreakEffect()
		if re:GetHandler():IsRelateToChain(ev) then
			Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
		end
	end
end