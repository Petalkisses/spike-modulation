%第一步，得到原始数据a的Raster和随机数据c的Raster
Raster_shuffle=cell(1,2500);Raster_real=cell(1,2500);%建立空cell待补充
for u=1:2500;%随机2500次
   Ic=[];Ia=[];%每一个I循环代表它是Raster内部的每一行（或每一个spike）
   for i=1:length(SWR);%
      time=SWR(i);%得到SWR的时间戳,单位：秒
      order_spike=find(spike>(time-1)&spike<(time+1));%得到SWR前后一秒的时间范围内spike的活动的索引
      spike_SWR=spike(order_spike);%根据索引为SWR赋值
      spike_SWR=spike_SWR-time;%SWR时间归一化
      A=transpose(spike_SWR);
      spike_count=length(spike_SWR);
      B=(rand(1,spike_count)-0.5)*0.1;%B为生成随机数，控制范围在-0.05到0.05
      C=A+B+(rand-0.5);%生成A的随机数据（抖动+漂移）C
     %检查C里的数据是否在范围内，如果不在范围内的话需要修正
      MoreThan1=find(C>1);
      C(MoreThan1)=C(MoreThan1)-1;      
      LessThan1=find(C<-1);
      C(LessThan1)=C(LessThan1)+1;
      Ic=[Ic,C];Ia=[Ia,A];%随机数据的Raster:Ic,原始数据的Raster:Ia
    end
    Raster_shuffle{u}=Ic;Raster_real{u}=Ia;
end
%第二步，得到原始数据a的PSTH，随机数据c的PSTH和由随机数据c平均而成的基线数据PSTH
%计算原始数据的PSTH
f=Raster_real{1};
edges = [-1:0.02:1]; %Define the edges of the histogram
psth = zeros(101,1); %Initialize the PSTH with zeros
bar(edges,psth); %Plot PSTH as a bar graph
[PSTH_real,x]=hist(f,edges);%把PSTH画出来，提取纵轴高度y和横轴中点x
PSTH_real=PSTH_real(2:100);%去掉两端
%计算随机数据的PSTH
PSTH_shuffle=cell(1,2500);
 for i=1:2500;
    f=Raster_shuffle{i};
    edges = [-1:0.02:1]; %Define the edges of the histogram
    psth = zeros(101,1); %Initialize the PSTH with zeros
    bar(edges,psth); %Plot PSTH as a bar graph
    [y,x]=hist(f,edges);%把每一个PSTH画出来，提取纵轴高度y和横轴中点x
    y=y(2:100);%去掉两端
    PSTH_shuffle{i}=[y];
 end

%计算随机平均/基线数据的PSTH
Raster_baseline=[];
for i=1:2500;
   Raster_baseline=[Raster_shuffle{i},Raster_baseline];
end
edges = [-1:0.02:1]; %Define the edges of the histogram
psth = zeros(101,1); %Initialize the PSTH with zeros
bar(edges,psth); %Plot PSTH as a bar graph
[PSTH_baseline,x]=hist(Raster_baseline,edges);%把每一个PSTH画出来，提取纵轴高度y和横轴中点x
PSTH_baseline=PSTH_baseline*0.0004;%平均
PSTH_baseline=PSTH_baseline(2:100);%去掉两端

%计算时间窗口内的平方，得到方差%%需要把时间窗口定义好，以方便后期修正
Square_real=sum(PSTH_real(50:60).^2);%调参数：时间窗口为50到60
Square_baseline=sum(PSTH_baseline(50:60).^2);%调参数：时间窗口为50到60
SquareDifference_real=Square_real-Square_baseline;%作差

SquareDifference_Shuffle=[]
for i=1:2500;
    Square_shuffle=PSTH_shuffle{i};
    Square_shuffle=sum(Square_shuffle(50:60).^2);%调参数：时间窗口为50到60
    SquareDifference_shuffle=Square_shuffle-Square_baseline;%作差
    SquareDifference_Shuffle=[SquareDifference_Shuffle,SquareDifference_shuffle];
end

%比较方差大小，判断调制效应

Max_SquareDifference_Shuffle=find(SquareDifference_Shuffle>SquareDifference_real);
if length(Max_SquareDifference_Shuffle)<25;%调参数：统计显著性
    disp 神经元受到显著调制;disp(datestr(now));
else disp 神经元未受到显著调制;disp(datestr(now));
end

%循环分析多个神经元，以下循环输入至命令行，需要调参

%SPIKE={SPK09a SPK09b SPK09c SPK09U SPK10a SPK10b SPK10c SPK10U SPK11a SPK11b SPK11c SPK11U};
%Zscore_real=cell(1:length(SPIKE));
%for m=1:12;
%spike=SPIKE{m};
%Neuron_modulation_identify;
%Zscore_real{m}=zscore(PSTH_real);
%disp(m);
%end

%画图并导出，以下循环输入至命令行
%for i=1:12;
%figure(i);
%heatmap(Zscore_real{i},'ColorLimits',[0 3]);colormap(gca, 'jet'); 
%saveas(gcf,num2str(i),'epsc')
%end
%导出z分数的realPSTH，以下循环输入至命令行
%for i=1:12;
%x=Zscore_real{i};
%xlswrite('1',x,i);
%end

