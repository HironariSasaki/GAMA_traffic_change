/**
* Name: Normalcar
* Based on the internal empty template. 
* Author: HironariSasaki
* Tags: 
*/


model Normalcar

import 'Main.gaml'
import 'Vehicle.gaml'

species normalcar parent:vehicle {
	
	point o; //始点
	point d; //目的地
	point old_o;
	point old_d;
	intersection o_node;
	intersection d_node;
	int o_id;
	int d_id;
	building g; //目的地の建物
	date d_time;
	int restart_during_time;
	rgb car_color<-#yellow;
	
	agent drived;
	float start_time;//道路に入った時間
	float end_time;//道路から抜けた時間
	int current_road_id;
	float drived_speed;
	
	path path_data;//走行しているpathをストック
	float expect_time;//予想到着時間
	float path_start;//pathの走行開始時間
	float path_end;//pathの走行にかかった時間
	float error_rate;//予想到着時間と計測到着時間との誤差率
	bool test <- true;
	
	bool citizen<-false;
	building residence_place;
	building shop_place;
	
	init {
		drive_ov <- true;
		vehicle_length <- 3.4;
		max_speed <- 60 #km/#h;
		max_acceleration <- 3.5;
	}
	
	reflex move_action {
		if current_road != nil {
		ask road(current_road){
			myself.max_speed <- maxspeed #km/#h;
			}
		}
		
		if final_target != nil {
			do drive();
		}else if final_target = nil {
			o_node <- d_node;
			old_d <- d;
			o <- old_d;
			o_id <- o_node.node_id;
			
			d_node <- one_of(intersection where (each.node_id != o_node.node_id));
			d <- d_node.location; 
			d_id<-d_node.node_id;
			
			loop while:true{
				current_path <- compute_path(graph: road_network, target: intersection(d)); 
				
				if current_path != nil{
					break;
				}else if current_path = nil {
					write 'path nil';
					write 'before:'+string(d);
					write d_id;
					d_node <- one_of(intersection where (each.node_id != o_node.node_id));
					d <- d_node.location;
					write 'change:'+string(d);
					d_id<-d_node.node_id;
					write d_id;
				}
			}
			
			do drive();
		}
	}
	
	reflex start when:drive_ov = true and drived = nil and current_road != nil {
		start_time <- time;
		drived <- current_road;	
	}
	
	
	
	reflex drived_info when: drive_ov = true and drived != nil and current_road != drived{
		
		end_time <- time-start_time ;
		ask road(drived){
			myself.drived_speed <-((length/myself.end_time)*3.6) with_precision 3;
			speed_sum <- speed_sum + myself.drived_speed;
			car_num <- car_num + 1;
			all_car_num <- all_car_num + 1;
		}
		start_time <- time;
		drived <- current_road;
	}
	
	aspect base {
		if citizen = false {
			draw circle(3) color:car_color border:true;
		}else {
			draw circle(3) color:#red border:true;
		}
		
	}
	
}

