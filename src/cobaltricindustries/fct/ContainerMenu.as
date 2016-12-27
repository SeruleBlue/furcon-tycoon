package cobaltricindustries.fct {
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	import flash.utils.describeType;
	
	/**
	 * Main menu and level select screen.
	 * @author Serule Blue
	 */
	public class ContainerMenu extends ABST_Container {
		private var engine:Engine;
		private var menu:*; //SWC_MainMenu;
		
		/**
		 * A MovieClip handling the main menu
		 * @param	_eng			A reference to the Engine
		 */
		public function ContainerMenu(_eng:Engine) {
			engine = _eng;
			
			//menu = new SWC_MainMenu();
			//addChild(menu);
			menu.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		protected function init(e:Event):void {
			menu.removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		override public function step():Boolean {
			return completed;
		}
		
		/**
		 * Clean-up code
		 */
		protected function destroy():void {
			if (menu != null) {
				if (contains(menu)) {
					removeChild(menu);
				}
			}
			menu = null;
			engine = null;
		}
	}
}
