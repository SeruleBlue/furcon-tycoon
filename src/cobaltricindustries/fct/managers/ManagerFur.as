package src.cobaltricindustries.fct.managers {
	import src.cobaltricindustries.fct.ContainerGame;
	import src.cobaltricindustries.fct.props.actor.Fur;
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
				cg.game.addChild(fur.mc_object);
				addObject(fur);
				fur.enableDebugging();
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