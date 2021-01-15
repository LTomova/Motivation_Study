function [resp, RT_resp] = craving_scale2(blc,w,x0,y0)
%craving_scale: rating subjective craving
% type: social, food and control question for control block

downkey=1;
upkey=2;
ckey=3;
%duration how long participants can take to make their decision
respDur=5;

scale = imread('ratingscale_vert.jpg'); %to display scale
fill = imread('fil_vert.jpg');   %to diplay scale

%create size of ratingscale on screen
destrect_sc=[710,350,850,650];

penWidthPixels = 4;% Pen width for the frame

%ask question depending on block
if blc == 1
    ques='How much do you want social contact right now?'; %social
elseif blc == 2
    ques='How much do you want food right now?'; %food
elseif blc == 3
    ques='How much did you like the flower pictures?'; %control
end

    %starting values for scale
    pos = 500; %starting position of fill
    destrect_fl=[710,pos,850,650]; %create first fill location
    rx=5;
    pumps = '5';
    
    %create screen with first question
    responseStart = GetSecs;
    confirm = 0;
    
    %draw first scale
    ratingscale= Screen('MakeTexture',w,scale);
    fillscale= Screen('MakeTexture',w,fill);
    Screen('DrawTexture',w,ratingscale, [], destrect_sc);
    Screen('DrawTexture',w,fillscale, [], destrect_fl);
    DrawFormattedText(w, pumps,450,500,[255,255,255],40);
    DrawFormattedText(w, ques,x0-300,y0-300,[255,255,255],30);
    Screen(w,'Flip');
    
    
    thiskey=0;
    FlushEvents('keyDown');
    
    stop=responseStart+ respDur; 
    
    while GetSecs < stop %wait for ckey press and make sure screen coordinates work
        
        DisableKeysForKbCheck([87 46 34 6 54 162]); % scanner trigger can't mess with input (adapt this depending on scanner trigger key)
       
        
        %wait for keypress
         [a , keyCode,b] = KbPressWait(-3);
        if a  %if keypress occurs
            Key = find(keyCode); %% find keycode of key that was pressed
            thiskey = KbName(Key(1)); %% figure out its name (taking only the first button if subjects hit more than one)
            thiskey = str2double(thiskey(1)); %% make it a number, taking only the first (since KbName can return multiple e.g. 1! instead of 1)
            %if key 1 is pressed go down on scale
            if (thiskey == downkey)
                %  while pos < 725
                pos = pos + 28; %move cursor on screen
                if pos > 650 %if limit reached stop moving
                    pos=650;
                else
                    rx = rx - 1; %subtract 1 for each move that is made to left
                    if rx < 0 %if limit reached stop subtracting
                        rx=0;
                    else
                        pumps = num2str(rx);%change number of pumps on screen
                        destrect_fl=[710,pos,850,650];
                        %draw whole scale again with new fill and numbers
                        ratingscale= Screen(w,'MakeTexture',scale);
                        fillscale= Screen(w,'MakeTexture',fill);
                        Screen('DrawTexture',w,ratingscale, [], destrect_sc);
                        Screen('DrawTexture',w,fillscale, [], destrect_fl);
                        DrawFormattedText(w, pumps,450,500,[255,255,255],40);
                        DrawFormattedText(w, ques,x0-300,y0-300,[255,255,255],30);
                        Screen(w,'Flip');
                    end
                end
            elseif (thiskey == upkey)  %if key 2 is pressed go up(see comments above for explanations)
                pos = pos - 28;
                if pos < 350
                    pos=350;
                else
                    rx = rx + 1;
                    if rx > 10
                        rx=10;
                    else
                        pumps =  num2str(rx);
                        destrect_fl=[710,pos,850,650];
                        %draw whole scale again with new fill and numbers
                        ratingscale= Screen(w,'MakeTexture',scale);
                        fillscale= Screen(w,'MakeTexture',fill);
                        Screen('DrawTexture',w,ratingscale, [], destrect_sc);
                        Screen('DrawTexture',w,fillscale, [], destrect_fl);
                        DrawFormattedText(w, pumps,450,500,[255,255,255],40);
                        DrawFormattedText(w, ques,x0-300,y0-300,[255,255,255],30);
                        Screen(w,'Flip');
                    end
                end
            elseif(thiskey == ckey) %if confirm key is pressed
                RT_resp = GetSecs- responseStart;
                confirm = 1;
                %paint ratingscale
                ratingscale= Screen(w,'MakeTexture',scale);
                fillscale= Screen(w,'MakeTexture',fill);
                Screen('DrawTexture',w,ratingscale, [], destrect_sc);
                Screen('DrawTexture',w,fillscale, [], destrect_fl);
                DrawFormattedText(w, pumps,450,500,[255,255,255],40);
                DrawFormattedText(w, ques,x0-300,y0-300,[255,255,255],30);
                %make black frame around rectangle
                Screen('FrameRect', w, [255,255,255], destrect_sc, penWidthPixels);
                Screen(w,'Flip');
                save safetylog
                if GetSecs < (responseStart + respDur)
                    xy = stop - RT_resp;
                    ay=xy-responseStart;
                    WaitSecs(ay);
                end
                Screen('Close');
            end
        end
    end
    
    resp=rx;
    if confirm ~= 1
        resp=9999;
        RT_resp=9999;
    end


end

