function CIC_v3
%% CIC: Cue Induced Craving Task
% for PTB Version 3.0.13 on Matlab 2015b on MacOS
% this version has the final timings for the fMRI study
% written by Livia Tomova, 2018


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% input data for response


% subj_id
subID = input('Enter the Subject ID: ');
runNr = input ('Enter the number of this run: ');
triggerKey='+';
%set paths - for individualized pics, this needs to be adapted for each participant!
rootDir = '/Users/maruq/Documents/Experiments/SISO/CIC';
fDir=fullfile(rootDir,'/FoodCues/FoodPics_ID153/Session3');
sDir=fullfile(rootDir,'/SocialCues/SocialPics_ID153/Session3');
cDir=fullfile(rootDir,'/ControlCues/ControlPics_ID153/Session3');
%read in images from each directory
FIms=dir(fullfile(fDir,'*.jpg'));
SIms=dir(fullfile(sDir,'*.jpg'));
CIms=dir(fullfile(cDir,'*.jpg'));
load(fullfile(sDir,'SIms_txt.mat'));
stxt=SIms_txt;
load(fullfile(fDir,'FIms_txt.mat'));
ftxt=FIms_txt;
load(fullfile(cDir,'CIms_txt.mat'));
ctxt=CIms_txt;


%check if log folder already exists and if not create it
logpath = './log_CIC';
subjectdir = fullfile(logpath,sprintf('CIC_%s_run%d',subID,runNr));
exdir=exist(subjectdir);
if exdir== 7
    sprintf('A folder with this name already exists. The experiment is stopped to not overwrite any data.')
    return
else
    mkdir(logpath,sprintf('CIC_%s_run%d',subID,runNr))
end

%conditons:
% 1= social
% 2= food
% 3= control
% a randomization will be made for each run (6 runs, 6 blocks per run (2 blocks per condition))



%jitter iti_CIC distribution: mean=3.5, range= 2-6 
load iti_CIC
%shuffle values for each experiment
jit1=Shuffle(iti_CIC);  %jit1= jit for fixation cross at beginning of trial
jit2=Shuffle(iti_CIC);  %jit2= jit for fixation cross before craving question

%in first run: create order of all images which will be saved to use during experiment
% in other runs: use the same order

if runNr == 1
exp_order=randperm(54);
exp_order=Shuffle(exp_order);
save exp_order exp_order
else
    load exp_order
end

% configurations
cd(rootDir);
HideCursor;
disp        = max(Screen('Screens'));
[w, wRect]  = Screen('OpenWindow',disp,0);
[x0, y0]		= RectCenter(wRect);   % Screen center.
Screen(   'Preference', 'SkipSyncTests', 1);
Screen(w, 'TextFont', 'Helvetica');
Screen(w, 'TextSize', 45);  %30

%instructions
title = 'Picture task';
instructions1 = 'Look at the pictures on the screen and read the text';


%in case background screen should be white, add this:
%Screen('FillRect', window, [255,255,255])


% this is when the run starts
runStart = GetSecs;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% present instructions
DrawFormattedText(w, title,x0-300,y0-300,[255,255,255],40);
DrawFormattedText(w, instructions1,x0-300,y0-200,[255,255,255],40);
Screen(w,'Flip');

%wait for trigger pulse
while 1
    FlushEvents;
    trig=GetChar;
    if trig == triggerKey
        break
    end
end

ExperimentStart = GetSecs;

%start with fixation cross (only 6s because first trial also starts with fixation cross)
Screen(w, 'TextSize', 50);
    DrawFormattedText(w, '+',x0,y0,[255,255,255],40);
    Screen(w, 'Flip');
    WaitSecs(6);
    Screen('Close');
    
%create count for each run    
if runNr==1
countc=0;
counts=0;
countf=0;
elseif runNr ==2
    countc =9;
    counts =9;
    countf =9;
elseif runNr==3
    countc =18;
    counts =18;
    countf =18;
elseif runNr ==4
    countc=27;
    counts=27;
    countf=27;
elseif runNr ==5
    countc =36;
    counts =36;
    countf =36;
elseif runNr == 6
    countc = 45;
    counts = 45;
    countf = 45;
end
    
%create random order of conditions for block
    condpm=randperm(3);
    condtmp=perms(condpm);
    cond(1,1:3)=condtmp(1,1:3);
    cond(1,4:6)=condtmp(2,1:3);
    cond(1,7:9)=condtmp(3,1:3);
    
    trial=0;
%% blockstart
for block = 1:9
    
    %draw fixation cross (jittered duration)
    DrawFormattedText(w, '+',x0,y0,[255,255,255],40);
    Screen(w,'Flip');
    WaitSecs(jit1(block));
    Screen('Close');
    

    %imageloopstart
    BlockDisplayStart(block)=GetSecs;
    for img=1:3
        
        trial=trial+1;
        
        %read in images for current block

        if cond(block) == 1
            counts = counts+1;
            thisim=exp_order(counts); %randomization
            %read in image for this block
            cimg=SIms(thisim).name;
            randpic=imread(fullfile(sDir,cimg));
            randtxt=stxt;
        elseif cond(block) == 2
            countf = countf+1;
            thisim=exp_order(countf); %randomization
            %read in image for this block
            cimg=FIms(thisim).name;
            randpic=imread(fullfile(fDir,cimg));
            randtxt=ftxt;
        elseif cond(block) == 3
            countc = countc+1;
            thisim=exp_order(countc); %randomization
            %read in image for this block
            cimg=CIms(thisim).name;
            randpic=imread(fullfile(cDir,cimg));
            randtxt=ctxt;
        end
        

        thisline=randtxt{thisim,1};
        [ypic,xpic,~]=size(randpic);
        sx=700; %desired x-size of the image (in pixels)
        sy=ypic*sx/xpic; %desired y size - keep it proportional
        destrect=[x0-sx/2,y0-sy/2,x0+sx/2,y0+sy/2];
        
        % display the image
        %image(imread(RandomImage));
        Screen(w, 'TextSize', 36);
        pictex=Screen(w,'MakeTexture',randpic);
        Screen('DrawTexture',w,pictex,[],destrect);
        DrawFormattedText(w, thisline,x0-300,y0+300,[255,255,255],30);
        PicDisplayStart(trial)=GetSecs;
        Screen(w, 'Flip');
        WaitSecs(5);
        Screen('Close');
        PicDisplayEnd(trial)=GetSecs;
        
        %fixation between each img (not jittered)
        Screen(w, 'TextSize', 40);
        DrawFormattedText(w, '+',x0,y0,[255,255,255],40);
        Screen(w, 'Flip');
        WaitSecs(1);
        Screen('Close');
        
    end %end of image loop for block
    BlockDisplayEnd(block)=GetSecs;

    %draw fixation cross (jittered duration)
    DrawFormattedText(w, '+',x0,y0,[255,255,255],40);
    Screen(w,'Flip');
    WaitSecs(jit2(block));
    Screen('Close');
    
    %call rating scale function and log responses
    blc=cond(block);
    RatingStart(block)=GetSecs;
   [resp, RT_resp ] = craving_scale2(blc,w,x0,y0); 
    response(block)=resp;
    RT(block)=RT_resp;
    RatingEnd(block)=GetSecs;

   %in case task crashes each block is continuously saved
    save safetylog
    
end

%final fixation cross before end of run
Screen(w, 'TextSize', 50);
    DrawFormattedText(w, '+',x0,y0,[255,255,255],40);
    Screen(w, 'Flip');
    WaitSecs(8);
    Screen('Close');

%log data
RunEnd=GetSecs;
cd(subjectdir);
save (['CIC_', subID, '_run', num2str(runNr),'.mat']);
Screen('CloseAll');
cd(rootDir);
warning on;


end

