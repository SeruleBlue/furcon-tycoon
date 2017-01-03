package src.cobaltricindustries.fct {
	import src.cobaltricindustries.fct.managers.ManagerFur;
	import src.cobaltricindustries.fct.managers.MetaManager;
	import src.cobaltricindustries.fct.props.actor.Fur;
	import src.cobaltricindustries.fct.support.Demographics;
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
	import src.cobaltricindustries.fct.support.graph.Hotel;
	import src.cobaltricindustries.fct.support.Schedule;
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
		public var schedule:Schedule;
		public var demographics:Demographics;
		public var hotel:Hotel;

		/// Position of mouse in previous frame.
		private var prevX:Number = 0;
		/// Position of mouse in previous frame.
		private var prevY:Number = 0;

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
			
			// Initialize the Graph Network.
			graphMaster = new GraphMaster(this);
			graphMaster.initNodes("simple");
			graphMaster.initGraph();
			
			// Initialize support classes.
			ui = new UI(this);
			time = new Time(this);
			metaManager.addManager(time, "time");
			hotel = new Hotel(this, "The Harriot");
			schedule = new Schedule(this, hotel);
			demographics = new Demographics(this);
			metaManager.addManager(schedule, "schedule");
			
			// Initialize Managers.
			metaManager.addManager(new ManagerFur(this), "fur");
			
			//graphMaster.debugDrawNetwork();
			
			// Intitialize the UI.
			ui.setTime(time.getCurrentFormattedTime());
			ui.setDay(time.day);
			
			//demographics.displayDemographic("Age");			
			// (!) -------------------- Debug only -------------------- (!)
			demographics.displayDemographic("Money");
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
			updateMouseLocation();

			return completed;
		}
		
		/**
		 * Remember the new location of the mouse.
		 * Implemented here to ensure it fires after all other managers.
		 */
		private function updateMouseLocation():void {
			prevX = mouseX;
			prevY = mouseY;
		}
		
		/**
		 * Returns true if the mouse is in a different position than in the previous frame.
		 * @return
		 */
		public function didMouseUpdate():Boolean {
			return prevX != mouseX || prevY != mouseY;
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
