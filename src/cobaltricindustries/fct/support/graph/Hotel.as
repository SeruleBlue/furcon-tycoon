package src.cobaltricindustries.fct.support.graph {
	import flash.display.MovieClip;
	import src.cobaltricindustries.fct.ContainerGame;
	import src.cobaltricindustries.fct.support.ABST_Support;
	import src.cobaltricindustries.fct.support.conevent.ConRoom;
	/**
	 * Helps define the hotel's rooms.
	 * @author Serule Blue
	 */
	public class Hotel extends ABST_Support {
		public var name:String = "The Harriot";
		/// Dictionary of room names to rooms.
		public var rooms:Object;
		
		public function Hotel(cg_:ContainerGame, name_:String) {
			super(cg_);
			name = name_;
			rooms = { };
			
			var ic:MovieClip = cg.game.mc_innerContainer;
			var nm:Object = cg.graphMaster.nodeMap;
			switch (name) {
				case "The Harriot":
					rooms["Ballroom"] = new ConRoom("Ballroom", ic.rm_ball, [nm["gn_ball_w"], nm["gn_ball_e"]]);
					rooms["Panel 3"] = new ConRoom("Panel 3", ic.rm_p3, [nm["gn_p3"]]);
					break;
			}
		}
	}
}