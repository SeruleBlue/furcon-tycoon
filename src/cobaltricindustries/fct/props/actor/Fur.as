package src.cobaltricindustries.fct.props.actor {
	import flash.events.MouseEvent;
	import src.cobaltricindustries.fct.ContainerGame;
	import src.cobaltricindustries.fct.props.ABST_Movable;
	import src.cobaltricindustries.fct.props.actor.logic.*;
	import src.cobaltricindustries.fct.support.conevent.ConEvent;
	import src.cobaltricindustries.fct.support.Schedule;
	import src.cobaltricindustries.fct.System;
	import flash.display.MovieClip;
	import flash.geom.Point;
	import src.cobaltricindustries.fct.SM;
	
	/**
	 * Object representing an individual, con-going furry.
	 * @author Serule Blue
	 */
	public class Fur extends ABST_Movable {
		public var handle:String = "Anonymous Furry";
		public var age:int = 22;
		
		public var inventory:Array = [];
		
		/// The Schedule this Fur knows about (not necessarily the 'real' one).
		public var schedule:Schedule;
		public var eventOfInterest:ConEvent;
		
		/// Dictionary of string keys to Logics.
		public var brain:Object = { };
		
		public function Fur(_cg:ContainerGame, _mc_object:MovieClip = null) {
			super(_cg, _mc_object, _cg.hitbox);
			
			stats["happiness"] = 	[50, 0, 100,	-1, 0, System.SECOND * 2];
			stats["energy"] = 		[50, 0, 100,	-1, 0, System.SECOND * 30];

			stats["hunger"] = 		[0, 0, 100,		 1, 0, System.SECOND * 30];
			stats["thirst"] = 		[0, 0, 100,		 1, 0, System.SECOND * 30];
			stats["toilet"] = 		[0, 0, 100,		 1, 0, System.SECOND * 30];

			stats["money"] = 		[50, 0, 9999];
			
			brain["event"] = new LogicEvent(this);
			brain["idle"] = new LogicIdle(this);
			brain["move"] = new LogicMove(this);
			brain["schedule"] = new LogicSchedule(this);
		}
		
		override public function step():Boolean {
			updateStats();
			
			switch (state) {
				case SM.STATE_MOVE_FREE:
				case SM.STATE_MOVE_NETWORK:
				case SM.STATE_MOVE_FROM_NETWORK:
					brain["move"].runLogic();
					break;
				case SM.STATE_IN_EVENT:
					brain["event"].runLogic();
					break;
				case SM.STATE_IDLE:
				default:
					brain["idle"].runLogic();
					break;
			}

			return super.step();
		}
		
		/**
		 * Sets PoI, NoI, and EoI to null.
		 */
		public function resetAllInterests():void {
			pointOfInterest = null;
			nodeOfInterest = null;
			eventOfInterest = null;
		}
		
		/**
		 * Set a new PoI, start moving to it, and optionally set the Logic to perform once we're there.
		 * @param	poi				The new Point of Interest
		 * @param	noPath			Whether to calculate a path or beeline
		 * @param	callbackLogic	The Logic to call once we've arrived
		 */
		public function moveAndCallback(poi:Point, noPath:Boolean = false, callbackLogic:ABST_Logic = null):void {
			setPOI(poi, noPath);
			brain["move"].callbackLogic = callbackLogic;
		}
		
		override protected function onClick(e:MouseEvent):void {
			var out:String = handle + " (" + age + ")\n";
			out += "HAP: " + stats["happiness"][0] + "\n";
			out += "NOI: " + (nodeOfInterest ? nodeOfInterest.mc_object.name : "---") + "\n";
			out += "EOI: " + (eventOfInterest ? eventOfInterest.name : "---") + "\n";
			out += "state: " + SM.enumToString(state) + "\n";
			cg.ui.setDebug(out);
		}
	}
}