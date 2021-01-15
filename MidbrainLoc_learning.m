
function MidbrainLoc_learning
% learn stimuli for functional localizer for dopaminergic midbrain (SN/VTA)
% shows participants each image and asks if familiar or not
% duration=1min38s
% made by Livia Tomova 2018

rootDir = '/Users/maruq/Documents/Experiments/SISO/Midbrain_Loc';
imDir=fullfile(rootDir,'/LocIms/TIms');
MyImages=dir(fullfile(imDir,'*.jpg'));


%% Psychtoolbox
%  Here, all necessary PsychToolBox functions are initiated and the
%  instruction screens are set up.
Screen('Preference','VisualDebugLevel',0);
Screen('Preference', 'SkipSyncTests', 1);
KbName('UnifyKeyNames');
%try
cd(rootDir);
HideCursor;
disp        = max(Screen('Screens'));
[w, wRect]  = Screen('OpenWindow',disp,0);
[x0, y0]		= RectCenter(wRect);   % Screen center.
Screen(   'Preference', 'SkipSyncTests', 1);
Screen(w, 'TextFont', 'Helvetica');
Screen(w, 'TextSize', 45);  %30
task		= sprintf('Familiarization task');
instructions1		= sprintf('Press 1 if familiar image and press 2 if novel image');
instructions2		= sprintf('You have 2 seconds to respond');
Question1           = sprintf('Familiar?');
Question2           = sprintf('Yes=press1     No=press2');
Pressyes            = sprintf('YES=press1     No=press2');
Pressno             = sprintf('Yes=press1     NO=press2');
quesDur =2;
Screen(w, 'DrawText', task, x0-125, y0-60, 255);
Screen(w, 'DrawText', instructions1, x0-400, y0, 255);
Screen(w, 'DrawText', instructions2, x0-250, y0+60, 255);
Screen(w, 'Flip');
WaitSecs(5);
Screen('Close');% Instructional screen is presented.


count=0;
for trial = 1:15
    
    count=count+1;
    
    if ((trial == 6) || (trial == 11) || (trial == 16))
        count=count-5;
    end
    
    %read in image for this trial
    trialIm=MyImages(count).name;
    randpic=imread(fullfile(imDir,trialIm));
    
    
    [ypic,xpic,~]=size(randpic);
    sx=900; %desired x-size of the image (in pixels)
    sy=ypic*sx/xpic; %desired y size - keep it proportional
    destrect=[x0-sx/2,y0-sy/2,x0+sx/2,y0+sy/2];
    
    % display the image
    %image(imread(RandomImage));
    pictex=Screen(w,'MakeTexture',randpic);
    Screen('DrawTexture',w,pictex,[],destrect);
    Screen(w, 'Flip');
    WaitSecs(2);
    Screen('Close');
    
    %question if cue familiar
    Screen(w, 'DrawText', Question1, x0-400, y0, 255);
    Screen(w, 'DrawText', Question2, x0-400, y0+60, 255);
    Screen(w, 'Flip');
    responseStart=GetSecs;
    
    while ( GetSecs - responseStart ) < quesDur
        DisableKeysForKbCheck([87 46 34 6 54 162])
        [a,~,keyCode]	= KbCheck(-3);					% check to see if a key is being pressed
        if a
            
            button= find(keyCode);
            key= KbName(button(1));
            key=str2num(key(1));
            
            if exist('key','var')==1
                response(trial)=key;
            else
                key=99;
                response(trial)=key;
            end
            if key ==1
                
                Screen(w, 'DrawText', Question1, x0-400, y0, 255);
                Screen(w, 'DrawText', Pressyes, x0-400, y0+60, 255);
                Screen(w, 'Flip');
                
            elseif key ==2
                
                
                Screen(w, 'DrawText', Question1, x0-400, y0, 255);
                Screen(w, 'DrawText', Pressno, x0-400, y0+60, 255);
                Screen(w, 'Flip');
            end
        end
    end
    %SOA
    Screen(w, 'TextSize', 34);
    DrawFormattedText(w, '+',x0,y0,[255,255,255],40);
    Screen(w, 'Flip');
    WaitSecs(0.5);
    Screen('Close');
    
    clear key
end %trial loop

Screen('CloseAll');

save training
warning on;


end %main function

