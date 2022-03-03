

clear; ccc=':';

expri='TWIN201';
expri1=[expri,'Pr001qv062221'];  expri2=[expri,'B'];  


indir='/mnt/HDDC/pwin/Experiments/expri_twin/';  

year='2018'; mon='06';  infilenam='wrfout';  dom='01';  grids=1; 


s_date='23'; s_hr='01';  s_min='00';

    infile1=[indir,'/',expri1,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    infile2=[indir,'/',expri2,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00']; 

 tic
    
 PowSpe=cal_spectr(infile1,infile2,1:33);    
 [~,CMDTE] = cal_DTE_2D(infile1,infile2) ; 
 
 toc