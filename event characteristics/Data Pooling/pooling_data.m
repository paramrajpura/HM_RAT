
%% loading the files (cond = homecage(1))
r1_c1_post = load("Rat_Hm_Ephys_Rat1_389236_20200904_postsleep.mat");
r2_c1_post = load("Rat_Hm_Ephys_Rat2_389237_20200910_postsleep.mat");
r4_c1_post = load("Rat_Hm_Ephys_Rat4_389239_20201104_postsleep.mat");
%r5_c1_post = load("");
r7_c1_post = load("Rat_Hm_Ephys_Rat7_406578_20210714_postsleep.mat");
r8_c1_post = load("Rat_Hm_Ephys_Rat8_406579_20210803_postsleep.mat");

r1_c1_pre = load("Rat_Hm_Ephys_Rat1_389236_20200904_presleep.mat");
r2_c1_pre = load("Rat_Hm_Ephys_Rat2_389237_20200910_presleep.mat");
r4_c1_pre = load("Rat_Hm_Ephys_Rat4_389239_20201104_presleep.mat");
r7_c1_pre = load("Rat_Hm_Ephys_Rat7_406578_20210714_presleep.mat");
r8_c1_pre = load("Rat_Hm_Ephys_Rat8_406579_20210803_presleep.mat");
%% loading the files (cond = retreival(2))
r1_c2_post = load("Rat_Hm_Ephys_Rat1_389236_20200909_postsleep.mat");
r2_c2_post = load("Rat_Hm_Ephys_Rat2_389237_20200915_postsleep.mat");
r4_c2_post = load("Rat_Hm_Ephys_Rat4_389239_20201109_postsleep.mat");
r7_c2_post = load("Rat_Hm_Ephys_Rat7_406578_20210720_postsleep.mat");
r8_c2_post = load("Rat_Hm_Ephys_Rat8_406579_20210810_postsleep.mat");

r1_c2_pre = load("Rat_Hm_Ephys_Rat1_389236_20200909_presleep.mat");
r2_c2_pre = load("Rat_Hm_Ephys_Rat2_389237_20200915_presleep.mat");
r4_c2_pre = load("Rat_Hm_Ephys_Rat4_389239_20201109_presleep.mat");
r7_c2_pre = load("Rat_Hm_Ephys_Rat7_406578_20210720_presleep.mat");
r8_c2_pre = load("Rat_Hm_Ephys_Rat8_406579_20210810_presleep.mat");
%% loading the files (cond = update(3))
r1_c3_post = load("Rat_Hm_Ephys_Rat1_389236_20200911_postsleep.mat");
r2_c3_post = load("Rat_Hm_Ephys_Rat2_389237_20200917_postsleep.mat");
r4_c3_post = load("Rat_Hm_Ephys_Rat4_389239_20201111_postsleep.mat");
r7_c3_post = load("Rat_Hm_Ephys_Rat7_406578_20210722_postsleep.mat");
r8_c3_post = load("Rat_Hm_Ephys_Rat8_406579_20210821_postsleep.mat");

r1_c3_pre = load("Rat_Hm_Ephys_Rat1_389236_20200911_presleep.mat");
r2_c3_pre = load("Rat_Hm_Ephys_Rat2_389237_20200917_presleep.mat");
r4_c3_pre = load("Rat_Hm_Ephys_Rat4_389239_20201111_presleep.mat");
r7_c3_pre = load("Rat_Hm_Ephys_Rat7_406578_20210722_presleep.mat");
r8_c3_pre = load("Rat_Hm_Ephys_Rat8_406579_20210821_presleep.mat");
%%
fields = {'ripples','spindles','deltas'};
c = cell(length(fields),1);
s = cell2struct(c,fields);
y = cell2struct(cell(6,1),{'Rat1','Rat2','Rat4','Rat5','Rat7','Rat8'});
x = cell2struct(cell(4,1),{'hour1','hour2','hour3','hour4'});
x.hour1 = y; x.hour2 = y; x. hour3 = y; x.hour4 = y;
s.ripples = x; s.spindles = x; s.deltas = x;

pre_cond1 = s;
pre_cond2 = s;
pre_cond3 = s;
post_cond1 = s;
post_cond2 = s;
post_cond3 = s;
%%
% making the cond1 files
% postsleep
%Rat1
post_cond1.ripples.hour1.Rat1 = r1_c1_post.data.ripple_array(1:length(r1_c1_post.data.rippleXhr.hour1));
post_cond1.ripples.hour2.Rat1 = r1_c1_post.data.ripple_array(1:length(r1_c1_post.data.rippleXhr.hour2));
post_cond1.ripples.hour3.Rat1 = r1_c1_post.data.ripple_array(1:length(r1_c1_post.data.rippleXhr.hour3));
post_cond1.ripples.hour4.Rat1 = r1_c1_post.data.ripple_array(1:length(r1_c1_post.data.rippleXhr.hour4));

post_cond1.spindles.hour1.Rat1 = r1_c1_post.data.spindle_array(1:length(r1_c1_post.data.spindleXhr.hour1));
post_cond1.spindles.hour2.Rat1 = r1_c1_post.data.spindle_array(1:length(r1_c1_post.data.spindleXhr.hour2));
post_cond1.spindles.hour3.Rat1 = r1_c1_post.data.spindle_array(1:length(r1_c1_post.data.spindleXhr.hour3));
post_cond1.spindles.hour4.Rat1 = r1_c1_post.data.spindle_array(1:length(r1_c1_post.data.spindleXhr.hour4));

post_cond1.deltas.hour1.Rat1 = r1_c2_post.data.delta_array(1:length(r1_c1_post.data.deltaXhr.hour1));
post_cond1.deltas.hour2.Rat1  = r1_c2_post.data.delta_array(1:length(r1_c1_post.data.deltaXhr.hour2));
post_cond1.deltas.hour3.Rat1  = r1_c2_post.data.delta_array(1:length(r1_c1_post.data.deltaXhr.hour3));
post_cond1.deltas.hour4.Rat1  = r1_c2_post.data.delta_array(1:length(r1_c1_post.data.deltaXhr.hour4));

%Rat2
post_cond1.ripples.hour1.Rat2 = r2_c1_post.data.ripple_array(1:length(r2_c1_post.data.rippleXhr.hour1));
post_cond1.ripples.hour2.Rat2 = r2_c1_post.data.ripple_array(1:length(r2_c1_post.data.rippleXhr.hour2));
post_cond1.ripples.hour3.Rat2 = r2_c1_post.data.ripple_array(1:length(r2_c1_post.data.rippleXhr.hour3));
post_cond1.ripples.hour4.Rat2 = r2_c1_post.data.ripple_array(1:length(r2_c1_post.data.rippleXhr.hour4));

post_cond1.spindles.hour1.Rat2 = r2_c1_post.data.spindle_array(1:length(r2_c1_post.data.spindleXhr.hour1));
post_cond1.spindles.hour2.Rat2 = r2_c1_post.data.spindle_array(1:length(r2_c1_post.data.spindleXhr.hour2));
post_cond1.spindles.hour3.Rat2 = r2_c1_post.data.spindle_array(1:length(r2_c1_post.data.spindleXhr.hour3));
post_cond1.spindles.hour4.Rat2 = r2_c1_post.data.spindle_array(1:length(r2_c1_post.data.spindleXhr.hour4));

post_cond1.deltas.hour1.Rat2 = r2_c1_post.data.delta_array(1:length(r2_c1_post.data.deltaXhr.hour1));
post_cond1.deltas.hour2.Rat2 = r2_c1_post.data.delta_array(1:length(r2_c1_post.data.deltaXhr.hour2));
post_cond1.deltas.hour3.Rat2 = r2_c1_post.data.delta_array(1:length(r2_c1_post.data.deltaXhr.hour3));
post_cond1.deltas.hour4.Rat2 = r2_c1_post.data.delta_array(1:length(r2_c1_post.data.deltaXhr.hour4));

%Rat4
post_cond1.ripples.hour1.Rat4 = r4_c1_post.data.ripple_array(1:length(r4_c1_post.data.rippleXhr.hour1));
post_cond1.ripples.hour2.Rat4 = r4_c1_post.data.ripple_array(1:length(r4_c1_post.data.rippleXhr.hour2));
post_cond1.ripples.hour3.Rat4 = r4_c1_post.data.ripple_array(1:length(r4_c1_post.data.rippleXhr.hour3));
post_cond1.ripples.hour4.Rat4 = r4_c1_post.data.ripple_array(1:length(r4_c1_post.data.rippleXhr.hour4));

post_cond1.spindles.hour1.Rat4 = r4_c1_post.data.spindle_array(1:length(r4_c1_post.data.spindleXhr.hour1));
post_cond1.spindles.hour2.Rat4 = r4_c1_post.data.spindle_array(1:length(r4_c1_post.data.spindleXhr.hour2));
post_cond1.spindles.hour3.Rat4 = r4_c1_post.data.spindle_array(1:length(r4_c1_post.data.spindleXhr.hour3));
post_cond1.spindles.hour4.Rat4 = r4_c1_post.data.spindle_array(1:length(r4_c1_post.data.spindleXhr.hour4));

post_cond1.deltas.hour1.Rat4 = r4_c1_post.data.delta_array(1:length(r4_c1_post.data.deltaXhr.hour1));
post_cond1.deltas.hour2.Rat4 = r4_c1_post.data.delta_array(1:length(r4_c1_post.data.deltaXhr.hour2));
post_cond1.deltas.hour3.Rat4 = r4_c1_post.data.delta_array(1:length(r4_c1_post.data.deltaXhr.hour3));
post_cond1.deltas.hour4.Rat4 = r4_c1_post.data.delta_array(1:length(r4_c1_post.data.deltaXhr.hour4));

%Rat7
post_cond1.ripples.hour1.Rat7 = r7_c1_post.data.ripple_array(1:length(r7_c1_post.data.rippleXhr.hour1));
post_cond1.ripples.hour2.Rat7 = r7_c1_post.data.ripple_array(1:length(r7_c1_post.data.rippleXhr.hour2));
post_cond1.ripples.hour3.Rat7 = r7_c1_post.data.ripple_array(1:length(r7_c1_post.data.rippleXhr.hour3));
post_cond1.ripples.hour4.Rat7 = r7_c1_post.data.ripple_array(1:length(r7_c1_post.data.rippleXhr.hour4));

post_cond1.spindles.hour1.Rat7 = r7_c1_post.data.spindle_array(1:length(r7_c1_post.data.spindleXhr.hour1));
post_cond1.spindles.hour2.Rat7 = r7_c1_post.data.spindle_array(1:length(r7_c1_post.data.spindleXhr.hour2));
post_cond1.spindles.hour3.Rat7 = r7_c1_post.data.spindle_array(1:length(r7_c1_post.data.spindleXhr.hour3));
post_cond1.spindles.hour4.Rat7 = r7_c1_post.data.spindle_array(1:length(r7_c1_post.data.spindleXhr.hour4));

post_cond1.deltas.hour1.Rat7 = r7_c1_post.data.delta_array(1:length(r7_c1_post.data.deltaXhr.hour1));
post_cond1.deltas.hour2.Rat7 = r7_c1_post.data.delta_array(1:length(r7_c1_post.data.deltaXhr.hour2));
post_cond1.deltas.hour3.Rat7 = r7_c1_post.data.delta_array(1:length(r7_c1_post.data.deltaXhr.hour3));
post_cond1.deltas.hour4.Rat7 = r7_c1_post.data.delta_array(1:length(r7_c1_post.data.deltaXhr.hour4));

%Rat8
post_cond1.ripples.hour1.Rat8 = r8_c1_post.data.ripple_array(1:length(r8_c1_post.data.rippleXhr.hour1));
post_cond1.ripples.hour2.Rat8 = r8_c1_post.data.ripple_array(1:length(r8_c1_post.data.rippleXhr.hour2));
post_cond1.ripples.hour3.Rat8 = r8_c1_post.data.ripple_array(1:length(r8_c1_post.data.rippleXhr.hour3));
post_cond1.ripples.hour4.Rat8 = r8_c1_post.data.ripple_array(1:length(r8_c1_post.data.rippleXhr.hour4));

post_cond1.spindles.hour1.Rat8 = r8_c1_post.data.spindle_array(1:length(r8_c1_post.data.spindleXhr.hour1));
post_cond1.spindles.hour2.Rat8 = r8_c1_post.data.spindle_array(1:length(r8_c1_post.data.spindleXhr.hour2));
post_cond1.spindles.hour3.Rat8 = r8_c1_post.data.spindle_array(1:length(r8_c1_post.data.spindleXhr.hour3));
post_cond1.spindles.hour4.Rat8 = r8_c1_post.data.spindle_array(1:length(r8_c1_post.data.spindleXhr.hour4));

post_cond1.deltas.hour1.Rat8 = r1_c1_post.data.delta_array(1:length(r8_c1_post.data.deltaXhr.hour1));
post_cond1.deltas.hour2.Rat8  = r1_c1_post.data.delta_array(1:length(r8_c1_post.data.deltaXhr.hour2));
post_cond1.deltas.hour3.Rat8  = r1_c1_post.data.delta_array(1:length(r8_c1_post.data.deltaXhr.hour3));
post_cond1.deltas.hour4.Rat8  = r1_c1_post.data.delta_array(1:length(r8_c1_post.data.deltaXhr.hour4));
%%
% making the cond1 files
% presleep
%Rat 1
pre_cond1.ripples.hour1.Rat1 = r1_c1_pre.data.ripple_array(1:length(r1_c1_pre.data.rippleXhr.hour1));
pre_cond1.spindles.hour1.Rat1 = r1_c1_pre.data.spindle_array(1:length(r1_c1_pre.data.spindleXhr.hour1));
pre_cond1.deltas.hour1.Rat1 = r1_c1_pre.data.delta_array(1:length(r1_c1_pre.data.deltaXhr.hour1));

%Rat 2
pre_cond1.ripples.hour1.Rat2 = r2_c1_pre.data.ripple_array(1:length(r2_c1_pre.data.rippleXhr.hour1));
pre_cond1.spindles.hour1.Rat2 = r2_c1_pre.data.spindle_array(1:length(r2_c1_pre.data.spindleXhr.hour1));
pre_cond1.deltas.hour1.Rat2 = r2_c1_pre.data.delta_array(1:length(r2_c1_pre.data.deltaXhr.hour1));

%Rat 4
pre_cond1.ripples.hour1.Rat4 = r4_c1_pre.data.ripple_array(1:length(r4_c1_pre.data.rippleXhr.hour1));
pre_cond1.spindles.hour1.Rat4 = r4_c1_pre.data.spindle_array(1:length(r4_c1_pre.data.spindleXhr.hour1));
pre_cond1.deltas.hour1.Rat4 = r4_c1_pre.data.delta_array(1:length(r4_c1_pre.data.deltaXhr.hour1));

%Rat 7
pre_cond1.ripples.hour1.Rat7 = r7_c1_pre.data.ripple_array(1:length(r7_c1_pre.data.rippleXhr.hour1));
pre_cond1.spindles.hour1.Rat7 = r7_c1_pre.data.spindle_array(1:length(r7_c1_pre.data.spindleXhr.hour1));
pre_cond1.deltas.hour1.Rat7 = r7_c1_pre.data.delta_array(1:length(r7_c1_pre.data.deltaXhr.hour1));

%Rat 8
pre_cond1.ripples.hour1.Rat8 = r8_c1_pre.data.ripple_array(1:length(r8_c1_pre.data.rippleXhr.hour1));
pre_cond1.spindles.hour1.Rat8 = r8_c1_pre.data.spindle_array(1:length(r8_c1_pre.data.spindleXhr.hour1));
pre_cond1.deltas.hour1.Rat8 = r8_c1_pre.data.delta_array(1:length(r8_c1_pre.data.deltaXhr.hour1));
% struct for the presleep of conition 2 is made (rat7 didn't have any delta
% events in presleep!)

%%
% making the cond2 files
% postsleep
%Rat1
post_cond2.ripples.hour1.Rat1 = r1_c2_post.data.ripple_array(1:length(r1_c2_post.data.rippleXhr.hour1));
post_cond2.ripples.hour2.Rat1 = r1_c2_post.data.ripple_array(1:length(r1_c2_post.data.rippleXhr.hour2));
post_cond2.ripples.hour3.Rat1 = r1_c2_post.data.ripple_array(1:length(r1_c2_post.data.rippleXhr.hour3));
post_cond2.ripples.hour4.Rat1 = r1_c2_post.data.ripple_array(1:length(r1_c2_post.data.rippleXhr.hour4));

post_cond2.spindles.hour1.Rat1 = r1_c2_post.data.spindle_array(1:length(r1_c2_post.data.spindleXhr.hour1));
post_cond2.spindles.hour2.Rat1 = r1_c2_post.data.spindle_array(1:length(r1_c2_post.data.spindleXhr.hour2));
post_cond2.spindles.hour3.Rat1 = r1_c2_post.data.spindle_array(1:length(r1_c2_post.data.spindleXhr.hour3));
post_cond2.spindles.hour4.Rat1 = r1_c2_post.data.spindle_array(1:length(r1_c2_post.data.spindleXhr.hour4));

post_cond2.deltas.hour1.Rat1 = r1_c2_post.data.delta_array(1:length(r1_c2_post.data.deltaXhr.hour1));
post_cond2.deltas.hour2.Rat1  = r1_c2_post.data.delta_array(1:length(r1_c2_post.data.deltaXhr.hour2));
post_cond2.deltas.hour3.Rat1  = r1_c2_post.data.delta_array(1:length(r1_c2_post.data.deltaXhr.hour3));
post_cond2.deltas.hour4.Rat1  = r1_c2_post.data.delta_array(1:length(r1_c2_post.data.deltaXhr.hour4));

%Rat2
post_cond2.ripples.hour1.Rat2 = r2_c2_post.data.ripple_array(1:length(r2_c2_post.data.rippleXhr.hour1));
post_cond2.ripples.hour2.Rat2 = r2_c2_post.data.ripple_array(1:length(r2_c2_post.data.rippleXhr.hour2));
post_cond2.ripples.hour3.Rat2 = r2_c2_post.data.ripple_array(1:length(r2_c2_post.data.rippleXhr.hour3));
post_cond2.ripples.hour4.Rat2 = r2_c2_post.data.ripple_array(1:length(r2_c2_post.data.rippleXhr.hour4));

post_cond2.spindles.hour1.Rat2 = r2_c2_post.data.spindle_array(1:length(r2_c2_post.data.spindleXhr.hour1));
post_cond2.spindles.hour2.Rat2 = r2_c2_post.data.spindle_array(1:length(r2_c2_post.data.spindleXhr.hour2));
post_cond2.spindles.hour3.Rat2 = r2_c2_post.data.spindle_array(1:length(r2_c2_post.data.spindleXhr.hour3));
post_cond2.spindles.hour4.Rat2 = r2_c2_post.data.spindle_array(1:length(r2_c2_post.data.spindleXhr.hour4));

post_cond2.deltas.hour1.Rat2 = r2_c2_post.data.delta_array(1:length(r2_c2_post.data.deltaXhr.hour1));
post_cond2.deltas.hour2.Rat2 = r2_c2_post.data.delta_array(1:length(r2_c2_post.data.deltaXhr.hour2));
post_cond2.deltas.hour3.Rat2 = r2_c2_post.data.delta_array(1:length(r2_c2_post.data.deltaXhr.hour3));
post_cond2.deltas.hour4.Rat2 = r2_c2_post.data.delta_array(1:length(r2_c2_post.data.deltaXhr.hour4));
%Rat4
post_cond2.ripples.hour1.Rat4 = r4_c2_post.data.ripple_array(1:length(r4_c2_post.data.rippleXhr.hour1));
post_cond2.ripples.hour2.Rat4 = r4_c2_post.data.ripple_array(1:length(r4_c2_post.data.rippleXhr.hour2));
post_cond2.ripples.hour3.Rat4 = r4_c2_post.data.ripple_array(1:length(r4_c2_post.data.rippleXhr.hour3));
post_cond2.ripples.hour4.Rat4 = r4_c2_post.data.ripple_array(1:length(r4_c2_post.data.rippleXhr.hour4));

post_cond2.spindles.hour1.Rat4 = r4_c2_post.data.spindle_array(1:length(r4_c2_post.data.spindleXhr.hour1));
post_cond2.spindles.hour2.Rat4 = r4_c2_post.data.spindle_array(1:length(r4_c2_post.data.spindleXhr.hour2));
post_cond2.spindles.hour3.Rat4 = r4_c2_post.data.spindle_array(1:length(r4_c2_post.data.spindleXhr.hour3));
post_cond2.spindles.hour4.Rat4 = r4_c2_post.data.spindle_array(1:length(r4_c2_post.data.spindleXhr.hour4));

post_cond2.deltas.hour1.Rat4 = r4_c2_post.data.delta_array(1:length(r4_c2_post.data.deltaXhr.hour1));
post_cond2.deltas.hour2.Rat4 = r4_c2_post.data.delta_array(1:length(r4_c2_post.data.deltaXhr.hour2));
post_cond2.deltas.hour3.Rat4 = r4_c2_post.data.delta_array(1:length(r4_c2_post.data.deltaXhr.hour3));
post_cond2.deltas.hour4.Rat4 = r4_c2_post.data.delta_array(1:length(r4_c2_post.data.deltaXhr.hour4));

%Rat7
post_cond2.ripples.hour1.Rat7 = r7_c2_post.data.ripple_array(1:length(r7_c2_post.data.rippleXhr.hour1));
post_cond2.ripples.hour2.Rat7 = r7_c2_post.data.ripple_array(1:length(r7_c2_post.data.rippleXhr.hour2));
post_cond2.ripples.hour3.Rat7 = r7_c2_post.data.ripple_array(1:length(r7_c2_post.data.rippleXhr.hour3));
post_cond2.ripples.hour4.Rat7 = r7_c2_post.data.ripple_array(1:length(r7_c2_post.data.rippleXhr.hour4));

post_cond2.spindles.hour1.Rat7 = r7_c2_post.data.spindle_array(1:length(r7_c2_post.data.spindleXhr.hour1));
post_cond2.spindles.hour2.Rat7 = r7_c2_post.data.spindle_array(1:length(r7_c2_post.data.spindleXhr.hour2));
post_cond2.spindles.hour3.Rat7 = r7_c2_post.data.spindle_array(1:length(r7_c2_post.data.spindleXhr.hour3));
post_cond2.spindles.hour4.Rat7 = r7_c2_post.data.spindle_array(1:length(r7_c2_post.data.spindleXhr.hour4));

post_cond2.deltas.hour1.Rat7 = r7_c2_post.data.delta_array(1:length(r7_c2_post.data.deltaXhr.hour1));
post_cond2.deltas.hour2.Rat7 = r7_c2_post.data.delta_array(1:length(r7_c2_post.data.deltaXhr.hour2));
post_cond2.deltas.hour3.Rat7 = r7_c2_post.data.delta_array(1:length(r7_c2_post.data.deltaXhr.hour3));
post_cond2.deltas.hour4.Rat7 = r7_c2_post.data.delta_array(1:length(r7_c2_post.data.deltaXhr.hour4));

%Rat8
post_cond2.ripples.hour1.Rat8 = r8_c2_post.data.ripple_array(1:length(r8_c2_post.data.rippleXhr.hour1));
post_cond2.ripples.hour2.Rat8 = r8_c2_post.data.ripple_array(1:length(r8_c2_post.data.rippleXhr.hour2));
post_cond2.ripples.hour3.Rat8 = r8_c2_post.data.ripple_array(1:length(r8_c2_post.data.rippleXhr.hour3));
post_cond2.ripples.hour4.Rat8 = r8_c2_post.data.ripple_array(1:length(r8_c2_post.data.rippleXhr.hour4));

post_cond2.spindles.hour1.Rat8 = r8_c2_post.data.spindle_array(1:length(r8_c2_post.data.spindleXhr.hour1));
post_cond2.spindles.hour2.Rat8 = r8_c2_post.data.spindle_array(1:length(r8_c2_post.data.spindleXhr.hour2));
post_cond2.spindles.hour3.Rat8 = r8_c2_post.data.spindle_array(1:length(r8_c2_post.data.spindleXhr.hour3));
post_cond2.spindles.hour4.Rat8 = r8_c2_post.data.spindle_array(1:length(r8_c2_post.data.spindleXhr.hour4));

post_cond2.deltas.hour1.Rat8 = r1_c2_post.data.delta_array(1:length(r8_c2_post.data.deltaXhr.hour1));
post_cond2.deltas.hour2.Rat8  = r1_c2_post.data.delta_array(1:length(r8_c2_post.data.deltaXhr.hour2));
post_cond2.deltas.hour3.Rat8  = r1_c2_post.data.delta_array(1:length(r8_c2_post.data.deltaXhr.hour3));
post_cond2.deltas.hour4.Rat8  = r1_c2_post.data.delta_array(1:length(r8_c2_post.data.deltaXhr.hour4));
%%
% making the cond2 files
% presleep
%Rat 1
pre_cond2.ripples.hour1.Rat1 = r1_c2_pre.data.ripple_array(1:length(r1_c2_pre.data.rippleXhr.hour1));
pre_cond2.spindles.hour1.Rat1 = r1_c2_pre.data.spindle_array(1:length(r1_c2_pre.data.spindleXhr.hour1));
pre_cond2.deltas.hour1.Rat1 = r1_c2_pre.data.delta_array(1:length(r1_c2_pre.data.deltaXhr.hour1));

%Rat 2
pre_cond2.ripples.hour1.Rat2 = r2_c2_pre.data.ripple_array(1:length(r2_c2_pre.data.rippleXhr.hour1));
pre_cond2.spindles.hour1.Rat2 = r2_c2_pre.data.spindle_array(1:length(r2_c2_pre.data.spindleXhr.hour1));
pre_cond2.deltas.hour1.Rat2 = r2_c2_pre.data.delta_array(1:length(r2_c2_pre.data.deltaXhr.hour1));

%Rat 4
pre_cond2.ripples.hour1.Rat4 = r4_c2_pre.data.ripple_array(1:length(r4_c2_pre.data.rippleXhr.hour1));
pre_cond2.spindles.hour1.Rat4 = r4_c2_pre.data.spindle_array(1:length(r4_c2_pre.data.spindleXhr.hour1));
pre_cond2.deltas.hour1.Rat4 = r4_c2_pre.data.delta_array(1:length(r4_c2_pre.data.deltaXhr.hour1));

%Rat 7
pre_cond2.ripples.hour1.Rat7 = r7_c2_pre.data.ripple_array(1:length(r7_c2_pre.data.rippleXhr.hour1));
pre_cond2.spindles.hour1.Rat7 = r7_c2_pre.data.spindle_array(1:length(r7_c2_pre.data.spindleXhr.hour1));
pre_cond2.deltas.hour1.Rat7 = r7_c2_pre.data.delta_array(1:length(r7_c2_pre.data.deltaXhr.hour1));

%Rat 8
pre_cond2.ripples.hour1.Rat8 = r8_c2_pre.data.ripple_array(1:length(r8_c2_pre.data.rippleXhr.hour1));
pre_cond2.spindles.hour1.Rat8 = r8_c2_pre.data.spindle_array(1:length(r8_c2_pre.data.spindleXhr.hour1));
pre_cond2.deltas.hour1.Rat8 = r8_c2_pre.data.delta_array(1:length(r8_c2_pre.data.deltaXhr.hour1));
% struct for the presleep of conition 2 is made (rat7 didn't have any delta
% events in presleep!)

%%

% making the cond3 files
% postsleep
%Rat1
post_cond3.ripples.hour1.Rat1 = r1_c3_post.data.ripple_array(1:length(r1_c3_post.data.rippleXhr.hour1));
post_cond3.ripples.hour2.Rat1 = r1_c3_post.data.ripple_array(1:length(r1_c3_post.data.rippleXhr.hour2));
post_cond3.ripples.hour3.Rat1 = r1_c3_post.data.ripple_array(1:length(r1_c3_post.data.rippleXhr.hour3));
post_cond3.ripples.hour4.Rat1 = r1_c3_post.data.ripple_array(1:length(r1_c3_post.data.rippleXhr.hour4));

post_cond3.spindles.hour1.Rat1 = r1_c3_post.data.spindle_array(1:length(r1_c3_post.data.spindleXhr.hour1));
post_cond3.spindles.hour2.Rat1 = r1_c3_post.data.spindle_array(1:length(r1_c3_post.data.spindleXhr.hour2));
post_cond3.spindles.hour3.Rat1 = r1_c3_post.data.spindle_array(1:length(r1_c3_post.data.spindleXhr.hour3));
post_cond3.spindles.hour4.Rat1 = r1_c3_post.data.spindle_array(1:length(r1_c3_post.data.spindleXhr.hour4));

post_cond3.deltas.hour1.Rat1 = r1_c3_post.data.delta_array(1:length(r1_c3_post.data.deltaXhr.hour1));
post_cond3.deltas.hour2.Rat1  = r1_c3_post.data.delta_array(1:length(r1_c3_post.data.deltaXhr.hour2));
post_cond3.deltas.hour3.Rat1  = r1_c3_post.data.delta_array(1:length(r1_c3_post.data.deltaXhr.hour3));
post_cond3.deltas.hour4.Rat1  = r1_c3_post.data.delta_array(1:length(r1_c3_post.data.deltaXhr.hour4));

%Rat2
post_cond3.ripples.hour1.Rat2 = r2_c3_post.data.ripple_array(1:length(r2_c3_post.data.rippleXhr.hour1));
post_cond3.ripples.hour2.Rat2 = r2_c3_post.data.ripple_array(1:length(r2_c3_post.data.rippleXhr.hour2));
post_cond3.ripples.hour3.Rat2 = r2_c3_post.data.ripple_array(1:length(r2_c3_post.data.rippleXhr.hour3));
post_cond3.ripples.hour4.Rat2 = r2_c3_post.data.ripple_array(1:length(r2_c3_post.data.rippleXhr.hour4));

post_cond3.spindles.hour1.Rat2 = r2_c3_post.data.spindle_array(1:length(r2_c3_post.data.spindleXhr.hour1));
post_cond3.spindles.hour2.Rat2 = r2_c3_post.data.spindle_array(1:length(r2_c3_post.data.spindleXhr.hour2));
post_cond3.spindles.hour3.Rat2 = r2_c3_post.data.spindle_array(1:length(r2_c3_post.data.spindleXhr.hour3));
post_cond3.spindles.hour4.Rat2 = r2_c3_post.data.spindle_array(1:length(r2_c3_post.data.spindleXhr.hour4));

post_cond3.deltas.hour1.Rat2 = r2_c3_post.data.delta_array(1:length(r2_c3_post.data.deltaXhr.hour1));
post_cond3.deltas.hour2.Rat2 = r2_c3_post.data.delta_array(1:length(r2_c3_post.data.deltaXhr.hour2));
post_cond3.deltas.hour3.Rat2 = r2_c3_post.data.delta_array(1:length(r2_c3_post.data.deltaXhr.hour3));
post_cond3.deltas.hour4.Rat2 = r2_c3_post.data.delta_array(1:length(r2_c3_post.data.deltaXhr.hour4));
%Rat4
post_cond3.ripples.hour1.Rat4 = r4_c3_post.data.ripple_array(1:length(r4_c3_post.data.rippleXhr.hour1));
post_cond3.ripples.hour2.Rat4 = r4_c3_post.data.ripple_array(1:length(r4_c3_post.data.rippleXhr.hour2));
post_cond3.ripples.hour3.Rat4 = r4_c3_post.data.ripple_array(1:length(r4_c3_post.data.rippleXhr.hour3));
post_cond3.ripples.hour4.Rat4 = r4_c3_post.data.ripple_array(1:length(r4_c3_post.data.rippleXhr.hour4));

post_cond3.spindles.hour1.Rat4 = r4_c3_post.data.spindle_array(1:length(r4_c3_post.data.spindleXhr.hour1));
post_cond3.spindles.hour2.Rat4 = r4_c3_post.data.spindle_array(1:length(r4_c3_post.data.spindleXhr.hour2));
post_cond3.spindles.hour3.Rat4 = r4_c3_post.data.spindle_array(1:length(r4_c3_post.data.spindleXhr.hour3));
post_cond3.spindles.hour4.Rat4 = r4_c3_post.data.spindle_array(1:length(r4_c3_post.data.spindleXhr.hour4));

post_cond3.deltas.hour1.Rat4 = r4_c3_post.data.delta_array(1:length(r4_c3_post.data.deltaXhr.hour1));
post_cond3.deltas.hour2.Rat4 = r4_c3_post.data.delta_array(1:length(r4_c3_post.data.deltaXhr.hour2));
post_cond3.deltas.hour3.Rat4 = r4_c3_post.data.delta_array(1:length(r4_c3_post.data.deltaXhr.hour3));
post_cond3.deltas.hour4.Rat4 = r4_c3_post.data.delta_array(1:length(r4_c3_post.data.deltaXhr.hour4));

%Rat7
post_cond3.ripples.hour1.Rat7 = r7_c3_post.data.ripple_array(1:length(r7_c3_post.data.rippleXhr.hour1));
post_cond3.ripples.hour2.Rat7 = r7_c3_post.data.ripple_array(1:length(r7_c3_post.data.rippleXhr.hour2));
post_cond3.ripples.hour3.Rat7 = r7_c3_post.data.ripple_array(1:length(r7_c3_post.data.rippleXhr.hour3));
post_cond3.ripples.hour4.Rat7 = r7_c3_post.data.ripple_array(1:length(r7_c3_post.data.rippleXhr.hour4));

post_cond3.spindles.hour1.Rat7 = r7_c3_post.data.spindle_array(1:length(r7_c3_post.data.spindleXhr.hour1));
post_cond3.spindles.hour2.Rat7 = r7_c3_post.data.spindle_array(1:length(r7_c3_post.data.spindleXhr.hour2));
post_cond3.spindles.hour3.Rat7 = r7_c3_post.data.spindle_array(1:length(r7_c3_post.data.spindleXhr.hour3));
post_cond3.spindles.hour4.Rat7 = r7_c3_post.data.spindle_array(1:length(r7_c3_post.data.spindleXhr.hour4));

post_cond3.deltas.hour1.Rat7 = r7_c3_post.data.delta_array(1:length(r7_c3_post.data.deltaXhr.hour1));
post_cond3.deltas.hour2.Rat7 = r7_c3_post.data.delta_array(1:length(r7_c3_post.data.deltaXhr.hour2));
post_cond3.deltas.hour3.Rat7 = r7_c3_post.data.delta_array(1:length(r7_c3_post.data.deltaXhr.hour3));
post_cond3.deltas.hour4.Rat7 = r7_c3_post.data.delta_array(1:length(r7_c3_post.data.deltaXhr.hour4));

%Rat8
post_cond3.ripples.hour1.Rat8 = r8_c3_post.data.ripple_array(1:length(r8_c3_post.data.rippleXhr.hour1));
post_cond3.ripples.hour2.Rat8 = r8_c3_post.data.ripple_array(1:length(r8_c3_post.data.rippleXhr.hour2));
post_cond3.ripples.hour3.Rat8 = r8_c3_post.data.ripple_array(1:length(r8_c3_post.data.rippleXhr.hour3));
post_cond3.ripples.hour4.Rat8 = r8_c3_post.data.ripple_array(1:length(r8_c3_post.data.rippleXhr.hour4));

post_cond3.spindles.hour1.Rat8 = r8_c3_post.data.spindle_array(1:length(r8_c3_post.data.spindleXhr.hour1));
post_cond3.spindles.hour2.Rat8 = r8_c3_post.data.spindle_array(1:length(r8_c3_post.data.spindleXhr.hour2));
post_cond3.spindles.hour3.Rat8 = r8_c3_post.data.spindle_array(1:length(r8_c3_post.data.spindleXhr.hour3));
post_cond3.spindles.hour4.Rat8 = r8_c3_post.data.spindle_array(1:length(r8_c3_post.data.spindleXhr.hour4));

post_cond3.deltas.hour1.Rat8 = r8_c3_post.data.delta_array(1:length(r8_c3_post.data.deltaXhr.hour1));
post_cond3.deltas.hour2.Rat8 = r8_c3_post.data.delta_array(1:length(r8_c3_post.data.deltaXhr.hour2));
post_cond3.deltas.hour3.Rat8 = r8_c3_post.data.delta_array(1:length(r8_c3_post.data.deltaXhr.hour3));
post_cond3.deltas.hour4.Rat8 = r8_c3_post.data.delta_array(1:length(r8_c3_post.data.deltaXhr.hour4));
%%
% making the cond3 files
% presleep
%Rat 1
pre_cond3.ripples.hour1.Rat1 = r1_c3_pre.data.ripple_array(1:length(r1_c3_pre.data.rippleXhr.hour1));
pre_cond3.spindles.hour1.Rat1 = r1_c3_pre.data.spindle_array(1:length(r1_c3_pre.data.spindleXhr.hour1));
pre_cond3.deltas.hour1.Rat1 = r1_c3_pre.data.delta_array(1:length(r1_c3_pre.data.deltaXhr.hour1));

%Rat 2
pre_cond3.ripples.hour1.Rat2 = r2_c3_pre.data.ripple_array(1:length(r2_c3_pre.data.rippleXhr.hour1));
pre_cond3.spindles.hour1.Rat2 = r2_c3_pre.data.spindle_array(1:length(r2_c3_pre.data.spindleXhr.hour1));
pre_cond3.deltas.hour1.Rat2 = r2_c3_pre.data.delta_array(1:length(r2_c3_pre.data.deltaXhr.hour1));

%Rat 4
pre_cond3.ripples.hour1.Rat4 = r4_c3_pre.data.ripple_array(1:length(r4_c3_pre.data.rippleXhr.hour1));
pre_cond3.spindles.hour1.Rat4 = r4_c3_pre.data.spindle_array(1:length(r4_c3_pre.data.spindleXhr.hour1));
pre_cond3.deltas.hour1.Rat4 = r4_c3_pre.data.delta_array(1:length(r4_c3_pre.data.deltaXhr.hour1));

%Rat 7
pre_cond3.ripples.hour1.Rat7 = r7_c3_pre.data.ripple_array(1:length(r7_c3_pre.data.rippleXhr.hour1));
pre_cond3.spindles.hour1.Rat7 = r7_c3_pre.data.spindle_array(1:length(r7_c3_pre.data.spindleXhr.hour1));
pre_cond3.deltas.hour1.Rat7 = r7_c3_pre.data.delta_array(1:length(r7_c3_pre.data.deltaXhr.hour1));

%Rat 8
pre_cond3.ripples.hour1.Rat8 = r8_c3_pre.data.ripple_array(1:length(r8_c3_pre.data.rippleXhr.hour1));
pre_cond3.spindles.hour1.Rat8 = r8_c3_pre.data.spindle_array(1:length(r8_c3_pre.data.spindleXhr.hour1));
pre_cond3.deltas.hour1.Rat8 = r8_c3_pre.data.delta_array(1:length(r8_c3_pre.data.deltaXhr.hour1));

%subplot(2,1,1);plot(r1_pre_c2_h1_ripple_vect);title('presleep rat1 hour1 ripple');
%subplot(2,1,2);plot(r1_post_c2_h1_ripple_vect);title('postsleep rat1 hour1 ripple');
%%
%saving the files (*.mat)
save('presleep_homecage.mat', 'pre_cond1');
save('postsleep_homecage.mat','post_cond1');
save('presleep_retrieval.mat', 'pre_cond2');
save('postsleep_retrieval.mat','post_cond2');
save('presleep_update.mat', 'pre_cond3');
save('postsleep_update.mat','post_cond3');
%%
clear all
clc
%%
% storing the number of events
% 1)run the first section (loading the files (cond = retreival(2))

x = cell2struct(cell(2,1),{'presleep','postsleep'});
y = cell2struct(cell(3,1),{'cond1','cond2','cond3'});
x.presleep = y; x.postsleep = y;

z = cell2struct(cell(4,1),{'hour1','hour2','hour3','hour4'});
z.hour1 = cell(1,4);z.hour2 = cell(1,4); z.hour3 = cell(1,4); z.hour4 = cell(1,4);
x.postsleep.cond1 = z;x.postsleep.cond2 = z;x.postsleep.cond3 = z;
x.presleep.cond1 = cell(1,4);x.presleep.cond2 = cell(1,4);x.presleep.cond3 = cell(1,4);
count_ripples = x; count_spindles = x; count_deltas = x;
%%
%counting the events for the first condition (to do)
%%
%counting the events for the second condition (retrieval)
%%
%presleep
%counting the ripple events
count_ripples.presleep.cond2{1} =length(r1_c2_pre.data.rippleXhr.hour1);
count_ripples.presleep.cond2{2} =length(r2_c2_pre.data.rippleXhr.hour1);
count_ripples.presleep.cond2{3} =length(r4_c2_pre.data.rippleXhr.hour1);
count_ripples.presleep.cond2{4} =length(r7_c2_pre.data.rippleXhr.hour1);

%counting the spindle events
count_spindles.presleep.cond2{1} =length(r1_c2_pre.data.spindleXhr.hour1);
count_spindles.presleep.cond2{2} =length(r2_c2_pre.data.spindleXhr.hour1);
count_spindles.presleep.cond2{3} =length(r4_c2_pre.data.spindleXhr.hour1);
count_spindles.presleep.cond2{4} =length(r7_c2_pre.data.spindleXhr.hour1);

%counting the delta events
count_deltas.presleep.cond2{1} =length(r1_c2_pre.data.deltaXhr.hour1);
count_deltas.presleep.cond2{2} =length(r2_c2_pre.data.deltaXhr.hour1);
count_deltas.presleep.cond2{3} =length(r4_c2_pre.data.deltaXhr.hour1);
count_deltas.presleep.cond2{4} =length(r7_c2_pre.data.deltaXhr.hour1);

%%
%postsleep
%counting the ripple events
%hour 1
count_ripples.postsleep.cond2.hour1{1} =length(r1_c2_post.data.rippleXhr.hour1);
count_ripples.postsleep.cond2.hour1{2} =length(r2_c2_post.data.rippleXhr.hour1);
count_ripples.postsleep.cond2.hour1{3} =length(r4_c2_post.data.rippleXhr.hour1);
count_ripples.postsleep.cond2.hour1{4} =length(r7_c2_post.data.rippleXhr.hour1);

%hour 2
count_ripples.postsleep.cond2.hour2{1} =length(r1_c2_post.data.rippleXhr.hour2);
count_ripples.postsleep.cond2.hour2{2} =length(r2_c2_post.data.rippleXhr.hour2);
count_ripples.postsleep.cond2.hour2{3} =length(r4_c2_post.data.rippleXhr.hour2);
count_ripples.postsleep.cond2.hour2{4} =length(r7_c2_post.data.rippleXhr.hour2);

%hour 3
count_ripples.postsleep.cond2.hour3{1} =length(r1_c2_post.data.rippleXhr.hour3);
count_ripples.postsleep.cond2.hour3{2} =length(r2_c2_post.data.rippleXhr.hour3);
count_ripples.postsleep.cond2.hour3{3} =length(r4_c2_post.data.rippleXhr.hour3);
count_ripples.postsleep.cond2.hour3{4} =length(r7_c2_post.data.rippleXhr.hour3);

%hour 4
count_ripples.postsleep.cond2.hour4{1} =length(r1_c2_post.data.rippleXhr.hour4);
count_ripples.postsleep.cond2.hour4{2} =length(r2_c2_post.data.rippleXhr.hour4);
count_ripples.postsleep.cond2.hour4{3} =length(r4_c2_post.data.rippleXhr.hour4);
count_ripples.postsleep.cond2.hour4{4} =length(r7_c2_post.data.rippleXhr.hour4);

%counting the spindle events
%hour 1
count_spindles.postsleep.cond2.hour1{1} =length(r1_c2_post.data.spindleXhr.hour1);
count_spindles.postsleep.cond2.hour1{2} =length(r2_c2_post.data.spindleXhr.hour1);
count_spindles.postsleep.cond2.hour1{3} =length(r4_c2_post.data.spindleXhr.hour1);
count_spindles.postsleep.cond2.hour1{4} =length(r7_c2_post.data.spindleXhr.hour1);

%hour 2
count_spindles.postsleep.cond2.hour2{1} =length(r1_c2_post.data.spindleXhr.hour2);
count_spindles.postsleep.cond2.hour2{2} =length(r2_c2_post.data.spindleXhr.hour2);
count_spindles.postsleep.cond2.hour2{3} =length(r4_c2_post.data.spindleXhr.hour2);
count_spindles.postsleep.cond2.hour2{4} =length(r7_c2_post.data.spindleXhr.hour2);

%hour 3
count_spindles.postsleep.cond2.hour3{1} =length(r1_c2_post.data.spindleXhr.hour3);
count_spindles.postsleep.cond2.hour3{2} =length(r2_c2_post.data.spindleXhr.hour3);
count_spindles.postsleep.cond2.hour3{3} =length(r4_c2_post.data.spindleXhr.hour3);
count_spindles.postsleep.cond2.hour3{4} =length(r7_c2_post.data.spindleXhr.hour3);

%hour 4
count_spindles.postsleep.cond2.hour4{1} =length(r1_c2_post.data.spindleXhr.hour4);
count_spindles.postsleep.cond2.hour4{2} =length(r2_c2_post.data.spindleXhr.hour4);
count_spindles.postsleep.cond2.hour4{3} =length(r4_c2_post.data.spindleXhr.hour4);
count_spindles.postsleep.cond2.hour4{4} =length(r7_c2_post.data.spindleXhr.hour4);


%counting the delta events
%hour 1
count_deltas.postsleep.cond2.hour1{1} =length(r1_c2_post.data.deltaXhr.hour1);
count_deltas.postsleep.cond2.hour1{2} =length(r2_c2_post.data.deltaXhr.hour1);
count_deltas.postsleep.cond2.hour1{3} =length(r4_c2_post.data.deltaXhr.hour1);
count_deltas.postsleep.cond2.hour1{4} =length(r7_c2_post.data.deltaXhr.hour1);

%hour 2
count_deltas.postsleep.cond2.hour2{1} =length(r1_c2_post.data.deltaXhr.hour2);
count_deltas.postsleep.cond2.hour2{2} =length(r2_c2_post.data.deltaXhr.hour2);
count_deltas.postsleep.cond2.hour2{3} =length(r4_c2_post.data.deltaXhr.hour2);
count_deltas.postsleep.cond2.hour2{4} =length(r7_c2_post.data.deltaXhr.hour2);

%hour 3
count_deltas.postsleep.cond2.hour3{1} =length(r1_c2_post.data.deltaXhr.hour3);
count_deltas.postsleep.cond2.hour3{2} =length(r2_c2_post.data.deltaXhr.hour3);
count_deltas.postsleep.cond2.hour3{3} =length(r4_c2_post.data.deltaXhr.hour3);
count_deltas.postsleep.cond2.hour3{4} =length(r7_c2_post.data.deltaXhr.hour3);

%hour 4
count_deltas.postsleep.cond2.hour4{1} =length(r1_c2_post.data.deltaXhr.hour4);
count_deltas.postsleep.cond2.hour4{2} =length(r2_c2_post.data.deltaXhr.hour4);
count_deltas.postsleep.cond2.hour4{3} =length(r4_c2_post.data.deltaXhr.hour4);
count_deltas.postsleep.cond2.hour4{4} =length(r7_c2_post.data.deltaXhr.hour4);
%%
%counting the events of the third condition (update)
%run the third section

%%
%presleep of cond 3
%counting the ripple events
count_ripples.presleep.cond3{1} =length(r1_c3_pre.data.rippleXhr.hour1);
count_ripples.presleep.cond3{2} =length(r2_c3_pre.data.rippleXhr.hour1);
count_ripples.presleep.cond3{3} =length(r4_c3_pre.data.rippleXhr.hour1);
count_ripples.presleep.cond3{4} =length(r7_c3_pre.data.rippleXhr.hour1);

%counting the spindle events
count_spindles.presleep.cond3{1} =length(r1_c3_pre.data.spindleXhr.hour1);
count_spindles.presleep.cond3{2} =length(r2_c3_pre.data.spindleXhr.hour1);
count_spindles.presleep.cond3{3} =length(r4_c3_pre.data.spindleXhr.hour1);
count_spindles.presleep.cond3{4} =length(r7_c3_pre.data.spindleXhr.hour1);

%counting the delta events
count_deltas.presleep.cond3{1} =length(r1_c3_pre.data.deltaXhr.hour1);
count_deltas.presleep.cond3{2} =length(r2_c3_pre.data.deltaXhr.hour1);
count_deltas.presleep.cond3{3} =length(r4_c3_pre.data.deltaXhr.hour1);
count_deltas.presleep.cond3{4} =length(r7_c3_pre.data.deltaXhr.hour1);
%%
%postsleep of cond 3
%counting the ripple events
%hour 1
count_ripples.postsleep.cond3.hour1{1} =length(r1_c3_post.data.rippleXhr.hour1);
count_ripples.postsleep.cond3.hour1{2} =length(r2_c3_post.data.rippleXhr.hour1);
count_ripples.postsleep.cond3.hour1{3} =length(r4_c3_post.data.rippleXhr.hour1);
count_ripples.postsleep.cond3.hour1{4} =length(r7_c3_post.data.rippleXhr.hour1);

%hour 2
count_ripples.postsleep.cond3.hour2{1} =length(r1_c3_post.data.rippleXhr.hour2);
count_ripples.postsleep.cond3.hour2{2} =length(r2_c3_post.data.rippleXhr.hour2);
count_ripples.postsleep.cond3.hour2{3} =length(r4_c3_post.data.rippleXhr.hour2);
count_ripples.postsleep.cond3.hour2{4} =length(r7_c3_post.data.rippleXhr.hour2);

%hour 3
count_ripples.postsleep.cond3.hour3{1} =length(r1_c3_post.data.rippleXhr.hour3);
count_ripples.postsleep.cond3.hour3{2} =length(r2_c3_post.data.rippleXhr.hour3);
count_ripples.postsleep.cond3.hour3{3} =length(r4_c3_post.data.rippleXhr.hour3);
count_ripples.postsleep.cond3.hour3{4} =length(r7_c3_post.data.rippleXhr.hour3);

%hour 4
count_ripples.postsleep.cond3.hour4{1} =length(r1_c3_post.data.rippleXhr.hour4);
count_ripples.postsleep.cond3.hour4{2} =length(r2_c3_post.data.rippleXhr.hour4);
count_ripples.postsleep.cond3.hour4{3} =length(r4_c3_post.data.rippleXhr.hour4);
count_ripples.postsleep.cond3.hour4{4} =length(r7_c3_post.data.rippleXhr.hour4);

%counting the spindle events
%hour 1
count_spindles.postsleep.cond3.hour1{1} =length(r1_c3_post.data.spindleXhr.hour1);
count_spindles.postsleep.cond3.hour1{2} =length(r2_c3_post.data.spindleXhr.hour1);
count_spindles.postsleep.cond3.hour1{3} =length(r4_c3_post.data.spindleXhr.hour1);
count_spindles.postsleep.cond3.hour1{4} =length(r7_c3_post.data.spindleXhr.hour1);

%hour 2
count_spindles.postsleep.cond3.hour2{1} =length(r1_c3_post.data.spindleXhr.hour2);
count_spindles.postsleep.cond3.hour2{2} =length(r2_c3_post.data.spindleXhr.hour2);
count_spindles.postsleep.cond3.hour2{3} =length(r4_c3_post.data.spindleXhr.hour2);
count_spindles.postsleep.cond3.hour2{4} =length(r7_c3_post.data.spindleXhr.hour2);

%hour 3
count_spindles.postsleep.cond3.hour3{1} =length(r1_c3_post.data.spindleXhr.hour3);
count_spindles.postsleep.cond3.hour3{2} =length(r2_c3_post.data.spindleXhr.hour3);
count_spindles.postsleep.cond3.hour3{3} =length(r4_c3_post.data.spindleXhr.hour3);
count_spindles.postsleep.cond3.hour3{4} =length(r7_c3_post.data.spindleXhr.hour3);

%hour 4
count_spindles.postsleep.cond3.hour4{1} =length(r1_c3_post.data.spindleXhr.hour4);
count_spindles.postsleep.cond3.hour4{2} =length(r2_c3_post.data.spindleXhr.hour4);
count_spindles.postsleep.cond3.hour4{3} =length(r4_c3_post.data.spindleXhr.hour4);
count_spindles.postsleep.cond3.hour4{4} =length(r7_c3_post.data.spindleXhr.hour4);

%counting the delta events
%hour 1
count_deltas.postsleep.cond3.hour1{1} =length(r1_c3_post.data.deltaXhr.hour1);
count_deltas.postsleep.cond3.hour1{2} =length(r2_c3_post.data.deltaXhr.hour1);
count_deltas.postsleep.cond3.hour1{3} =length(r4_c3_post.data.deltaXhr.hour1);
count_deltas.postsleep.cond3.hour1{4} =length(r7_c3_post.data.deltaXhr.hour1);

%hour 2
count_deltas.postsleep.cond3.hour2{1} =length(r1_c3_post.data.deltaXhr.hour2);
count_deltas.postsleep.cond3.hour2{2} =length(r2_c3_post.data.deltaXhr.hour2);
count_deltas.postsleep.cond3.hour2{3} =length(r4_c3_post.data.deltaXhr.hour2);
count_deltas.postsleep.cond3.hour2{4} =length(r7_c3_post.data.deltaXhr.hour2);

%hour 3
count_deltas.postsleep.cond3.hour3{1} =length(r1_c3_post.data.deltaXhr.hour3);
count_deltas.postsleep.cond3.hour3{2} =length(r2_c3_post.data.deltaXhr.hour3);
count_deltas.postsleep.cond3.hour3{3} =length(r4_c3_post.data.deltaXhr.hour3);
count_deltas.postsleep.cond3.hour3{4} =length(r7_c3_post.data.deltaXhr.hour3);

%hour 4
count_deltas.postsleep.cond3.hour4{1} =length(r1_c3_post.data.deltaXhr.hour4);
count_deltas.postsleep.cond3.hour4{2} =length(r2_c3_post.data.deltaXhr.hour4);
count_deltas.postsleep.cond3.hour4{3} =length(r4_c3_post.data.deltaXhr.hour4);
count_deltas.postsleep.cond3.hour4{4} =length(r7_c3_post.data.deltaXhr.hour4);

%%
