/**
* Name: Road
* Based on the internal empty template. 
* Author: HironariSasaki
* Tags: 
*/


model Road

import 'Main.gaml'

species road skills:[road_skill] {//schedules:[]{
	int road_id;
	int one_way;
	float maxspeed;
	int num_lanes;
	int p_lane_r;
	int m_lane_r;
	rgb color<-#grey;
	float width<-3.0;
	
	
	
	float length;
	float speed_sum<-0.0;
	int car_num<-0;
	float current_ave_sp;
	float sp_ratio ;
	
	bool is_thin <- false;
	
	int all_car_num<-0;
	list car_num_manage<-[];
	int count_time<-300;
	float vehicle_length <- 3.4;
	
	int current_car_num;
	
//	reflex when:every(600 #cycles){
//		if length(all_agents) != 0 {
//			write string(road_id)+":"+string(length)+"m :"+string(length(all_agents))+"台";
//			write string(vehicle_length*length(all_agents)+(5*(length(all_agents)-1)))+"/"+string(length);
//		
//		}
//	}


    //指定サイクルごとにリストに通行車数を追加。networkにも使用。
	reflex when:every(count_time #cycles){
		//write 'id'+string(road_id)+":"+string(all_car_num)+"台";
		car_num_manage <- car_num_manage + all_car_num;
		//write car_num_manage;
		all_car_num <- 0;
	}
	
	reflex when:every(1 #cycles){
		current_car_num <- length(all_agents);
	}
	
	aspect base {
		//draw shape color:color end_arrow:3;
		//draw string(maxspeed) color:#black font:font(10);
		if road_id_on = true {
			draw string(road_id) color:#blue font:font(16);	
		}
		
		
		if linked_road != nil {
			draw shape color:color width:2;
		}
		else if linked_road = nil {
			draw shape color:color width:1 end_arrow:5;
		}
		
	}
}

