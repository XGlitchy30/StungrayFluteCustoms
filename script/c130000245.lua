--[[
Superguida Drago Arcobaleno Oscuro Cristallo Finale - Spettro
Card Author: AuroraUline
Scripted by: XGlitchy30
]]

local s,id = GetID()
Duel.LoadScript("glitchylib_new.lua")
Duel.LoadScript("glitchymods_fusion.lua")
Duel.LoadScript("glitchylib_delayed_event.lua")
function s.initial_effect(c)
	c:EnableReviveLimit()
	--7 DARK "Crystal Beast" and/or "Rainbow Dark" monsters with different names, including "Crystal Beast Rainbow Dark Dragon"
	Fusion.AddProcMixN(c,true,true,s.ffilter,7)
	Fusion.SetMaterialGroupCheck(c,s.fgoalcheck,s.fprunecheck)
	--If this card is Fusion Summoned: Special Summon any number of "Crystal Beast" Monster Cards from your Spell & Trap Zones.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetCondition(xgl.FusionSummonedCond)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--If a "Crystal Beast" monster(s) you control is destroyed and placed in the Spell & Trap Zone(s): Inflict 200 damage to your opponent for each.
	aux.RegisterMergedDelayedEventGlitchy(c,id,EVENT_MOVE,s.cfilter,id,LOCATION_MZONE,false,LOCATION_MZONE,nil,id+1,true,nil,true)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET,EFFECT_FLAG2_CHECK_SIMULTANEOUS)
	e2:SetCode(EVENT_CUSTOM+id)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetFunctions(aux.MergedDelayedEventCondition,nil,s.damtg,s.damop)
	c:RegisterEffect(e2)
	--If this card would be destroyed by battle or card effect, you can destroy 2 face-up "Crystal Beast" cards instead.
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,2)
	e3:SetType(EFFECT_TYPE_CONTINUOUS|EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_MZONE)
	e3:HOPT()
	e3:SetTarget(s.reptg)
	e3:SetOperation(s.repop)
	c:RegisterEffect(e3)
end
s.listed_names={130000241}
s.listed_series={SET_CRYSTAL_BEAST,SET_RAINBOW_DARK}
s.material_setcode={SET_CRYSTAL_BEAST,SET_RAINBOW_DARK}

function s.ffilter(c,fc,sumtype,tp,sub,mg,sg)
	if c:IsLocation(LOCATION_SZONE) then
		attrchk=c:IsOriginalAttribute(ATTRIBUTE_DARK) or c:IsAttribute(ATTRIBUTE_DARK,fc,sumtype,tp)
	else
		attrchk=c:IsAttribute(ATTRIBUTE_DARK,fc,sumtype,tp)
	end
	return attrchk and (c:IsSetCard({SET_CRYSTAL_BEAST,SET_RAINBOW_DARK},fc,sumtype,tp) or c:IsSummonCode(fc,sumtype,tp,79407975))
end
function s.mandatory_fusmat(c,fc,sumtype,tp,sub,sub2)
	return c:IsSummonCode(fc,sumtype,tp,130000241) or (sub and c:CheckFusionSubstitute(fc)) or (sub2 and c:IsHasEffect(CARD_FUSION_PARASITE_ANIME))
end
function s.fgoalcheck(tp,sg,fc,sumtype,sub,sub2)
	return sg:IsExists(s.mandatory_fusmat,1,nil,fc,sumtype,tp,sub,sub2)
end
function s.fprunecheck(tp,sg,fc,sumtype,sub,sub2)
	return not sg:IsExists(s.dupfilter,1,nil,sg,fc,sumtype,tp,sub,sub2)
end
function s.dupfilter(c,sg,fc,sumtype,tp,sub,sub2)
	if sub2 and c:IsHasEffect(CARD_FUSION_PARASITE_ANIME) then return false end
	local code=c:GetCode(fc,sumtype,tp)
	return sg:IsExists(s.samenamefilter,1,c,code,fc,sumtype,tp,sub2)
end
function s.samenamefilter(c,code,fc,sumtype,tp,sub2)
	if sub2 and c:IsHasEffect(CARD_FUSION_PARASITE_ANIME) then return false end
    return c:IsSummonCode(fc,sumtype,tp,code)
end

--E1
function s.filter(c,e,tp)
	return c:IsFaceup() and c:IsMonsterCard() and c:IsSetCard(SET_CRYSTAL_BEAST) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.Group(s.filter,tp,LOCATION_SZONE,0,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,LOCATION_SZONE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	local g=Duel.Group(s.filter,tp,LOCATION_SZONE,0,nil,e,tp)
	if #g==0 then return end
	Duel.HintMessage(tp,HINTMSG_SPSUMMON)
	local sg=g:Select(tp,1,ft,nil)
	if #sg>0 then
		Duel.SpecialSummon(sg,0,tp,tp,true,false,POS_FACEUP)
	end
end

--E2
function s.cfilter(c,_,tp)
	return c:IsFaceup() and c:IsSetCard(SET_CRYSTAL_BEAST) and c:IsLocation(LOCATION_SZONE) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp) and c:GetSequence()<5
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	if eg then
		local tg=aux.SelectSimultaneousEventGroup(eg,tp,id+1,1,e,id+2)
		local val=#tg*200
		Duel.SetTargetParam(val)
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,val)
	else
		Duel.SetTargetParam(0)
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
	end
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if d>0 then
		Duel.Damage(p,d,REASON_EFFECT)
	end
end

--E3
function s.repfilter(c,e)
	return c:IsFaceup() and c:IsSetCard(SET_CRYSTAL_BEAST)
		and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsReason(REASON_REPLACE) and c:IsOnField() and c:IsFaceup()
		and Duel.IsExistingMatchingCard(s.repfilter,tp,LOCATION_ONFIELD,0,2,c,e) end
	if Duel.SelectEffectYesNo(tp,c,96) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)
		local g=Duel.SelectMatchingCard(tp,s.repfilter,tp,LOCATION_ONFIELD,0,2,2,c,e)
		Duel.SetTargetCard(g)
		for tc in g:Iter() do
			tc:SetStatus(STATUS_DESTROY_CONFIRMED,true)
		end
		return true
	else return false end
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	for tc in g:Iter() do
		tc:SetStatus(STATUS_DESTROY_CONFIRMED,false)
	end
	Duel.Destroy(g,REASON_EFFECT|REASON_REPLACE)
end