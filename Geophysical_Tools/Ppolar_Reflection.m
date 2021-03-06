function [R phase_shift T] = Ppolar_Reflection(e1,e2,theta,thickness,frequency,method,correction_flag,plotter);
% (C) Nick Holschuh - Penn State University - 2015 (Nick.Holschuh@gmail.com)
% Reflection Coefficient for P-polarized light (with oscillations in the
% plane formed by the transmission ray and the pole to the plane of the
% reflector (i.e. dipole antenna parallel to the transmission direction)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The inputs are as follows:
%
% e1 - The dielectric constant of medium 1
% e2 - The dielectric constant of medium 2
% theta - The incidence angle of approach for the ray (in radians)
% thickness - reflection bed thickness (needed for method 2 only)
% frequency - center frequency of the pulse reflecting
% method - Either the solution that includes thin-film effects (1) or the
%          fresnel reflection coefficient (2)
% correction_flag - (0) provide the simple reflection coefficient, (1)
%   the log-power effect of variability in the reflection coefficient to
%   remove from a set of radar data to isolate other variables.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

EM_coefficient_import;

%%%%%%% This is a demo option, to verify that the code works
if e1 == 0
    plotter = 1;
    e1 = 1.5^2;
    e2 = 1;
    theta = deg2rad(0:90);
    thickness = 1000;
    method = 1;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Contingencies for missing arguments
if exist('correction_flag') == 0
    correction_flag = 0;
end

if exist('theta') == 0
    theta = deg2rad(0:90);
elseif length(theta) == 0
    theta = deg2rad(0:90);
end

if exist('thickness') == 0
    method = 2;
else
    if thickness == 0;
        method = 2;
    end
end

if exist('frequency') == 0
    method = 2;
else
    if frequency == 0;
        method = 2;
    end
end

if exist('method') == 0 
   if exist('frequency') == 1
       method = 1;
   end
else
    if method == 0
        method = 2;
    end
end

if exist('plotter') == 0
    plotter = 0;
end

if size(e1) ~= size(e2)
    if prod(size(e1)) > prod(size(e2))
        e2 = e2*ones(size(e1));
    else
        e1 = e1*ones(size(e2));
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if method == 1
    e1 = e1*e_0;
    e2 = e2*e_0;
    e3 = e1;
    gamma1 = 2*pi*frequency*sqrt(e1*mu_0).*cos(theta);
    gamma2 = 2*pi*frequency*sqrt(e2*mu_0).*sqrt(1 - (e1*sin(theta).^2/e2));
    gamma3 = gamma1;

    %%% Equation from Bradford and Deeds, 2006
    R = (gamma1.*e3 - gamma3.*e1 - sqrt(-1)*(gamma1.*gamma3.*e2./gamma2 - gamma2.*e1.*e3./e2).*tan(gamma2.*thickness))./ ...
        (gamma1.*e3 + gamma3.*e1 - sqrt(-1)*(gamma1.*gamma3.*e2./gamma2 + gamma2.*e1.*e3./e2).*tan(gamma2.*thickness));
    
    T = 1- R.^2;
    
    phase_shift = rad2deg(phase(R));
    
    
elseif method == 2
    % This is the equation for Fresnel Reflectivity. The above equation is true
    % for all layer thickness (it approaches fresnel for layer 2 thickness >
    % wavelength)
    
    %%%%% Method Solution 1
    R = (cos(theta) - (sqrt(e1)./sqrt(e2)).*sqrt(1-(sqrt(e1).*sin(theta)./sqrt(e2)).^2)) ./ ...
        (cos(theta) + (sqrt(e1)./sqrt(e2)).*sqrt(1-(sqrt(e1).*sin(theta)./sqrt(e2)).^2));
    
    %%%%% Method Solution 2
%     theta_t = asin(sqrt(e1./e2).*sin(theta));
%     R = (sqrt(e2).*cos(theta) - sqrt(e1).*cos(theta_t)) ./ ...
%         (sqrt(e1).*cos(theta_t) + sqrt(e2).*cos(theta));
    
        T = 1- R.^2;
    
    phase_shift = rad2deg(atan2(imag(R),real(R)));
end

if correction_flag == 1
    R2 = R;
    R = -10*log10(R.^2);
else
    R2 = -10*log10(R.^2);
end

if plotter == 1
    if min(size(theta)) == 1
        subplot(2,1,1)
        plot(rad2deg(theta),R.^2)
        xlabel('Incedence Angle (^o)')
        subplot(2,1,2)
        plot(rad2deg(theta),R2)
        xlabel('Incedence Angle (^o)')
    else
        subplot(2,1,1)
        imagesc(R)
        subplot(2,1,2)
        imagesc(R2)
    end
end



end