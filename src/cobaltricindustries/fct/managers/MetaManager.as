package src.cobaltricindustries.fct.managers {
	import src.cobaltricindustries.fct.ContainerGame;
	import src.cobaltricindustries.fct.System;
	/**
	 * Manages the Managers and Support classes.
	 * @author Serule Blue
	 */
	public class MetaManager {
		protected var cg:ContainerGame;
		
		/// An array of ABST_Managers and ABST_Supports.
		private var managerArray:Array;
		
		/// Maps a string key to a manager.
		public var managerMap:Object;
		
		public function MetaManager(_cg:ContainerGame) {
			cg = _cg;
			managerArray = [];
			managerMap = { };
		}
		
		/**
		 * Called once per frame by ContainerGame
		 * Step all of the objects in managerArray
		 */
		public function step():void {
			if (managerArray.length > 0) {
				for (var i:int = managerArray.length - 1; i >= 0; i--) {
					managerArray[i].step();
				}
			}
		}
		
		/**
		 * Add an ABST_Manager or ABST_Support to be managed
		 * @param	man		class to be managed
		 * @param	key		the man's identifier
		 */
		public function addManager(man:*, key:String):void {
			if (managerArray) {
				managerMap[key] = man;
				managerArray.push(man);
			}
		}
		
		public function destroy():void {
			for (var i:int = managerArray.length - 1; i >= 0; i--) {
				// TODO cleanup managers
			}
		}
	}
}