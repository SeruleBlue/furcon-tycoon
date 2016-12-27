package src.cobaltricindustries.fct.props {
	import src.cobaltricindustries.fct.ContainerGame;
	import src.cobaltricindustries.fct.props.ABST_Movable;
	import src.cobaltricindustries.fct.System;
	import flash.display.MovieClip;
	import flash.geom.Point;
	
	/**
	 * Object representing an individual, con-going furry.
	 * @author Serule Blue
	 */
	public class Fur extends ABST_Movable {
		
		public var handle:String = "Anonymous Furry";
		public var age:int = 22;
		
		public var inventory:Array = [];
		
		public function Fur(_cg:ContainerGame, _mc_object:MovieClip = null) {
			super(_cg, _mc_object, _cg.hitbox);
			
			stats["happiness"] = [50, 0, 100];
			stats["energy"] = [50, 0, 100];

			stats["hunger"] = [0, 0, 100];
			stats["thirst"] = [0, 0, 100];
			stats["toilet"] = [0, 0, 100];

			stats["money"] = [100, 0, 9999];
		}
	}
}