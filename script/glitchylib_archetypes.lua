--Library for archetype-specific functions

Duel.LoadScript("glitchylib_new.lua")

--ANCESTAGON
if Ancestagon then
	local function tefilter(c,e,tp)
		return c:IsType(TYPE_PENDULUM) and c:IsSetCard(SET_ANCESTAGON) and c:IsAbleToExtraFaceupAsCost(e,tp)
	end
	function Ancestagon.DukeSilveraptorTributeCost(e,tp,eg,ep,ev,re,r,rp,chk)
		e:SetLabel(1)
		local c=e:GetHandler()
		local extraGroup
		local altcostGroup=Duel.Group(Card.IsHasEffect,tp,LOCATION_MZONE,0,nil,CARD_ANCESTAGON_DUKE_SILVERAPTOR)
		if #altcostGroup>0 and c:IsLevelAbove(8) and c:IsSetCard(SET_ANCESTAGON) then
			extraGroup=altcostGroup:GetXyzMaterialGroup(tefilter,e,tp)
		end
		if chk==0 then
			return xgl.CheckReleaseGroupCost(tp,Card.IsSetCard,2,2,extraGroup,false,aux.ReleaseCheckMMZ,nil,SET_ANCESTAGON)
		end
		local _,g1,g2=xgl.SelectReleaseGroupCost(tp,Card.IsSetCard,2,2,extraGroup,false,aux.ReleaseCheckMMZ,nil,SET_ANCESTAGON)
		if #g2>0 then
			Duel.SendtoExtraP(g2,tp,REASON_COST)
		end
		if #g1>0 then
			Duel.Release(g1,REASON_COST)
		end
	end
end

--DEMONISU
if Demonisu then
	function Demonisu.RegisterOnSummonEffect(c,id,tgflag,limflag)
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(id,0)
		e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
		e1:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
		e1:SetCode(EVENT_SUMMON_SUCCESS)
		e1:HOPT()
		e1:SetFunctions(
			nil,
			nil,
			Demonisu.OnSummonTarget(tgflag),
			Demonisu.OnSummonOperation(id,tgflag,limflag)
		)
		c:RegisterEffect(e1)
	end
	function Demonisu.OnSummonFilter(tgflag)
		return	function(c,fid)
					return c:IsFaceup() and not c:HasFlagEffectLabel(tgflag,fid)
				end
	end
	function Demonisu.OnSummonTarget(tgflag)
		return	function(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
					local fid=e:GetHandler():GetFieldID()
					if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and Demonisu.OnSummonFilter(tgflag)(chkc,fid) end
					if chk==0 then return Duel.IsExistingTarget(Demonisu.OnSummonFilter(tgflag),tp,0,LOCATION_MZONE,1,nil,fid) end
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
					Duel.SelectTarget(tp,Demonisu.OnSummonFilter(tgflag),tp,0,LOCATION_MZONE,1,1,nil,fid)
				end
	end
	function Demonisu.OnSummonOperation(id,tgflag,limflag)
		return	function(e,tp,eg,ep,ev,re,r,rp)
					local c=e:GetHandler()
					if not c:IsRelateToChain() or not c:IsFaceup() then return end
					local tc=Duel.GetFirstTarget()
					if tc:IsRelateToChain() then
						local fid=c:GetFieldID()
						tc:RegisterFlagEffect(tgflag,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,fid,aux.Stringid(id,1))
						if not c:HasFlagEffectLabel(limflag,fid) then
							c:RegisterFlagEffect(limflag,RESET_EVENT|RESETS_STANDARD,0,1,fid)
							local e1=Effect.CreateEffect(c)
							e1:SetDescription(id,1)
							e1:SetType(EFFECT_TYPE_FIELD)
							e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
							e1:SetCode(EFFECT_ONLY_ATTACK_MONSTER)
							e1:SetRange(LOCATION_MZONE)
							e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
							e1:SetTarget(
								function(e,c)
									return c:HasFlagEffectLabel(tgflag,e:GetLabel())
								end
							)
							e1:SetValue(
								function(e,c)
									return c==e:GetHandler()
								end
							)
							e1:SetLabel(fid)
							e1:SetReset(RESET_EVENT|RESETS_STANDARD)
							c:RegisterEffect(e1)
							local e2=Effect.CreateEffect(c)
							e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
							e2:SetCode(EVENT_ADJUST)
							e2:SetLabel(fid)
							e2:SetCondition(
								function(e,tp,eg,ep,ev,re,r,rp)
									local c=e:GetOwner()
									return not c:HasFlagEffectLabel(limflag,e:GetLabel())
								end
							)
							e2:SetOperation(Demonisu.ResetFlagHints(tgflag))
							Duel.RegisterEffect(e2,tp)
						end
					end
				end
	end
	function Demonisu.ResetFlagHints(tgflag)
		return	function(e,tp,eg,ep,ev,re,r,rp)
					local fid=e:GetLabel()
					local g=Duel.Group(Card.HasFlagEffectLabel,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,tgflag,fid)
					for tc in aux.Next(g) do
						tc:GetFlagEffectWithSpecificLabel(tgflag,fid,true)
					end
					e:Reset()
				end
	end

	function Demonisu.RegisterAttackNegate(c,id,ctg,target,op)
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(id,2)
		if ctg then
			e2:SetCategory(ctg)
		end
		e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
		e2:SetCode(EVENT_ATTACK_ANNOUNCE)
		e2:SetRange(LOCATION_MZONE)
		e2:HOPT()
		e2:SetFunctions(
			function(e,tp,eg,ep,ev,re,r,rp)
				local d=Duel.GetAttackTarget()
				return d and d==e:GetHandler() and eg:GetFirst():GetControler()~=tp
			end,
			xgl.ToHandSelfCost,
			target,
			Demonisu.NegateAttackOperation(op)
		)
		c:RegisterEffect(e2)
	end
	function Demonisu.NegateAttackOperation(op)
		return	function(e,tp,eg,ep,ev,re,r,rp)
					local tc=Duel.GetFirstTarget()
					local res=tc and tc:IsRelateToChain() and tc:IsRelateToBattle()
					local IsAttackNegated=Duel.NegateAttack()
					op(e,tp,eg,ep,ev,re,r,rp,tc,res,IsAttackNegated)
				end
	end
end

--NECROVALLEY
local _NecroValleyFilter = Auxiliary.NecroValleyFilter

function Auxiliary.NecroValleyFilter(f)
	if not aux.NecroValleyFilterMod then
		return _NecroValleyFilter(f)
	else
		return	function(target,...)
					local res=f(target,...)
					if not res then return false end
					local dischk=Duel.IsChainDisablable(0)
					if not dischk then
						return true
					end
					if last_tp and Duel.IsPlayerAffectedByEffect(last_tp,CARD_THE_VALLEY_OF_GRAVEKEEPERS) and target:IsLocation(LOCATION_GRAVE) and not Duel.IsPlayerAffectedByEffect(target:GetControler(),EFFECT_NECRO_VALLEY_IM) then
						return false
					end
					return not (target:IsHasEffect(EFFECT_NECRO_VALLEY) and not target:IsHasEffect(CARD_HIDDEN_MONASTERY_OF_NECROVALLEY))
				end
	end
end

--NUMBERS
function Auxiliary.NumberLPCondition(e,p,val,chk)
	if Duel.GetLP(p)<=val then return true end
	local eset={Duel.GetPlayerEffect(p,CARD_NUMBERS_REVOLUTION)}
	for _,ce in ipairs(eset) do
		local tg=ce:GetTarget()
		if not tg or tg(ce,e:GetHandler(),p,e,val,chk) then
			return true
		end
	end
	return false
end