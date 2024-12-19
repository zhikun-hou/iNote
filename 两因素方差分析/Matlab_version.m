clear; clc;

% ============= 两因素完全随机 ==================

tbl = table([3,6,4,3]',[4,6,4,2]',[5,7,5,2]',[4,5,3,3]',[8,9,8,7]',[12,13,12,11]','VariableNames',["A1B1","A1B2","A1B3","A2B1","A2B2","A2B3"]);

% matlab的anova2函数需要以特定方式进行排列
mat = table2array(tbl);

% 输出anova的结果
[p,tbl,stats] = anova2([mat(1:4,1:3);mat(1:4,4:6)],4,"off");
tbl
ms = tbl{5,4};
df = tbl{5,3};

% 输出事后多重比较的结果
results = multcompare(stats,"Display","off");
tbl = array2table(results,"VariableNames",["Group A","Group B","Lower Limit","A-B","Upper Limit","P-value"])

% 输出简单效应的结果
simple = array2table(strings(0,3));
simple.Properties.VariableNames = {'conditions','F value','P value'};

[p,tbl2,stats] = anova1(mat(:,1:3),[],"off");
F = tbl2{2,4}/ms;
simple{1,1} = "A=1";
simple{1,2} = F;
simple{1,3} = 1-fcdf(F,tbl2{2,3},df);
[p,tbl2,stats] = anova1(mat(:,4:6),[],"off");
F = tbl2{2,4}/ms;
simple{2,1} = "A=2";
simple{2,2} = F;
simple{2,3} = 1-fcdf(F,tbl2{2,3},df);

[p,tbl2,stats] = anova1(mat(:,[1,4]),[],"off");
F = tbl2{2,4}/ms;
simple{3,1} = "B=1";
simple{3,2} = F;
simple{3,3} = 1-fcdf(F,tbl2{2,3},df);
[p,tbl2,stats] = anova1(mat(:,[2,5]),[],"off");
F = tbl2{2,4}/ms;
simple{4,1} = "B=2";
simple{4,2} = F;
simple{4,3} = 1-fcdf(F,tbl2{2,3},df);
[p,tbl2,stats] = anova1(mat(:,[3,6]),[],"off");
F = tbl2{2,4}/ms;
simple{5,1} = "B=3";
simple{5,2} = F;
simple{5,3} = 1-fcdf(F,tbl2{2,3},df);

simple

% ============= 两因素重复测量 被试间设计 ==================

tbl = table([3,6,4,3,4,5,3,3]',[4,6,4,2,8,9,8,7]',[5,7,5,2,12,13,12,11]',categorical([1,1,1,1,2,2,2,2]'),'VariableNames',["B1","B2","B3","A"]);

design = table([1,2,3]','VariableNames',["B"]);
rm = fitrm(tbl,'B1-B3~A','WithinModel','B','WithinDesign',design);

mauchly(rm) % 球形检验：没有通过
epsilon(rm) % 查看Greenhouse-Geisser和Huyb-Feldt的epsilon
tbl_within = ranova(rm) % 查看被试内因素的结果
tbl_between = anova(rm) % 查看被试间因素的结果

mat = tbl{:,["B1","B2","B3"]};

% 计算简单效应
simple = array2table(strings(0,3));
simple.Properties.VariableNames = {'conditions','F value','P value'};

rm = fitrm(tbl(1:4,1:3),"B1-B3~1",'WithinDesign',table(categorical([1,2,3]'),'VariableNames',{'B'}));
tbl2 = ranova(rm);
simple{1,1} = "A=1";
simple{1,2} = tbl2{1,4};
simple{1,3} = tbl2{1,5};
rm = fitrm(tbl(5:8,1:3),"B1-B3~1",'WithinDesign',table(categorical([1,2,3]'),'VariableNames',{'B'}));
tbl2 = ranova(rm);
simple{2,1} = "A=2";
simple{2,2} = tbl2{1,4};
simple{2,3} = tbl2{1,5};

[p,tbl2,stats] = anova1(reshape(mat(:,1),4,2),[],"off");
simple{3,1} = "B=1";
simple{3,2} = tbl2{2,5};
simple{3,3} = tbl2{2,6};
[p,tbl2,stats] = anova1(reshape(mat(:,2),4,2),[],"off");
simple{4,1} = "B=2";
simple{4,2} = tbl2{2,5};
simple{4,3} = tbl2{2,6};
[p,tbl2,stats] = anova1(reshape(mat(:,3),4,2),[],"off");
simple{5,1} = "B=3";
simple{5,2} = tbl2{2,5};
simple{5,3} = tbl2{2,6};

simple

% ============= 两因素重复测量 被试内设计 ==================

tbl = table([3,6,4,3]',[4,6,4,2]',[5,7,5,2]',[4,5,3,3]',[8,9,8,7]',[12,13,12,11]');

% 注意，必须使用categorical函数将数值变量转化为因子，否则计算出的自由度不正确
design = table(categorical([1,1,1,2,2,2]'),categorical([1,2,3,1,2,3]'),'VariableNames',{'A','B'});
rm = fitrm(tbl,'Var1-Var6~1','WithinModel','A*B','WithinDesign',design);

[output,between,within] = ranova(rm,'WithinModel','A*B');
disp(output)
% 由于有多个被试内因素，需要手动指定C矩阵
mauchly(rm,within{3}) % 球形检验：B
mauchly(rm,within{4}) % 球形检验：A*B

% 输出简单效应的结果
simple = array2table(strings(0,3));
simple.Properties.VariableNames = {'conditions','F value','P value'};

rm = fitrm(tbl(:,1:3),"Var1-Var3~1",'WithinDesign',table(categorical([1,2,3]'),'VariableNames',{'B'}));
tbl2 = ranova(rm);
simple{1,1} = "A=1";
simple{1,2} = tbl2{1,4};
simple{1,3} = tbl2{1,5};
rm = fitrm(tbl(:,4:6),"Var4-Var6~1",'WithinDesign',table(categorical([1,2,3]'),'VariableNames',{'B'}));
tbl2 = ranova(rm);
simple{2,1} = "A=2";
simple{2,2} = tbl2{1,4};
simple{2,3} = tbl2{1,5};
rm = fitrm(tbl(:,[1,4]),"Var1,Var4~1",'WithinDesign',table(categorical([1,2]'),'VariableNames',{'A'}));
tbl2 = ranova(rm);
simple{3,1} = "B=1";
simple{3,2} = tbl2{1,4};
simple{3,3} = tbl2{1,5};
rm = fitrm(tbl(:,[2,5]),"Var2,Var5~1",'WithinDesign',table(categorical([1,2]'),'VariableNames',{'A'}));
tbl2 = ranova(rm);
simple{4,1} = "B=1";
simple{4,2} = tbl2{1,4};
simple{4,3} = tbl2{1,5};
rm = fitrm(tbl(:,[3,6]),"Var3,Var6~1",'WithinDesign',table(categorical([1,2]'),'VariableNames',{'A'}));
tbl2 = ranova(rm);
simple{5,1} = "B=1";
simple{5,2} = tbl2{1,4};
simple{5,3} = tbl2{1,5};

simple

