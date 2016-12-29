package src.cobaltricindustries.fct.props.actor {
	import flash.events.MouseEvent;
	import src.cobaltricindustries.fct.ContainerGame;
	import src.cobaltricindustries.fct.props.ABST_Movable;
	import src.cobaltricindustries.fct.props.actor.logic.*;
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
		
		/// Dictionary of string keys to Logics.
		public var brain:Object = { };
		
		public function Fur(_cg:ContainerGame, _mc_object:MovieClip = null) {
			super(_cg, _mc_object, _cg.hitbox);
			
			stats["happiness"] = 	[75, 0, 100,	-1, 0, System.SECOND * 2];
			stats["energy"] = 		[50, 0, 100,	-1, 0, System.SECOND * 30];

			stats["hunger"] = 		[0, 0, 100,		 1, 0, System.SECOND * 30];
			stats["thirst"] = 		[0, 0, 100,		 1, 0, System.SECOND * 30];
			stats["toilet"] = 		[0, 0, 100,		 1, 0, System.SECOND * 30];

			stats["money"] = 		[50, 0, 9999];
			
			brain["idle"] = new LogicIdle(this);
			brain["move"] = new LogicMove(this);
		}
		
		override public function step():Boolean {
			updateStats();
			
			switch (state) {
				case STATE_MOVE_FREE:
				case STATE_MOVE_NETWORK:
				case STATE_MOVE_FROM_NETWORK:
					brain["move"].runLogic();
					break;
				case STATE_IDLE:
				default:
					brain["idle"].runLogic();
					break;
			}

			return super.step();
		}
		
		override protected function onClick(e:MouseEvent):void {
			var out:String = handle + " (" + age + ")\n";
			out += "HAP: " + stats["happiness"][0] + "\n";
			out += "NoI: " + (nodeOfInterest ? nodeOfInterest.mc_object.name : "--") + "\n";
			out += "state: " + state + "\n";
			cg.ui.setDebug(out);
		}
	}
}