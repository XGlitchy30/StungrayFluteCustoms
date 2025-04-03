--[[
B.E.F. Shield Machinery
Card Author: Knightmare88
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	c:Activation()
	--[[Reduce the Levels of all "B.E.S." monsters in your hand by 1.]]
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_BES))
	e1:SetValue(-1)
	c:RegisterEffect(e1)
	--[[Once per turn, if you control no monsters: You can pay 500 LP; Special Summon 1 "B.E.S. Garun Token" (Machine/LIGHT/Level 1/1000 ATK/0 DEF). It cannot be Tributed, nor used as material for a
	Synchro or Link Summon, except for the Summon of a "B.E.S." monster.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,0)
	e2:SetCategory(CATEGORIES_TOKEN)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:OPT()
	e2:SetFunctions(
		xgl.ControlNoMonstersCond(),
		aux.PayLPCost(500),
		s.tktg,
		s.tkop
	)
	c:RegisterEffect(e2)
	--[[Once per turn, if you would remove a counter(s) from a "B.E.S." monster you control, you can pay 500 LP instead.]]
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,2)
	e3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EFFECT_RCOUNTER_REPLACE+COUNTER_BES)
	e3:SetRange(LOCATION_SZONE)
	e3:OPT()
	e3:SetCondition(s.rcon)
	e3:SetOperation(s.rop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_BES}

--E2
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMZoneCount(tp)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_BES_GARUN,SET_BES,TYPES_TOKEN,1000,0,1,RACE_MACHINE,ATTRIBUTE_LIGHT) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	if s.tktg(e,tp,eg,ep,ev,re,r,rp,0) then
		local c=e:GetHandler()
		local token=Duel.CreateToken(tp,TOKEN_BES_GARUN)
		if Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP) then
			local e0=Effect.CreateEffect(c)
			e0:SetType(EFFECT_TYPE_SINGLE)
			e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_IGNORE_IMMUNE)
			e0:SetCode(EFFECT_UNRELEASABLE_NONSUM)
			e0:SetReset(RESET_EVENT|RESETS_STANDARD)
			e0:SetValue(1)
			token:RegisterEffect(e0,true)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetCode(EFFECT_UNRELEASABLE_SUM)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			e1:SetValue(aux.TargetBoolFunction(aux.NOT(Card.IsSetCard),SET_BES))
			token:RegisterEffect(e1,true)
			local e2=Effect.CreateEffect(c)
			e2:SetDescription(id,1)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_CLIENT_HINT)
			e2:SetCode(EFFECT_CANNOT_BE_MATERIAL)
			e2:SetValue(s.matlimit)
			e2:SetReset(RESET_EVENT|RESETS_STANDARD)
			token:RegisterEffect(e2,true)
		end
		Duel.SpecialSummonComplete()
	end
end
function s.matlimit(e,sc,sumtype,tp)
	if sc:IsSetCard(SET_BES) then return false end
	local allowed={SUMMON_TYPE_SYNCHRO,SUMMON_TYPE_LINK}
	local sum=(SUMMON_TYPE_SYNCHRO|SUMMON_TYPE_XYZ)&sumtype
	for _,val in pairs(allowed) do
		if sum==val then return true end
	end
	return false
end

--E3
function s.rcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and Duel.CheckLPCost(tp,500)
end
function s.rop(e,tp,eg,ep,ev,re,r,rp)
	Duel.PayLPCost(tp,500)
end