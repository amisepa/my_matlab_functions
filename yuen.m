% function [Ty,diff,CI,da,db,df,p] = yuen(a,b,percent,alpha)
% 
% % Computes Ty (Yuen's T statistic)
% Ty=(tma-tmb) / sqrt(da+db), where tma & tmb are trimmed means of a & b,
% and da & db are yuen's estimate of the standard errors of tma & tmb.
% Ty is distributed approximately as Student's t with estimated degrees of freedom, df.
% The p-value (p) is the probability of obtaining a t-value whose absolute value
% is greater than Ty if the null hypothesis (i.e., tma-tmb = mu) is true.
% In other words, p is the p-value for a two-tailed test of H0: tma-tmb=0;
% Data arrays a & b must be vectors; percent must be a number between 0 & 100.
% 
% Default values:%   percent = 20;%   alpha = 0.05; necessary to compute the CI
% See Wilcox (2005), Introduction to Robust Estimation and Hypothesis
% Testing (2nd Edition), page 159-161 for a description of the Yuen% procedure.
% You can also check David C. Howell, Statistical Methods for Psychology,
% sixth edition, p.43, 323, 362-363.
% 
% Original code by Prof. Patrick J. Bennett, McMaster University
% Added CI output, various editing, GAR, University of Glasgow, Dec 2007
% See also YUEND

function [Ty,diff,CI,da,db,df,p] = yuen(a,b,percent,alpha)


if nargin<4
    alpha=.05;
end
if nargin<3
    percent=20;
end
if isempty(a) || isempty(b)
    error('yuen:InvalidInput', 'data vectors cannot have length=0');
end
if (min(size(a))>1) || (min(size(b))>1)
    error('yuen:InvalidInput', 'yuen requires that the data are input as vectors.');
end
if (percent >= 100) || (percent < 0)
    error('yuen:InvalidPercent', 'PERCENT must be between 0 and 100.');
end

[swa,ga] = winvar(a,percent); % winsorized variance of a & # items winsorized
[swb,gb] = winvar(b,percent); % winsorized variance of b & # items winsorized

% yuen's estimate of standard errors for a and b
na=length(a);ha=na-2*ga;da=((na-1)*swa)/(ha*(ha-1));
nb=length(b);hb=nb-2*gb;db=((nb-1)*swb)/(hb*(hb-1));% trimmed means

ma=tm(a,percent);
mb=tm(b,percent);

diff=ma-mb;

Ty=diff./sqrt(da+db);

da2=da^2;
db2=db^2;

df= ((da+db).^2) / ( (da2/(ha-1)) + (db2/(hb-1)) );

p=2*(1-tcdf(abs(Ty),df)); % 2-tailed probability

t=tinv(1-alpha./2,df); % 1-alpha/2 quantile of Student's distribution with df degrees of freedom 

CI(1)=(ma-mb)-t.*sqrt(da+db); 
CI(2)=(ma-mb)+t.*sqrt(da+db);

end
