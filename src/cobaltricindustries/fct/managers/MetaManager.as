package src.cobaltricindustries.fct.managers {
	import src.cobaltricindustries.fct.ContainerGame;
	import src.cobaltricindustries.fct.System;
	/**
	 * Manages the Managers.
	 * @author Serule Blue
	 */
	public class MetaManager {
		protected var cg:ContainerGame;
		
		/// An array of ABST_Managers.
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
		 * Step all of the objects in objArray (and stop keeping track of those that are completed)
		 */
		public function step():void {
			if (managerArray.length > 0) {
				for (var i:int = managerArray.length - 1; i >= 0; i--) {
					managerArray[i].step();
				}
			}
		}
		
		/**
		 * Add an ABST_Manager to be managed
		 * @param	man		an ABST_Manager to be managed
		 * @param	key		the man's identifier
		 */
		public function addManager(man:ABST_Manager, key:String):void {
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