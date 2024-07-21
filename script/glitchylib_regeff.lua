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
	
	local res=_RegisterEffect(c,e,...)
	
	return res
end