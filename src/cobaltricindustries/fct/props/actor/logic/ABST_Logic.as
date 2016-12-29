package src.cobaltricindustries.fct.props.actor.logic {
	import src.cobaltricindustries.fct.props.actor.Fur;
	/**
	 * Abstract state machine logic for a Fur.
	 * @author Serule Blue
	 */
	public class ABST_Logic {
		/// The Fur that this Logic is attached to
		protected var fur:Fur;
		
		public function ABST_Logic(fur_:Fur) {
			fur = fur_;
		}
		
		/**
		 * Run whatever logic is associated with this Logic.
		 */
		public function runLogic(... args):void {
			// override this function
		}
	}
}