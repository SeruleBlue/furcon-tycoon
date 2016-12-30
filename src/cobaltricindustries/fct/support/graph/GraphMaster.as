package src.cobaltricindustries.fct.support.graph {
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.geom.Point;
	import src.cobaltricindustries.fct.ContainerGame;
	import src.cobaltricindustries.fct.support.ABST_Support
	import src.cobaltricindustries.fct.System;
	import src.cobaltricindustries.fct.props.ABST_Movable;
	
	/**
	 * Helper class to manage the hotel's pathfinding network
	 * @author Serule Blue
	 */
	public class GraphMaster extends ABST_Support {
		public var nodes:Array = [];				// unordered list of nodes for iteration
		public var nodeMap:Object;					// map of MovieClip name to node object
		
		public var nodeDirections:Object = { };		// Floyd-Warshall directions
		
		public function GraphMaster(_cg:ContainerGame) {
			super(_cg);
		}
		
		/**
		 * Manually add hotel network nodes
		 * @param	hotelName
		 */
		public function initNodes(hotelName:String):void {
			var ic:MovieClip = cg.game.mc_innerContainer;
			nodeMap = { };
			
			// Add all of the GraphNodes.
			// Also hide all of the room MovieClips.
			for (var i:int = 0; i < ic.numChildren; i++) {
				var obj:DisplayObject = ic.getChildAt(i);
				if (obj.name.indexOf("gn_") == 0) {
					addNode(obj as MovieClip);
				} else if (obj.name.indexOf("rm_") == 0) {
					obj.visible = false;
				}
			}

			// Now add the edges manually.
			switch (hotelName) {
				case "simple":
					// Define spawn nodes
					nodeMap["gn_en_s"].isSpawn = true;
					nodeMap["gn_en_e"].isSpawn = true;
					
					// Entry
					nodeMap["gn_en_s"].connectNodes(["gn_ls_se"]);
					nodeMap["gn_en_e"].connectNodes(["gn_ls_se"]);
					
					// Lobby South
					nodeMap["gn_ls_w"].connectNodes(["gn_mh_e", "gn_ls_c", "gn_ls_se"]);
					nodeMap["gn_ls_c"].connectNodes(["gn_ln_ne", "gn_ln_se", "gn_ls_w", "gn_ls_se"]);
					nodeMap["gn_ls_se"].connectNodes(["gn_ln_se", "gn_ls_c", "gn_ls_w"]);
					
					// Lobby North
					nodeMap["gn_ln_nw"].connectNodes(["gn_p4_e", "gn_mh_e", "gn_ln_c", "gn_ln_ne", "gn_ln_se"]);
					nodeMap["gn_ln_c"].connectNodes(["gn_brm", "gn_mh_ce", "gn_mh_e", "gn_ln_nw", "gn_ln_ne", "gn_ln_se"]);
					nodeMap["gn_ln_ne"].connectNodes(["gn_brf", "gn_ln_nw", "gn_ln_c", "gn_ln_se", "gn_ls_c"]);
					nodeMap["gn_ln_se"].connectNodes(["gn_ln_nw", "gn_ln_c", "gn_ln_ne", "gn_ls_c", "gn_ls_se"]);
					
					// Main Hall
					nodeMap["gn_mh_w"].connectNodes(["gn_ball_w", "gn_p0", "gn_p1", "gn_mh_cw"]);
					nodeMap["gn_mh_cw"].connectNodes(["gn_mh_w", "gn_ball_e", "gn_p2", "gn_mh_ce"]);
					nodeMap["gn_mh_ce"].connectNodes(["gn_mh_cw", "gn_sh", "gn_mh_e", "gn_ln_c"]);
					nodeMap["gn_mh_e"].connectNodes(["gn_p3", "gn_mh_ce", "gn_ln_nw", "gn_ln_c", "gn_ls_w"]);
					
					// Side Hall
					nodeMap["gn_sh"].connectNodes(["gn_mh_ce", "gn_p4_w"]);
					
					// Ballroom
					nodeMap["gn_ball_w"].connectNodes(["gn_mh_w", "gn_ball_e"]);
					nodeMap["gn_ball_e"].connectNodes(["gn_ball_w", "gn_mh_cw"]);
					
					// Panel Rooms
					nodeMap["gn_p0"].connectNodes(["gn_mh_w"]);
					nodeMap["gn_p1"].connectNodes(["gn_mh_w"]);
					nodeMap["gn_p2"].connectNodes(["gn_mh_cw"]);
					nodeMap["gn_p3"].connectNodes(["gn_mh_e"]);
					nodeMap["gn_p4_w"].connectNodes(["gn_sh", "gn_p4_sw", "gn_p4_e"]);
					nodeMap["gn_p4_sw"].connectNodes(["gn_p4_w", "gn_p4_e"]);
					nodeMap["gn_p4_e"].connectNodes(["gn_p4_w", "gn_p4_sw", "gn_ln_nw"]);
					
					// Bathrooms
					nodeMap["gn_brm"].connectNodes(["gn_ln_c"]);
					nodeMap["gn_brf"].connectNodes(["gn_ln_ne"]);
				break;
				default:
					trace("[GraphMaster] Warning: Nothing defined for hotel with name", hotelName);
			}
			
			initGraph();
		}
		
		/**
		 * Add a node to the network
		 * @param	mc		MovieClip to be associated with the node
		 */
		public function addNode(mc:MovieClip):void {
			var node:GraphNode = new GraphNode(cg, this, mc);
			nodes.push(node);
			var n:String = mc.name;
			nodeMap[n] = node;
		}
		
		/**
		 * Populate the nodeDirections map using Floyd-Warshall
		 */
		public function initGraph():void {
			var dist:Object = {};
			var node:GraphNode; var other:GraphNode;
			var i:int; var j:int; var k:int;
			
			// initialization
			for each (node in nodes) {
				dist[node.mc_object.name] = { };
				nodeDirections[node.mc_object.name] = { };
				for each (other in nodes) {
					if (node.edges.indexOf(other) != -1) {
						dist[node.mc_object.name][other.mc_object.name] = node.edgeCost[other.mc_object.name];
						nodeDirections[node.mc_object.name][other.mc_object.name] = other;
					}
					else {
						dist[node.mc_object.name][other.mc_object.name] = 99999999;
						nodeDirections[node.mc_object.name][other.mc_object.name] = null;
					}
				}
			}
			
			// Floyd-Warshall
			var newDist:Number;
			for (k = 0; k < nodes.length; k++) {
				for (i = 0; i < nodes.length; i++) {
					for (j = 0; j < nodes.length; j++) {
						if (dist[nodes[i].mc_object.name][nodes[k].mc_object.name] + dist[nodes[k].mc_object.name][nodes[j].mc_object.name] < dist[nodes[i].mc_object.name][nodes[j].mc_object.name]) {
							dist[nodes[i].mc_object.name][nodes[j].mc_object.name] = dist[nodes[i].mc_object.name][nodes[k].mc_object.name] + dist[nodes[k].mc_object.name][nodes[j].mc_object.name];
							nodeDirections[nodes[i].mc_object.name][nodes[j].mc_object.name] = nodeDirections[nodes[i].mc_object.name][nodes[k].mc_object.name];
						}
					}
				}
			}
		}
		
		/**
		 * Get a path of network nodes from an object to a destination
		 * @param	origin			ABST_Movable that is requesting a path
		 * @param	destination		Point, place to go to
		 * @return					Ordered array of nodes
		 */
		public function getPath(origin:ABST_Movable, destination:Point):Array {
			var start:GraphNode = getNearestValidNode(origin, new Point(origin.mc_object.x, origin.mc_object.y));
			var end:GraphNode = getNearestValidNode(origin, destination);
			if (start == null || end == null || nodeDirections[start.mc_object.name][end.mc_object.name] == null)
				return [];
			var path:Array = [start];
			while (start != end) {
				start = nodeDirections[start.mc_object.name][end.mc_object.name];
				path.push(start);
			}				
			return path;
		}
		
		/**
		 * Find the nearest node within LOS of the origin to the target
		 * @param	origin			ABST_Movable to base LOS off of
		 * @param	target			Point of interest
		 * @param	ignoreWalls		true to ignore LOS check
		 * @return					The closest node (possibly within LOS)
		 */
		public function getNearestValidNode(origin:ABST_Movable, target:Point, ignoreWalls:Boolean = false ):GraphNode {
			if (!origin || !target) return null;
			var originalPos:Point = new Point(origin.mc_object.x, origin.mc_object.y);
			origin.mc_object.x = target.x;
			origin.mc_object.y = target.y;
			var dist:Number = 99999;
			var nearest:GraphNode = null;
			var newDist:Number;
			for each (var node:GraphNode in nodes) {
				// Ignore spawn-only nodes.
				if (node.isSpawn) continue;
				newDist = System.getDistance(target.x, target.y, node.mc_object.x, node.mc_object.y);
				if (newDist > dist) continue;
				if (ignoreWalls || System.hasLineOfSight(origin, new Point(node.mc_object.x, node.mc_object.y))) {
					dist = newDist;
					nearest = node;
				}
			}
			origin.mc_object.x = originalPos.x;
			origin.mc_object.y = originalPos.y;
			return nearest;
		}
		
		/**
		 * Draw the network for debugging purposes.
		 */
		public function debugDrawNetwork():void {
			var mc:MovieClip = new MovieClip();
			cg.game.addChild(mc);
			mc.graphics.lineStyle(1, 0xFF0000, 0.25);
			for each (var node:GraphNode in nodes) {
				mc.graphics.drawCircle(node.mc_object.x, node.mc_object.y, 15);
				for each (var other:GraphNode in node.edges) {
					mc.graphics.moveTo(node.mc_object.x, node.mc_object.y);
					mc.graphics.lineTo(other.mc_object.x, other.mc_object.y);
				}
			}
			trace('[GraphMaster] WARNING: Network debugging enabled.');
		}
	}
}