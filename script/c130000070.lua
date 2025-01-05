--[[
Hieratic Seal of Release
Card Author: ExaltedDawn
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--[[Tribute 1 "Hieratic" Effect Monster, then target 1 Effect Monster your opponent controls; destroy it, then Special Summon 1 Level 6 or higher Dragon Normal Monster from your hand or Deck.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_DESTROY|CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_MAIN_END)
	e1:HOPT(true)
	e1:SetFunctions(nil,s.cost,s.target,s.activate)
	c:RegisterEffect(e1)
	--[[You can banish this card from your GY and reveal 1 "Hieratic" monster in your hand, then target 1 "Hieratic" monster you control; it gains 400 ATK/DEF for every Normal Monster you control and
	in your GY.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,2)
	e2:SetCategory(CATEGORIES_ATKDEF)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:HOPT()
	e2:SetFunctions(
		nil,
		xgl.CreateCost(xgl.LabelCost,aux.bfgcost,xgl.RevealCost(xgl.MonsterFilter(Card.IsSetCard,SET_HIERATIC),1,1,nil)),
		s.statstg,
		s.statsop
	)
	c:RegisterEffect(e2)
	aux.GlobalCheck(s,function()
		local ge=Effect.GlobalEffect()
		ge:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		ge:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		ge:SetCode(EVENT_ATTACK_ANNOUNCE)
		ge:SetOperation(s.checkop)
		Duel.RegisterEffect(ge,0)
	end)
end
s.listed_series={SET_HIERATIC}

function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local fid=eg:GetFirst():GetFieldID()
	local p=eg:GetFirst():GetControler()
	if Duel.GetFlagEffect(p,id)~=0 and Duel.GetFlagEffectLabel(p,id)~=fid then
		Duel.SetFlagEffectLabel(p,id,0)
	else
		Duel.RegisterFlagEffect(p,id,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,0,1,fid)
	end
end

--E1
function s.cfilter(c)
	return c:IsSetCard(SET_HIERATIC) and c:IsType(TYPE_EFFECT)
end
function s.rlcheck(sg,tp,exg,e)
	return Duel.IsExists(true,s.desfilter,tp,0,LOCATION_MZONE,1,sg,sg,e,tp)
end
function s.desfilter(c,sg,e,tp,ignoreSS)
	local excg=sg and sg:Clone() or Group.CreateGroup()
	excg:AddCard(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and Duel.GetMZoneCount(tp,excg)>0 and (ignoreSS or Duel.IsExists(false,s.spfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,excg,e,tp))
end
function s.spfilter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsRace(RACE_DRAGON) and c:IsLevelAbove(6) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	if chk==0 then
		return (not e:IsHasType(EFFECT_TYPE_ACTIVATE) or (Duel.GetFlagEffect(tp,id)==0 or Duel.GetFlagEffectLabel(tp,id)~=0)) and Duel.CheckReleaseGroupCost(tp,s.cfilter,1,1,false,s.rlcheck,nil,e)
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		local c=e:GetHandler()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_OATH)
		e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetCondition(s.atkcon)
		e1:SetTarget(s.atktg)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
		aux.RegisterClientHint(c,nil,tp,1,0,aux.Stringid(id,1),nil)
	end
	Duel.HintMessage(tp,HINTMSG_RELEASE)
	local g=Duel.SelectReleaseGroupCost(tp,s.cfilter,1,1,false,s.rlcheck,nil,e)
	Duel.Release(g,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.desfilter(chkc,nil,e,tp,true) end
	if chk==0 then
		local isCostChecked=e:GetLabel()==1
		e:SetLabel(0)
		return isCostChecked or Duel.IsExists(true,s.desfilter,tp,0,LOCATION_MZONE,1,nil,nil,e,tp)
	end
	e:SetLabel(0)
	local g=Duel.Select(HINTMSG_DESTROY,true,tp,s.desfilter,tp,0,LOCATION_MZONE,1,1,nil,nil,e,tp)
	Duel.SetCardOperationInfo(g,CATEGORY_DESTROY)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and Duel.Destroy(tc,REASON_EFFECT)>0 and Duel.GetMZoneCount(tp)>0 then
		local g=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.spfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.BreakEffect()
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end

function s.atkcon(e)
	return Duel.GetFlagEffect(e:GetHandlerPlayer(),id)~=0
end
function s.atktg(e,c)
	return c:GetFieldID()~=Duel.GetFlagEffectLabel(e:GetHandlerPlayer(),id)
end

--E2
function s.atkfilter(c)
	return c:IsFaceupEx() and c:IsMonster() and c:IsType(TYPE_NORMAL)
end
function s.statstg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() and chkc:IsSetCard(SET_HIERATIC) end
	local g=Duel.Group(s.atkfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,nil)
	if chk==0 then
		local c=e:GetHandler()
		local isCostChecked=e:GetLabel()==1
		e:SetLabel(0)
		if isCostChecked and g:IsContains(c) then
			g:RemoveCard(c)
		end
		return #g>0 and Duel.IsExistingTarget(aux.FaceupFilter(Card.IsSetCard,SET_HIERATIC),tp,LOCATION_MZONE,0,1,nil)
	end
	e:SetLabel(0)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local tc=Duel.SelectTarget(tp,aux.FaceupFilter(Card.IsSetCard,SET_HIERATIC),tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	local val=#g*400
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,tc,1,tp,val)
	Duel.SetOperationInfo(0,CATEGORY_DEFCHANGE,tc,1,tp,val)
end
function s.statsop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsFaceup() then
		local val=Duel.GetMatchingGroupCount(s.atkfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,nil)*400
		if val==0 then return end
		tc:UpdateATKDEF(val,val,true,{e:GetHandler(),true})
	end
end