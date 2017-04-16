package src.cobaltricindustries.fct.props.actor.stats {
	import flash.display.MovieClip;
	import src.cobaltricindustries.fct.props.actor.Fur;
	import src.cobaltricindustries.fct.System;
	/**
	 * Controls visibility of a Fur's thought/speech bubble.
	 * @author Alexander Huynh
	 */
	public class Bubble {
		
		private var fur:Fur;
		private var bubble:MovieClip;
		private var cooldownArr:Array = [0, 0];
		
		public static var enum:int = 0;
		public static const CD_VISIBILITY:int = enum++;
		public static const CD_EMOTION:int = enum++;

		private const VIS_COOLDOWN:int = 90;
		
		public function Bubble(_fur:Fur) {
			fur = _fur;
			bubble = fur.mc_object.mc_thought;
			bubble.visible = false;
		}
		 
		public function step():void {
			// step cooldowns
			for (var i:int = 0; i < cooldownArr.length; i++) {
				if (cooldownArr[i] > 0) {
					cooldownArr[i]--;
					if (i == CD_VISIBILITY) {
						if (cooldownArr[i] == 1) bubble.visible = false;
						if (cooldownArr[i] > 0) return;		// quit if bubble visible
					}
				}
			}
			
			if (System.rand(99.5)) return;
			
			if (cooldownArr[CD_EMOTION] == 0) {
				if (cooldownArr[i] == 1) bubble.visible = false;
				cooldownArr[CD_VISIBILITY] = VIS_COOLDOWN;
				cooldownArr[CD_EMOTION] = System.getRandInt(300, 600);
				bubble.visible = true;
				bubble.gotoAndStop(fur.getStat("happiness") > 45 ? "happy" : "sad");
			}
		}
	}
}