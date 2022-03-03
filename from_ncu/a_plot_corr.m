%
cov_obsmodel_prof('Vr','V',40)
cov_obsmodel_prof('Vr','U',40)
cov_obsmodel_prof('Vr','QVAPOR',40)
cov_obsmodel_prof('Vr','QRAIN',40)
cov_obsmodel_prof('Vr','T',40)

cov_obsmodel_prof('Zh','V',40)
cov_obsmodel_prof('Zh','U',40)
cov_obsmodel_prof('Zh','QVAPOR',40)
cov_obsmodel_prof('Zh','QRAIN',40)
cov_obsmodel_prof('Zh','T',40)

close all
%}
%
cov_obsmodel_prof('Vr','V',256)
cov_obsmodel_prof('Vr','U',256)
cov_obsmodel_prof('Vr','QVAPOR',256)
cov_obsmodel_prof('Vr','QRAIN',256)
cov_obsmodel_prof('Vr','T',256)

cov_obsmodel_prof('Zh','V',256)
cov_obsmodel_prof('Zh','U',256)
cov_obsmodel_prof('Zh','QVAPOR',256)
cov_obsmodel_prof('Zh','QRAIN',256)
cov_obsmodel_prof('Zh','T',256)
%}
%{
corr_obsmodel('Vr','V',40,4,0.5,248,83)
corr_obsmodel('Vr','U',40,4,0.5,248,83)
corr_obsmodel('Vr','QVAPOR',40,4,0.5,248,83)
corr_obsmodel('Vr','QRAIN',40,4,0.5,248,83)
corr_obsmodel('Zh','V',40,4,0.5,248,83)
corr_obsmodel('Zh','U',40,4,0.5,248,83)
corr_obsmodel('Zh','QVAPOR',40,4,0.5,248,83)
corr_obsmodel('Zh','QRAIN',40,4,0.5,248,83)
%
corr_obsmodel('Vr','V',256,4,0.5,248,83)
corr_obsmodel('Vr','U',256,4,0.5,248,83)
corr_obsmodel('Vr','QVAPOR',256,4,0.5,248,83)
corr_obsmodel('Vr','QRAIN',256,4,0.5,248,83)
corr_obsmodel('Zh','V',256,4,0.5,248,83)
corr_obsmodel('Zh','U',256,4,0.5,248,83)
corr_obsmodel('Zh','QVAPOR',256,4,0.5,248,83)
corr_obsmodel('Zh','QRAIN',256,4,0.5,248,83)
%}
%corr_obsmodel('Vr','T',40,4,0.5,188,83)
%corr_obsmodel('Vr','T',256,4,0.5,188,83)
%corr_obsmodel('Zh','T',40,4,0.5,188,83)
%corr_obsmodel('Zh','T',256,4,0.5,188,83)
%corr_obsmodel('Vr','T',256,4,0.5,248,83)
%
corr_obsmodel('Vr','V',40,4,0.5,188,83)
corr_obsmodel('Vr','U',40,4,0.5,188,83)
corr_obsmodel('Vr','QVAPOR',40,4,0.5,188,83)
corr_obsmodel('Vr','QRAIN',40,4,0.5,188,83)
corr_obsmodel('Zh','V',40,4,0.5,188,83)
corr_obsmodel('Zh','U',40,4,0.5,188,83)
corr_obsmodel('Zh','QVAPOR',40,4,0.5,188,83)
corr_obsmodel('Zh','QRAIN',40,4,0.5,188,83)

corr_obsmodel('Vr','V',256,4,0.5,188,83)
corr_obsmodel('Vr','U',256,4,0.5,188,83)
corr_obsmodel('Vr','QVAPOR',256,4,0.5,188,83)
corr_obsmodel('Vr','QRAIN',256,4,0.5,188,83)
corr_obsmodel('Zh','V',256,4,0.5,188,83)
corr_obsmodel('Zh','U',256,4,0.5,188,83)
corr_obsmodel('Zh','QVAPOR',256,4,0.5,188,83)
corr_obsmodel('Zh','QRAIN',256,4,0.5,188,83)
%}

%{
for i=11:12
corr_obsmodel_rand('Vr','QVAPOR',4,0.5,188,83,100) 
system(['mv largens/largens/largens_0000_30329_wrfo_Vr-qv_m40sprd.png largens/largens/largens_0000_30329_wrfo_Vr-qv_m40sprd_',num2str(i),'.png']);
end

for i=11:12
corr_obsmodel_rand('Vr','QVAPOR',4,0.5,248,83,100)
system(['mv largens/largens/largens_0000_30881_wrfo_Vr-qv_m40sprd.png largens/largens/largens_0000_30881_wrfo_Vr-qv_m40sprd_',num2str(i),'.png']);
end
%}

%{
rad=[4 3];  aza=[188 208 223 248];  dis=[83 73];
for i=1:length(rad)
for j=1:length(aza)
for k=1:length(dis)
 corr_obsmodel_hline('Zh','QVAPOR',rad(i),0.5,aza(j),dis(k))
 corr_obsmodel_hline('Vr','QVAPOR',rad(i),0.5,aza(j),dis(k))
end
end
end
%}


