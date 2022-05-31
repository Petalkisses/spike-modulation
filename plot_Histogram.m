for i=1:length(timestampx);
time=timestampx(i);%得到SWR的时间戳,单位：秒
order_spike=find(spike>(time-1)&spike<(time+1));%得到SWR前后一秒的时间范围内spike的活动的索引
spike_SWR=spike(order_spike);
spike_SWR=spike_SWR-time;
writematrix(spike_SWR,'spike.xlsx','WriteMode','append');%把所有索引的SWR周边的spike时间信息保存在spike.xlsx里
end;%结束后使用histogram再把汇总的spike画出来
edges = [-1:0.02:1]; %Define the edges of the histogram
psth = zeros(101,1); %Initialize the PSTH with zeros
bar(edges,psth); %Plot PSTH as a bar graph
histogram(spike1,edges);
%version1.1 Histogram