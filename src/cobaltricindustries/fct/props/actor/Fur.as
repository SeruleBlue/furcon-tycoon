package src.cobaltricindustries.fct.props.actor {
	import flash.events.MouseEvent;
	import src.cobaltricindustries.fct.ContainerGame;
	import src.cobaltricindustries.fct.props.ABST_Movable;
	import src.cobaltricindustries.fct.props.actor.logic.*;
	import src.cobaltricindustries.fct.props.actor.stats.Buff;
	import src.cobaltricindustries.fct.support.conevent.ConEvent;
	import src.cobaltricindustries.fct.support.Schedule;
	import src.cobaltricindustries.fct.System;
	import flash.display.MovieClip;
	import flash.geom.Point;
	import src.cobaltricindustries.fct.SM;
	import src.cobaltricindustries.fct.props.actor.stats.Buffs;
	
	/**
	 * Object representing an individual, con-going furry.
	 * @author Serule Blue
	 */
	public class Fur extends ABST_Movable {
		public var handle:String = "???";
		public var age:int = 22;
		public var gender:String;		// Biological gender, yo

		public var inventory:Array = [];
		
		/// The Schedule this Fur knows about (not necessarily the 'real' one).
		public var schedule:Schedule;
		public var eventOfInterest:ConEvent;
		
		/// Dictionary of string keys to Logics.
		public var brain:Object = { };
		
		/// Dictionary of string keys (traits) to Number (values [0-100]).
		public var traits:Object = { };
		
		public function Fur(_cg:ContainerGame, _mc_object:MovieClip = null) {
			super(_cg, _mc_object, _cg.hitbox);
			mc_object.cacheAsBitmap = true;
			
			stats["happiness"] = 	[50, 0, 100];
			stats["energy"] = 		[50, 0, 100];

			stats["hunger"] = 		[0, 0, 100];
			stats["thirst"] = 		[0, 0, 100];
			stats["toilet"] = 		[0, 0, 100];

			stats["money"] = 		[50, 0, 9999];
			
			FurDesigner.designFur(this);
			
			applyBuff(Buffs.HAP_DRAIN.getCopy(this));
			
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
			var out:String = handle + " (age " + age + ", " + gender + ")\n";
			out += "Money: $" + stats["money"][0] + "\n\n";
			out += "HAP: " + stats["happiness"][0] + "\n";
			
			out += "NOI: " + (nodeOfInterest ? nodeOfInterest.mc_object.name : "---") + "\n";
			out += "EOI: " + (eventOfInterest ? eventOfInterest.name : "---") + "\n";
			out += "state: " + SM.enumToString(state) + "\n\n";
			
			out += "-- Interests --\n";
			out += "Art: " + Math.round(100 * traits["Art"]) + "\n";
			out += "Writing: " + Math.round(100 * traits["Writing"]) + "\n";
			out += "Fursuiting: " + Math.round(100 * traits["Fursuiting"]);
			cg.ui.setDebug(out);
		}
	}
}