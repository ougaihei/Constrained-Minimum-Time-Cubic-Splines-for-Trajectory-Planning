clc
clear all

%% Setting up the spline
ndof = 3;                                % Number of joints
init_time = [0,2,7,12]';                 % Initial time vector
q1 = [0, 2, 12, 5]';                     % Initial points vector (Joint 1)
q2 = [0, 3, 15, 13]';                    % Initial points vector (Joint 2)
q3 = [0, 5, 6, 1]';                      % Initial points vector (Joint 3)
q = [q1 q2, q3];                         % Initial points matrix
qdot_b1 = [0, 0]';                       % Spline boundary velocities (Joint 1)
qdot_b2 = [0, 0]';                       % Spline boundary velocities (Joint 2)
qdot_b3 = [0, 0]';                       % Spline boundary velocities (Joint 3)
qdot_b = [qdot_b1, qdot_b2, qdot_b3];    % Spline boundary velocities
qdot_max = [5, 7, 3];                   % Maximum velocity that can be reached                 
h0 = diff(init_time);                    % Knots vector 
w = max(abs(q(2:end,:) - q(1:end-1,:))./(repmat(qdot_max, [length(q)-1 1])))';

%% Setting up the spline knots optimization
options = optimoptions(@fmincon,'Algorithm','sqp');
[h,fval] = fmincon(@objfun, h0, [], [], [], [], w, h0,... 
   @(h)confuneqMultipleQs(h, ndof, q, qdot_b, qdot_max), options);

%% Resulting spline based on the optimized knots with given constraints.
new_time = zeros(length(h)+1, 1); % New knot vector
new_time (1) = 0;
for i=2:length(h)+1
    new_time(i) = new_time (i-1) + h(i-1);
end
for m=1:ndof
	[s0, s1, s2, s3] = cubic_spline(h, q(:,m), qdot_b(:,m)); % Generating spline constants
    figure
    plot(new_time, q(:,m), 'o');
    hold on
    plot_cubic_spline(new_time, s0, s1, s2, s3);
end
