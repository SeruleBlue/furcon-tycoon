package cobaltricindustries.fct {
	import flash.display.MovieClip;
	
	/**
	 * 	An Engine-steppable container.
	 * 	ABSTRACT CLASS - do not instantiate.
	 * 	@author Serule Blue
	 */
	public class ABST_Container extends MovieClip {

		/// Whether this Container is done and the Engine should continue.
		protected var completed:Boolean;

		public function ABST_Container() {
			completed = false;
		}

		public function step():Boolean {
			return completed;
		}

		public function setComplete():void {
			completed = true;
		}
	}
}
