function pres = compute_pressure( mu, dnw, phi, theta, qv, Rd,Rv,gamma,p0 )
% FUNCTION pres : Computes pressure from gas law as in WRF.
%
% CS version of Ryan's m-file.
% Computes pressure from gas law as in WRF.
%
% alpha = inverse density of dry air, computed from hydrostatic relation
% for the dry air:  - dphi/deta = -mu alpha.
%
% Inputs:
%       mu    =   (full) dry hydrostatic surf. press (2d)
%       dnw   =   intervals between w levels, at mass pts
%       phi   =   (full) geopotential, at w pts
%       theta =   (full) potential temperature, at mass pts
%       qv    =   water-vapor mixing ratio, at mass pts
%       Rd,Rv,gamma,p0
%             =   dry and moist gas constants, c_p/c_v, reference pressure
% Output:
%       pres  =   (full) pressure, at mass pts
%
% See wrf subroutine calc_p_rho_phi.

% Data Assimilation Research Testbed -- DART
% Copyright 2004-2007, Data Assimilation Research Section
% University Corporation for Atmospheric Research
% Licensed under the GPL -- www.gpl.org/licenses/gpl.html
%
% <next few lines under version control, do not edit>
% $URL: http://subversion.ucar.edu/DAReS/DART/trunk/models/wrf/matlab/compute_pressure.m $
% $Id: compute_pressure.m 3440 2008-07-01 23:07:15Z thoar $
% $Revision: 3440 $
% $Date: 2008-07-01 17:07:15 -0600 (Tue, 01 Jul 2008) $

 phi_eta =  ...
  ( phi(2:end,:,:) - phi(1:end-1,:,:) ) ./ repmat( dnw(:), [1 size(mu)] );
 alpha = -phi_eta ./ repmat( reshape( mu, [1 size(mu)] ), [ length(dnw) 1 1 ] );

 % Gas law:
 pres = p0 * ( Rd * theta .* (1 + (Rd/Rv)*qv ) ./ ( p0 * alpha ) ).^gamma ;
~                                                                                                                             
