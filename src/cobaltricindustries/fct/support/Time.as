package src.cobaltricindustries.fct.support {
	import src.cobaltricindustries.fct.ContainerGame;
	import src.cobaltricindustries.fct.System;
	
	/**
	 * Manages everything to do with the game time.
	 * @author Serule Blue
	 */
	public class Time extends ABST_Support {
		/// Index into System.DAYS
		public var day:int = 1;
		/// The current hour, in 24-hour format. (0 == midnight)
		public var hour:int = 8;
		public var minute:int = 0;
		
		/// The current count of the number of frames.
		public var frameCounter:int = 0;
		
		/// Number of updates per frame (default 1).
		public var gameSpeed:int = 1;
		/// If gameSpeed > 0, keeps track of what additional step we're on (useful to only call UI when = 0)
		public static var stepCounter:int;
		
		public function Time(_cg:ContainerGame) {
			super(_cg);
			stepCounter = 0;
		}
		
		override public function step():void {
			updateTime();
		}	
		
		/**
		 * Performs 1 tick of time updating.
		 */
		private function updateTime():void {
			if (++frameCounter == System.FRAMES_IN_MINUTE) {
				frameCounter = 0;
				if (++minute == 60) {
					minute = 0;
					if (++hour == 24) {
						hour = 0;
						if (++day == System.DAYS.length) {
							day = 0;
						}
						cg.ui.setDay(day);
					}
				}
				cg.ui.setTime(getFormattedTime());
			}
		}

		/**
		 * Returns the current time in hh:mmam/pm format.
		 * @return
		 */
		public function getFormattedTime():String {
			var isAm:Boolean = hour < 12 || hour == 24;
			var strHour:String;
			if (hour == 0) {
				strHour = "12"; 
			} else if (hour > 12) {
				strHour = (hour - 12).toString();
			} else {
				strHour = hour.toString();
			}
			var strMinute:String = System.pad(minute);
			return strHour + ":" + strMinute + " " + (isAm ? "am" : "pm");
		}
		
		/**
		 * Returns true if stepCounter is 0 (UI should update, etc.)
		 * @return
		 */
		public static function isKeyframe():Boolean {
			return stepCounter == 0;
		}
	}
}