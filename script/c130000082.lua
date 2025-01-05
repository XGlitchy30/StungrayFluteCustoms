--[[
Our Story in the Wind
Card Author: AuroraUline
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--[[During the Battle Phase: Target 1 monster you control; change it to face-up Attack Position (if possible), also, if it is a Psychic monster, it gains 600 ATK until the end of the turn.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_POSITION|CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET|EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:HOPT()
	e1:SetFunctions(
		aux.AND(xgl.BattlePhaseCond(),xgl.ExceptOnDamageCalc),
		nil,
		s.target,
		s.activate
	)
	c:RegisterEffect(e1)
	--[[At the end of the Battle Phase, if no attacks were declared this turn: You can banish this card; draw 1 card. You must control a "Linaan" card to activate and resolve this effect.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:HOPT()
	e2:SetHintTiming(TIMING_BATTLE_END)
	e2:SetFunctions(s.drcon,aux.bfgcost,xgl.DrawTarget(0),s.drawop)
	c:RegisterEffect(e2)
	--Count declared attacks
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_ATTACK_ANNOUNCE)
		ge1:SetOperation(function() Duel.RegisterFlagEffect(0,id,RESET_PHASE|PHASE_END,0,1) end)
		Duel.RegisterEffect(ge1,0)
	end)
end
s.listed_series={SET_LINAAN}

--E1
function s.filter(c,IsDamageStep,MustBeFaceup)
	local IsPsychic=c:IsRace(RACE_PSYCHIC)
	if IsDamageStep and not IsPsychic and (not MustBeFaceup or not c:IsFaceup()) then return false end
	return not c:IsPosition(POS_FACEUP_ATTACK) or (c:IsFaceup() and IsPsychic)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local IsDamageStep=Duel.GetCurrentPhase()==PHASE_DAMAGE
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc,IsDamageStep,true) end
	if chk==0 then return Duel.IsExists(true,s.filter,tp,LOCATION_MZONE,0,1,nil,IsDamageStep) end
	local tc=Duel.Select(HINTMSG_TARGET,true,tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil,IsDamageStep):GetFirst()
	Duel.SetOperationInfo(0,CATEGORY_POSITION,tc,1,0,0)
	local IsFaceupPsychic=tc:IsFaceup() and tc:IsRace(RACE_PSYCHIC)
	Duel.SetConditionalOperationInfo(IsFaceupPsychic,0,CATEGORY_ATKCHANGE,tc,1,tp,600)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		if not tc:IsPosition(POS_FACEUP_ATTACK) then
			Duel.ChangePosition(tc,POS_FACEUP_ATTACK)
		end
		if tc:IsFaceup() and tc:IsRace(RACE_PSYCHIC) then
			tc:UpdateATK(600,RESET_PHASE|PHASE_END,{e:GetHandler(),true})
		end
	end
end

--E2
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()==PHASE_BATTLE and Duel.IsExists(false,aux.FaceupFilter(Card.IsSetCard,SET_LINAAN),tp,LOCATION_ONFIELD,0,1,nil) and not Duel.HasFlagEffect(0,id)
end
function s.drawop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsExists(false,aux.FaceupFilter(Card.IsSetCard,SET_LINAAN),tp,LOCATION_ONFIELD,0,1,nil) then return end
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end