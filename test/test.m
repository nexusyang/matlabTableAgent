clear;clc;
T=readtable("data\worldMacroData.xlsx",TextType="string",VariableNamingRule="preserve");
T.Properties.VariableNames(["Var1","Var2"])=['VName',"Nation"];
T.VName=fillmissing(T.VName,"previous");
vs_xy=["通胀（平均消费者价格）—指数", "广义货币（现价本币）（本币）"];
T=T(ismember(T.VName,vs_xy),:);
T=T.stack(3:width(T),'IndexVariableName','Year','NewDataVariableName','Data')...
.unstack('Data','VName','VariableNamingRule','preserve')...
.grouptransform("Nation",@transTableFunc,["广义货币（现价本币）（本币）","通胀（平均消费者价格）—指数"]);
% stack(T,3:width(T),'IndexVariableName','Year','NewDataVariableName','Data');
% T=T.unstack(0,0,'Data','VName','VariableNamingRule','preserve');
% T=grouptransform(T,"Nation",@transTableFunc,["广义货币（现价本币）（本币）","通胀（平均消费者价格）—指数"]);
figure(1);
hold all;
gscatter(T.("广义货币（现价本币）（本币）"),T.("通胀（平均消费者价格）—指数"),T.Nation);
xlim([-0.2 0.5]);
ylim([-0.02 0.16]);