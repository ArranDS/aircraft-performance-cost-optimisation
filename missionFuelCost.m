function [fuel_required_kg, cost_gbp, feasible] = missionFuelCost( ...
    LD, SFC_1_per_hr, R_m, V_ms, OEW_kg, PL_kg, MTOW_kg, reserve, fuel_price_gbp_per_kg)
% Computes fuel required using the breguet range equation and a simple mass
% model, then applies MTOW feasibility and computes a cost proxy.
%
% Inputs:
%   LD               - lift to drag ratio
%   SFC_1_per_hr     - specific fuel consumption 1/hr
%   R_m              - mission range in m
%   V_ms             - cruise speed in m/s
%   OEW_kg           - operating empty weight in kg
%   PL_kg            - payload in kg
%   MTOW_kg          - max take off weight in kg
%   reserve          - reserve factor 
%   fuel_price_gbp_per_kg - fuel price in £/kg
%
% Outputs:
%   fuel_required_kg - fuel required in kg
%   cost_gbp         - cost proxy in £/trip
%   feasible         - true if the OEW + PL + fuel <= MTOW

    % Basic validation
    if LD <= 0 || SFC_1_per_hr <= 0 || R_m <= 0 || V_ms <= 0
        fuel_required_kg = NaN;
        cost_gbp = NaN;
        feasible = false;
        return;
    end

    % Converting SFC to 1/s for consistency with V in m/s
    SFC_1_per_s = SFC_1_per_hr / 3600;

    % The breguet equation rearranged to solve ln(Wi/Wf)
    ln_Wi_over_Wf = (R_m * SFC_1_per_s) / (V_ms * LD);

    % The weight assumptions
    Wf_kg = OEW_kg + PL_kg;          % final weight
    Wi_kg = Wf_kg * exp(ln_Wi_over_Wf);

    % Fuel required (+ the reserve)
    fuel_required_kg = (Wi_kg - Wf_kg) * reserve;

    % Feasibility check against the MTOW
    feasible = (OEW_kg + PL_kg + fuel_required_kg) <= MTOW_kg;

    % The cost proxy
    cost_gbp = fuel_required_kg * fuel_price_gbp_per_kg;
end
