--When this card is X Summoned
function Glitchy.RitualSummonedCond(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
function Glitchy.FusionSummonedCond(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function Glitchy.SynchroSummonedCond(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function Glitchy.XyzSummonedCond(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
function Glitchy.PendulumSummonedCond(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_PENDULUM)
end
function Glitchy.LinkSummonedCond(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function Glitchy.ProcSummonedCond(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL+1)
end

--Equip
function Glitchy.IsEquippedCond(e)
	return e:GetHandler():GetEquipTarget()
end
function Glitchy.IsEquippedToCond(f)
	return	function(e,tp)
				if not tp then tp=e:GetHandlerPlayer() end
				local ec=e:GetHandler():GetEquipTarget()
				return ec and (not f or f(ec,e,tp))
			end
end

--Turn/Phase Conditions
function Glitchy.DrawPhaseCond(tp)
	return	function(e,p)
				local tp = (tp==0) and p or (tp==1) and 1-p or nil
				return Duel.IsDrawPhase(tp)
			end
end
function Glitchy.StandbyPhaseCond(tp)
	return	function(e,p)
				local tp = (tp==0) and p or (tp==1) and 1-p or nil
				return Duel.IsStandbyPhase(tp)
			end
end
function Glitchy.MainPhaseCond(tp,ct)
	return	function(e,p)
				local tp = (tp==0) and p or (tp==1) and 1-p or nil
				return Duel.IsMainPhase(tp,ct)
			end
end
function Glitchy.BattlePhaseCond(tp)
	return	function(e,p)
				local tp = (tp==0) and p or (tp==1) and 1-p or nil
				return Duel.IsBattlePhase(tp)
			end
end
function Glitchy.MainOrBattlePhaseCond(tp,ct)
	return	function(e,p)
				local tp = (tp==0) and p or (tp==1) and 1-p or nil
				return Duel.IsMainPhase(tp,ct) or Duel.IsBattlePhase(tp)
			end
end
function Glitchy.EndPhaseCond(tp)
	return	function(e,p)
				local tp = (tp==0) and p or (tp==1) and 1-p or nil
				return Duel.IsEndPhase(tp)
			end
end
function Glitchy.ExceptOnDamageStep()
	return Glitchy.ExceptOnDamageCalc()
end
function Glitchy.ExceptOnDamageCalc()
	return Duel.GetCurrentPhase()~=PHASE_DAMAGE or not Duel.IsDamageCalculated()
end
function Glitchy.TurnPlayerCond(tp)
	return	function(e,p)
				if not p then p=e:GetHandlerPlayer() end
				local tp = (not tp or tp==0) and p or 1-p
				return Duel.GetTurnPlayer()==tp
			end
end

--Type-Related
----XYZ
function Glitchy.HasXyzMaterialCond(e)
	return e:GetHandler():GetOverlayCount()>0
end

----LINK
function Glitchy.ThisCardPointsToCond(f,min)
	if not f then f=aux.TRUE end
	return	function(e)
				local tp=e:GetHandlerPlayer()
				return e:GetHandler():GetLinkedGroup():IsExists(f,min,nil,e,tp)
			end
end