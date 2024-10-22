/**
* Name: Main
* Based on the internal empty template. 
* Author: HironariSasaki
* Tags: 
*/

//git_test/2024/10/22/17:12



model Main

import 'Parameters.gaml'
import 'Road.gaml'
import 'Building.gaml'
import 'Intersection.gaml'
import 'Vehicle.gaml'
import 'Normalcar.gaml'
import 'Residence_car.gaml'
import 'Mobcar.gaml'
import 'Random_car.gaml'
import 'Test.gaml'


global {
	
	map shop_id <- user_input_dialog('make_shop_building',[enter('building_id',list)]);
	map no_signal_id <- user_input_dialog('node_id',[enter('node_id',list)]);
	map signal_id <- user_input_dialog('node_id',[enter('node_id',list)]);
	
	
	
	
	list<point>loc_cars <- [];
	list<building> shop_building;
	int come_back_num<-0;
	int chart_value1;
	int chart_value2;
	int chart_value3;

	
	
	init {
		write shop_id;
		write no_signal_id;
		write signal_id;
		create road from:shape_file_road with:[
			road_id::int(read("road_id")),
			p_lane_r::int(read("planesu")),
			m_lane_r::int(read("mlanesu")),
			one_way::int(read("oneway")), 
			maxspeed::float(read("maxspeed")),
			num_lanes::int(read("lanes")),
			length::float(read("length"))
		]{  
			if p_lane_r = nil or p_lane_r = 0{
				num_lanes <- 1;
			}else {
				num_lanes <- p_lane_r;}
			if maxspeed = nil or maxspeed = 0.0{
				maxspeed <- 30.0;}
			current_ave_sp <- maxspeed;
			//one_wayがNoなら(一方通行でないなら)もう一方向向けのロードを作成
			if one_way = 0 {
				create road {
					self.location <- myself.location;
					self.shape <- polyline(reverse(myself.shape.points)); //.pointsでオブジェクト（road）を構成する点たちのリストを取得し、revereseでそれのつなぐ方向（始点と終点）のリストを反転し、polylineで再結合
					self.maxspeed <- myself.maxspeed;
					self.num_lanes <- myself.num_lanes;
					self.p_lane_r <- myself.p_lane_r;
					self.m_lane_r <- myself.m_lane_r;
					self.linked_road <- myself;
					myself.linked_road <- self;
					self.road_id <- myself.road_id;
					self.length <- myself.length;
					self.current_ave_sp <- myself.current_ave_sp;
				}
			}
		}//road
		
		create intersection from:shape_file_node with:
			[ signal_type::(string(read("signaltype"))),
		  	  inter_num::(int(read("nodeno"))),
		 	  node_id::(int(read('node_id')))
			]{
				text_node_id <- string(node_id);
				if no_signal_id['node_id']!=nil and node_id in no_signal_id['node_id']{
					//signal_type <- "1";
					is_traffic_signal <- false;
				}
				if signal_id['node_id']!=nil and node_id in signal_id['node_id']{
					is_traffic_signal <- true;
				}
			}
//			

		
		road_network <- as_driving_graph(road, intersection);
		
		ask intersection {
			
			if length(roads_in)=0 and length(self.roads_out)=0 {
				do die;
			}
			
			if (is_traffic_signal = true) {
				// v_roads_inの作成
				if (length(roads_in)=4 or length(roads_in)=3) {
					loop i over: roads_in {
						add road(i) to:v_roads_in;
					}
				} else {
					loop i over: roads_in {
						if (road(i).is_thin != true) {
							add road(i) to:v_roads_in;
						}
					}
				}
				
				// 位置を計算
				if length(v_roads_in) > 2 and length(v_roads_in) < 5{
					loop i from:0 to:length(v_roads_in)-1 {
						add signal_loc_re(i) to:signal_locations;
					}
				}
				stop << [];
			}
			
			
			
			//stop << []; //この空のリストをstopに代入しないとjavaエラー
		}
		//do die;
		
		
		

		//building
		create building from: shape_file_building with:
		[ blcode::int(read('blcode')),
		  maxhigh::int(read('maxhigh')),
		  type::read('type'),
		  build_id::int(read('buld_id')),
		  building_name::string(read('name'))
		]{
			height <- rnd(10.0#m,30#m);
			if shop_id['building_id']!=nil and build_id in shop_id['building_id']{
				type <- 'shop';
			}
		}
		list<building> residence_building <- building where (each.type="residence");
		shop_building <- building where (each.type='shop');

		//write shop_building;
		loop i over:shop_building{
			i.color <- rgb(rnd(1,255,1),rnd(1,255,1),rnd(1,255,1));
		}
		
		create residence_car number:residence_num {
			residence_place <- one_of(residence_building);
			residence_place.color <- #lightblue;
			
			loop i over:shop_building {
				int count<-1;
				path to_shop;
				loop while:count <10 and to_shop = nil{
					to_shop <- compute_path(graph:road_network,target:intersection(i.location),source:intersection(residence_place.location));
					count<-count+1;
				}
				
				float to_shop_length<-0.0;
				if to_shop != nil {				
					loop j over:to_shop.edges{
						ask road(j) {
							to_shop_length <- to_shop_length + length;
						}
					}
				}else if to_shop=nil {
					
					//write 'path nil'+string(i);
				}
				if to_shop_length != 0.0 {
					shop_length[to_shop_length] <- i;
				}
			}

			//mapの中を店までの距離で昇順にソート
			list<float> pre_sort <- shop_length.keys sort_by (each);
			map<float,building> sort_test;
			
			loop i over:pre_sort{
				add shop_length[i] to:sorted_shop;
				sort_test[i]<-shop_length[i];
			}
			//write sort_test;
			
			location <- residence_place.location;
		    
			
		}

			
//		//normalcar
		create normalcar number:normalcar_num {
			o_node <- one_of(intersection);
			o <- o_node.location;
			o_id<-o_node.node_id;
			location <- o;
			
			d_node <- one_of(intersection where (each.node_id != o_node.node_id));
			d <- d_node.location;
			d_id<-d_node.node_id;
			
			loop while:true{
				current_path <- compute_path(graph: road_network,target:intersection(d));
				//write d;
				if current_path != nil {
					break;
				}else if current_path = nil {
					d_node <- one_of(intersection where (each.node_id != o_node.node_id));
					d <- d_node.location;
					d_id<-d_node.node_id;
				
				}
			}
		}//normalcar

	
//		//mobcar
		no5 <- one_of(intersection where (each.node_id = 5));
		no12 <- one_of(intersection where (each.node_id = 12));
		no36 <- one_of(intersection where (each.node_id = 36));
	    no37 <- one_of(intersection where (each.node_id = 37));
	    //北から南
		create mobcar number:1 {
			o <- no5.location;
			d <- no12.location;
			location <- o;
			loop while:true {
				current_path <- compute_path(graph:road_network,target:intersection(d));
				
				if current_path != nil {
					break;
				}
			}		
		}//mobcar
		//南から北
		create mobcar number:1 {
			o <- no12.location;
			d <- no5.location;
			location <- o;
			loop while:true {
				current_path <- compute_path(graph:road_network,target:intersection(d));
				if current_path != nil {
					break;
				}
			}	
		}
//		
//		if test_agent_on = true {
//			create test_agent;
//		}
	
	
		
	}//initここまで
	
	
	
//	reflex when:every(10#cycle){
//			loc_cars <- [];
//			ask normalcar{
//			add self.location to: loc_cars;
//			}
//		}
//	//北から南	
	reflex when:every(10#cycle){
		create mobcar number:1 {
			o <- no5.location;
			d <- no12.location;
			location <- o;
			loop while:true {
				current_path <- compute_path(graph:road_network,target:intersection(d));
				if current_path != nil {
					break;
				}
			}	
		}
	}
	//南から北
	reflex when:every(10#cycles){
		create mobcar number:1 {
			o <- no12.location;
			d <- no5.location;
			location <- o;
			loop while:true {
				current_path <- compute_path(graph:road_network,target:intersection(d));
				if current_path != nil {
					break;
				}
			}	
		}
	}
	
	reflex when:cycle=10{
		ask intersection where (each.node_id=37){
			write roads_in;
			loop i over:roads_in{
				write road(i).road_id;
			}
		}
	}
	 


	
//	reflex when:come_back_num = residence_num {
//		write string(come_back_num)+':all came back!!';
//		come_back_num <- 0;
//	}

//	reflex when:cycle=100{
//		ask intersection where (each.node_id=16){
//			stop[0]<-[];
//			is_traffic_signal <- false;
//		}
//	}
//	reflex when:cycle=200{
//		ask intersection where (each.node_id=16){
//			is_traffic_signal <-true;
//		}
//	}

	reflex when:cycle=100{
		ask intersection where (each.node_id = 16){
			write signal_type;
		}
	}
	
	reflex when:every(60#s){
		ask road{
			if car_num != 0 {
				current_ave_sp <- (speed_sum/car_num) with_precision 3;
			}else if car_num = 0 {
				current_ave_sp <- maxspeed;
			}
			
			sp_ratio <- current_ave_sp/maxspeed;
			
			if ave_speed_map = true{
				if  0.8 <= sp_ratio and sp_ratio <=1.0 and cycle != 0{
					color <- #green;
				}else if 0.6 <= sp_ratio and sp_ratio < 0.8 and cycle != 0 {
					color <- #lightgreen;
				}else if 0.4 <= sp_ratio and sp_ratio < 0.6 and cycle != 0{
					color <- #yellow;
				}else if 0.2 <= sp_ratio and sp_ratio < 0.4 and cycle != 0 {
					color <- #orange;
				}else if 0.0 <= sp_ratio and sp_ratio < 0.2 and cycle != 0{
					color <- #red;
				}else if cycle = 0 {
					color <- #grey;
				}
			}
			
			if jam_map = true{
				if 0.0 <= sp_ratio and sp_ratio < 0.2 and cycle != 0{
					color<-#red;
					//write car_num;
					//write current_ave_sp;
				}else if 0.2 <= sp_ratio and sp_ratio < 0.4 and cycle != 0{
					color<-#orange;
				}
			}
			
			car_num<-0;
			speed_sum<-0.0;
			
		}
	}

	
	
	
}//globalここまで







experiment traffic_change type:gui {
	output {
		display city_display type:3d{
			species road aspect:base;
			species building aspect:base;
			species intersection aspect:base;
			species normalcar aspect:base;
			species mobcar aspect:base;
			species residence_car aspect:base;
			species intersection;
			overlay position:{0,0} size:{200,100} background:#grey transparency:0.2 border:#black rounded:true {
				draw "時計" font:font("Helvetica", 20,#bold) at:{10,30} color:#black;
				draw string(current_date.year)+'/'+string(current_date.month)+'/'+string(current_date.day) font:font("Helvetica",20,#bold) at:{10,60} color:#black;
				draw string(current_date.hour)+':'+string(current_date.minute)+':'+string(current_date.second) font:font("Helvetica",20,#bold) at:{10,90} color:#black;
			}
		}
		
			display chart_display refresh: every(10#cycles) type: 2d{
			chart "customers_num" type: series size: {1,1} position: {10,10}{
				
				loop i over:shop_building{
					data string(i) value:i.human_num color:i.color marker:false;
				}
			
				}
			}
		
	}
	
}
//git/2024/10/22/14:33
//git/2024/10/22/14:40

