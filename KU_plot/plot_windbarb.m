  function plot_windbarb(WS,WD,P3,wbarx0,wcut)


    theta = 450-WD;
    wbar  = linspace(0,5,wcut);
    wfeah = linspace(0,1.0,3);
    wfeaf = linspace(0,2.0,3);
    
    wbarx = wbarx0 + wbar*cosd(theta);
    wbary = -log(P3) + wbar*sind(theta)./35;
    kt    = round(round(WS./0.514444)./5);

    plot(wbarx,wbary,'-k','LineWidth',1.0)
    
    
    if (kt == 1)
        wfeax = wbarx(wcut-2)   +wfeah.*cosd(theta-60);
        wfeay = wbary(wcut-2)   +wfeah.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
    end
    if (kt == 2)
        wfeax = wbarx(wcut  )   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut  )   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
    end
    if (kt == 3)
        wfeax = wbarx(wcut  )   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut  )   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-2)   +wfeah.*cosd(theta-60);
        wfeay = wbary(wcut-2)   +wfeah.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
    end
    if (kt == 4)
        wfeax = wbarx(wcut  )   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-2)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-2)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
    end
    if (kt == 5)
        wfeax = wbarx(wcut  )   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut  )   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-2)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-2)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-4)   +wfeah.*cosd(theta-60);
        wfeay = wbary(wcut-4)   +wfeah.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
    end
    if (kt == 6)
        wfeax = wbarx(wcut  )   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut  )   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-2)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-2)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-4)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-4)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
    end
    if (kt == 7)
        wfeax = wbarx(wcut  )   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut  )   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-2)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-2)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-4)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-4)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-6)   +wfeah.*cosd(theta-60);
        wfeay = wbary(wcut-6)   +wfeah.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
    end
    if (kt == 8)
        wfeax = wbarx(wcut  )   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut  )   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-2)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-2)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-4)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-4)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-6)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-6)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
    end
    if (kt == 9)
        wfeax = wbarx(wcut  )   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut  )   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-2)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-2)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-4)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-4)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-6)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-6)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-8)   +wfeah.*cosd(theta-60);
        wfeay = wbary(wcut-8)   +wfeah.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
    end
    if (kt == 10)
        wfeax = wbarx(wcut-2)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-2)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        plot([wbarx(wcut  ) wfeax(end)],[wbary(wcut  ) wfeay(end)],'-k','LineWidth',1.0)
    end
    if (kt == 11)
        wfeax = wbarx(wcut-2)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-2)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        plot([wbarx(wcut  ) wfeax(end)],[wbary(wcut  ) wfeay(end)],'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-4)   +wfeah.*cosd(theta-60);
        wfeay = wbary(wcut-4)   +wfeah.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
    end
    if (kt == 12)
        wfeax = wbarx(wcut-2)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-2)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        plot([wbarx(wcut  ) wfeax(end)],[wbary(wcut  ) wfeay(end)],'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-4)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-4)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
    end
    if (kt == 13)
        wfeax = wbarx(wcut-2)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-2)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        plot([wbarx(wcut  ) wfeax(end)],[wbary(wcut  ) wfeay(end)],'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-4)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-4)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-6)   +wfeah.*cosd(theta-60);
        wfeay = wbary(wcut-6)   +wfeah.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
    end
    if (kt == 14)
        wfeax = wbarx(wcut-2)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-2)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        plot([wbarx(wcut  ) wfeax(end)],[wbary(wcut  ) wfeay(end)],'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-4)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-4)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-6)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-6)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
    end
    if (kt == 15)
        wfeax = wbarx(wcut-2)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-2)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        plot([wbarx(wcut  ) wfeax(end)],[wbary(wcut  ) wfeay(end)],'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-4)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-4)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-6)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-6)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-8)   +wfeah.*cosd(theta-60);
        wfeay = wbary(wcut-8)   +wfeah.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
    end
    if (kt == 16)
        wfeax = wbarx(wcut-2)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-2)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        plot([wbarx(wcut  ) wfeax(end)],[wbary(wcut  ) wfeay(end)],'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-4)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-4)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-6)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-6)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-8)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-8)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
    end
    if (kt == 17)
        wfeax = wbarx(wcut-2)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-2)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        plot([wbarx(wcut  ) wfeax(end)],[wbary(wcut  ) wfeay(end)],'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-4)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-4)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-6)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-6)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-8)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-8)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-10)   +wfeah.*cosd(theta-60);
        wfeay = wbary(wcut-10)   +wfeah.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
    end
    if (kt == 18)
        wfeax = wbarx(wcut-2)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-2)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        plot([wbarx(wcut  ) wfeax(end)],[wbary(wcut  ) wfeay(end)],'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-4)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-4)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-6)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-6)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-8)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-8)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-10)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-10)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
    end
    if (kt == 19)
        wfeax = wbarx(wcut-2)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-2)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        plot([wbarx(wcut  ) wfeax(end)],[wbary(wcut  ) wfeay(end)],'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-4)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-4)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-6)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-6)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-8)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-8)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-10)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-10)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-12)   +wfeah.*cosd(theta-60);
        wfeay = wbary(wcut-12)   +wfeah.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
    end
    if (kt == 20)
        wfeax = wbarx(wcut-2)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-2)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        plot([wbarx(wcut  ) wfeax(end)],[wbary(wcut  ) wfeay(end)],'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-4)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-4)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        plot([wbarx(wcut-2) wfeax(end)],[wbary(wcut-2) wfeay(end)],'-k','LineWidth',1.0)
    end
    
    