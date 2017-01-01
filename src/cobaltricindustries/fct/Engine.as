package src.cobaltricindustries.fct {
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Point;

	/**
	 * Primary game 'holder' and updater.
	 * @author Serule Blue
	 */
	public class Engine extends MovieClip {		
		private const STATE_MENU:int = 0;
		private const STATE_GAME:int = 1;
		
		private const RET_NORMAL:int = 10;
		private const RET_RESTART:int = 11;
		
		private var gameState:int = STATE_GAME;
		private var returnCode:int = RET_NORMAL;
		private var container:MovieClip;
		
		public var superContainer:SWC_Mask;
		
		public function Engine() {			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		/**
		 * Helper to init the global keyboard listener (quality buttons)
		 * @param	e	the captured Event, unused
		 */
		private function onAddedToStage(e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			addEventListener(Event.ENTER_FRAME, step);					// primary game loop firer
			superContainer = new SWC_Mask();
			superContainer.x += System.GAME_OFFSX;
			superContainer.y += System.GAME_OFFSY;
			stage.addChild(superContainer);

			switchToContainer(new ContainerGame(this), 0, 0);
			gameState = STATE_GAME;
		}

		/**
		 * Primary game loop event firer. Steps the current container, and advances
		 * 	to the next one if the current container is complete
		 * @param	e	the captured Event, unused
		 */
		public function step(e:Event):void {
			if (container != null && container.step()) {
				switch (gameState) {			// determine which new container to go to next
					case STATE_MENU:
						switchToContainer(new ContainerGame(this), 0, 0);
						gameState = STATE_GAME;
					break;
					case STATE_GAME:
						if (returnCode == RET_NORMAL) {
							switchToContainer(new ContainerMenu(this), 0, 0);
							gameState = STATE_MENU;
						}
						else if (returnCode == RET_RESTART) {
							switchToContainer(new ContainerGame(this), 0, 0);
							gameState = STATE_GAME;
						}
					break;
				}
			}
		}
		
		/**
		 * Helper to switch from the current container to the new, given one
		 * @param	containerNew		The container to switch to
		 * @param	offX				Offset x to translate the new container by
		 * @param	offY				Offset y to translate the new container by
		 */
		private function switchToContainer(containerNew:ABST_Container, offX:Number = 0, offY:Number = 0):void {
			if (container != null && superContainer.mc_base.contains(container)) {
				superContainer.mc_base.removeChild(container);
				container = null;
			}
			container = containerNew;
			container.x += offX;
			container.y += offY;
			superContainer.mc_base.addChild(container);
			container.tabChildren = false;
			container.tabEnabled = false;
			
			returnCode = RET_NORMAL;
		}
	}
}