function [car_cell] = parameters_loop(cP,aP,eP,DTp,Bp,tP)

% more elegant solution to loop through parameters (in comparison to nested
%   for loops)
% output car_cell: a cell containing a car for each possible combination of
%   parameters
    [mass,driver_weight,accel_driver_weight,wheelbase,weight_dist,track_width,wheel_radius,cg_height,...
    roll_center_height_front,roll_center_height_rear,R_sf,I_zz,cda,cla,distribution,cla_p_deg_p,D_p_deg_p,redline,shift_point,shift_time,torque_fn_index,...
    final_drive,drivetrain_efficiency,G_d1,G_d2_overrun,G_d2_driving,brake_distribution,max_braking_torque,gamma,p_i]...
    = ndgrid(cP.mass,cP.driver_weight,cP.accel_driver_weight,cP.wheelbase,cP.weight_dist,cP.track_width,cP.wheel_radius,cP.cg_height,...
    cP.roll_center_height_front,cP.roll_center_height_rear,cP.R_sf,cP.I_zz,aP.cda,aP.cla,aP.distribution,aP.cla_p_deg_p,aP.D_p_deg_p,eP.redline,eP.shift_point,...
    eP.shift_time,eP.torque_fn_index,DTp.final_drive,DTp.drivetrain_efficiency,DTp.G_d1,DTp.G_d2_overrun,DTp.G_d2_driving,Bp.brake_distribution,...
    Bp.max_braking_torque,tP.gamma,tP.p_i,tP.friction_scaling_factor);

for i = 1:numel(mass)
    aero = Aero(cda(i),cla(i),distribution(i), cla_p_deg_p(i), D_p_deg_p(i));
    powertrain = Powertrain(redline(i),shift_point(i),eP.gears,eP.primary_reduction,eP.torque_fn{torque_fn_index(i)},shift_time(i),...
        final_drive(i),wheel_radius(i),drivetrain_efficiency(i),...
                G_d1(i),G_d2_overrun(i),G_d2_driving(i),brake_distribution(i),max_braking_torque(i));
    tire = Tire2(gamma(i),p_i(i),tP.Fx_parameters,tP.Fy_parameters,tP.friction_scaling_factor); 
    car = Car(mass(i)+driver_weight(i),wheelbase(i),weight_dist(i),track_width(i),wheel_radius(i),...
        cg_height(i),roll_center_height_front(i),roll_center_height_rear(i),R_sf(i),I_zz(i),aero,...
        powertrain,tire); 
    accel_car = Car(mass(i)+accel_driver_weight(i),wheelbase(i),weight_dist(i),track_width(i),...
        wheel_radius(i),cg_height(i),roll_center_height_front(i),roll_center_height_rear(i),R_sf(i),...
        I_zz(i),aero,powertrain,tire); 
    car_cell{i,1} = car;
    car_cell{i,2} = accel_car;
end
