package cobaltricindustries.fct.support {
	import cobaltricindustries.fct.ContainerGame;

	/**
	 * Abstract support class
	 * @author Serule Blue
	 */
	public class ABST_Support {
		protected var cg:ContainerGame;
		
		public function ABST_Support(_cg:ContainerGame) {
			cg = _cg;
		}
		
		public function step():void {
			// -- override this function
		}
		
		public function destroy():void {
			cg = null;
		}
	}
}