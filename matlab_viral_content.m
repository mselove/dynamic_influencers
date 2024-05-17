% matlab_viral_content.m
%
% Code for "Influencers: The Power of Comments"
% by Nistor, Selove, and Villas-Boas (2024)
%
% Used to create Figure 4


% Clear all variables
clear;

% Model parameters
beta = 1.2;     % rate at which current followers attract new followers
gamma = 0.75;   % fraction willing to follow if inauthentic
phi = 1.5;      % profits per follower if inauthentic
r = 0.1;        % discount rate
delta = 0.1;    % time unit used in value function iteration process
lambda = 10;    % Rate of organic posts per unit of time
mu = 5;         % Rate of sponsorship offers per unit of time
theta = 0.2;    % Fraction of sponsorship offers with good fit
v = 0.02;       % Probability of going viral, for each post
z = 0.5;        % Fraction of the people not following the influencer who see a viral post


% Possible awareness levels (state variable)
awareness = [1:100000]'./100000;

% Profits if authentic
profits_authentic = awareness + v.*z.*(1-awareness);

% Profits if inauthentic
profits_inauthentic = phi.*(gamma.*awareness + v.*z.*(1-gamma.*awareness));

% State after delta units of time if authentic
awareness_authentic = awareness + delta.*beta.*awareness.*(1-awareness);
awareness_authentic_index = round(100000.*awareness_authentic,0);

% State after delta units of time if inauthentic
awareness_inauthentic = awareness + delta.*gamma.*beta.*awareness.*(1-awareness);
awareness_inauthentic_index = round(100000.*awareness_inauthentic,0);

% Compute index of new state if influencer goes viral
awareness_index = [1:100000]';
viral_index = round(awareness_index + z.*(100000 - awareness_index));

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
    value_inauthentic = value_inauthentic + delta.*v.*(lambda + mu).*(value_func(viral_index) - value_func);

    % Value function if authentic
    value_authentic = profits_authentic .* delta + exp(-r*delta).*value_func(awareness_authentic_index);
    value_authentic = value_authentic + delta.*v.*(lambda + theta.*mu).*(value_func(viral_index) - value_func);

    % Update value function to optimize given current estimate
    value_func = max(value_inauthentic,value_authentic);
end

% Opimal policy function given value function after convergence
policy_func = 1.*(value_authentic > value_inauthentic);
plot(policy_func)