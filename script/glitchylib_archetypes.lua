--Library for archetype-specific functions

Duel.LoadScript("glitchylib_new.lua")

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
					return f(target,...) and not (target:IsHasEffect(EFFECT_NECRO_VALLEY) and not target:IsHasEffect(CARD_HIDDEN_MONASTERY_OF_NECROVALLEY) and Duel.IsChainDisablable(0))
				end
	end
end

--NUMBERS
function Auxiliary.NumberLPCondition(e,p,val,chk)
	if Duel.GetLP(p)<=val then return true end
	local eset={Duel.IsPlayerAffectedByEffect(p,CARD_NUMBERS_REVOLUTION)}
	for _,ce in ipairs(eset) do
		local tg=ce:GetTarget()
		if not tg or tg(ce,e:GetHandler(),p,e,val,chk) then
			return true
		end
	end
	return false
end