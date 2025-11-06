--[[
Fortunes of the Ladies' Luck
Card Author: AuroraUline
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
Duel.LoadScript("glitchylib_new.lua")
Duel.LoadScript("glitchymods_gamble.lua")
function s.initial_effect(c)
	--Target 1 "Lady Luck" monster you control; roll a six-sided die, then apply the appropriate effect based on the result from those listed on that monster.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_DICE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRelevantTimings()
	e1:HOPT()
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--During your Main Phase: You can banish this card from your GY, then target 1 "Lady Luck" monster you control; negate its effects, and if you do, Special Summon 1 "Lady Luck" monster from your Deck with a different name, but its effects are negated.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_DISABLE|CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:HOPT()
	e2:SetFunctions(
		xgl.MainPhaseCond(0),
		aux.bfgcost,
		xgl.Target{
			f = s.disfilter,
			loc1 = LOCATION_MZONE,
			extrachk = s.ftchk,
			hint = HINTMSG_DISABLE,
			extratg = s.opinfo
		},
		s.spop
	)
	c:RegisterEffect(e2)
end
s.listed_series={SET_LADY_LUCK}
s.roll_dice=true

--E1
function s.checkeffect(e,tp,eg,ep,ev,re,r,rp)
	if e:IsHasCategory(CATEGORY_DICE) then
		local etyp,ecode=e:GetType(),e:GetCode()
		local tg=e:GetTarget()
		if not tg then
			return true
		end
		if etyp&EFFECT_TYPES_EVENT~=0 and etyp&EFFECT_TYPE_SINGLE==0 and ecode~=EVENT_FREE_CHAIN then
			local checkev,ceg,cep,cev,cre,cr,crp = Duel.CheckEvent(ecode,true)
			if checkev and tg(e,tp,ceg,cep,cev,cre,cr,crp,0) then
				return true
			end
		end
		if tg(e,tp,eg,ep,ev,re,r,rp,0) then
			return true
		end
	end
	return false
end
function s.tgfilter(c,tp,eg,ep,ev,re,r,rp)
	if not (c:IsFaceup() and c:IsSetCard(SET_LADY_LUCK) and c.roll_dice) then return false end
	local eset={c:GetOwnEffects()}
	for _,e in ipairs(eset) do
		if s.checkeffect(e,tp,eg,ep,ev,re,r,rp) then return true end
	end
	return false
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local te=e:GetLabelObject()
		local tg=te:GetTarget()
		return tg and tg(e,tp,eg,ep,ev,re,r,rp,0,chkc)
	end
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,0,1,nil,tp,eg,ep,ev,re,r,rp) end
	e:SetProperty(EFFECT_FLAG_CARD_TARGET)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tc=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,tp,eg,ep,ev,re,r,rp):GetFirst()
	local valid_effs, descs = {},{}
	local eset={tc:GetOwnEffects()}
	for _,ce in ipairs(eset) do
		if s.checkeffect(ce,tp,eg,ep,ev,re,r,rp) then
			table.insert(valid_effs,ce)
			table.insert(descs,ce:GetDescription())
		end
	end
	local te
	if #valid_effs>1 then
		local opt=Duel.SelectOption(tp,table.unpack(descs))+1
		te=valid_effs[opt]
	elseif #valid_effs==1 then
		te=valid_effs[1]
	else
		return
	end
	Duel.ClearTargetCard()
	tc:CreateEffectRelation(e)
	
	local prop=te:GetProperty()
	e:SetProperty(prop)
	
	local tg=te:GetTarget()
	if tg then
		local c=e:GetHandler()
		if prop&EFFECT_FLAG_CARD_TARGET~=0 and c:IsLocation(LOCATION_SZONE) and xgl.GetSelfTargetExceptionForSpellTrap(e)==c then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
			e1:SetLabelObject(e)
			e1:SetValue(s.efilter)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_CHAIN)
			c:RegisterEffect(e1,true)
		end
		local tgchk=false
		local etyp,ecode=te:GetType(),te:GetCode()
		if etyp&EFFECT_TYPES_EVENT~=0 and etyp&EFFECT_TYPE_SINGLE==0 and ecode~=EVENT_FREE_CHAIN then
			local checkev,ceg,cep,cev,cre,cr,crp = Duel.CheckEvent(ecode,true)
			if checkev then
				tgchk=true
				tg(e,tp,ceg,cep,cev,cre,cr,crp,chk)
			end
		end
		if not tgchk then
			tg(e,tp,eg,ep,ev,re,r,rp,chk)
		end
	end
	te:SetLabel(e:GetLabel())
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabel(0)
	e:SetLabelObject(te)
	Duel.ClearOperationInfo(0)
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local d=Duel.TossDice(tp,1)
	local te=e:GetLabelObject()
	if not te then return end
	local tc=te:GetHandler()
	if not tc:IsRelateToEffect(e) or not tc:IsFaceup() then return end
	e:SetLabel(te:GetLabel())
	e:SetLabelObject(te:GetLabelObject())
	local op=te:GetOperation()
	if op then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_SKIP_DICE_ROLL)
		e1:SetTargetRange(1,0)
		e1:SetTarget(function (_e,_de) return _de==e end)
		e1:SetValue(d)
		e1:SetReset(RESET_CHAIN)
		Duel.RegisterEffect(e1,tp)
		Duel.BreakEffect()
		op(e,tp,eg,ep,ev,re,r,rp)
	end
end
function s.efilter(e,re,rp)
	return re==e:GetLabelObject()
end

--E2
function s.disfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(SET_LADY_LUCK) and c:IsNegatableMonster() and Duel.IsExists(false,s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetCode())
end
function s.spfilter(c,e,tp,...)
	return c:IsSetCard(SET_LADY_LUCK) and not c:IsCode(...) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.ftchk(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetMZoneCount(tp)>0
end
function s.opinfo(g,e,tp,eg,ep,ev,re,r,rp,chk)
	Duel.SetCardOperationInfo(g,CATEGORY_DISABLE)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsFaceup() and tc:IsCanBeDisabledByEffect(e) then
		local _,_,res=Duel.Negate(tc,e,nil,false,false,TYPE_MONSTER) 
		if res and Duel.GetMZoneCount(tp)>0 then
			local g=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,tc:GetCode())
			if #g>0 then
				Duel.SpecialSummonNegate(e,g,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end