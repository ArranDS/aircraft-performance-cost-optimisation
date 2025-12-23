%% Aircraft Performance & Cost Optimisation
% Hybrid aerospace + analytics project:
% - Computes the fuel required for a short haul mission using the beguet range equation
% - Applie a MTOW feasibility constraint
% - It computes a simple cost proxy (fuel burn * fuel price)
% - Then runs sensitivity sweeps and a grid search optimisation over L/D and SFC
% - ArranDS

clear; clc; close all;


%% Baseline assumptions

% Mission
R_km    = 1200;                 % range of mission in km
R_m     = R_km * 1000;          % in m
V_ms    = 230;                  % cruise speed in m/s
reserve = 1.05;                 % adding a 5% extra fuel margin

% Simple mass model
OEW_kg  = 42000;                % operating empty weight in kg
PL_kg   = 16000;                % payload weight in kg
MTOW_kg = 78000;                % max take off weight limit in kg

% baseline L/D + engine SFC
LD0  = 17;                      % baseline lift-to-drag ratio 
SFC0 = 0.60;                    % baseline SFC 1/hr

% The cost model
fuel_price_gbp_per_kg = 0.75;   % in £/kg


%% Single-point baseline run
[Fuel0_kg, Cost0_gbp, feasible0] = missionFuelCost( ...
    LD0, SFC0, R_m, V_ms, OEW_kg, PL_kg, MTOW_kg, reserve, fuel_price_gbp_per_kg);

fprintf("Baseline results (L/D=%.1f, SFC=%.2f 1/hr):\n", LD0, SFC0);
fprintf("  Fuel required: %.0f kg\n", Fuel0_kg);
fprintf("  Cost proxy:    £%.0f / trip\n", Cost0_gbp);
fprintf("  Feasible MTOW: %s\n\n", string(feasible0));

%% First sensitivity sweep: Fuel vs L/D (keeping SFC constant)
LD_vec = linspace(14, 20, 61);
Fuel_LD = nan(size(LD_vec));

for i = 1:numel(LD_vec)
    Fuel_LD(i) = missionFuelCost( ...
        LD_vec(i), SFC0, R_m, V_ms, OEW_kg, PL_kg, MTOW_kg, reserve, fuel_price_gbp_per_kg);
end

figure;
plot(LD_vec, Fuel_LD, "LineWidth", 1.5);
grid on;
xlabel("Lift-to-Drag Ratio (L/D)");
ylabel("Fuel Required (kg)");
title("Sensitivity: Fuel Required vs L/D (SFC constant)");

%% Second sensitivity sweep: Cost vs SFC (keeping L/D constant)
SFC_vec = linspace(0.50, 0.70, 81);
Cost_SFC = nan(size(SFC_vec));

for i = 1:numel(SFC_vec)
    [~, Cost_SFC(i)] = missionFuelCost( ...
        LD0, SFC_vec(i), R_m, V_ms, OEW_kg, PL_kg, MTOW_kg, reserve, fuel_price_gbp_per_kg);
end

figure;
plot(SFC_vec, Cost_SFC, "LineWidth", 1.5);
grid on;
xlabel("SFC (1/hr)");
ylabel("Cost Proxy (£/trip)");
title("Sensitivity: Cost Proxy vs SFC (L/D constant)");

%% Grid search "optimisation": minimise cost over L/D and SFC
LD_grid  = linspace(14, 20, 121);      
SFC_grid = linspace(0.50, 0.70, 161);  

Cost_map = nan(numel(SFC_grid), numel(LD_grid));
Fuel_map = nan(numel(SFC_grid), numel(LD_grid));
Feas_map = false(numel(SFC_grid), numel(LD_grid));

for r = 1:numel(SFC_grid)
    for c = 1:numel(LD_grid)
        [f_kg, c_gbp, feas] = missionFuelCost( ...
            LD_grid(c), SFC_grid(r), R_m, V_ms, OEW_kg, PL_kg, MTOW_kg, reserve, fuel_price_gbp_per_kg);

        Fuel_map(r, c) = f_kg;
        Cost_map(r, c) = c_gbp;
        Feas_map(r, c) = feas;
    end
end

% Find best feasible solution (min cost among feasible points)
Cost_feasible = Cost_map;
Cost_feasible(~Feas_map) = NaN;

[minCost, idx] = min(Cost_feasible(:));
[r_best, c_best] = ind2sub(size(Cost_feasible), idx);

LD_best   = LD_grid(c_best);
SFC_best  = SFC_grid(r_best);
Fuel_best = Fuel_map(r_best, c_best);

fprintf("---- Optimisation result (grid search) ----\n");
fprintf("Best L/D: %.2f\n", LD_best);
fprintf("Best SFC: %.3f 1/hr\n", SFC_best);
fprintf("Fuel at best point: %.0f kg\n", Fuel_best);
fprintf("Min cost: £%.0f / trip\n\n", minCost);

%% Visualising the cost surface and infeasible region
figure;

imagesc(LD_grid, SFC_grid, Cost_map);
set(gca, 'YDir', 'normal');
colorbar;
grid on;
xlabel('L/D');
ylabel('SFC (1/hr)');
title('Cost Proxy Surface (£/trip) across L/D and SFC');
hold on;

% Best point
h_best = plot(LD_best, SFC_best, 'o', ...
    'MarkerFaceColor', 'w', ...
    'MarkerEdgeColor', 'k', ...
    'MarkerSize', 8, ...
    'LineWidth', 1.5);

% Infeasible points, could have none
[rr, cc] = find(~Feas_map);
h_infeas = gobjects(0);   
if ~isempty(rr)
    h_infeas = plot(LD_grid(cc), SFC_grid(rr), 'k.', 'MarkerSize', 3);
end

handles = [];
labels  = {};

if ~isempty(rr)
    handles = [handles, h_infeas(1)];
    labels  = [labels, {'Infeasible (MTOW)'}];
end

handles = [handles, h_best];
labels  = [labels, {'Best point'}];

lgd = legend(handles, labels, 'Location', 'southoutside');
set(lgd, 'AutoUpdate', 'off');

hold off;

%% Summary table
bestTable = table(LD_best, SFC_best, Fuel_best, minCost, feasible0, ...
    "VariableNames", {"LD_best","SFC_best_1_per_hr","Fuel_best_kg","MinCost_gbp","BaselineFeasible"});
disp(bestTable);
