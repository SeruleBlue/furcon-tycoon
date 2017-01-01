package src.cobaltricindustries.fct.props.actor.stats {
	import src.cobaltricindustries.fct.System;
	/**
	 * Static class defining common buffs.
	 * @author Alexander Huynh
	 */
	public class Buffs {
		/// Lose 10 HAP per hour.
		public static var HAP_DRAIN:Buff = new Buff("Happiness Drain", null, "happiness", -1, 10 * System.FRAMES_IN_MINUTE);
			
		public function Buffs() {
		}
	}
}