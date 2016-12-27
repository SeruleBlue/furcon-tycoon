package src.cobaltricindustries.fct.support.graph {
	import flash.display.MovieClip;
	import src.cobaltricindustries.fct.ContainerGame;
	import src.cobaltricindustries.fct.System;
	
	/**
	 * An individual network node.
	 * @author Serule Blue
	 */
	public class GraphNode {
		private var cg:ContainerGame;
		private var gm:GraphMaster;
		public var mc_object:MovieClip;
		
		public var edges:Array = [];
		public var edgeCost:Object = { };
		
		public function GraphNode(_cg:ContainerGame, _gm:GraphMaster, _mc_object:MovieClip) {
			cg = _cg;
			gm = _gm;
			mc_object = _mc_object;
			mc_object.visible = false;
		}
		
		/**
		 * Add edges to this node and update edge costs
		 * @param	nodes		Array of nodes to create edges to
		 */
		public function connectNodes(nodes:Array):void {
			var other:GraphNode;
			for each (var str:String in nodes) {
				other = gm.nodeMap[str];
				edges.push(other);
				edgeCost[str] = System.getDistance(mc_object.x, mc_object.y, other.mc_object.x, other.mc_object.y);
			}
		}
	}
}