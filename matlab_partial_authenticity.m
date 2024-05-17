% matlab_partial_authenticity.m
%
% Code for "Influencers: The Power of Comments"
% by Nistor, Selove, and Villas-Boas (2024)
%
% Used to create Figure 3
%


% Clear all variables
clear;

% Model parameters
beta = 1.2;     % rate at which current followers attract new followers
gamma = 0.75;   % fraction willing to follow if inauthentic
phi = 1.5;      % profits per follower if inauthentic
r = 0.1;        % discount rate
delta = 0.1;    % time unit used in value function iteration process


% Possible awareness levels (state variable)
awareness = [1:100000]'./100000;

% Step 1: Initialize estimate of value function based on what happens
% if the influencer always follows the long-run optimal policy.
% This step helps with convergence of the next value function iteration step.

% Optimal policy as awareness approaches 1
y_long_run = (gamma + phi - 2)./(2*(1-gamma).*(phi-1));
y_long_run = min(max(y_long_run,0),1);

% Set policy to long-run optimal policy for all awareness levels
policy_func = y_long_run .* ones (100000,1);

% Calculate profits at each awareness level
current_profits = (1 + (gamma-1).*policy_func).*((1 + (phi-1).*policy_func)).*awareness;

% Compute new state after delta units of time with this policy
new_awareness = awareness + delta.*(1+(gamma-1).*policy_func).*beta.*awareness.*(1-awareness);
new_awareness_index = round(100000.*new_awareness,0);

% Initialize value function
value_func = current_profits./r;

% Initial value function loop
% Computes value function if influencer always
% follows long-run optimal policy
for value_init_loop = 1:1000
    % Update value function to optimize given current estimate
    value_func = current_profits .* delta + exp(-r*delta).*value_func(new_awareness_index);
end

% Step 2: Value function iteration with optimal policy at each state

% Initialize value function derivative
value_deriv = zeros (100000,1);

% Value function interation loop
for value_loop = 1:10000
    % Value function derivative
    % Computed by comparing current value
    % with value at awareness 0.001 higher
    value_deriv = 1000.*[(value_func(101) - value_func(1)).*ones(100,1); value_func(101:100000) - value_func(1:99900)];

    % Compute optimal policy
    policy_func = (gamma + phi - 2 + beta.*(gamma-1).*(1-awareness).*value_deriv)./(2*(1-gamma)*(phi-1));
    policy_func = min(max(policy_func,0),1);

    % Compute current profits for optimal policy
    current_profits = (1 + (gamma-1).*policy_func).*((1 + (phi-1).*policy_func)).*awareness;

    % Compute new state after delta units of time with optimal policy
    new_awareness = awareness + delta.*(1+(gamma-1).*policy_func).*beta.*awareness.*(1-awareness);
    new_awareness_index = round(100000.*new_awareness,0);

    % Update value function to optimize given current estimate
    value_func = current_profits .* delta + exp(-r*delta).*value_func(new_awareness_index);
end

% Print out optimal policy from 0 to 1 in increments of 0.001
indexes_of_policy = 100.*[1:1000]';
policy_func(indexes_of_policy)