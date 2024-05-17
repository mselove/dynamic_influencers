% matlab_celebrities.m
%
% Code for "Influencers: The Power of Comments"
% by Nistor, Selove, and Villas-Boas (2024)
%
% Used to create Figure 2
%


% Clear all variables
clear;

% Model parameters
alpha = 0.35;   % direct growth for celebrity
beta = 1.2;     % rate at which current followers attract new followers
gamma = 0.75;   % fraction willing to follow if inauthentic
phi = 1.5;      % profits per follower if inauthentic
r = 0.1;        % discount rate
delta = 0.1;    % time unit used in value function iteration process


% Possible awareness levels (state variable)
awareness = [1:100000]'./100000;

% Profits if authentic
profits_authentic = awareness;

% Profits if inauthentic
profits_inauthentic = gamma.*phi.*awareness;

% State after delta units of time if authentic
awareness_authentic = awareness + delta.*(alpha + beta.*awareness).*(1-awareness);
awareness_authentic_index = round(100000.*awareness_authentic,0);

% State after delta units of time if inauthentic
awareness_inauthentic = awareness + delta.*(alpha + gamma.*beta.*awareness).*(1-awareness);
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