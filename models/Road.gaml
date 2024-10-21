/**
* Name: Road
* Based on the internal empty template. 
* Author: HironariSasaki
* Tags: 
*/


model Road

import 'Main.gaml'

species road skills:[road_skill] schedules:[]{
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
	
	aspect base {
		//draw shape color:color end_arrow:3;
		//draw string(maxspeed) color:#black font:font(10);
		draw string(road_id) color:#blue font:font(16);
		
		if linked_road != nil {
			draw shape color:color width:2;
		}
		else if linked_road = nil {
			draw shape color:color width:1 end_arrow:5;
		}
		
	}
}

