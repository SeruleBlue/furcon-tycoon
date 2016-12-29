﻿package src.cobaltricindustries.fct {
	import src.cobaltricindustries.fct.managers.ManagerFur;
	import src.cobaltricindustries.fct.managers.MetaManager;
	import src.cobaltricindustries.fct.props.actor.Fur;
	import src.cobaltricindustries.fct.support.graph.GraphMaster;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import flash.media.Sound;
	import flash.media.SoundMixer;
	import flash.events.MouseEvent;
	import flash.utils.getTimer;
	import src.cobaltricindustries.fct.support.Time;
	import src.cobaltricindustries.fct.support.UI;
	
	/**
	 * Primary game container and controller.
	 * @author Serule Blue
	 */
	public class ContainerGame extends ABST_Container {		
		public var engine:Engine;

		/// The SWC object containing graphics assets for the game
		public var game:SWC_ContainerGame;
		
		public var hitbox:MovieClip;
		
		public var graphMaster:GraphMaster;
	
		public var metaManager:MetaManager;
		
		public var ui:UI;
		public var time:Time;

		/**
		 * A MovieClip containing all of a FCT level
		 * @param	eng		A reference to the Engine
		 */
		public function ContainerGame(eng:Engine) {
			super();
			engine = eng;
			
			game = new SWC_ContainerGame();
			addChild(game);
			game.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		protected function init(e:Event):void {
			game.removeEventListener(Event.ADDED_TO_STAGE, init);
			
			hitbox = game.mc_innerContainer.mc_collisionBox;
			
			metaManager = new MetaManager(this);
			metaManager.addManager(new ManagerFur(this), "fur");
			
			ui = new UI(this);
			time = new Time(this);
			metaManager.addManager(time, "time");
			
			graphMaster = new GraphMaster(this);
			graphMaster.initNodes("simple");
			graphMaster.initGraph();
			
			//graphMaster.debugDrawNetwork();
			
			// Intitialize the UI
			ui.setTime(time.getFormattedTime());
			ui.setDay(time.day);
		}
		
		/**
		 * Called by Engine every frame to update the game
		 * @return		completed, true if this container is done
		 */
		override public function step():Boolean {
			if (completed) {
				return completed;
			}
			// Otherwise, do stuff first.
			Time.stepCounter = 0;
			for (var i:int = 0; i < time.gameSpeed; i++) {
				metaManager.step();
				Time.stepCounter++;
			}

			return completed;
		}

		/**
		 * Clean-up code
		 * @param	e	the captured Event, unused
		 */
		protected function destroy(e:Event):void {
			setComplete();
		}
	}
}
