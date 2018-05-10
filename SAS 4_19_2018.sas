libname original "C:\Users\AHENDE8\Dropbox\Dissertation work\Datasets\Original- Do Not Touch\SAS";
libname a "C:\Users\AHENDE8\Dropbox\Dissertation work\Datasets\Analysis\SAS";
*find location of formats and open;
libname formats "C:\Users\AHENDE8\Dropbox\Dissertation work\Datasets\Analysis\SAS";
options fmtsearch=(formats);

*to look at formats and answer options;
proc format library=formats FMTLIB;
run;


*create original DO NOT TOUCH file; *only did this the first time, then can ignore after dataset is replicated;
data original.a;
set a;
run;

*create working analysis file;
data a.analysis;
set original.a;
run;



**********************************************************
*start here in future after running libname and formats;
*view data;
proc format library=a.formats; run;
proc contents data=a.analysis; run;

*look at demographics by low high depressed people and missing values;
proc freq data=a.analysis;
tables age*eds_cat marital*eds_cat education*eds_cat income*eds_cat 
gravidity*eds_cat parity*eds_cat ins_type*eds_cat alcohol*eds_cat 
tobacco*eds_cat firstprenatalbmi_cat*eds_cat marijuana*eds_cat/list; *or can do/list missing to see exactly where people are missing;
run; 

*delete observations with missing eds scores at timepoint 1;
data subset;
   set a.analysis;
   if eds_totalscore = . and visitnumber=1 then delete;
run;
*total sample size is 193 now;

proc print data=subset;
   title 'Omitting observations with missing EDS score at timepoint 1';
run;
proc means data=subset;
var age education income gravidity parity; *of all cont variables;
run;
proc univariate data=subset; *all pbde variables are not normally distributed;
var age pbde47 pbde99 pbde100 pbde153 eds_totalscore;
where visitnumber=1;
title;
run;

proc freq data=subset;
tables eds_cat;
where visitnumber=1;
run;
proc freq data=subset;
tables eds_cat;
where visitnumber=2;
run;

*look at demographics by low high depressed people and missing values of subset;
proc freq data=subset;
tables age*eds_cat marital*eds_cat  
 alcohol*eds_cat tobacco*eds_cat marijuana*eds_cat medicaid_type*eds_cat/norow nopercent missing;
where visitnumber=1;
run; 

proc freq data=subset;
tables firstprenatalbmi_cat*eds_cat ins_type*eds_cat income*eds_cat
        gravidity*eds_cat parity*eds_cat education*eds_cat/ norow nopercent missing;
where visitnumber=1;
run;

*look as associations between demographics and eds category;
title 'Associations between demographics and high and low risk of depression';
proc freq data=subset;
tables marital*eds_cat alcohol*eds_cat tobacco*eds_cat marijuana*eds_cat /chisq;
where visitnumber=1;
Title;
run;
proc freq data=subset;
tables education*eds_cat income*eds_cat ins_type*eds_cat firstprenatalbmi_cat*eds_cat medicaid_type*eds_cat/chisq;
where visitnumber=1;
Title;
run;

proc ttest data=subset;
class eds_cat;
var age;
where visitnumber=1;
run;

proc means data=subset;
var age;
class eds_cat;
where visitnumber=1;
run;
proc freq data=subset;
tables eds_cat marijuana tobacco alcohol/ list missing;
run;

proc freq data=subset;
tables eds_cat_tri1 eds_cat_tri2/ list missing;
run; 

proc print data=subset;
var income;
run;
proc contents data=subset;
run;

proc freq data=subset;
tables ins_type medicaid_type;
where visitnumber=1;
run;

data subset2;
set subset;
income3 = income;
     if income=. then income3=.;
     else if income=0 then income3=0;
	 else if income=1 or income=2 or income=3 then income3=1;
     else income3=2;
	 label income3 = ' Recoded income3, <100(0), 100-199(1), 200+(2)'; *good practice for any new variable created;

parity2= parity;
     if parity=. then parity2=.;
	 else if parity=0 then parity2=0;
     else if parity=1 then parity2=1;
	 else parity2=2;
	 label parity2= 'Recoded parity2, 0(0), 1(1), 2+(2)';

insurance=.;
	if ins_type=0 and medicaid_type=1 then insurance=1; *all Low income medicaid=1;
	else if ins_type=0 and medicaid_type=2 then insurance=2; *all RSM medicaid=2;
	else if ins_type=1 or ins_type=2 then insurance=3; *all private insurance=3;
	label insurance= 'Recoded insurance LIM(1), RSM(2), Private(3)';
	run;

*check variables against each other with missing;
proc freq data=subset2;
tables income3*income parity*parity2/list missing;
run; 
proc freq data=subset2;
tables income3*eds_cat parity2*eds_cat/missing;
where visitnumber=1;
run; 
proc freq data=subset2;
tables insurance*ins_type/list missing;
run;
proc freq data=subset2;
tables insurance*eds_cat/missing;
where visitnumber=1;
run; 

*check associations with parity2 and insurance;
proc freq data=subset2;
tables parity2*eds_cat/chisq;
where visitnumber=1;
Title;
run;
proc freq data=subset2;
tables insurance*eds_cat/chisq;
where visitnumber=1;
Title;
run;
proc glm data=subset2;
class insurance;
model eds_totalscore=insurance;
means insurance;
run;


*look at EDS categories created;
*eds_totalscore- con't variable, skewed right;
proc univariate data=subset2;
var eds_totalscore;
histogram eds_totalscore/normal;
run; 

proc freq data=subset2;
tables eds_cat eds_cat_tri1 eds_cat_tri2/list missing;
run;
*total N week 8-14 = 193, N week 24-30 = 160;

*look at eds categories by time 1 and time 2;
proc freq data=subset2;
tables eds_cat;
where visitnumber=1;
run;
proc freq data=subset2;
tables eds_cat;
where visitnumber=2;
run;
proc freq data=subset2;
tables eds_cat visitnumber;
run;

*create bar chart of eds categories;
title "Frequency of Overall EDS categories";
proc sgplot data=subset2;
vbar eds_cat;
run;
title "Frequency of EDS categories at 8-14 weeks";
proc sgplot data=subset2;
vbar eds_cat_tri1;
run;title "Frequency of EDS categories at 24-30 weeks";
proc sgplot data=subset2;
vbar eds_cat_tri2;
run;
********************************************************************************
*look at PBDE descriptives;
proc univariate data=subset2;
var pbde47 pbde99 pbde100 pbde153;
histogram pbde47 pbde99 pbde100 pbde153;
where visitnumber=1;
run;

*create scatterplot matrix of pbde variables by eds category;
proc sgscatter data=subset2;
  title "Scatterplot Matrix for PBDE Data";
  matrix pbde47 pbde99 pbde100 pbde153
         / group=eds_cat;
run;
title;

*graph scatterplot of EDS by each PBDE;
TITLE 'Scatterplot - EDS scores and PBDE47';
PROC GPLOT DATA=subset2;
     PLOT eds_totalscore*pbde47;
RUN;

TITLE 'Scatterplot - EDS scores and PBDE99';
PROC GPLOT DATA=subset2;
     PLOT eds_totalscore*pbde99 ;
RUN;

TITLE 'Scatterplot - EDS scores and PBDE100';
PROC GPLOT DATA=subset2;
     PLOT eds_totalscore*pbde100;
RUN;

TITLE 'Scatterplot - EDS scores and PBDE153';
PROC GPLOT DATA=subset2;
     PLOT eds_totalscore*pbde153 ;
RUN;

*look at quintile variables that are already in dataset;
proc freq data=subset2;
tables age*pbde100quintiles marital*pbde100quintiles education*pbde100quintiles
income*pbde100quintiles gravidity*pbde100quintiles parity*pbde100quintiles
ins_type*pbde100quintiles alcohol*pbde100quintiles 
tobacco*pbde100quintiles firstprenatalbmi_cat*pbde100quintiles 
marijuana*pbde100quintiles;
run; 

*need to make new variable with quartiles for pbde 47 99 100 153 bc quintiles is not recommended for exposures;
proc means data=subset2 n mean std q1 q3;
    var pbde47 pbde99 pbde100 pbde153; 
	where visitnumber=1;
	run;


*To construct quartiles, groups=4, must be
specified, otherwise the ranks (1,2,3,4,..)
are output.
*******************************************;
proc rank data=subset2
     groups=4
     out=quart;
var pbde47 pbde99 pbde100; *brought in;
ranks pbde47q pbde99q pbde100q; *created;
where visitnumber=1;

run;

*check work.quart output;
proc contents data= work.quart;
run;

*need to merge quart data containing the
quartiles into the main data set but need to make a separate (mid) temporary dataset;
data a; *new dataset I am creating;
merge quart subset2; *this is what I am bringing in (think of it as file A and file B);
by SUBJE0;
run;

* check new variable- upper quartile for each PBDE- not helpful;
proc means data=a missing;
    var pbde47q pbde99q pbde100q; 
	where visitnumber=1;
	run; 

*compared to original variable;
*Test to see what happened for missing; *must do each pbde separately;
	
proc means data=a missing; *says q1 has 119 observations (not equal quartiles);
class pbde47q;
var pbde47;
where visitnumber=1;
run;
proc means data=a missing; *says q2 has 124 observations;
class pbde99q;
var pbde99;
where visitnumber=1;
run;
proc means data=a missing; *says q2 has 122 obsertions;
class pbde100q;
var pbde100;
where visitnumber=1;
run;

*try a different method;
*use this code to find bounds of your quartiles;
Proc univariate data= subset2;
Var pbde47 pbde99 pbde100;
where visitnumber=1;
Run;
 
*This will output the q1 q2 q3 ? you can also do this in proc means like so:
*Proc means data = <dataset name> q1 q2 q3;
*Var <your pbde variable name>;
*Run;
 
*Take the values that are output and then code:;
*then create sum pbde variable to show high and low body burden;
data subset3;
set subset2;
pbde47_quartiles = .;
                If . <= pbde47 < 52.9 then pbde47_quartiles=0;
Else if 52.9 <= pbde47 < 86.0 then pbde47_quartiles=1;
Else if 86.0 <= pbde47 < 135.5 then pbde47_quartiles=2;
Else if pbde47 >= 135.5 then pbde47_quartiles=3;

 pbde99_quartiles = .;
                If . <= pbde99 < 11.8 then pbde99_quartiles=0;
Else if 11.8 <= pbde99 < 21.3 then pbde99_quartiles=1;
Else if 21.3 <= pbde99 < 38.5 then pbde99_quartiles=2;
Else if pbde99 >= 38.5 then pbde99_quartiles=3;

 pbde100_quartiles = .;
                If . <= pbde100 < 7.5 then pbde100_quartiles=0;
Else if 7.5 <= pbde100 < 17.0 then pbde100_quartiles=1;
Else if 17.0 <= pbde100 < 31.7 then pbde100_quartiles=2;
Else if pbde100 >= 31.7 then pbde100_quartiles=3;

highpbde= .;
   if pbde47_quartiles=3 and pbde99_quartiles=3 and pbde100_quartiles=3 then highpbde=1;
   else highpbde=0;
   label highpbde= 'Sum of 3rd Quartiles for PBDE 47, 99, 100'
   run;
lowpbde= .;
   if pbde47_quartiles=0 and pbde99_quartiles=0 and pbde100_quartiles=0 then lowpbde=1;
   else lowpbde=0;
   label lowpbde= 'Sum of Lower Quartiles for PBDE 47, 99, 100'
   run;

 
*as always, remember to check new variable against old variable;
proc freq data=subset3;
tables pbde47*pbde47_quartiles pbde99*pbde99_quartiles pbde100*pbde100_quartiles/list missing;
where visitnumber=1;
run; 
proc freq data=subset3; *checking to see how many people in each pbde quartile fall in low and high dep groups;
tables pbde47_quartiles*eds_cat/list missing;
where visitnumber=1;
run;
proc means data=subset3 missing; 
class pbde99_quartiles;
var pbde99;
where visitnumber=1;
run;
proc means data=subset3 missing; 
class pbde100_quartiles;
var pbde100;
where visitnumber=1;
run;
proc means data=subset3 missing; 
class pbde47_quartiles;
var pbde47;
where visitnumber=1;
run;
*check lowpbde and highpbde;
proc freq data=subset3; 
tables lowpbde*pbde47_quartiles*pbde99_quartiles*pbde100_quartiles/list missing;
where visitnumber=1;
run;
proc freq data=subset3; 
tables highpbde*pbde47_quartiles*pbde99_quartiles*pbde100_quartiles/list missing;
where visitnumber=1;
run;
proc freq data=subset3;
tables lowpbde;
where lowpbde=1 and visitnumber=1;
run;
proc freq data=subset3;
tables highpbde;
where highpbde=1 and visitnumber=1;
run;
* look at PBDEs by eds categories;
proc freq data=subset3;
tables lowpbde*eds_cat;
where lowpbde=1 and visitnumber=1;
run;
proc freq data=subset3;
tables highpbde*eds_cat/chisq;
where visitnumber=1;
run;
proc freq data=subset3;
tables lowpbde*eds_cat/chisq;
where visitnumber=1;
run;

proc means data=subset3;
var highpbde;
class eds_cat;
where visitnumber=1;
run;

* look at each pbde by high and low depressed people;
proc means data=subset3 missing;
var pbde47;
where visitnumber=1;
run;

proc means data=subset3 missing;
var pbde47;
class eds_cat;
where visitnumber=1;
run;

proc means data=subset3 missing;
var pbde99;
where visitnumber=1;
run;

proc means data=subset3 missing;
var pbde99;
class eds_cat;
where visitnumber=1;
run;

proc means data=subset3 missing;
var pbde100;
where visitnumber=1;
run;

proc means data=subset3 missing;
var pbde100;
class eds_cat;
where visitnumber=1;
run;
proc means data=subset3 missing;
var pbde153;
where visitnumber=1;
run;

proc means data=subset3 missing;
var pbde153;
class eds_cat;
where visitnumber=1;
run;
proc univariate data=subset3;
var pbde47 pbde99 pbde100 pbde153;
histogram pbde47 pbde99 pbde100 pbde153;
where visitnumber=1;
run;

*look at pbde distribution by age - do I want to use a matrix to view?;

 *create scatterplot matrix of pbde variables;
*this is not helpful;
proc sgscatter data=subset3;
  title "Scatterplot Matrix for Quartile PBDE Data";
  matrix pbde47_quartiles pbde99_quartiles pbde100_quartiles
         / group= eds_cat;
run;
title;

*would like to see graph of q=3 pbde data;
*this statement is not understood;
PROC GPLOT DATA=a;
     PLOT eds_totalscore*pbde47q if pbde47q=3;
RUN;


*create log transformed pbdes 99 100 153 (47 already done) and 
break EDS scores into 3 categories: low risk, high risk, severe risk;

data subset3;
set subset2;
Eds3_cat = eds_totalscore;
     if .<= eds_totalscore <= 9.99 then eds3_cat=0;
     else if 10 <= eds_totalscore <= 12.99 then eds3_cat=1;
     else eds3_cat=2;
	 label eds3_cat = ' Recoded eds_totalscore,low(0),high(1),severe(2)'; *good practice for any new variable created;

logPBDE99=log(pbde99);
label logpbde99 = 'Log transformation of PBDE 99';
logPBDE100=log(pbde100);
label logpbde100 = 'Log transformation of PBDE 100';
logPBDE153=log(pbde153);
label logpbde153 = 'Log transformation of PBDE 153';
GMpbde47=exp(1.9542489);
GMpbde99=exp(3.0553037);
GMpbde100=exp(2.6210122);
GMpbde153=exp(2.6210122);

if age=. then age_cat="                 ";
else if age <=24 then age_cat="Young 18-24";
else age_cat="Old 25-35";
run;

*as always, remember to check new variable against old variable;*so important;
proc freq data=subset3;
tables eds3_cat*eds_totalscore age*age_cat/list missing;
where visitnumber=1;
run; 
*get geometric means of each pbde;
proc means data=subset3 mean std cv min median max;
var pbde47 logpbde47 GMpbde47 pbde99 logpbde99 GMpbde99 pbde100 logpbde100 GMpbde100 pbde153 logpbde153 GMpbde153;
where visitnumber=1;
run;
*look at new eds category variable;
proc print data=subset3;
var eds_totalscore;
where visitnumber=1;
run;
proc freq data=subset3;
table eds3_cat;
where visitnumber=1;
run;
proc univariate data=subset3;
var age;
where visitnumber=1;
run;
proc freq data=subset3;
table age_cat*age;
where visitnumber=1;
run;
*check association between age categories and EDS categories;
proc freq data=subset3;
table age_cat*eds_cat/chisq;
where visitnumber=1;
run;
proc ttest data=subset3;
var age eds_totalscore;
where visitnumber=1;
run;
proc corr data=subset3;
var age eds_totalscore;
run;
proc corr data=subset3;
var tobacco logpbde47 logpbde99 logpbde100;
run;
***************************************;
 
* Need to make diff variable- change in EDS variable between time 1 and time 2;
proc freq data=a2;
table diff;
title 'checking variables';
run;title;

proc means data=a2;
class diff;
var eds_totalscore;
run;

proc means data=a2;
var eds_totalscore;
run;

*look at scatterplot matrix but with log pbde variables by eds_cat;
proc sgscatter data=subset3;
  title "Scatterplot Matrix for Log PBDE Data";
  matrix logpbde47 logpbde99 logpbde100 
         / group=eds_cat;
run;
title;

*make quartile variable for eds;
*look at main associations first
test main relationship
then test potential covariates between exposure and outcome
dag diagram 
put in table, use conservative pvalue of 0.02?
put those in model

***************************************************************START TESTING ASSOCIATIONS AND MODEL BUILDING;
*Test associations between EDS_category and each PBDE;
proc ttest data=subset3;
 class eds_cat;
 var pbde47;
 where visitnumber=1;
 run;
*Need to use nonparametric wilcoxin rank sum instead of ttest because all pbde variables are not normally distributed so 
 it violates underlying assumptions;
ods graphics on;
PROC NPAR1WAY data=subset3 wilcoxon median
plots= (wilcoxonboxplot medianplot);
Class eds_cat;
Var pbde47;
where visitnumber=1;
Exact; *OPTIONAL;
Run;
ods graphics off;
*shows great median box plot comparing 2 group medians and pvalue included;

ods graphics on;
PROC NPAR1WAY data=subset3 wilcoxon median
plots= (wilcoxonboxplot medianplot);
Class highpbde;
Var eds_totalscore;
where visitnumber=1;
Exact; *OPTIONAL;
Run;
ods graphics off;

 PROC NPAR1WAY data=subset3 wilcoxon;
 class eds_cat;
 var pbde99;
 where visitnumber=1;
 Exact;
 run;
PROC NPAR1WAY data=subset3 wilcoxon;
 class eds_cat;
 var pbde100;
 where visitnumber=1;
 Exact;
 run;
 proc corr data=subset3 spearman;
 plots=matrix (histogram);
 var

*test association between highpbde and lowpbde body burden and eds_cat; 
*not significant;
proc freq data=subset3;
tables highpbde*eds_cat/chisq;
where visitnumber=1;
Title;
run;
proc freq data=subset3;
tables tobacco*eds_cat/chisq;
where visitnumber=1;
title;
run;
proc NPAR1WAY data=subset3 wilcoxon;
 class tobacco;
 var pbde47;
 where visitnumber=1;
 run;
 proc NPAR1WAY data=subset3 wilcoxon;
 class tobacco;
 var pbde99;
 where visitnumber=1;
 run;
proc NPAR1WAY data=subset3 wilcoxon;
 class tobacco;
 var pbde100;
 where visitnumber=1;
 run;

proc freq data=subset3;
tables lowpbde*eds_cat/chisq;
where visitnumber=1;
Title;
run;

*test association between highpbde and lowpbde body burden and 3 eds cat (low, high, severe risk); 
*not significant;
proc freq data=subset3;
tables highpbde*eds3_cat/chisq;
where visitnumber=1;
Title;
run;
proc freq data=subset3;
tables lowpbde*eds3_cat/chisq;
where visitnumber=1;
Title;
run;  

proc corr data=subset3 spearman;*all highly correlated;
var pbde47 pbde99 pbde100;
where visitnumber=1;
run;
proc corr data=subset3 pearson spearman; *significant at pvalue=0.05;
var pbde47; 
with eds_totalscore;
where visitnumber=1;
run;
proc corr data=subset3 spearman;
var pbde99 eds_totalscore;
where visitnumber=1;
run;
proc corr data=subset3 spearman;
var pbde100 eds_totalscore;
where visitnumber=1;
run;

*now look at relationship between cont variables;
proc sgscatter data=subset3;
matrix eds_totalscore logpbde47 logpbde99 logpbde100 age;
title "Relationship between Risk of Depression, PBDE Congeners, and Age";
run;

proc univariate data=subset3;
var eds_totalscore;
histogram;
run;
proc corr data=subset3;
var eds_totalscore age; 
run;

*model building. I hypothesize higher pbde levels are associated with higher risk of depression;
*first look at unadjusted models (without the covariates);
proc reg data=subset3;
where visitnumber=1;
title "Impact of PBDE47 on Risk of Depression";
model eds_totalscore=pbde47;
run;
proc reg data=subset3;
where visitnumber=1;
title "Impact of PBDE99 on Risk of Depression";
model eds_totalscore=pbde99;
run;
proc reg data=subset3;
where visitnumber=1;
title "Impact of PBDE100 on Risk of Depression";
model eds_totalscore=pbde100;
run;

*add important covariates to each pbde model for adjusted models;
proc reg data=subset3;
where visitnumber=1;
title "Impact of LogPBDE47 on Risk of Depression";
model eds_totalscore=logpbde47 age marital medicaid_type firstprenatalbmi marijuana tobacco;
run;

proc reg data=subset3;
where visitnumber=1;
title "Impact of LogPBDE47 on Risk of Depression";
model eds_totalscore=logpbde47 age medicaid_type firstprenatalbmi marijuana tobacco;
run;*explains 19% of variability in EDS score at 8-12wks;
proc reg data=subset3;
where visitnumber=1;
title "Impact of LogPBDE47 on Risk of Depression";
model eds_totalscore=logpbde47 age medicaid_type firstprenatalbmi tobacco/CLB;
run;*explains 19% of variability in EDS score at 8-12wks;

proc reg data=subset3; *same characteristics with unlogged pbde;
where visitnumber=1;
title "Impact of PBDE47 on Risk of Depression";
model eds_totalscore=pbde47 age medicaid_type firstprenatalbmi tobacco/CLB;
run;

*if remove medicaid_type;
proc reg data=subset3;
where visitnumber=1;
title "Impact of LogPBDE47 on Risk of Depression";
model eds_totalscore=logpbde47 age firstprenatalbmi tobacco;
run;*explains 16% of variability in EDS score at 8-12wks;
proc reg data=subset3;
where visitnumber=1;
title "Impact of LogPBDE47 on Risk of Depression";
model eds_totalscore=logpbde47 firstprenatalbmi tobacco;
run; *explains 16% of variability in EDS score at 8-12wks;
****************************
*now look at regression models without tobacco and marijuana and with new income variable;
*full model;
proc reg data=subset3;
where visitnumber=1;
title "Full Model Impact of LogPBDE47 on Risk of Depression";
model eds_totalscore=logpbde47 age marital insurance firstprenatalbmi;
run; *6% variability;
*remove insurance;
proc reg data=subset3;
where visitnumber=1;
title "Full Model Impact of LogPBDE47 on Risk of Depression";
model eds_totalscore=logpbde47 age marital firstprenatalbmi/CLB;
run; *6% variability;

**************************
*look at pbde99;
proc reg data=subset3;
where visitnumber=1;
title "Impact of LogPBDE99 on Risk of Depression";
model eds_totalscore=logpbde99 age marital income firstprenatalbmi;
run;* explains 5%;

proc reg data=subset3;
where visitnumber=1;
title "Impact of LogPBDE99 on Risk of Depression";
model eds_totalscore=logpbde99 age marital firstprenatalbmi;
run;*  same 5%;
*look at pbde100;
proc reg data=subset3;
title "Impact of LogPBDE100 on Risk of Depression";
model eds_totalscore=logpbde100 age marital income firstprenatalbmi;
run;
*************************************************
**************************************************
START HERE TO COMPLETE LINEAR REG TABLE FOR 100 and add CLB to 99;
proc reg data=subset4;
where visitnumber=1;
title "Impact of LogPBDE100 on Risk of Depression";
model eds_totalscore=logpbde100 age marital medicaid_type firstprenatalbmi marijuana tobacco;
run;* explains 19%;
proc reg data=subset4;
where visitnumber=1;
title "Impact of LogPBDE100 on Risk of Depression";
model eds_totalscore=logpbde100 age medicaid_type firstprenatalbmi marijuana tobacco;
run;* explains 19%;
proc reg data=subset4;
where visitnumber=1;
title "Impact of LogPBDE100 on Risk of Depression";
model eds_totalscore=logpbde100 age medicaid_type firstprenatalbmi tobacco/CLB;
run;* explains 18%;

proc reg data=subset4;
where visitnumber=1;
title "Impact of PBDE100 on Risk of Depression";
model eds_totalscore=pbde100 age medicaid_type firstprenatalbmi tobacco/CLB;
run;

proc reg data=subset4;
where visitnumber=1;
title "Impact of LogPBDE100 on Risk of Depression";
model eds_totalscore=logpbde100 medicaid_type firstprenatalbmi tobacco;
run;*explains 18%;
proc reg data=subset4;
where visitnumber=1;
title "Impact of LogPBDE100 on Risk of Depression";
model eds_totalscore=logpbde100 firstprenatalbmi tobacco;
run; *explains 16%;

*look at high pbde body burden;
proc reg data=subset4;
where visitnumber=1;
title "Impact of High PBDE body burden on Risk of Depression";
model eds_totalscore=highpbde age marital medicaid_type firstprenatalbmi marijuana tobacco;
run;* explains 17%;
proc reg data=subset4;
where visitnumber=1;
title "Impact of highpbde on Risk of Depression";
model eds_totalscore=highpbde age medicaid_type firstprenatalbmi marijuana tobacco;
run;* explains 17%;
proc reg data=subset4;
where visitnumber=1;
title "Impact of highpbde on Risk of Depression";
model eds_totalscore=highpbde age medicaid_type firstprenatalbmi tobacco/CLB;
run;* explains 17%;
proc reg data=subset4;
where visitnumber=1;
title "Impact of highpbde on Risk of Depression";
model eds_totalscore=highpbde medicaid_type firstprenatalbmi tobacco;
run;*explains 17%;
proc reg data=subset4;
where visitnumber=1;
title "Impact of highpbde on Risk of Depression";
model eds_totalscore=highpbde firstprenatalbmi tobacco;
run; *explains 15%;

*look at low pbde body burden;
proc reg data=subset4;
where visitnumber=1;
title "Impact of Low PBDE body burden on Risk of Depression";
model eds_totalscore=lowpbde age marital medicaid_type firstprenatalbmi marijuana tobacco;
run;* explains 18%;
proc reg data=subset4;
where visitnumber=1;
title "Impact of lowpbde on Risk of Depression";
model eds_totalscore=lowpbde age medicaid_type firstprenatalbmi marijuana tobacco;
run;* explains 18%;
proc reg data=subset4;
where visitnumber=1;
title "Impact of lowpbde on Risk of Depression";
model eds_totalscore=lowpbde age medicaid_type firstprenatalbmi tobacco/CLB;
run;* explains 18%;
proc reg data=subset4;
where visitnumber=1;
title "Impact of lowpbde on Risk of Depression";
model eds_totalscore=lowpbde medicaid_type firstprenatalbmi tobacco;
run;*explains 17%;
proc reg data=subset4;
where visitnumber=1;
title "Impact of lowpbde on Risk of Depression";
model eds_totalscore=lowpbde firstprenatalbmi tobacco;
run; *explains 16%;

********************************************************************;
proc freq data= subset4;
tables eds_cat;
where visitnumber=1;
run;
* Make logistic regression models;
proc logistic data=subset4 PLOTS(ONLY)=ROC;
where visitnumber=1;
model eds_cat (EVENT='high ris')= pbde47 firstprenatalbmi tobacco age medicaid_type marijuana marital;
Output out=pred P=predicted xbeta=logit;
run;  

*check for multicollinearity between the independent variables;
data subset5;
set subset4;

if eds_cat= '    ' then edsnumber= .;
    else if eds_cat = "high ris" then edsnumber= 1;
	else if edsnumber=0;
	run;

proc reg data=subset5; *no multicollinearity observed since all VIF are <10;
model edsnumber= pbde47 firstprenatalbmi tobacco age medicaid_type marijuana marital/VIF;
run;

*Reduced model ;
proc logistic data=subset4 PLOTS(ONLY)=ROC;
where visitnumber=1;
class tobacco(param=ref ref="Yes")ins_type (param=ref ref="Medicaid");
model eds_cat (EVENT='high ris')= pbde47 firstprenatalbmi tobacco ins_type;
Output out=pred2 P=predicted xbeta=logit;
run;  
proc logistic data=subset4;
title 'Fit Reduced Model (no interaction terms)';
where visitnumber=1;
class tobacco(param=ref ref="Yes")ins_type (param=ref ref="Medicaid");
model eds_cat (EVENT='high ris')= pbde47 firstprenatalbmi tobacco ins_type/lackfit aggregate scale=none;
run; *using the ins_type variable is not as informative as medicaid type;

*repeat but with medicaid type and log and unlogged pbde;
proc logistic data=subset4 PLOTS(ONLY)=ROC;
where visitnumber=1;
class tobacco(param=ref ref="No")medicaid_type (param=ref ref="RSM");
model eds_cat (EVENT='high ris')= pbde47 firstprenatalbmi tobacco medicaid_type age;
Output out=pred2 P=predicted xbeta=logit;
run;  
*run log and unlogged pbde;
proc logistic data=subset4;
title 'Fit Reduced Model (no interaction terms)';
where visitnumber=1;
class tobacco(param=ref ref="No")medicaid_type (param=ref ref="RSM");
model eds_cat (EVENT='high ris')= pbde47 firstprenatalbmi tobacco medicaid_type age/lackfit aggregate scale=none;
run; 
*look at unadjusted OR log and unlogged pbde;
proc logistic data=subset4 PLOTS(ONLY)=ROC;
where visitnumber=1;
model eds_cat (EVENT='high ris')= logpbde47;
Output out=pred2 P=predicted xbeta=logit;
run;  
proc logistic data=subset4 PLOTS(ONLY)=ROC;
where visitnumber=1;
model eds_cat (EVENT='high ris')= firstprenatalbmi;
Output out=pred2 P=predicted xbeta=logit;
run;  
proc logistic data=subset4 PLOTS(ONLY)=ROC;
where visitnumber=1;
class tobacco(ref="No")/param=ref;
model eds_cat (EVENT='high ris')= tobacco;
Output out=pred2 P=predicted xbeta=logit;
run;  
proc logistic data=subset4 PLOTS(ONLY)=ROC;
where visitnumber=1;
class medicaid_type(ref="RSM")/param=ref;
model eds_cat (EVENT='high ris')= medicaid_type;
Output out=pred2 P=predicted xbeta=logit;
run;  
proc logistic data=subset4 PLOTS(ONLY)=ROC;
where visitnumber=1;
model eds_cat (EVENT='high ris')= age;
Output out=pred2 P=predicted xbeta=logit;
run;  

*log reg with pbde99;
proc logistic data=subset4 PLOTS(ONLY)=ROC;
where visitnumber=1;
class tobacco(param=ref ref="No")medicaid_type (param=ref ref="RSM");
model eds_cat (EVENT='high ris')= logpbde99 firstprenatalbmi tobacco medicaid_type age;
Output out=pred2 P=predicted xbeta=logit;
run;  
*run log and unlogged pbde;
proc logistic data=subset4;
title 'Fit Reduced Model (no interaction terms)';
where visitnumber=1;
class tobacco(param=ref ref="No")medicaid_type (param=ref ref="RSM");
model eds_cat (EVENT='high ris')= pbde99 firstprenatalbmi tobacco medicaid_type age/lackfit aggregate scale=none;
run; 

*get OR estimate and CI for log and unlogged PBDE99;
proc logistic data=subset4 PLOTS(ONLY)=ROC;
where visitnumber=1;
model eds_cat (EVENT='high ris')= pbde99;
Output out=pred2 P=predicted xbeta=logit;
run;
proc logistic data=subset4 PLOTS(ONLY)=ROC;
where visitnumber=1;
model eds_cat (EVENT='high ris')= logpbde99;
Output out=pred2 P=predicted xbeta=logit;
run;

*log reg with pbde100;
proc logistic data=subset4 PLOTS(ONLY)=ROC;
where visitnumber=1;
class tobacco(param=ref ref="No")medicaid_type (param=ref ref="RSM");
model eds_cat (EVENT='high ris')= logpbde100 firstprenatalbmi tobacco medicaid_type age;
Output out=pred2 P=predicted xbeta=logit;
run;  
*run log and unlogged pbde;
proc logistic data=subset4;
title 'Fit Reduced Model (no interaction terms)';
where visitnumber=1;
class tobacco(param=ref ref="No")medicaid_type (param=ref ref="RSM");
model eds_cat (EVENT='high ris')= pbde100 firstprenatalbmi tobacco medicaid_type age/lackfit aggregate scale=none;
run; 

*get OR estimate and CI for log and unlogged PBDE100;
proc logistic data=subset4 PLOTS(ONLY)=ROC;
where visitnumber=1;
model eds_cat (EVENT='high ris')= pbde100;
Output out=pred2 P=predicted xbeta=logit;
run;
proc logistic data=subset4 PLOTS(ONLY)=ROC;
where visitnumber=1;
model eds_cat (EVENT='high ris')= logpbde100;
Output out=pred2 P=predicted xbeta=logit;
run;

*unlog reg with highpbde;
proc logistic data=subset4 PLOTS(ONLY)=ROC;
where visitnumber=1;
class tobacco(param=ref ref="No")medicaid_type (param=ref ref="RSM");
model eds_cat (EVENT='high ris')= highpbde firstprenatalbmi tobacco medicaid_type age;
Output out=pred2 P=predicted xbeta=logit;
run;  
*run unlogged highpbde;
proc logistic data=subset4;
title 'Fit Reduced Model (no interaction terms)';
where visitnumber=1;
class tobacco(param=ref ref="No")medicaid_type (param=ref ref="RSM");
model eds_cat (EVENT='high ris')= highpbde firstprenatalbmi tobacco medicaid_type age/lackfit aggregate scale=none;
run; 

*get OR estimate and CI for unlogged highpbde;
proc logistic data=subset4 PLOTS(ONLY)=ROC;
where visitnumber=1;
model eds_cat (EVENT='high ris')= highpbde;
Output out=pred2 P=predicted xbeta=logit;
run;

*unlog reg with lowpbde;
proc logistic data=subset4 PLOTS(ONLY)=ROC;
where visitnumber=1;
class tobacco(param=ref ref="No")medicaid_type (param=ref ref="RSM");
model eds_cat (EVENT='high ris')= lowpbde firstprenatalbmi tobacco medicaid_type age;
Output out=pred2 P=predicted xbeta=logit;
run;  
*run unlogged lowpbde;
proc logistic data=subset4;
title 'Fit Reduced Model (no interaction terms)';
where visitnumber=1;
class tobacco(param=ref ref="No")medicaid_type (param=ref ref="RSM");
model eds_cat (EVENT='high ris')= lowpbde firstprenatalbmi tobacco medicaid_type age/lackfit aggregate scale=none;
run; 

*get OR estimate and CI for unlogged lowpbde;
proc logistic data=subset4 PLOTS(ONLY)=ROC;
where visitnumber=1;
model eds_cat (EVENT='high ris')= lowpbde;
Output out=pred2 P=predicted xbeta=logit;
run;
