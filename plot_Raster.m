for p=1:length(timestampx);
time=timestampx(p);%得到SWR的时间戳,单位：秒
order_spike=find(spike>(time-2)&spike<(time+2));%得到SWR前后一秒的时间范围内spike的活动的索引
spike_SWR=spike(order_spike);
spike_SWR=spike_SWR-time;
%figure %Create a new figure
hold on %Allow multiple plots on the same graph
for i = 1:length(spike_SWR) %Loop through each spike time
line([spike_SWR(i),spike_SWR(i)],[p p+1]) %Create a tick mark at x = t1(i) with a height of 1
end
end;
saveas(1,'fig1.fig')%saveas(gca, filename, fileformat);
print(1,'-dmeta','fig1.emf');
%verision1.0 Raster
