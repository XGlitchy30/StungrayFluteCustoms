--[[
Wiccink Calligrapher
Card Author: Aurora
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--[[You can target 1 "Wiccink Token" you control; destroy it, and if you do, Special Summon this card from your hand]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_DESTROY|CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:HOPT()
	e1:SetFunctions(nil,nil,s.sptg,s.spop)
	c:RegisterEffect(e1)
	--[[Once per turn, at the start of the Battle Phase: You can double the original ATK/DEF of all "Wiccink Tokens" you control until the end of the Battle Phase.
	This card cannot attack during the turn you use this effect]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORIES_ATKDEF)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE|PHASE_BATTLE_START)
	e2:SetRange(LOCATION_MZONE)
	e2:OPT()
	e2:SetFunctions(nil,s.atkcost,s.atktg,s.atkop)
	c:RegisterEffect(e2)
	--[[Once per turn, if a "Wiccink" card(s) would be destroyed by a card effect, you can shuffle that many "Wiccink" Spells from your GY or banishment into the Deck.]]
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_MZONE)
	e3:OPT()
	e3:SetTarget(s.reptg)
	e3:SetValue(s.repval)
	e3:SetOperation(s.repop)
	c:RegisterEffect(e3)
	local g=Group.CreateGroup()
	g:KeepAlive()
	e3:SetLabelObject(g)
	--Register attacks by this card
	local ge1=Effect.CreateEffect(c)
	ge1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_CONTINUOUS)
	ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_CANNOT_NEGATE)
	ge1:SetCode(EVENT_ATTACK_ANNOUNCE)
	ge1:SetOperation(s.regop)
	c:RegisterEffect(ge1)
end
s.listed_names={TOKEN_WICCINK}
s.listed_series={SET_WICCINK}

function s.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,0,1)
end

--E1
function s.filter(c,tp)
	return c:IsFaceup() and c:IsCode(TOKEN_WICCINK) and Duel.GetMZoneCount(tp,c)>0
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and s.filter(chkc,tp) end
	local c=e:GetHandler()
	if chk==0 then
		return Duel.IsExists(true,s.filter,tp,LOCATION_ONFIELD,0,1,nil,tp) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	local g=Duel.Select(HINTMSG_DESTROY,true,tp,s.filter,tp,LOCATION_ONFIELD,0,1,1,nil,tp)
	Duel.SetCardOperationInfo(g,CATEGORY_DESTROY)
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and Duel.Destroy(tc,REASON_EFFECT)>0 then
		local c=e:GetHandler()
		if c:IsRelateToChain() then
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end

--E2
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:HasFlagEffect(id) end
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(STRING_CANNOT_ATTACK)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
	c:RegisterEffect(e1,true)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.Group(aux.FaceupFilter(Card.IsCode,TOKEN_WICCINK),tp,LOCATION_MZONE,0,nil)
	if chk==0 then
		return #g>0
	end
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,g,#g,tp,LOCATION_MZONE,0,OPINFO_FLAG_FUNCTION,s.opinfofunc1)
	Duel.SetCustomOperationInfo(0,CATEGORY_DEFCHANGE,g,#g,tp,LOCATION_MZONE,0,OPINFO_FLAG_FUNCTION,s.opinfofunc2)
end
function s.opinfofunc1(c)
	return {c:GetBaseAttack()*2}
end
function s.opinfofunc2(c)
	return {c:GetBaseDefense()*2}
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.Group(aux.FaceupFilter(Card.IsCode,TOKEN_WICCINK),tp,LOCATION_MZONE,0,nil)
	for tc in g:Iter() do
		local oatk,odef=tc:GetBaseAttack(),tc:GetBaseDefense()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_BASE_ATTACK)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_BATTLE)
		e1:SetValue(oatk*2)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_BASE_DEFENSE)
		e2:SetValue(odef*2)
		tc:RegisterEffect(e2)
	end
end

--E3
function s.repfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_WICCINK) and c:IsOnField() and not c:IsReason(REASON_REPLACE)
		and c:IsReason(REASON_BATTLE|REASON_EFFECT) and not c:HasFlagEffect(id)
end
function s.desfilter(c)
	return c:IsFaceupEx() and c:IsSpell() and c:IsSetCard(SET_WICCINK) and c:IsAbleToDeck() and aux.nvfilter(c)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=eg:FilterCount(s.repfilter,nil)
	if chk==0 then return ct>0 and Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_GB,0,ct,nil) end
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)
		local tg=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_GB,0,ct,ct,nil)
		local g=e:GetLabelObject()
		g:Clear()
		for tc in tg:Iter() do
			tc:RegisterFlagEffect(id,RESET_EVENT|(RESETS_STANDARD&~RESET_TURN_SET)|RESET_CHAIN,0,1)
			g:AddCard(tc)
		end
		return true
	else return false end
end
function s.repval(e,c)
	return s.repfilter(c)
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,1-tp,id)
	local tg=e:GetLabelObject()
	Duel.HintSelection(tg)
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT|REASON_REPLACE)
end