/**
* Name: Residencecar
* Based on the internal empty template. 
* Author: HironariSasaki
* Tags: 
*/


model Residencecar

import 'Main.gaml'
import 'Vehicle.gaml'

global {
	int die_num<-0;
	list<int> prob_num <-[0,0,0];
	int count_car<-0;
}

species residence_car parent:vehicle {
	rgb color <- #blue;
	int car_size<-3;
	point o; //始点
	point d; //目的地
	building g; //目的地の建物
	date d_time;
	int restart_during_time;
	
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
	
	building residence_place;
	building shop_place;
	building g_b;
	map<float,building> shop_length;
	list<building> sorted_shop;

	
	
	bool is_drive<-false;
	bool go_home<-false;
	path to_home<- nil;
	int calc_num<-0;
	
	int go_hour<-1000;
	int go_minute<-1000;
	int go_second<-1000;
	
	init {
		//drive_ov <- true;
		vehicle_length <- 3.4;
		max_speed <- 60 #km/#h;
		max_acceleration <- 3.5;
		
	}
		
	//店に行く時間を午前0:00:00に決める
	reflex when:current_date.hour = 13 and
				current_date.minute = 0 and 
				current_date.second = 10 {
					
			//go_hour <- rnd(14,16,1);
			go_hour <- 13;
			go_minute <- rnd(1,59,1);
			go_second <- rnd(0,59,1);

			int shop_num <- length(sorted_shop);
			if shop_num >=2{
				float shop_select_prob <- rnd(0.0,1.0,0.1);
	 			if shop_select_prob <= 0.7{
	 				shop_place <- sorted_shop[0];
	 			}else{
	 				int index <- rnd(1,length(sorted_shop)-1,1);
	 				shop_place <- sorted_shop[index];
	 			}
			}else if shop_num=1{
				shop_place <- sorted_shop[0];
			}else if shop_num=0{
				color<-#red;
			}
			
		if shop_place != nil{
			//write "出発時刻："+string(go_hour)+":"+string(go_minute)+":"+string(go_second);
		}
	}
	
	
	reflex when:(go_hour != 1000 and go_minute != 1000 and go_second != 1000) and
				(current_date.hour = go_hour and current_date.minute = go_minute and current_date.second = go_second) and
				 shop_place != nil{
		
		g_b <- shop_place;
		d <- shop_place.location;


		loop while:calc_num < 10 {
			current_path <- compute_path(graph: road_network,target:intersection(d));
			calc_num <- calc_num + 1;
			if current_path != nil {
				calc_num <- 0;
				is_drive <- true;
				break;
			}else if current_path = nil and calc_num = 10 {
				calc_num <- 0;

				break;
			}
		}

		//is_drive <- true;
	}
	
	reflex {
		if current_road != nil {
			ask road(current_road){
				myself.max_speed<- maxspeed #km/#h;
			}
		}
	}
	
	reflex when:final_target != nil and is_drive = true {
		do drive();
	}
	
	//店についたときの処理
	reflex when:final_target = nil and is_drive = true and g_b.type = 'shop'  {
		is_drive <- false;
		location <- d;
		do unregister;
		restart_during_time <- rnd(cycle + 1200, cycle + 2400, 60);

		ask shop_place{
			human_num <- human_num+1;
			if name = 'shop1' {
				chart_value1 <- human_num;
			}else if name = 'shop2'{
				chart_value2 <- human_num;
			}else if name = 'shop3'{
				chart_value3 <- human_num;
			}
		}
	}
	
		//店から家へ変える処理
	reflex time_togo when:(restart_during_time = cycle) and (restart_during_time != 0){
		d <- residence_place.location;
		g_b <- residence_place;
		
		loop while:calc_num < 10 {
			current_path <- compute_path(graph: road_network,target:intersection(d));
			calc_num <- calc_num + 1;
			if current_path != nil {
				calc_num <- 0;
				to_home<-current_path;
				go_home <- true;
				//write '2';
				is_drive <- true;
				break;
			}else if current_path = nil and calc_num = 10 {
				calc_num <- 0;
				die_num <- die_num + 1;
				//上でunregisterしてるから大丈夫
				//write "I'll do warp!"+":"+string(die_num);
				location <- residence_place.location;
				break;
			
				//do die;
			}
		}
		ask shop_place{
			human_num <- human_num-1;		
		}
		
		//to_home <- current_path;
		//is_drive <- true;
	}
	
	//店から帰ってきたときの処理
	reflex when:final_target = nil and is_drive = true and go_home = true {//location != shop_place.location  {
		is_drive <- false;
		location <- d;
		go_home <- false;
		do unregister;
		to_home <- nil;
		//write 'come back home';
		come_back_num <- come_back_num + 1;
		
	}
	
	reflex start when:is_drive = true and drived = nil and current_road != nil {
		start_time <- time;
		drived <- current_road;
	}
	
	reflex drived_info when: is_drive = true and drived != nil and current_road != drived{
		end_time <- time-start_time ;
		ask road(drived){
			myself.drived_speed <-((length/myself.end_time)*3.6) with_precision 3;
			//write myself.drived_speed;
			speed_sum <- speed_sum + myself.drived_speed;
			car_num <- car_num + 1;
			all_car_num <- all_car_num + 1;
		}
		//write drived_speed;
		start_time <- time;
		drived <- current_road;
	}
	
	
//	reflex when: drive_ov = true and distance_to_goal < 8#m {
	
	aspect base {
		draw circle(car_size) color:color;
//		if to_home != nil {
//			draw self.to_home.shape color:#red width:2;
//		}
	
	}
}



