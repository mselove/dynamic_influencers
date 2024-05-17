% matlab_main_model.m
%
% Code for "Influencers: The Power of Comments"
% by Nistor, Selove, and Villas-Boas (2024)
%
% Used to create Figure 1
% Estimates with numerical integration and value function interation


% Clear all variables
clear;

% Model parameters
beta = 1.2;     % rate at which current followers attract new followers
gamma = 0.75;   % fraction willing to follow if inauthentic
phi = 1.5;      % profits per follower if inauthentic
r = 0.1;        % discount rate
delta = 0.1;    % time unit used in value function iteration process


% Method 1: Numerican integration to solve condition in Propostion 1

% Check each awareness level from 0 to 1 in increments of 0.001
for awareness_loop = 1:1000
    current_awareness = awareness_loop./1000;

    % Threshold for value function derivative at which policy changes
    threshold_term = (gamma.*phi - 1)/((1-gamma).*beta.*(1-current_awareness));

    % Numerical integration to compute value function derivative
    integral = 0;

    % Integrate from t = 0 to t = 10 in increments of 0.001
    for time_loop = 1:10000
        current_time = time_loop ./1000;
        integral_numerator = (exp(-(gamma.*beta + r).*current_time)).*gamma.*phi;
        integral_denominator = (current_awareness + (1-current_awareness).*exp(-gamma.*beta.*current_time))^2;
        integral = integral + 0.001 .* (integral_numerator./integral_denominator);
        %[current_time 0.01 .* (integral_numerator./integral_denominator)]
    end

    % Check if condition is met
    if (abs(threshold_term-integral)<0.01)
        current_awareness
    end
end



% Method 2: Value function iteration

% Possible awareness levels (state variable)
awareness = [1:100000]'./100000;

% Profits if authentic
profits_authentic = awareness;

% Profits if inauthentic
profits_inauthentic = gamma.*phi.*awareness;

% State after delta units of time if authentic
awareness_authentic = awareness + delta.*beta.*awareness.*(1-awareness);
awareness_authentic_index = round(100000.*awareness_authentic,0);

% State after delta units of time if inauthentic
awareness_inauthentic = awareness + delta.*gamma.*beta.*awareness.*(1-awareness);
awareness_inauthentic_index = round(100000.*awareness_inauthentic,0);

% Initialize value function
value_func = profits_inauthentic./r;
value_authentic = value_func;
value_inauthentic = value_func;

% Initialize policy function (zero if inauthentic, one if authentic)
policy_func = zeros (100000,1);

% Value function interation loop
for value_loop = 1:10000
    % Value function if inauthentic
    value_inauthentic = profits_inauthentic .* delta + exp(-r*delta).*value_func(awareness_inauthentic_index);
    
    % Value function if authentic
    value_authentic = profits_authentic .* delta + exp(-r*delta).*value_func(awareness_authentic_index);

    % Update value function to optimize given current estimate
    value_func = max(value_inauthentic,value_authentic);
end

% Opimal policy function given value function after convergence
policy_func = 1.*(value_authentic > value_inauthentic);
plot(policy_func)