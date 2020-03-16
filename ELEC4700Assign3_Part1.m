% Creator: Rudi Hidvary 
% Student Number: 101037815
% Class: ELEC 4700 
% Document: Assignment 3

% MODEL INSTRUCTIONS
% Please first run the simulation with the parameters provided before playing with them to see
% the simulation run as i intended it to. Most the of the model parameters
% are self explanatory but there is some help if needed.

% Clears all of the variables, the command line, and closes all previous
% graphs 
close all
clear
clc

% Constants for Model 
m0 = 9.11e-31; % electron mass (kg)
k = 1.381e-23; % boltzmans constant
q = 1.602e-19; % elementary charge (C) 

% Model Parameters
% ------------------------------------------------------------------------
% ------------------------------------------------------------------------
% These parameters can be changed to see the effect they have on the
% simulation 
length = 200e-9;        % size of simulation in x dierection (m)
height = 100e-9;        % size of simulation in y direction (m)
Lbottle = 100e-9;        % sets the size of the bottleneck length
Hbottle = 20e-9;        % sets the size of the bottlenck height
temperature = 300;      % temperature of the system in kelvin
me = 0.26*m0;           % Effective mass of an electron in our simulation
e_num = 100;         % Number of electrons in the simulation 
simlength = 1000;         % Sets the number of iterations the simulation undergoes, 1 interation is 1 femtosecond
timestep = 2e-15;           % Sets the length in real time that corresponds to the duratoin of a simulation length
graph_pause = 3;        % Length graph is presented in a figure 
sim_pause = 0.00001;          % Sets the length of time that the simulation pauses for at each step 
bin_num =  12;          % Histogram bin number 
bin_num_3D = 10;       % gives the number of bins for the 3d histogram electron density plot
% Choose the type of boundary conditions for the third simulation 
boundary_type =  0; % 0 is for specular 1 for diffusive boundary type
% Setting whether or not the electron density is displayed as a movie. If
% the value is 0 then it will just show the final electron density but if
% the value is 1 it will play the electron density as a movie in real time.
e_density_movie = 0;
% As with the electron density map, the temperature map can be played as a
% movie as well, this is computationally expensive and not recommended for
% large numbers of particles or iterations.
temp_movie = 0;
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------

%XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
% Code to setup the voltage across the plot as well as the electric field
L = 200; % using 1 nanometer sections 
W = 100;
V0 = 0.1; % Initial voltage is 0.1 volts which will be applied to one end of the simulation while the other is held at ground and the sides are free nodes
VX1 = V0;
VXL = 0;
gnd = 0;

G = sparse(W*L,W*L); 
B = zeros(W*L,1);

% Using  conduction of 1 acroos the entire plate for this case
% Loop used to initialize the matrix G and B to find V vector 
for x = 1:L
    for y = 1:W
        n = (x-1)*W+y; % Used to place correct values in the G matrix
        nxm = (x-2)*W+y;
        nxp = (x)*W+y;
        nym = (x-1)*W+(y-1);
        nyp = (x-1)*W+(y+1);         
        if(x == 1) % Case for lower X boundary
            B(n,1) = VX1;
            G(n,n) = 1;
        elseif(x == L) % Case for upper X boundary 
            B(n,1) = VXL;
            G(n,n) = 1;
        else % Case for calculated nodes
            G(n,n) = -4;
            G(n,nxm) = 1;
            G(n,nxp) = 1;
            G(n,nym) = 1;
            G(n,nyp) = 1;
            B(n,1) = 0;
        end
    end
end

% Solve for the voltages at each node 
V = G\B; % Using backslash to simplfy code and speed up calculations

% Map the voltage vector to a matrix so that it can be viewed
for x = 1:L
    for y = 1:W
        n = (x-1)*W+y;
        map(y,x) = V(n,1);
    end
end


% Electric Field Calculations 
[Ex,Ey] = gradient(map);
Jx = (-Ex);
Jy = (-Ey);

% Question 1.a
%averageEField = mean(mean(sqrt((Ex.^2)+(Ey.^2))));
averageEField = (0 - 0.1)/(200e-9);
E = averageEField;
fprintf('The Uniform Electric Field Was Found to be: E = %e (Newtons/Coulomb) \n',E)

% Question 1.b
% Force Calculations 
force = -q*E;
F = force;
fprintf('The Force on Each Electron Was Found to be: F = %e (Newtons) \n',F)

% Question 1.c
% Acceleration Calculations 
acceleration = F/me;
a = acceleration;
fprintf('The Acceleration of Each Electron Was Found to be: a = %e (m/s^2) \n',a)

% end of Laplace setup
%XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX


% Initial Calculations 
% THERMAL VELOCITY
thermal_velocity = sqrt((2*k*temperature)/me); % velocity in (m/s)
fprintf('QUESTION 1\n')
fprintf('The thermal velocity of all of the particles Vth = %d',thermal_velocity);
fprintf('(m/s) \n')

% Initializing the Simulation Parameters 
initial_xposition = length*rand(e_num,1); % Sets the initial x positions as a vector of randomly selected numbers over the length of the simulation
initial_yposition = height*rand(e_num,1); % Sets the initial y position as a vector of randomly selected numbers over the length of the simulation
theta = 2*pi*rand(e_num,1); % Initializes a vector of random angles the size of the number of electrons
initial_xvelocity = thermal_velocity.*cos(theta).*ones(e_num,1); % Sets the initial velocity as the thermal temperature  
initial_yvelocity = thermal_velocity.*sin(theta).*ones(e_num,1); % 

% Assigning each particle a random colour from the rgb grid so they can be
% identified in the simulation
colour_specs = rand(e_num,3); 

% Timestep is the amount of time between each interval of the calculations 

old_xposition = initial_xposition; % Sets the 
old_yposition = initial_yposition;
new_xvelocity = initial_xvelocity;
new_yvelocity = initial_yvelocity;

initial_velocity = (mean(initial_xvelocity.^2)) + (mean(initial_yvelocity.^2));
initial_temp = (initial_velocity*me)/(2*k);
temp = [initial_temp];


% Simulation loop that continually updates the simulation at each timestep
% and calculates the new positions of the particles by using time and
% velocity. At each iteration the average velocity is found and used to
% calculate the systems temperature
for time = 1:simlength 
    % The average velocity and the temperature of the system at each time
    % step are calculated to be used in plotting and finding the mean free
    % path given the average time between collisions 
    averageVel = (mean(new_xvelocity.^2)) + (mean(new_yvelocity.^2)); 
    temp(time) = (averageVel*me)/(2*k); 
    
    % Updating the new positions using the velocity
    new_xposition = old_xposition + new_xvelocity*timestep;
    new_yposition = old_yposition + new_yvelocity*timestep;

    % Boundary Conditions being imposed for particle wrap around and
    % reflectoin at the tep and bottom of the simulation surface
    % Logical index parameters that check if a praticle has left the bounds
    % and how these cases are handled
    overboundx = new_xposition > 200e-9;
    underboundx = new_xposition < 0;
    overboundy = new_yposition > 100e-9;
    underboundy = new_yposition < 0;
    new_xposition(overboundx) = new_xposition(overboundx) - 200e-9;  
    new_xposition(underboundx) = new_xposition(underboundx) + 200e-9;
    new_yvelocity(overboundy) = -new_yvelocity(overboundy);
    new_yvelocity(underboundy) = -new_yvelocity(underboundy);
    
    old_xposition = new_xposition;
    old_yposition = new_yposition;
    
end
hold off

time = 0:simlength;
temp = [initial_temp temp];

% Question 1.b MEAN FREE PATH
% Mean Free Path Calculation 
Tmn = 0.2e-12; % Mean time between collisions 
MFP_Q1 = averageVel*Tmn; % Mean didtance travelled before collision occurs using the given mean time
fprintf('The average distance a particle travels before a collision occurs MFP =  %d',MFP_Q1)
fprintf('(m) \n')
%-------------------------------------------------------------------------------------------------------------------------------------------



%------------------------------------------------------------------------------------------------------------------------------------------------
% Question 2.a

% Initial Calculations 
% The thermal velocity needs to be made random and assigned to each
% variable. The random distribution is plotted in a histogram which shows
% the randomly generated distribution. This is achieved by generating two 
% random distibutions and finding the square of the sum of squares to get 
% the maxwell-boltzmann distribution 
thermal_velocity = sqrt((2*k*temperature)/me); % velocity in (m/s)
distribution1 = randn(e_num,1)*(thermal_velocity/sqrt(2));
distribution2 = randn(e_num,1)*(thermal_velocity/sqrt(2));
maxwell_boltzmann_dist = sqrt((distribution1.^2)+(distribution2.^2));
random_velocity = maxwell_boltzmann_dist;

% Plot of the histogram of the distributed velocities 
figure(1)
histogram(random_velocity,bin_num);
title('Thermal Velocity Distribution')
xlabel('Random Thermal Velocity (m/s)')
ylabel('Number of Particles Within Range')
grid on
pause(graph_pause)

% Initializing the Simulation Parameters 
% Setting the initial x and y velocities to values from the randomly
% generated distribution
initial_xposition = length*rand(e_num,1); % Sets the initial x positions as a vector of randomly selected numbers over the length of the simulation
initial_yposition = height*rand(e_num,1); % Sets the initial y position as a vector of randomly selected numbers over the length of the simulation
theta = 2*pi*rand(e_num,1); % Initializes a vector of random angles the size of the number of electrons
initial_xvelocity = random_velocity.*cos(theta).*ones(e_num,1); % Sets the initial velocity as a value from the distribution that gives thermal velocity
initial_yvelocity = random_velocity.*sin(theta).*ones(e_num,1); % 

% Initial position plot 
figure(2)
scatter(initial_xposition, initial_yposition, 'ko')
hold on
title('Initial Particle Positions')
xlabel('X Position (m)')
ylabel('Y Position (m)')
axis([0 200e-9 0 100e-9])
grid on
pause(graph_pause)

new_xposition = initial_xposition;
new_yposition = initial_yposition;
new_xvelocity = initial_xvelocity;
new_yvelocity = initial_yvelocity;

initial_velocity = (mean(new_xvelocity.^2)) + (mean(new_yvelocity.^2));
initial_temp = (initial_velocity*me)/(2*k);
temp = [initial_temp];

% Scattering Equation to get a probability value to be compared to 
Pscatter = (1-exp(-(timestep/Tmn))); % Used to compare to random variable for scattering chance

% Mean Free Path and Mean Collision Time Equation collision number
% initializatoin
collision_num = 0; 

% Question 2.b
% Simulation loop that continually updates the simulation at each timestep
% and keeps track of the number of collisoins that occur due to scattering
% and records the temperature of the system at each timestep.
for time = 1:simlength  
    % Electron scattering and reevaluation of velocity distribution at each
    % time step to get more random values than using the same distribution
    % that is outside of the loop
    rand_threshold = rand(e_num,1); % Sets a vector of random numbers for each electron to be compared to the scattering value
    distribution1 = randn(e_num,1)*(thermal_velocity/sqrt(2));
    distribution2 = randn(e_num,1)*(thermal_velocity/sqrt(2));
    maxwell_boltzmann_dist = sqrt((distribution1.^2)+(distribution2.^2));
    new_velocity = maxwell_boltzmann_dist;
    
    % using a for loop to check each of the electrons in the system to see
    % if scattering occured by using a randomly generated number for each
    % of the particles, then rethermalizing the velocites if scatrering has occured 
    for index = 1:e_num
        if rand_threshold(index) < Pscatter 
            theta = 2*pi*rand(1);
            new_xvelocity(index) = cos(theta)*new_velocity(index);  
            new_yvelocity(index) = sin(theta)*new_velocity(index);
            %Counts the number of collisions that have occured to be used
            %to calculate the mean time between collisions 
            collision_num = collision_num + 1; 
        end
    end
    % All of the particles are then accelerated due to the field 
    new_xvelocity = new_xvelocity + a*timestep;
    
    % Updating the new positions at each timestep
    new_xposition = new_xposition + new_xvelocity*timestep;
    new_yposition = new_yposition + new_yvelocity*timestep;

    % Boundary Conditions being imposed 
    overboundx = new_xposition > 200e-9;
    underboundx = new_xposition < 0;
    overboundy = new_yposition > 100e-9;
    underboundy = new_yposition < 0;
    new_xposition(overboundx) = new_xposition(overboundx) - 200e-9;  
    new_xposition(underboundx) = new_xposition(underboundx) + 200e-9;
    new_yvelocity(overboundy) = -new_yvelocity(overboundy);
    new_yvelocity(underboundy) = -new_yvelocity(underboundy);

    % Plotting the updating positions of the particle trajectories
    % Question 2.b 2D PLOT OF TRAJECTORIES
    scatter(new_xposition,new_yposition,2,colour_specs)
    title('Simulation Number 2')
    xlabel('Distance (nm)')
    ylabel('Distance (nm)')
    axis([0 200e-9 0 100e-9]) 
    pause(sim_pause)
    
    % finding the average velocities of all of the particles
    averageVel = (mean(new_xvelocity.^2)) + (mean(new_yvelocity.^2));
    % Collect value of temperature over the simulation length
    temp(time) = (averageVel*me)/(2*k);
end
hold off

% TEMPERATURE PLOT
time = 0:simlength;
temp = [initial_temp temp];
% Plotting the Temperature of the system
figure(3)
plot(time*timestep,temp)
title('Average Temperature Over Time')
xlabel('Time (s)')
ylabel('Simulation Temperature (K)')
grid on
pause(graph_pause)

% Calculating the average amount of time between collisions by using the
% total time the simulation ran for and the number of particles in the
% simulation divided by the amount of collisions to get the average time
% betwen collisions
calculated_Tmn_Q2 = (timestep*simlength*e_num)/(collision_num);
% Once the average time between colliosns is calculated, then the mean free
% path can be found by mulitpling by the average velocity of all of the
% particles in the simulation
calculated_MFP_Q2 = calculated_Tmn_Q2*averageVel;

% Calculating the percent error of the mean time and mean free path
percent_error_Tmn = (100*abs(calculated_Tmn_Q2-Tmn))/Tmn;
percent_error_MFP = (100*abs(calculated_MFP_Q2-MFP_Q1))/MFP_Q1;

% Printing the answer statments 
fprintf('\nQUESTION 2')
fprintf('\nThe amount of collisions that occured collisions = %d ',collision_num)
fprintf('\nThe average time between collisions was found to be %d',calculated_Tmn_Q2)
fprintf(' (s)\nComparing this to the given value of %d (s)',Tmn)
fprintf('\nThe percent error of the average time is %f percent',percent_error_Tmn)
fprintf('\nThe mean free path was calculated to be %d',calculated_MFP_Q2)
fprintf(' (m)\nComparing this to the previously calculated value of %d (m)\n',MFP_Q1)
fprintf('The percent error of the MFP is %f percent\n',percent_error_MFP)


% Plotting a 3D histogram for the elecron density over the surface of the simulation 
if(e_density_movie == 1)
    for a = 1:simlength
        figure(4)
        hist3([x_position_hist(:,a) y_position_hist(:,a)],[bin_num_3D bin_num_3D])
        colormap jet;
        colorbar;
        set(gcf,'renderer','opengl');
        set(get(gca,'child'),'FaceColor','interp','CDataMode','auto');
        title('Electron Density Visual Map')
        xlabel('Distance in X Direction (m)')
        ylabel('Distance in Y Direction (m)')
        zlabel('number of Electron in Area')
        pause(sim_pause)
    end
else 
    figure(4)
        hist3([new_xposition new_yposition],[bin_num_3D bin_num_3D])
        colormap jet
        colorbar
        set(gcf,'renderer','opengl');
        set(get(gca,'child'),'FaceColor','interp','CDataMode','auto');
        title('Electron Density Visual Map')
        xlabel('Distance in X Direction (m)')
        ylabel('Distance in Y Direction (m)')
        zlabel('number of Electron in Area')
        pause(graph_pause)
end

% Calculates the velocity of each of the particles so thaty they can be
% made into a temperature map.
particleVel = sqrt((new_xvelocity.^2) + (new_yvelocity.^2));
particleTemp = (particleVel.*me)./(2*k);

% Plots the colour spectrum for the particles for their calculated
% temperature and a bar to help dicern the temperature of a given
% particle. There is a choice between playing the temperature as a movie of
% the simulation or it can be just displayed as the final values of
% velocity and position.
if(temp_movie == 1)
    figure(5)
    for a = 1:simlength
        scatter(x_position_hist(:,a), y_position_hist(:,a),12,particle_temp_hist(:,a))
        colormap jet
        colorbar
        grid on
        title('Coloured Temperature Map of Particles')
        xlabel('Distance in X Direction (m)')
        ylabel('Distance in Y Direction (m)')
        axis([0 200e-9 0 100e-9])
        pause(sim_pause)
    end
else
    figure(5)
    scatter(new_xposition,new_yposition,12,particleTemp)
    colormap jet
    colorbar
    grid on
    title('Coloured Temperature Map of Particles')
    xlabel('Distance in X Direction (m)')
    ylabel('Distance in Y Direction (m)')
    axis([0 200e-9 0 100e-9])
    pause(graph_pause)
end


%XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
G = sparse(W*L,W*L); 
B = zeros(W*L,1);
conductionTypeA = 1;
conductionTypeB = 0.01;
conduction = conductionTypeA.*ones(W,L);

% Defining the boundaries for the bottleneck
XUpperBound = 0.75*L;
XLowerBound = 0.25*L;
YUpperBound = 0.6*W;
YLowerBound = 0.4*W;

% Sets all of the bottleneck conduction values 
for x = 1:L
    for y = 1:W
        if((x <= XUpperBound && x >= XLowerBound && y <= YLowerBound) || (x <= XUpperBound && x >= XLowerBound && y >= YUpperBound))
            conduction(y,x) = conductionTypeB;
        end
    end
end

% Set the voltages at the edge cases
V0 = 0.1;
VX1 = V0;
VXL = 0;
VY1 = 0;
VYW = 0;

% Loop used to initialize the matrix G and B to find V vector 
for x = 1:L
    for y = 1:W
        n = (x-1)*W+y; 
        nxm = (x-2)*W+y;
        nxp = (x)*W+y;
        nym = (x-1)*W+(y-1);
        nyp = (x-1)*W+(y+1);         
        if(x == 1)
            B(n,1) = VX1;
            G(n,n) = 1;
        elseif(x == L)
            B(n,1) = VXL;
            G(n,n) = 1;
        elseif(y == 1)
            cxm = (conduction(y,x) + conduction(y,x-1))/2;
            cxp = (conduction(y,x) + conduction(y,x+1))/2;
            cyp = (conduction(y,x) + conduction(y+1,x))/2;
            
            G(n,n) = -(cxm+cxp+cyp);
            G(n,nxm) = cxm;
            G(n,nxp) = cxp;
            G(n,nyp) = cyp;
            
            B(n,1) = VY1;
        elseif(y == W)  
            cxm = (conduction(y,x) + conduction(y,x-1))/2;
            cxp = (conduction(y,x) + conduction(y,x+1))/2;
            cym = (conduction(y,x) + conduction(y-1,x))/2;
            
            G(n,n) = -(cxm+cxp+cym);
            G(n,nxm) = cxm;
            G(n,nxp) = cxp;
            G(n,nym) = cym;
       
            B(n,1) = VYW;
        else % Calculated 
            cxm = (conduction(y,x) + conduction(y,x-1))/2;
            cxp = (conduction(y,x) + conduction(y,x+1))/2;
            cyp = (conduction(y,x) + conduction(y+1,x))/2;
            cym = (conduction(y,x) + conduction(y-1,x))/2;
            
            G(n,n) = -(cxm+cxp+cym+cyp);
            G(n,nxm) = cxm;
            G(n,nxp) = cxp;
            G(n,nym) = cym;
            G(n,nyp) = cyp;
            B(n,1) = 0;
        end
    end
end

% solve for the voltage vector
V = G\B;

% Loop to map answer vector to a matrix to be plotted
for x = 1:L
    for y = 1:W
        n = (x-1)*W+y;
        map(y,x) = V(n,1);
    end
end

% Using the gradient function to determine the electric field 
[Ex,Ey] = gradient(map);


% Plotting the conduction
figure(6)
surf(conduction)
title('Conduction Value')
xlabel('X Direction')
ylabel('Y Direction')
zlabel('Conduction Value')
colorbar
grid on 
pause(graph_pause)

% Plotting the voltage 
figure(7) 
surf(map)
title('Voltage Over Varying Conduction')
xlabel('X Direction')
ylabel('Y Direction')
zlabel('Voltage')
grid on 
colormap jet
colorbar
pause(graph_pause)

% Plotting the electric field 
figure(8) 
quiver(-Ex,-Ey,'b')
title('Electric Field')
xlabel('X Direction')
ylabel('Y Direction')
grid on 
pause(graph_pause) 

%XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

% Initial Calculations 
% The thermal velocity needs to be made random and assigned to each
% variable. The random distribution is plotted in a histogram which shows
% the randomly generated distribution.
thermal_velocity = sqrt((2*k*temperature)/me); % velocity in (m/s)
distribution1 = randn(e_num,1)*(thermal_velocity/sqrt(2));
distribution2 = randn(e_num,1)*(thermal_velocity/sqrt(2));
maxwell_boltzmann_dist = sqrt((distribution1.^2)+(distribution2.^2));
random_velocity = maxwell_boltzmann_dist;

% Plotting the histogram of the randomly generated distribution 
figure(9)
histogram(random_velocity,bin_num);
title('Thermal Velocity Distribution')
xlabel('Random Thermal Velocity (m/s)')
ylabel('Number of Particles Within Range')
grid on
pause(graph_pause)

% Setting whether the boundaries are specular = 0 or diffusive = 1
% boundary_type = 0; % Specular
% boundary_type = 1; % Diffusive

% Initializing the Simulation Parameters 
initial_xposition = length*rand(e_num,1); % Sets the initial x positions as a vector of randomly selected numbers over the length of the simulation
initial_yposition = height*rand(e_num,1); % Sets the initial y position as a vector of randomly selected numbers over the length of the simulation

% Checking the boundaries and marking the particles that have spawned
% inside the restrcted region.
inboundx = (initial_xposition < ((length/2)+(Lbottle/2))) & (initial_xposition > ((length/2)-(Lbottle/2)));
inboundy = (initial_yposition < ((height/2)-(Hbottle/2))) | (initial_yposition > ((height/2)+(Hbottle/2)));
inbound = inboundx & inboundy;

% Using a while loop to reinitialize any of the particles that have spawned in the restriced region 
while(max(inbound) > 0)
    initial_xposition(inbound) = rand(size(initial_xposition(inbound),1),1)*length;
    initial_yposition(inbound) = rand(size(initial_yposition(inbound),1),1)*height;
    % recheck the boundaries to see if there are still particles that have
    % spawned inside the restriced regions. 
    inboundx = (initial_xposition < ((length/2)+(Lbottle/2))) & (initial_xposition > ((length/2)-(Lbottle/2)));
    inboundy = (initial_yposition < ((height/2)-(Hbottle/2))) | (initial_yposition > ((height/2)+(Hbottle/2)));
    inbound = inboundx & inboundy;
end

% Initialize random velocities for each of the particles given the random
% distribution that was generated
theta = 2*pi*rand(e_num,1); % Initializes a vector of random angles the size of the number of electrons
initial_xvelocity = random_velocity.*cos(theta).*ones(e_num,1); % Sets the initial velocity as a value from the distribution that gives thermal velocity
initial_yvelocity = random_velocity.*sin(theta).*ones(e_num,1); % 

% Plot the Electon density map at the beginning of the simulation
figure(100)
subplot(1,2,1)
hist3([initial_xposition initial_yposition],[bin_num_3D bin_num_3D])
colormap jet
colorbar
set(gcf,'renderer','opengl');
set(get(gca,'child'),'FaceColor','interp','CDataMode','auto');
title('Electron Density Visual Map')
xlabel('Distance in X Direction (m)')
ylabel('Distance in Y Direction (m)')
zlabel('number of Electron in Area')
pause(graph_pause)

% Plots the initial positions of the particles 
figure(10)
scatter(initial_xposition, initial_yposition, 'ko')
hold on
rectangle('Position',[((length-Lbottle)/2) 0 Lbottle ((height-Hbottle)/2)])
rectangle('Position',[((length-Lbottle)/2) ((height+Hbottle)/2) Lbottle ((height-Hbottle)/2)])
title('Initial Particle Positions')
xlabel('X Position (m)')
ylabel('Y Position (m)')
axis([0 200e-9 0 100e-9])
grid on
pause(graph_pause)

new_xposition = initial_xposition;  
new_yposition = initial_yposition;
new_xvelocity = initial_xvelocity;
new_yvelocity = initial_yvelocity;

initial_velocity = (mean(new_xvelocity.^2)) + (mean(new_yvelocity.^2));
initial_temp = (initial_velocity*me)/(2*k);
temp = [initial_temp];

% Scattering Equations
Pscatter = (1-exp(-(timestep/Tmn))); % Used to compare to random variable for scattering chance
collision_num = 0;

old_xposition = new_xposition;  
old_yposition = new_yposition;

if(e_density_movie == 1 || temp_movie == 1)
    x_position_hist = [ones(e_num,simlength)];
    y_position_hist = [ones(e_num,simlength)];
    particle_velocity_hist = [ones(e_num,simlength)];
    particle_temp_hist = [ones(e_num,simlength)];
end
    


% Simulation loop that continually updates the simulation at each timestep
% and calculates the average velocity
for time = 1:simlength 
    
    % Assign correct acceleration as a result of the electric field 
    for count = 1:e_num
        X = ceil((10^9)*new_xposition(count));
        Y = ceil((10^9)*new_yposition(count));
        if(X<=0||Y<=0||X>=201||Y>=101)
        else
        EX = (10^9)*Ex(Y,X);
        EY = (10^9)*Ey(Y,X);
        FX = -q*EX;
        FY = -q*EY;
        AX = FX/me;
        AY = FY/me;
        new_xvelocity(count) = new_xvelocity(count) + AX*timestep;
        new_yvelocity(count) = new_yvelocity(count) + AY*timestep;
        end
    end
    
    
    % Electron scattering and reevaluation of velocity
    rand_threshold = rand(e_num,1); % Sets a vector of random numbers for each electron
    distribution1 = randn(e_num,1)*(thermal_velocity/sqrt(2));
    distribution2 = randn(e_num,1)*(thermal_velocity/sqrt(2));
    maxwell_boltzmann_dist = sqrt((distribution1.^2)+(distribution2.^2));
    new_velocity = maxwell_boltzmann_dist;
    for index = 1:e_num 
        if rand_threshold(index) < Pscatter 
            theta = 2*pi*rand(1);
            new_xvelocity(index) = cos(theta)*new_velocity(index);  
            new_yvelocity(index) = sin(theta)*new_velocity(index);
            %Counts the number of collisions that have occured to be used
            %to calculate the mean time between collisions 
            collision_num = collision_num + 1;
        end
    end
    
    new_xvelocity = new_xvelocity + a*timestep;    
    
    new_xposition = old_xposition + new_xvelocity*timestep;
    new_yposition = old_yposition + new_yvelocity*timestep;

    % Boundary Conditions being imposed 
    overboundx = new_xposition > 200e-9;
    underboundx = new_xposition < 0;
    overboundy = new_yposition > 100e-9;
    underboundy = new_yposition < 0;
    new_xposition(overboundx) = new_xposition(overboundx) - 200e-9;  
    new_xposition(underboundx) = new_xposition(underboundx) + 200e-9;
    new_yvelocity(overboundy) = -new_yvelocity(overboundy);
    new_yvelocity(underboundy) = -new_yvelocity(underboundy);

    % Restricted Region Boundary Cases
    overhorizontal =  (new_xposition > ((length/2)-(Lbottle/2))) & (new_xposition < ((length/2)+(Lbottle/2))) & ((new_yposition < ((height/2)-(Hbottle/2))) | (new_yposition > ((height/2)+(Hbottle/2))));
    previous_left = (old_xposition <= ((length/2)-(Lbottle/2)));
    previous_right = (old_xposition >= ((length/2)+(Lbottle/2)));
    previous_in = (old_xposition > ((length/2)-(Lbottle/2))) & (old_xposition < ((length/2)+(Lbottle/2)));
    previous_up = (old_yposition > (height/2));
    previous_down = (old_yposition <= (height/2));
    % if particles come from left and go over to restricted region, flip the
    % velocities 
    % Diffusive Boundary (Random Generated new velocity)
    if (boundary_type == 1)
        distribution1 = randn(e_num,1)*(thermal_velocity/sqrt(2));
        distribution2 = randn(e_num,1)*(thermal_velocity/sqrt(2));
        maxwell_boltzmann_dist = sqrt((distribution1.^2)+(distribution2.^2));
        new_velocity = maxwell_boltzmann_dist;

        theta = 2*pi*rand(e_num,1);
        % For the electron to the left of the boundary
        new_xvelocity(overhorizontal & previous_left) = -abs(cos(theta(overhorizontal & previous_left)).*new_velocity(overhorizontal & previous_left));
        new_yvelocity(overhorizontal & previous_left) = sin(theta(overhorizontal & previous_left)).*new_velocity(overhorizontal & previous_left);
        % for the electrons to the right of the boundary
        new_xvelocity(overhorizontal & previous_right) = abs(cos(theta(overhorizontal & previous_right)).*new_velocity(overhorizontal & previous_right));
        new_yvelocity(overhorizontal & previous_right) = sin(theta(overhorizontal & previous_right)).*new_velocity(overhorizontal & previous_right);
        % for the electrons in the tunnel region
        new_xvelocity(overhorizontal & previous_in & previous_up) = cos(theta(overhorizontal & previous_in & previous_up)).*new_velocity(overhorizontal & previous_in & previous_up);
        new_yvelocity(overhorizontal & previous_in & previous_up) = -abs(sin(theta(overhorizontal & previous_in & previous_up)).*new_velocity(overhorizontal & previous_in & previous_up));
        new_xvelocity(overhorizontal & previous_in & previous_down ) = cos(theta(overhorizontal & previous_in & previous_down)).*new_velocity(overhorizontal & previous_in & previous_down);
        new_yvelocity(overhorizontal & previous_in & previous_down) = abs(sin(theta(overhorizontal & previous_in & previous_down)).*new_velocity(overhorizontal & previous_in & previous_down));
        % To boot any stray particles that may be stuck
        %new_xposition(overhorizontal & ~previous_left & ~previous_right & ~previous_in) = new_xposition(overhorizontal & ~previous_left & ~previous_right & ~previous_in) - 
    else 
        % Specular boundary conditions
        new_xvelocity(overhorizontal & (previous_left | previous_right)) = -new_xvelocity(overhorizontal & (previous_left | previous_right));
        new_yvelocity(overhorizontal & previous_in) = -new_yvelocity(overhorizontal & previous_in);
    end

    %Plotting the updating positions 
    %Question 3.a 2D PLOT OF TRAJECTORIES
    scatter(new_xposition,new_yposition,2,colour_specs)
    title('Simulation Number 3')
    xlabel('Distance (nm)')
    ylabel('Distance (nm)')
    grid on
    axis([0 200e-9 0 100e-9]) 
    pause(sim_pause)

    averageVel = (mean(new_xvelocity.^2)) + (mean(new_yvelocity.^2));
    temp(time) = (averageVel*me)/(2*k);

    old_xposition = new_xposition;
    old_yposition = new_yposition;
    
    if(e_density_movie == 1 || temp_movie == 1)
        x_position_hist(:,time) = new_xposition;
        y_position_hist(:,time) = new_yposition;
    end
    if(temp_movie == 1)
        particle_velocity_hist(:,time) = sqrt((new_xvelocity.^2)+(new_yvelocity.^2));
        particle_temp_hist(:,time) = (particle_velocity_hist(:,time).*me)./(2*k);
    end
    
end
hold off

% Concatenating to get the initial temperature of the system in the plot 
time = 0:simlength;
temp = [initial_temp temp];

% Plotting the Temperature of the system
figure(11)
plot(time*timestep,temp)
title('Average Temperature Over Time')
xlabel('Time (s)')
ylabel('Simulation Temperature (K)')
grid on
pause(graph_pause)

% Calculating the average amount of time between collisions by using the
% total time the simulation ran for and the number of particles in the
% simulation divided by the amount of collisions to get the average time
% betwen collisions
calculated_Tmn_Q3 = (timestep*simlength*e_num)/(collision_num);
% Once the average time between colliosns is calculated, then the mean free
% path can be found by mulitpling by the average velocity of all of the
% particles in the simulation
calculated_MFP_Q3 = calculated_Tmn_Q3*averageVel;

% Calculating the percent error fom the correct answer
percent_error_Tmn = (100*abs(calculated_Tmn_Q3-Tmn))/Tmn;
percent_error_MFP = (100*abs(calculated_MFP_Q3-MFP_Q1))/MFP_Q1;

% Printing the answer statments 
fprintf('\nQUESTION 3')
fprintf('\nThe amount of collisions that occured collisions = %d ',collision_num)
fprintf('\nThe average time between collisions was found to be %d',calculated_Tmn_Q3)
fprintf(' (s)\nComparing this to the given value of %d (s)',Tmn)
fprintf('\nThe percent error of the average time is %f percent',percent_error_Tmn)
fprintf('\nThe mean free path was calculated to be %d',calculated_MFP_Q3)
fprintf(' (m)\nComparing this to the preeviously calculated value of %d (m)\n',MFP_Q1)
fprintf('The percent error of the MFP is %f percent\n',percent_error_MFP)

% Plotting a 3D histogram for the elecron density over the surface of the simulation 
if(e_density_movie == 1)
    for a = 1:simlength
        figure(12)
        hist3([x_position_hist(:,a) y_position_hist(:,a)],[bin_num_3D bin_num_3D])
        colormap jet;
        colorbar;
        set(gcf,'renderer','opengl');
        set(get(gca,'child'),'FaceColor','interp','CDataMode','auto');
        title('Electron Density Visual Map')
        xlabel('Distance in X Direction (m)')
        ylabel('Distance in Y Direction (m)')
        zlabel('number of Electron in Area')
        axis([0 200e-9 0 100e-9])
        pause(sim_pause)
    end
else 
    figure(100)
    subplot(1,2,2)
        hist3([new_xposition new_yposition],[bin_num_3D bin_num_3D])
        colormap jet
        colorbar
        set(gcf,'renderer','opengl');
        set(get(gca,'child'),'FaceColor','interp','CDataMode','auto');
        title('Electron Density Visual Map')
        xlabel('Distance in X Direction (m)')
        ylabel('Distance in Y Direction (m)')
        zlabel('number of Electron in Area')
        axis([-1e-9 200e-9 -1e-9 100e-9])
        pause(graph_pause)
end

% Calculates the velocity of each of the particles so thaty they can be
% made into a temperature map.
particleVel = sqrt((new_xvelocity.^2) + (new_yvelocity.^2));
particleTemp = (particleVel.*me)./(2*k);

% Plots the colour spectrum for the particles for their calculated
% temperature and a bar to help dicern the temperature of a given
% particle. There is a choice between playing the temperature as a movie of
% the simulation or it can be just displayed as the final values of
% velocity and position.
if(temp_movie == 1)
    figure(13)
    for a = 1:simlength
        scatter(x_position_hist(:,a), y_position_hist(:,a),12,particle_temp_hist(:,a))
        colormap jet
        colorbar
        grid on
        title('Coloured Temperature Map of Particles')
        xlabel('Distance in X Direction (m)')
        ylabel('Distance in Y Direction (m)')
        axis([0 200e-9 0 100e-9])
        pause(sim_pause)
    end
else
    figure(13)
    scatter(new_xposition,new_yposition,12,particleTemp)
    colormap jet
    colorbar
    grid on
    title('Coloured Temperature Map of Particles')
    xlabel('Distance in X Direction (m)')
    ylabel('Distance in Y Direction (m)')
    axis([0 200e-9 0 100e-9])
    pause(graph_pause)
end


