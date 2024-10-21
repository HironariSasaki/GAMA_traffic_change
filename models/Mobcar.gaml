/**
* Name: Mobcar
* Based on the internal empty template. 
* Author: HironariSasaki
* Tags: 
*/


model Mobcar

import 'Main.gaml'
import 'Vehicle.gaml'


species mobcar parent:vehicle {
	
	point o;
	point d;
	path current_path;
	intersection o_node ;
	intersection d_node;
	int o_id;
	int d_id;		
	
	agent drived;
	float start_time;//道路に入った時間
	float end_time;//道路から抜けた時間
	int current_road_id;
	float drived_speed;
	rgb color<-#black;
	
	init {
		drive_ov <-true;
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
		}else  {
			do die;
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
		}
		start_time <- time;
		drived <- current_road;
	}
	

	
	aspect base {
		draw sphere(2#m) color:color;
	}
	
}

