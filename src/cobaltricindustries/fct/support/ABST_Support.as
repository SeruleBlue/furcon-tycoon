package src.cobaltricindustries.fct.support {
	import src.cobaltricindustries.fct.ContainerGame;

	/**
	 * Abstract support class.
	 * Differs from ABST_Manager in that they perform specialized actions,
	 * 	rather than keeping track of ABST_Objects.
	 * Managed by MetaManager.
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