package src.cobaltricindustries.fct.support {
	import flash.display.MovieClip;
	import src.cobaltricindustries.fct.ContainerGame;
	import src.cobaltricindustries.fct.System;
	
	/**
	 * Handles anything to do with the game UI.
	 * @author Serule Blue
	 */
	public class UI extends ABST_Support {
		
		private var ui:MovieClip;
		private const validStats:Array = ["money", "population", "rating"];
		
		public function UI(_cg:ContainerGame) {
			super(_cg);
			ui = cg.game.mc_ui;
		}
		
		/**
		 * Set the main UI with the given stats
		 * @param	stats	dictionary of stats
		 */
		public function setStats(stats:Object):void {
			for (var i:int = 0; i < validStats.length; i++) {
				var key:String = validStats[i];
				if (stats[key] != null) {
					switch (key) {
						case "money":
							ui.tf_money.text = stats[key];
							break;
						case "population":
							ui.tf_population.text = stats[key];
							break;
						case "rating":
							ui.tf_rating.text = stats[key];
							break;
					}
				}
			}
		}
		
		/**
		 * Sets the main UI with the given time
		 * @param	time	String time format
		 */
		public function setTime(time:String):void {
			ui.tf_time.text = time;
		}
		
		/**
		 * Sets the main UI with the given day
		 * @param	day		Index of current day in System.DAYS
		 */
		public function setDay(day:int):void {
			ui.tf_day.text = System.DAYS[day];
		}
		
		public function setDebug(str:String):void {
			ui.tf_debug.text = str;
		}
	}
}