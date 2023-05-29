function [h_bar]=colorbar_levels(Levls,varargin)
%%% Plots colorbar with discrete and specified colors and ticks
%%% Inputs:
%%% Levls- tick levels in colormap
%%% varargin - can have only one argument 'vert/horizontal' for the colorbar
%%% Output:
%%% h_bar is the handle to colorbar
len=length(Levls);
h_bar=[];
if(isempty(varargin)), arg='vert'; else arg=varargin{1}; end;
if(~isempty(Levls))
    L1=((1:length(Levls))*(diff(caxis)/(length(Levls)+1)))+min(caxis());
    if(lower(arg(1)) == 'h')
        h_bar=colorbar('location','SouthOutside','XTick',L1,'XTickLabel',Levls);
    elseif (lower(arg(1)) == 'v')
%        h_bar=colorbar('YTick',L1(2:2:end),'YTickLabel',Levls(2:2:end));
        h_bar=colorbar('YTick',L1,'YTickLabel',Levls);
    end
else
    h_bar=colorbar(arg);
end
