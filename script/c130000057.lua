--[[
Wish Upon a Drytron Star
Card Author: ExaltedDawn
Modifications by: XGlitchy30
This is essentially a "nerfed" version of Meteonis Drytron. Refer to the script of that card for the original authors
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--Ritual Summon
	Ritual.AddProcGreater({handler=c,filter=s.ritualfil,lv=Card.GetAttack,matfilter=s.filter,location=LOCATION_HAND|LOCATION_GRAVE,requirementfunc=Card.GetAttack,desc=aux.Stringid(id,0)})
	--Add itself to hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND|CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_DRYTRON}
--E1
function s.ritualfil(c)
	return c:GetAttack()>0 and c:IsRitualMonster() and c:IsSetCard(SET_DRYTRON)
end
function s.filter(c)
	return c:IsLocation(LOCATION_HAND|LOCATION_MZONE) and c:IsRace(RACE_MACHINE) and c:GetAttack()>0
end

--E2
function s.atkfilter(c,e,tp)
	return c:IsSetCard(SET_DRYTRON) and c:IsCanUpdateATK(-2000,e,tp,REASON_EFFECT,true)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.atkfilter(chkc,e,tp) end
	if chk==0 then return e:GetHandler():IsAbleToHand() and Duel.IsExistingTarget(s.atkfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local tc=Duel.SelectTarget(tp,s.atkfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp):GetFirst()
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,tc,1,tp,0,-2000)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() and tc:IsCanUpdateATK(-2000,e,tp,REASON_EFFECT) then
		local e1,diff,reg=tc:UpdateATK(-2000,RESET_PHASE|PHASE_END|RESET_OPPO_TURN,{c,true})
		if reg and diff==-2000 and not tc:IsImmuneToEffect(e1) and c:IsRelateToChain() then
			Duel.SendtoHand(c,nil,REASON_EFFECT)
		end
	end
end