%function a_plot_terrain(input)
%clear;  
ccc=':';
close all
%---setting

expri={'TWIN017B';'TWIN013B';'TWIN022B';
       'TWIN025B';'TWIN019B';'TWIN024B';
       'TWIN021B';'TWIN003B';'TWIN020B';
       'TWIN023B';'TWIN016B';'TWIN018B';};  
    
expnam={'V05H05';'V10H05';'V20H05';
        'V05H075';'V10H075';'V20H075';
        'V05H10';'TOPO';'V20H10';
        'V05H20';'V10H20';'V20H20'};
        
cexp=[ 75 190 237 ; 0  114  189;  5 55 160 ; 
       245 153 202; 200 50 170; 140 30 135 
       235 175 32 ;  220 85 25;  160 20 45;  
       143 204 128;  97 153  48; 35 120 35 ]/255;

% input=18;
% expri={['TWIN0',num2str(input,'%.2d'),'B']};         
% expnam='V20H20';
% lexp={'-'};  

%col=[0.38, 0.6, 0.188 ];

% plotarea=0;
%---setting  
year='2018'; mon='06'; s_date='23'; s_hr='00'; minu='00';
dom='01';  infilenam='wrfout'; 
%
indir='/mnt/HDD123/pwin/Experiments/expri_twin';  %outdir='/mnt/e/figures/expri_twin';
outdir='/mnt/e/figures/expri_twin/';

nexp=size(expri,1);
%---
%%
for ei=1:nexp
    hf=figure('position',[100 60 1000 480]);
      %------read netcdf data--------
      infile = [indir,'/',expri{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,minu,ccc,'00'];
      hgt = ncread(infile,'HGT');     
      plot(hgt(:,100),'LineWidth',4.5,'color',cexp(ei,:)); hold on        
      
% legh=legend(expnam,'Box','off','Interpreter','none','fontsize',18,'Location','ne','FontName','Monospaced');

set(gca,'fontsize',20,'linewidth',2,'Ylim',[0 2500])
xlabel('X (km)');  ylabel('Hheight (m)')
%tit='terrain height';   
tit=expnam{ei};
title(tit,'fontsize',30)
drawnow
%
fignam=['terrain_',expri{ei}(1:7)];
outfile=[outdir,'/',fignam];
print(hf,'-dpng',[outfile,'.png']) 
system(['convert -trim ',outfile,'.png ',outfile,'.png']);

end %exp
%%


expri={'TWIN003B';'TWIN013B'};  
    
expnam={'TOPO';'H500'};
        
cexp=[  227 128 29;122 170 43  ]/255;

exptext='210906';
 
nexp=size(expri,1);


hf=figure('position',[100 60 900 700]);


for ei=1:nexp
      %------read netcdf data--------
      infile = [indir,'/',expri{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,minu,ccc,'00'];
      hgt = ncread(infile,'HGT');     
      plot(hgt(:,100),'LineWidth',4.5,'color',cexp(ei,:)); hold on        
end %exp
     
legh=legend(expnam,'Box','off','Interpreter','none','fontsize',28,'Location','ne','FontName','Monospaced');

set(gca,'fontsize',20,'linewidth',2,'Ylim',[0 2500],'Ylim',[0 1500])
xlabel('X (km)');  ylabel('Hheight (m)')
%tit='terrain height';   
% tit=expnam{ei};
% title(tit,'fontsize',30)
drawnow
%
fignam=['terrain_',exptext];
outfile=[outdir,'/',fignam];
print(hf,'-dpng',[outfile,'.png']) 
system(['convert -trim ',outfile,'.png ',outfile,'.png']);