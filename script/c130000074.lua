--[[
Hieratic Dragon Prince of Thoth
Card Author: ExaltedDawn
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	c:EnableReviveLimit()
	--2 Level 5 monsters
	--[[Once per turn, you can also Xyz Summon "Hieratic Dragon Prince of Thoth" by using 1 "Hieratic" Normal Monster you control as material]]
	Xyz.AddProcedure(c,nil,5,2,s.ovfilter,aux.Stringid(id,0),2,s.xyzop)
	--[[During your Main Phase: You can either Tribute 1 monster from your hand, or detach 1 material from this card, then activate the appropriate effect, depending on what was detached or Tributed.
	● Normal Monster: Banish 1 monster from your opponent's GY.
	● Effect Monster: Target 1 Set card in your opponent's Spell & Trap Zone; while this card is face-up, that Set card cannot be activated until the End Phase, and your opponent must activate it during the End Phase or else send it to the GY.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,1)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetFunctions(nil,xgl.LabelCost,s.target,s.operation)
	c:RegisterEffect(e1,false,REGISTER_FLAG_DETACH_XMAT)
end
function s.ovfilter(c,tp,xyzc)
	return c:IsFaceup() and c:IsSetCard(SET_HIERATIC,xyzc,SUMMON_TYPE_XYZ,tp) and c:IsType(TYPE_NORMAL,xyzc,SUMMON_TYPE_XYZ,tp)
end
function s.xyzop(e,tp,chk)
	if chk==0 then return not Duel.HasFlagEffect(tp,id) end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,EFFECT_FLAG_OATH,1)
	return true
end

--E1
function s.cfilter(c,e,tp,release)
	if not c:IsMonsterType() then return false end
	if release then
		if not c:IsReleasable() then
			return false
		end
	elseif not c:IsAbleToDetachAsCost(e,tp) then
		return false
	end
	
	if c:IsType(TYPE_NORMAL) then
		return not Duel.PlayerHasFlagEffectLabel(tp,id+100,1) and Duel.IsExists(false,s.rmfilter,tp,0,LOCATION_GRAVE,1,c)
	elseif c:IsType(TYPE_EFFECT) then
		return not Duel.PlayerHasFlagEffectLabel(tp,id+100,2) and Duel.IsExists(true,Card.IsFacedown,tp,0,LOCATION_STZONE,1,c)
	else
		return false
	end
end
function s.rlcheck(sg,tp,exg)
	return Duel.IsExists(true,aux.TRUE,tp,0,LOCATION_MZONE,1,sg)
end
function s.rmfilter(c)
	return c:IsMonsterType() and c:IsAbleToRemove() and aux.SpElimFilter(c)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local xg=c:GetOverlayGroup()
	local b1=xg:IsExists(s.cfilter,1,nil,e,tp)
	local b2=Duel.CheckReleaseGroupCost(tp,s.cfilter,1,true,nil,nil,e,tp,true)
	if chk==0 then return b1 or b2 end
	local opt=xgl.Option(tp,nil,nil,{b1,STRING_DETACH},{b2,STRING_RELEASE})
	local typ=0
	if opt==0 then
		Duel.HintMessage(tp,HINTMSG_REMOVEXYZ)
		local tc=xg:FilterSelect(tp,s.cfilter,1,1,nil,e,tp):GetFirst()
		if tc then
			typ=tc:GetType()&(TYPE_NORMAL|TYPE_EFFECT)
			Duel.SendtoGrave(tc,REASON_COST)
			Duel.RaiseSingleEvent(c,EVENT_DETACH_MATERIAL,e,REASON_COST,tp,0,0)
		end
	elseif opt==1 then
		local tc=Duel.SelectReleaseGroupCost(tp,s.cfilter,1,1,true,nil,nil,e,tp,true):GetFirst()
		if tc then
			typ=tc:GetType()&(TYPE_NORMAL|TYPE_EFFECT)
			Duel.Release(tc,REASON_COST)
		end
	end
	Duel.SetTargetParam(typ)
	return typ
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_STZONE) and chkc:IsFacedown() end
	if chk==0 then
		local isCostChecked=e:GetLabel()==1
		e:SetLabel(0)
		return isCostChecked and s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	end
	e:SetLabel(0)
	local typ=s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local label=0
	if typ==TYPE_NORMAL then
		label=1
		e:SetCategory(CATEGORY_REMOVE)
		e:SetProperty(0)
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_GRAVE)
	elseif typ==TYPE_EFFECT then
		label=2
		e:SetCategory(0)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		Duel.Select(HINTMSG_TARGET,true,tp,Card.IsFacedown,tp,0,LOCATION_STZONE,1,1,nil)
	end
	Duel.RegisterFlagEffect(tp,id+100,RESET_PHASE|PHASE_END,0,1,label)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local typ=Duel.GetTargetParam()
	if typ==TYPE_NORMAL then
		local g=Duel.Select(HINTMSG_REMOVE,false,tp,s.rmfilter,tp,0,LOCATION_MZONE|LOCATION_GRAVE,1,1,nil)
		if #g>0 then
			Duel.HintSelection(g)
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		end
	elseif typ==TYPE_EFFECT then
		local c=e:GetHandler()
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToChain() and tc:IsFacedown() and c:IsRelateToChain() and c:IsFaceup() then
			c:SetCardTarget(tc)
			e:SetLabelObject(tc)
			c:ResetFlagEffect(id)
			tc:ResetFlagEffect(id)
			local fid=c:GetFieldID()
			c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,0,1,fid)
			tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,0,1,fid)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
			e1:SetCode(EFFECT_CANNOT_TRIGGER)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
			e1:SetLabelObject(tc)
			e1:SetCondition(s.rcon)
			e1:SetValue(1)
			tc:RegisterEffect(e1)
			--End of e1
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
			e2:SetCode(EVENT_PHASE|PHASE_END)
			e2:SetCountLimit(1)
			e2:SetReset(RESET_PHASE|PHASE_END)
			e2:SetLabel(fid)
			e2:SetLabelObject(e1)
			e2:SetCondition(s.rstcon)
			e2:SetOperation(s.rstop)
			Duel.RegisterEffect(e2,tp)
			--send to grave
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
			e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e3:SetCode(EVENT_PHASE|PHASE_END)
			e3:SetCountLimit(1)
			e3:SetReset(RESET_PHASE|PHASE_END)
			e3:SetLabel(fid)
			e3:SetLabelObject(tc)
			e3:SetCondition(s.agcon)
			e3:SetOperation(s.agop)
			Duel.RegisterEffect(e3,tc:GetControler())
			--activate check
			local e4=Effect.CreateEffect(c)
			e4:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
			e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e4:SetCode(EVENT_CHAINING)
			e4:SetReset(RESET_PHASE|PHASE_END)
			e4:SetLabel(fid)
			e4:SetLabelObject(e3)
			e4:SetOperation(s.rstop2)
			Duel.RegisterEffect(e4,tp)
		end
	end
end
function s.rcon(e)
	return e:GetOwner():IsHasCardTarget(e:GetHandler()) and e:GetHandler():HasFlagEffect(id)
end
function s.rstcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject():GetLabelObject()
	if tc:GetFlagEffectLabel(id)==e:GetLabel()
		and c:GetFlagEffectLabel(id)==e:GetLabel() then
		return not c:IsDisabled()
	else
		e:Reset()
		return false
	end
end
function s.rstop(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	te:Reset()
	Duel.HintSelection(Group.FromCards(e:GetHandler()))
end
function s.agcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(id)==e:GetLabel()
		and c:GetFlagEffectLabel(id)==e:GetLabel() then
		return not c:IsDisabled()
	else
		e:Reset()
		return false
	end
end
function s.agop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	Duel.SendtoGrave(tc,REASON_RULE,PLAYER_NONE,1-tp)
end
function s.rstop2(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	local c=e:GetOwner()
	if tc:GetFlagEffectLabel(id)~=e:GetLabel() or tc==c then return end
	c:CancelCardTarget(tc)
	local te=e:GetLabelObject()
	tc:ResetFlagEffect(id)
	if te then te:Reset() end
end