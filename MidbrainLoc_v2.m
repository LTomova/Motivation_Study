function MidbrainLoc_v2
%% Midloc: functional localizer for dopaminergic midbrain (SN/VTA)
% for PTB Version 3.0.13 on Matlab 2015b on MacOS
% duration: ~13min
% adapted from Krebs 2011
% made by Livia Tomova 2018

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% input data for response and specify paths for stimuli and output data

%subID
subID=input('Enter the Subject ID: ');
%set paths and create subject log folder
rootDir = '/Users/maruq/Documents/Experiments/SISO/Midbrain_Loc';
imDir=fullfile(rootDir,'/LocIms');
TimDir=fullfile(imDir,'/TIms');
NimDir=fullfile(imDir,'/EdIms');
TrainedImages=dir(fullfile(TimDir,'*.jpg'));
NewImages=dir(fullfile(NimDir,'*.jpg'));
logDir=fullfile(rootDir,'log');
%check if subjectdir with this name exists already, if not make one
subjectDir=fullfile(logDir,sprintf('MidbrainLoc_%s%d',subID));
exdir=exist(subjectDir);
if exdir ==7
    sprintf('A folder with this name already exists! Task stopped')
    return
else
    mkdir(logDir,sprintf('MidbrainLoc_%s%d',subID));
end
%load jitter distribution
load jit1
jitst=Shuffle(jit1);
jiten=Shuffle(jit1);
triggerKey='+';
%% Psychtoolbox
%  Here, all necessary PsychToolBox functions are initiated and the
%  instruction screens are set up.
Screen('Preference','VisualDebugLevel',0);
Screen('Preference', 'SkipSyncTests', 1);
KbName('UnifyKeyNames');
cd(rootDir);
HideCursor;
disp        = max(Screen('Screens'));
[w, wRect]  = Screen('OpenWindow',disp,0);
[x0, y0]		= RectCenter(wRect);   % Screen center.
Screen(   'Preference', 'SkipSyncTests', 1);
Screen(w, 'TextFont', 'Helvetica');
Screen(w, 'TextSize', 45);  %30
task		= sprintf('Gambling task');
instructions1		= sprintf('Press 1 if target < 5 and press 2 if target > 5');
instructions2		= sprintf('You have 500ms to respond to win the trial!');
Screen(w, 'DrawText', task, x0-125, y0-60, 255);
Screen(w, 'DrawText', instructions1, x0-400, y0, 255);
Screen(w, 'DrawText', instructions2, x0-400, y0+60, 255);
Screen(w, 'Flip');

%wait for trigger pulse
while 1
    FlushEvents;
    trig=GetChar;
    if trig == triggerKey
        break
    end
end

ExperimentStart = GetSecs;

Screen(w, 'TextSize', 50);
DrawFormattedText(w, '+',x0,y0,[255,255,255],40);
Screen(w, 'Flip');
WaitSecs(6);
Screen('Close');
% this is when the experiment starts




%randomize numbers 1-10
randtarget=randperm(9);
randtarget(randtarget==5)=[];


%make random order for condition:
%1=reward/novel
%2=loss/familiar
%distribution with 50% cond 1 and 50% cond 2 of all trials
count=0;
cond =  Shuffle(repmat([2 1],1,80/2));
for trial = 1:80
    %for trial = 1:80
    
    count=count+1;
    
    if ((trial == 9) || (trial == 17) || (trial == 25) || (trial == 33)...
            || (trial == 41) || (trial == 49) || (trial == 57) || (trial == 65)...
            || (trial ==73))
        randtarget=Shuffle(randtarget);
        count=count-8;
    end
    
    %if this is reward/novel trial, select picture from novel folder
    if cond(trial) == 1
        
        %read in image for this trial from folder with novel images
        trialIm=NewImages(trial).name;
        randpic=imread(fullfile(NimDir,trialIm));
        
    elseif cond(trial) == 2
        
        %make random selection of one of the 5 trained images
        trainim=randperm(5);
        trainim=Shuffle(trainim);
        thisim=trainim(1);
        
        %read in image for this trial from folder with trained images
        trialIm=TrainedImages(thisim).name;
        randpic=imread(fullfile(TimDir,trialIm));
        
        
    end
    
    [ypic,xpic,~]=size(randpic);
    sx=900; %desired x-size of the image (in pixels)
    sy=ypic*sx/xpic; %desired y size - keep it proportional
    destrect=[x0-sx/2,y0-sy/2,x0+sx/2,y0+sy/2];
    
    % display the image
    pictex=Screen(w,'MakeTexture',randpic);
    Screen('DrawTexture',w,pictex,[],destrect);
    CueDisplayStart(trial)=GetSecs;
    Screen(w, 'Flip');
    WaitSecs(2);
    Screen('Close');
    CueDisplayEnd(trial)=GetSecs;
    
    
    
    %draw fixation cross (jittered duration)
    Screen(w, 'TextSize', 50);
    DrawFormattedText(w, '+',x0,y0,[255,255,255],40);
    Screen(w, 'Flip');
    WaitSecs(jitst(trial));
    Screen('Close');
    
    %pick random number from
    trialtarget(trial)=randtarget(count);
    %show target
    Screen(w, 'TextSize', 50);
    DrawFormattedText(w, num2str(trialtarget(trial)),x0,y0,[255,255,255],40);
    Screen(w, 'Flip');
    WaitSecs(0.1);
    Screen('Close');
    
     %adaptive: if participants with 10 times in a row window for button press becomes slightly narrower 
    if trial >10
        sumwin=sum(win(trial-10:trial-1));
        if sumwin > 8
            quesDur(trial)=0.4;
        else
            quesDur(trial)=0.5;
        end
    else
        quesDur(trial)=0.5;
    end
    if trialtarget(trial) <5
        tar(trial)=1
    elseif trialtarget(trial) >5
        tar(trial)=2
    end
    %wait for response
    Screen(w, 'TextSize', 50);
    DrawFormattedText(w, '+',x0,y0,[255,255,255],40);
    Screen(w, 'Flip');
    responseStart=GetSecs;
    while ( GetSecs - responseStart ) < quesDur(trial)
        
        
        
        DisableKeysForKbCheck([87 46 34 6 54 162])
        [a,~,keyCode]	= KbCheck(-3);					% check to see if a key is being pressed
        if a
            
            button= find(keyCode);
            thiskey= KbName(button(1));
            thiskey=thiskey(1);
            thiskey=str2double(thiskey(1));
            responsetime(trial)=GetSecs-responseStart;
            %key(trial)=thiskey
            
        end
    end
    
    if exist('thiskey','var')==1
        key(trial)=thiskey
    else
        key(trial)=99;
    end
    
    %key=str2num(key(1))
    if tar(trial) ==1 && key(trial)==1
        win(trial) =1
    elseif tar(trial)==2 && key(trial)==2
        win(trial) =1
    else
        win(trial) =0
        
    end
    
    
    
    
    
    if cond (trial) ==1
        if win(trial)==1
            %outcome
            Screen(w, 'TextSize', 50);
            DrawFormattedText(w, 'You won 1$!',x0-150,y0,[255,255,255],40);
            OutcomeDisplayStart=GetSecs;
            Screen(w, 'Flip');
            WaitSecs(0.5);
            Screen('Close');
            
        elseif win(trial)==0
            %outcome
            Screen(w, 'TextSize', 50);
            DrawFormattedText(w, 'You lost -0.2cents!',x0-150,y0,[255,255,255],40);
            OutcomeDisplayStart=GetSecs;
            Screen(w, 'Flip');
            WaitSecs(0.5);
            Screen('Close');
        end
    elseif cond(trial) ==2
        if win(trial)==1
            %outcome
            Screen(w, 'TextSize', 50);
            DrawFormattedText(w, 'o',x0,y0,[255,255,255],40);
            OutcomeDisplayStart=GetSecs;
            Screen(w, 'Flip');
            WaitSecs(0.5);
            Screen('Close');
            
        elseif win(trial)==0
            %outcome
            Screen(w, 'TextSize', 50);
            DrawFormattedText(w, 'o',x0,y0,[255,255,255],40);
            OutcomeDisplayStart=GetSecs;
            Screen(w, 'Flip');
            WaitSecs(0.5);
            Screen('Close');
        end
    end
    
    
    
    %SOA
    Screen(w, 'TextSize', 50);
    DrawFormattedText(w, '+',x0,y0,[255,255,255],40);
    Screen(w, 'Flip');
    WaitSecs(jiten(trial));
    Screen('Close');
    
    
    clear thiskey
    
    save safetylog
    
end %trial

Screen(w, 'TextSize', 50);
DrawFormattedText(w, '+',x0,y0,[255,255,255],40);
Screen(w, 'Flip');
WaitSecs(6);
Screen('Close');


cd(subjectDir)
save(['MidbrainLoc_', subID ,'.mat']);

Screen('CloseAll');

warning on;

cd(rootDir)
end%main function
