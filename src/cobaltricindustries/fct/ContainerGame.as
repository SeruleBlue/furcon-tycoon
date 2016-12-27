package src.cobaltricindustries.fct {
	import src.cobaltricindustries.fct.props.Fur;
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
	
		public var furs:Array;

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
			
			
			// Temporary dev code!
			furs = [];
			var fur:Fur;
			for (var i:int = 0; i < 5; i++) {
				fur = new Fur(this, new SWC_Fur());
				game.addChild(fur.mc_object);
				furs.push(fur);
			}
			
			
			graphMaster = new GraphMaster(this);
			graphMaster.initNodes("simple");
			graphMaster.initGraph();
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
			
			for each (var fur:Fur in furs) {
				fur.step();
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
