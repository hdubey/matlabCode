%% basic Daisy World 
clear all
clc

%%
%Set Variables

T_opt_b = 295; %Optimal growth temperature of black daisies in K (default = 295)
T_opt_w = 295; %Optimal growth temperature of white daisies in K (default = 295)
k_b = 17.5^(-2); %Growth rate bracketed between 35 K of T_opt
k_w = 17.5^(-2); %Growth rate bracketed between 35 K of T_opt
albedo_g = 0.5; %Albedo of bare ground
albedo_w = 0.75; %Albedo of white daisies
albedo_b = 0.25; %Albedo of black daisies
S = 1368/4; %Solar radiation in W/m2 received by a planet located 1 au from the Sun
q = 10^9; %Heat transfer coefficient to ensure thermal equilibrium (set so that q < 0.2*SL/sigma)
sigma = 5.67*10^-8;% Stefan Boltzman constant J/s/m2/K4
gamma = .3; %Death rate (default = 0.3)

%% Initial Values
T = 250; %Initial temperature of daisy world in K (default = 300)
L = 2.4; %Luminosity (L is set to 2.0 where the black and white have two distinct cycles)
ntime = 300; %Number of timesteps in main loop (default = 100)

alpha_w = 0.01; %Fraction of land covered by white daisies
alpha_b = 0.01; %Fraction of land covered by black daisies
year = linspace(0,ntime,ntime);
temp = T_opt_w-49:1:T_opt_w+50;
alpha_w_store = zeros(1,ntime); %Storage vector for alpha_w
alpha_b_store = zeros(1,ntime); %Storage vector for alpha_b
temp_store = zeros(1,ntime); %Storage vector for Temperature
L_store = zeros(1,ntime); %Storage vector for luminosity
beta_white = zeros(1,ntime); % Storage vector for birth function for white
beta_black = zeros(1,ntime); % Storage vector for birth function for black
%% MAIN LOOP

%MAIN LOOP%
for itime = 1:ntime
	alpha_g = 1 - alpha_b - alpha_w; %Fraction of land that is bare ground
    % The equation below set the main albedo as a function of hte
    % proportions of daisies coupled with their respective albedos
	A = alpha_w*albedo_w + alpha_b*albedo_b + albedo_g*(alpha_g); %mean planetary albedo
	
	%store variables for plotting%
    alpha_w_store(itime) = alpha_w; 
	alpha_b_store(itime) = alpha_b;
	temp_store(itime) = T;
    % the equation below is a product of Stefan-Boltzmanns equation
    % S*L*(1-A) = sigma*T^4. In other words the temperature times sigma is
    % = to the solar energy actually being absorbed. It depends on the
    % current Albedo, which in turn is set by the proportions of Daisies.
	T = (S*L*(1-A)/sigma)^(1/4); %compute mean planetary temperature in radiative equilibrium
    T_bare(itime) = (S*L*(1-albedo_g)/sigma)^(1/4);
    % These next sets of equations create the temperature contribution from
    % each type of daisy and the bare planet. ie. Local temperatures.
	T_w = (q*(A - albedo_w) + T^4)^(1/4); %compute temperature of patch of white daisies
	T_b = (q*(A - albedo_b) + T^4)^(1/4); %compute temperature of patch of black daisies
	T_g = (q*(A - albedo_g) + T^4)^(1/4); %compute temperature of bare ground
    % The equations below set the proportions of daisies. These are based
    % on population replicator differential equations we have all seen in
    % our textbooks. ie. dw/dt=w*(p-w)*Birthrate-w*deathrate. In the code
    % form each change is iterated, so no differential equation is being
    % solved at once. so white daisies = white daisies + white daisies *
    % (proportion of land left*birthfunction(using local white daisy
    % temperature) - death rate)
	alpha_w = alpha_w + alpha_w*(alpha_g*betafn(T_w,T_opt_w,k_w) - gamma);
	alpha_b = alpha_b + alpha_b*(alpha_g*betafn(T_b,T_opt_b,k_b) - gamma);
    
    L_store(itime)= L; % luminosity over time
    beta_white(itime) = betafn(T_w,T_opt_w,k_w); %white birthrate value
    beta_black(itime) = betafn(T_b,T_opt_b,k_b); %black beathrate value
    %% *#@! with the numbers here!
    %L=L*(1+sin(itime)/14);
    %L= L*(1+sin(pi*itime/40)/150);
    L= L + 0.01 ;
    % HOLD L at 4 after luminosity steadily increases. Single species
    % steady solution. (white daisy)
%     if itime <= 201 
%         L= L + 0.01;
%     else if itime > 201;
%         L = L_store(201);
%     end
%     end
%         if itime == 260
%             sprintf('steady state temperature = %f', temp_store(259)-273)
%         end
end
%% Extra analysis
%  for comparison and such n such
    b_curve_white = birthgraph(temp,T_opt_w,k_w); %the full birthrate fnc
    b_curve_black = birthgraph(temp,T_opt_b,k_b); %the full birthrate fnc

%% PLOTS
%DATA PLOTTING%
figure(1);
subplot(3,1,1)
plot(year,temp_store - 273, '-',year,T_bare - 273, 'r')
xlim([1 ntime])
ylabel('temp [C]')
legend('Temperature with Daisies', 'Temperature without daisies')

subplot(3,1,2)
    plot(alpha_w_store, '--')
    xlim([1 ntime])
    ylim([0 1])
hold on
    plot(alpha_b_store, '-')
    ylabel('fractional cover')
    legend('white', 'black')
hold off

subplot(3,1,3);
    plot(year,L_store,'r');
    xlabel('year');
    ylabel('luminosity');

figure(2);
subplot(3,1,1)
    plot(L_store,temp_store - 273)
    ylabel('temp [C]')
    xlabel('luminosity')


subplot(3,1,2)
    plot(year,beta_white,'--b',year,beta_black,'b-');
    %plot(temp_store,beta_black,'--b',temp_store,beta_white,'b-');
    xlabel('year');
    ylabel('birthrate');
    legend('white', 'black')

subplot(3,1,3);
    plot(temp - 273,b_curve_white,('b'))
    xlabel('Temperature [C]');
    ylabel('birthrate');
    xlim([0,80]);
