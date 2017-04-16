package src.cobaltricindustries.fct.support {
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import src.cobaltricindustries.fct.ContainerGame;
	import src.cobaltricindustries.fct.System;
	import flash.events.MouseEvent;
	/**
	 * Handles anything to do with the main game UI.
	 * @author Serule Blue
	 */
	public class UI extends ABST_Support {
		
		private var ui:MovieClip;
		private const validStats:Array = ["money", "population", "rating"];
		private var windowArr:Array = [];
		
		public function UI(_cg:ContainerGame) {
			super(_cg);
			ui = cg.game.mc_ui;
			
			addShowHideListener(ui.btn_goal, ui.mc_goal);
			addShowHideListener(ui.btn_schedule, ui.mc_schedule);
			addShowHideListener(ui.btn_demographics, ui.mc_demographics);
		}
		
		/**
		 * Attach listeners to show/hide the given MovieClip when the given button is clicked
		 * @param	mc
		 */
		private function addShowHideListener(btn:DisplayObject, mc:MovieClip):void {
			mc.visible = false;
			btn.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
				for each (var otherMC:MovieClip in windowArr) {
					if (otherMC != mc) {
						otherMC.visible = false;
					}
				}
				mc.visible = !mc.visible;
			});
			windowArr.push(mc);
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