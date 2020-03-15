function [ExREP,ExChar,REPNum,gridFit,Population,Velocity,enterCountList,repNumList,avgPersonalFitnessList,avgGlobalFitnessList]=FMOPSOmain(Pop,Velo)
%UNTITLED3 粒子群优化算法的主函数
%
global SWITCHNUM TRAVDIS;
global setNum omiga C1 C2 MaxFlyVeo;
global OldPopulation PBESTS PBSESTFitNess  ExternFitNess ExternPopulation RepCount fitVictorLen ExternREPCharacter iteraNum  FitNessRate %ExpSetNum
%粒子群算法参数
setNum=5;   %种群数量 
%ExpSetNum=30; %外部种群种群大小
fitVictorLen=5; %适应度向量长度
RepCount=0;%外部种群包含的不重复解的数量
omiga=1.4;%惯性因子
C1=2.0;     %个体加速常数
C2=2.0;    %社会加速常数
MaxFlyVeo=2*TRAVDIS/SWITCHNUM; %最大飞行速度
iteraNum=10; %迭代次数
FitNessRate=1;
enterCountList=zeros(1,iteraNum);
repNumList=zeros(1,iteraNum);
avgPersonalFitnessList=[];
avgGlobalFitnessList=[];
%%
%产生初始种群
if nargin==2
    Population=Pop;
    Velocity=Velo;
else
    Population=CreateInitPopulation(setNum,SWITCHNUM);  %生成种群
    Velocity=zeros(setNum,SWITCHNUM);
end
ExternPopulation=zeros(setNum,SWITCHNUM);%外部种群
ExternFitNess=zeros(setNum,fitVictorLen);%外部种群的适应度向量
ExternREPCharacter=zeros(setNum,fitVictorLen);%外部存储的特征向量，指[Energy,Time,jerk,MissError,overSpeed,jerk]
PBSESTFitNess=zeros(setNum,fitVictorLen);
%初始化外部种群
PBESTS=Population;
OldPopulation=Population;
[Population,Velocity,~,gridPop,gridFit] = FMOPSOStatistics( Population,Velocity,0);  %统计并且更新外部种群
%%
%迭代开始
for iter=1:iteraNum
    %% 更新粒子群中的粒子速度和位置
    OldPopulation=Population;
     FitNessRate=1-iter/iteraNum;
    SIGMA=(1-iter/iteraNum)*1000;  %f-gbest的方差
    [Population,Velocity]=FMOPSOIterate(Population,Velocity,PBESTS,SIGMA,gridFit,gridPop); 
    Population=sort(Population,2);%重新排序一下
    %% 修改惯性因子,线性法
    omiga=0.9*(1-iter/iteraNum)+0.4;    
    [Population,Velocity,enterConter,gridPop,gridFit,avgPersonalFitness,avgGlobalFitness] = FMOPSOStatistics( Population,Velocity,iter);
    enterCountList(iter)=enterConter;
    repNumList(iter)=RepCount;   
    avgPersonalFitnessList=[avgPersonalFitnessList;avgPersonalFitness];
    avgGlobalFitnessList=[avgGlobalFitnessList;avgGlobalFitness];
    disp(iter);
end
    ExREP=ExternPopulation;
    ExChar=ExternREPCharacter;
    REPNum=RepCount;
    save('Result.mat','ExREP','ExChar','enterCountList','repNumList','avgGlobalFitnessList','avgPersonalFitnessList');
    figure('Name','更新率');
    plot(enterCountList);
    hold on
    plot(repNumList);
end

