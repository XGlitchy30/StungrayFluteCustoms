local _RegisterEffect = Card.RegisterEffect

local function IsEffectCode(code0,...)
	local x={...}
	for _,code in ipairs(x) do
		if code0==code then
			return true
		end
	end
	return false
end

function Card.RegisterEffect(c,eff,...)
	local e=eff
	if e:IsHasType(EFFECT_TYPE_GRANT) then
		e=e:GetLabelObject()
	end
	local type,prop,code,cond,val=e:GetType(),e:GetProperty(),e:GetCode(),e:GetCondition(),e:GetValue()
	
	if type==EFFECT_TYPE_SINGLE then
	
		--[[Fix interaction between continuous original stats modifiers and lingering current+original stats modifiers (both activated and non): for example, if Shrink's effect is applied to a monster and Unstable Evolution is later equipped to that monster, the original ATK of that monster should be determined by the effect of Unstable Evolution. Currently, EDOPro applies the effects in an incorrect order, which means that Unstable Evolution's modifier is overwritten by the one of Shrink, even if the former was applied strictly after the latter. The interaction between Darkworld Shackles and Shrink is also problematic, as the ATK of a monster affected by Shackles is supposed to remain unchanged even after Shrink is applied to it.
		REMOVE THIS CODE ONLY AFTER THE BUG IS FIXED IN THE CORE]]
		
		if IsEffectCode(code,EFFECT_SET_BASE_ATTACK,EFFECT_SET_BASE_DEFENSE) and prop&EFFECT_FLAG_SINGLE_RANGE==0 then
			e:SetCondition(aux.SetBaseStatsModCond(code,cond,val))
		end
	end
	
	local res=_RegisterEffect(c,e,...)
	
	return res
end

aux.ActualBaseStats={}

local _GetBaseAttack,_GetBaseDefense = Card.GetBaseAttack,Card.GetBaseDefense

function Card.GetBaseAttack(c)
	local actual=aux.ActualBaseStats[c]
	if actual and actual[1]>=0 then
		return actual[1]
	else
		return _GetBaseAttack(c)
	end
end
function Card.GetBaseDefense(c)
	local actual=aux.ActualBaseStats[c]
	if actual and actual[2]>=0 then
		return actual[2]
	else
		return _GetBaseDefense(c)
	end
end

function Auxiliary.SetBaseStatsModCond(code,cond,val)
	local base = EFFECT_SET_BASE_ATTACK and 1 or 2
	local code2= EFFECT_SET_BASE_ATTACK and EFFECT_SET_ATTACK or EFFECT_SET_DEFENSE
	return	function(e)
				local c=e:GetHandler()
				if aux.PreventFakeBaseStatLoop then return false end
				aux.PreventFakeBaseStatLoop=true
				local eset,eset2={c:IsHasEffect(code)},{c:IsHasEffect(code2)}
				aux.PreventFakeBaseStatLoop=false
				if not aux.ActualBaseStats[c] then
					aux.ActualBaseStats[c]={-1,-1}
				end
				for _,eff in ipairs(eset) do
					local eid=eff:GetFieldID()
					if eff:GetType()==EFFECT_TYPE_EQUIP and eid>e:GetFieldID() then
						aux.ActualBaseStats[c][base]=type(val)=="number" and val or val(e,c)
						return false
					end
				end
				for _,eff in ipairs(eset2) do
					if eff:GetType()==EFFECT_TYPE_EQUIP then
						aux.ActualBaseStats[c][base]=type(val)=="number" and val or val(e,c)
						return false
					end
				end
				aux.ActualBaseStats[c][base]=-1
				return not cond or cond(e)
			end
end