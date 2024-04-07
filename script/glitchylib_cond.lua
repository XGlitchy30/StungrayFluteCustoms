--When this card is X Summoned
function Auxiliary.RitualSummonedCond(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
function Auxiliary.FusionSummonedCond(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function Auxiliary.SynchroSummonedCond(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function Auxiliary.XyzSummonedCond(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
function Auxiliary.PendulumSummonedCond(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_PENDULUM)
end
function Auxiliary.LinkSummonedCond(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function Auxiliary.PandemoniumSummonedCond(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_PANDEMONIUM)
end
function Auxiliary.BigbangSummonedCond(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_BIGBANG)
end
function Auxiliary.TimeleapSummonedCond(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_TIMELEAP)
end
function Auxiliary.DriveSummonedCond(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_DRIVE)
end
function Auxiliary.ProcSummonedCond(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL+1)
end

--Equip
function Auxiliary.IsEquippedCond(e)
	return e:GetHandler():GetEquipTarget()
end
function Auxiliary.IsEquippedToCond(f)
	return	function(e,tp)
				if not tp then tp=e:GetHandlerPlayer() end
				local ec=e:GetHandler():GetEquipTarget()
				return ec and (not f or f(ec,e,tp))
			end
end

--Turn/Phase Conditions
function Auxiliary.DrawPhaseCond(tp)
	return	function(e,p)
				local tp = (tp==0) and p or (tp==1) and 1-p or nil
				return Duel.IsDrawPhase(tp)
			end
end
function Auxiliary.StandbyPhaseCond(tp)
	return	function(e,p)
				local tp = (tp==0) and p or (tp==1) and 1-p or nil
				return Duel.IsStandbyPhase(tp)
			end
end
function Auxiliary.MainPhaseCond(tp,ct)
	return	function(e,p)
				local tp = (tp==0) and p or (tp==1) and 1-p or nil
				return Duel.IsMainPhase(tp,ct)
			end
end
function Auxiliary.BattlePhaseCond(tp)
	return	function(e,p)
				local tp = (tp==0) and p or (tp==1) and 1-p or nil
				return Duel.IsBattlePhase(tp)
			end
end
function Auxiliary.MainOrBattlePhaseCond(tp,ct)
	return	function(e,p)
				local tp = (tp==0) and p or (tp==1) and 1-p or nil
				return Duel.IsMainPhase(tp,ct) or Duel.IsBattlePhase(tp)
			end
end
function Auxiliary.EndPhaseCond(tp)
	return	function(e,p)
				local tp = (tp==0) and p or (tp==1) and 1-p or nil
				return Duel.IsEndPhase(tp)
			end
end
function Auxiliary.ExceptOnDamageStep()
	return Auxiliary.ExceptOnDamageCalc()
end
function Auxiliary.ExceptOnDamageCalc()
	return Duel.GetCurrentPhase()~=PHASE_DAMAGE or not Duel.IsDamageCalculated()
end
function Auxiliary.TurnPlayerCond(tp)
	return	function(e,p)
				if not p then p=e:GetHandlerPlayer() end
				local tp = (not tp or tp==0) and p or 1-p
				return Duel.GetTurnPlayer()==tp
			end
end

--Type-Related
----XYZ
function Auxiliary.HasXyzMaterialCond(e)
	return e:GetHandler():GetOverlayCount()>0
end

----LINK
function Auxiliary.ThisCardPointsToCond(f,min)
	if not f then f=aux.TRUE end
	return	function(e)
				local tp=e:GetHandlerPlayer()
				return e:GetHandler():GetLinkedGroup():IsExists(f,min,nil,e,tp)
			end
end