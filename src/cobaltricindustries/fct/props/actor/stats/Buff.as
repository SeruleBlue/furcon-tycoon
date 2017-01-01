package src.cobaltricindustries.fct.props.actor.stats {
	import src.cobaltricindustries.fct.props.actor.Fur;
	
	/**
	 * A buff that changes a single stat over time.
	 * @author Serule Blue
	 */
	public class Buff {
		public var name:String;
		private var fur:Fur;
		private var statName:String;
		/// How much to change the stat by per buff tick.
		private var dStat:Number = 0;
		/// How many frames between applications of this buff.
		private var tickInterval:int;
		/// How many frames for this buff to last. -1 for infinite.
		private var totalDuration:int;
		
		private var tickCurrent:int;
		private var tickTotal:int;
		/**
		 * Constructor.
		 * @param	_fur
		 * @param	_statName
		 * @param	_dStat
		 * @param	_tickInterval
		 * @param	_totalDuration
		 */
		public function Buff(_name:String, _fur:Fur, _statName:String, _dStat:Number, _tickInterval:int, _totalDuration:int = -1) {
			name = _name;
			fur = _fur;
			statName = _statName;
			dStat = _dStat;
			tickInterval = _tickInterval;
			totalDuration = _totalDuration;
			tickCurrent = 0;
			reapply();
		}
		
		/**
		 * Returns a copy of this buff, applied to the given Fur. Used to copy from a 'master buff'.
		 * @param	newFur	The new Fur to apply the buff to.
		 * @return
		 */
		public function getCopy(newFur:Fur):Buff {
			return new Buff(name, newFur, statName, dStat, tickInterval, totalDuration);
		}
		
		/**
		 * Refresh this buff.
		 */
		public function reapply():void {
			tickTotal = 0;
		}
		
		/**
		 * Change a (previously-infinite) buff to expire.
		 * @param	ticksUntilExpire
		 */
		public function setToExpire(ticksUntilExpire:int):void {
			totalDuration = ticksUntilExpire;
		}
		
		/**
		 * Tick this buff.
		 * @return		true if the buff has expired
		 */
		public function step():Boolean {
			if (fur == null) return false;	// shouldn't happen
			if (++tickCurrent >= tickInterval) {
				fur.changeStat(statName, dStat);
				tickCurrent = 0;
			}
			if (totalDuration != -1) {
				return ++tickTotal >= totalDuration;
			}
			return false;
		}
		
		/**
		 * Set important things to null and hope the GC cleans this up lol.
		 */
		public function destroy():void {
			fur = null;
		}
	}
}