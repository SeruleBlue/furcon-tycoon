package src.cobaltricindustries.fct.managers {
	import flash.geom.Point;
	import src.cobaltricindustries.fct.ContainerGame;
	import src.cobaltricindustries.fct.props.actor.Fur;
	import src.cobaltricindustries.fct.System;
	/**
	 * Updates all Furs and provides aggregated stats.
	 * @author Serule Blue
	 */
	public class ManagerFur extends ABST_Manager {
		
		public function ManagerFur(_cg:ContainerGame) {
			super(_cg);		
			
			// Temporary dev code!
			var fur:Fur;
			for (var i:int = 0; i < 15; i++) {
				fur = new Fur(cg, new SWC_Fur());
				cg.game.mc_containerFurs.addChild(fur.mc_object);
				var pt:Point = System.getRandomValidLocationInRoom(cg.game.mc_innerContainer.rm_ls);
				fur.mc_object.x = pt.x; fur.mc_object.y = pt.y;
				addObject(fur);
				fur.schedule = cg.schedule;
				//fur.enableDebugging();
			}
		}
		
		override public function step():void {
			updateStats();
			super.step();
		}
		
		/**
		 * Update information and report it to the game.
		 */
		public function updateStats():void {
			var stats:Object = { };
			stats["population"] = objArray.length;
			
			// temporary thing
			var rating:int = 0;
			for each (var fur:Fur in objArray) {
				rating += fur.getStat("happiness");
			}
			stats["rating"] = int(rating / objArray.length);
			
			cg.ui.setStats(stats);
		}
	}
}