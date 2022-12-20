hold on
pgon = polyshape([0.79 0.79 1.58 1.58 3.17 3.17 ],...
    [-8.20 -1.95 -1.95 -6.07 -6.07 -8.20]);
plot(pgon, 'FaceColor', 'none','EdgeColor','r')

rectangle('Position',[0 -8.66 3.96 8.66],'LineStyle','-','LineWidth',0.5)
ylim([-8.66 0])
xlim([0 3.96])