--[[
Gravekeeper’s Augur
Card Author: AuroraUline
Scripted by: XGlitchy30
]]

local s,id = GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	c:EnableReviveLimit()
	local NecroCon = xgl.LocationGroupCond(aux.FaceupFilter(Card.IsCode,CARD_NECROVALLEY),LOCATION_ONFIELD,0,1)
	--2 "Gravekeeper's" monsters, including "Gravekeeper's Spiritualist”
	Fusion.AddProcMixN(c,true,true,s.ffilter,2)
	--If you control "Necrovalley": You can target 1 face-up card your opponent controls; negate its effects until the end of this turn.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:HOPT()
	e1:SetFunctions(
		NecroCon,
		nil,
		s.distg,
		s.disop
	)
	c:RegisterEffect(e1)
	--While you control "Necrovalley", your opponent cannot activate the effects of monsters in their GY that were destroyed by battle with a "Gravekeeper's" monster.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,1)
	e2:SetCondition(NecroCon)
	e2:SetValue(s.actval)
	c:RegisterEffect(e2)
	--Register flag to monsters destroyed by battle against "Gravekeeper's" monsters
	aux.GlobalCheck(s,function()
		local ge1=Effect.GlobalEffect()
		ge1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_BATTLED)
		ge1:SetOperation(s.regop)
		Duel.RegisterEffect(ge1,0)
	end)
end
s.listed_names={CARD_GRAVEKEEPERS_SPIRITUALIST,CARD_NECROVALLEY}
s.listed_series={SET_GRAVEKEEPERS}
s.material_setcode={SET_GRAVEKEEPERS}

function s.ffilter(c,fc,sumtype,sp,sub,mg,sg)
	return c:IsSetCard(SET_GRAVEKEEPERS,fc,sumtype,sp) and (not sg or sg:FilterCount(aux.TRUE,c)==0 or sg:IsExists(Card.IsCode,1,c,CARD_GRAVEKEEPERS_SPIRITUALIST,fc,sumtype,sp))
end

--GE1
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local tab={Duel.GetBattleMonster(0)}
	for i,tc in ipairs(tab) do
		if tc:IsStatus(STATUS_BATTLE_DESTROYED) then
			local oc=tab[3-i]
			if oc:IsFaceup() and oc:IsSetCard(SET_GRAVEKEEPERS) then
				tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD_EXC_GRAVE,0,1)
			end
		end
	end
end

--E1
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and chkc:IsNegatable() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsNegatable,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
	local g=Duel.SelectTarget(tp,Card.IsNegatable,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsFaceup() and tc:IsCanBeDisabledByEffect(e) then
		Duel.Negate(tc,e,RESET_PHASE|PHASE_END)
	end
end

--E2
function s.actval(e,re,tp)
	local rc=re:GetHandler()
	return rc and re:IsMonsterEffect() and re:GetActivateLocation()==LOCATION_GRAVE and rc:IsControler(1-e:GetHandlerPlayer())
		and rc:IsReason(REASON_BATTLE) and rc:HasFlagEffect(id)
end