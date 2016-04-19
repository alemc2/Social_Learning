function [out_recorder,out_rngstate] = PresentWords(randstate,window,windowRect,faces,observer_mode,recorder)
% randstate - state of rng to set to. Useful for reproduction.
% window - Psychtoolbox window handle
% windowRect - PTB rectangle enclosing the window
% faces - cell matrix containing faces to display
% observer_mode - true/false to indicate if just observing as experimenter.Defaults to false
% recorder - If observer_mode is true then we expect the recorder

if nargin<5
    observer_mode = false;
elseif nargin==5 && observer_mode==true
    error('We expect a recorder to be passed in observer mode');
end

if observer_mode == true
    move_index = 1;
end

rng(randstate);

out_recorder = outholder;

% Get the screen numbers. This gives us a number for each of the screens
% attached to our computer. For help see: Screen Screens?
screens = Screen('Screens');

% Draw we select the maximum of these numbers. So in a situation where we
% have two screens attached to our monitor we will draw to the external
% screen. When only one screen is attached to the monitor we will draw to
% this. For help see: help max
screenNumber = max(screens);

% Define black and white (white will be 1 and black 0). This is because
% luminace values are (in general) defined between 0 and 1.
% For help see: help WhiteIndex and help BlackIndex
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);

% Get the size of the on screen window in pixels.
% For help see: Screen WindowSize?
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Get the centre coordinate of the window in pixels
% For help see: help RectCenter
[xCenter, yCenter] = RectCenter(windowRect);

% Instruction rect is 70% at center
Instr_dst_rect = CenterRectOnPointd([0,0,0.7*screenXpixels,0.7*screenYpixels],xCenter,yCenter);

dictionary = {'pencil', 'farmer', 'curtain', 'house', 'parent', 'garden',...
    'turkey', 'mountain', 'river', 'bell', 'coffee', 'nose', 'hat', 'school',...
    'moon', 'drum'};
numwords = size(dictionary,2);
wordpermute = randperm(numwords)';

%Create face indices for easy cell access, each row in the indices
%correspond to a face
[p,q] = meshgrid(1:size(faces,1),1:size(faces,2));
faceindices = [p(:) q(:)];
numfaces = size(faceindices,1);

%Associate words with faces (randomly). Stores indices to look up faces and
%words. shuffle order so display is also random and not it any order.
associations = [ repmat(faceindices,numwords/numfaces,1), wordpermute];
num_associations = size(associations,1);
associations_shuffle = randperm(num_associations);
associations = associations(associations_shuffle,:);
% Critical lures - Associate words with equivalent faces. So swap row
% values
critical_lures = associations;
critical_lures(:,1) = mod(critical_lures(:,1),2)+1;
num_critical = size(critical_lures,1);
% Control lures - Associate words with non-equivalent faces. So swap column
% values and in both rows. Use critical lure merged with original set for
% the transform
control_lures = [associations; critical_lures];
control_lures(:,2) = mod(control_lures(:,2),2)+1;
num_control = size(control_lures,1);

%stage 5 instructions
instr_text = ['Good! The next section of the study is about memory.',... 
    'It is divided into two sections, a study section and a test section.\n',...
    'In the study section, you will see several words presented one at a time on different screens.\n',...
    'Following this, you will proceed to the test section, where you will be tested on your ',...
    'memory for these words.\n\n',...
    'You may now continue onto the study section. Study the words presented on the following screens ',...
    'for the upcoming memory test!',...
    '\n\n Press any button to continue'];
Screen('TextSize', window, 25);
Screen('TextFont', window, 'Times');
DrawFormattedText(window, instr_text,'wrapat', 'center', black, 70, [], [], [], [], Instr_dst_rect);
Screen('Flip', window);
KbStrokeWait;

%stage 5
for word_num=1:num_associations
    %Debug print
    disp(['Showing word ' dictionary{associations(word_num,3)} ' for face ' num2str(associations(word_num,1)) ',' num2str(associations(word_num,2))]);
    %Calculate image sizes and scaling.
    [As1,As2,As3] = size(faces{associations(word_num,1),associations(word_num,2)});
    A_asp_ratio = As2/As1;
    A_newh = screenYpixels/6;
    A_neww = A_asp_ratio*A_newh;
    A_theRect = [0 0 A_neww A_newh];
    %Position it in X center and 1/4th way from top.
    A_dst_rect = CenterRectOnPointd(A_theRect,screenXpixels/2,screenYpixels/6);
    
    %Draw the face
    imageTexture = Screen('MakeTexture',window,faces{associations(word_num,1),associations(word_num,2)});
    Screen('DrawTexture', window, imageTexture, [], A_dst_rect, 0);
    
    % Draw text (word) in the bottom of the screen in black
    Screen('TextSize', window, 40);
    Screen('TextFont', window, 'Times');
    DrawFormattedText(window, dictionary{associations(word_num,3)}, 'center',...
        screenYpixels * 0.45, [0 0 0]);
    
    % Flip to the screen. This command basically draws all of our previous
    % commands onto the screen. See later demos in the animation section on more
    % timing details. And how to demos in this section on how to draw multiple
    % rects at once.
    % For help see: Screen Flip?
    Screen('Flip', window);
    %Wait 5 sec before clearing and displaying next word
    WaitSecs(5);
    %Clear screen and display blank for 500 msec
    Screen('Flip', window);
    WaitSecs(0.5);
end

%stage 6 instructions
instr_text = ['Good! You just completed the study section.',... 
    'You will now move onto the test section.\n\n',...
    'In this section, we will test your memory for what you just saw.\n',... 
    'On each screen answer the question presented based on what you ',...
    'remember from the study section you just completed.\n\n',...
    'In the next sections, press Y for ''yes'' and press N for ''no''.',...
    '\n\n Press any button to continue'];
Screen('TextSize', window, 25);
Screen('TextFont', window, 'Times');
DrawFormattedText(window, instr_text,'wrapat', 'center', black, 70, [], [], [], [], Instr_dst_rect);
Screen('Flip', window);
KbStrokeWait;

%Stage 6
%randomly choose 8 associations, 4 critical lures and 4 control lures
rand_associations = randperm(num_associations,8);
rand_critical = randperm(num_critical,4);
rand_control = randperm(num_control,4);
%Put all these random selections into a display matrix, also store what the
%correct answer is 1 = Yes, 2 = No. Correct answer is stored in 4th column
disp_matrix = [ associations(rand_associations,:), ones(8,1); critical_lures(rand_critical,:), 2*ones(4,1); control_lures(rand_control,:), 2*ones(4,1)];
disp_num = size(disp_matrix,1);
disp_shuffle = randperm(disp_num);
disp_matrix = disp_matrix(disp_shuffle,:);
for trial=1:disp_num
    %Debug print
    disp(['TEST_STAGE:Showing word ' dictionary{disp_matrix(trial,3)} ' for face ' num2str(disp_matrix(trial,1)) ',' num2str(disp_matrix(trial,2))]);
    %Calculate image sizes and scaling.
    [As1,As2,As3] = size(faces{disp_matrix(trial,1),disp_matrix(trial,2)});
    A_asp_ratio = As2/As1;
    A_newh = screenYpixels/6;
    A_neww = A_asp_ratio*A_newh;
    A_theRect = [0 0 A_neww A_newh];
    %Position it in X center and 1/4th way from top.
    A_dst_rect = CenterRectOnPointd(A_theRect,screenXpixels/2,screenYpixels/6);
    
    %Draw the face
    imageTexture = Screen('MakeTexture',window,faces{disp_matrix(trial,1),disp_matrix(trial,2)});
    Screen('DrawTexture', window, imageTexture, [], A_dst_rect, 0);
    
    % Draw text (word) in the bottom of the screen in black
    Screen('TextSize', window, 40);
    Screen('TextFont', window, 'Times');
    DrawFormattedText(window, dictionary{disp_matrix(trial,3)}, 'center',...
        screenYpixels * 0.45, [0 0 0]);
    
    % Draw text in the bottom of the screen in black
    Screen('TextSize', window, 40);
    Screen('TextFont', window, 'Times');
    DrawFormattedText(window, 'Did this word appear with this face?', 'center',...
        screenYpixels * 0.65, [0 0 0]);
    DrawFormattedText(window, 'Yes', screenXpixels * 0.3,...
        screenYpixels * 0.75, [0 0 0]);
    DrawFormattedText(window, 'No', screenXpixels * 0.7,...
        screenYpixels * 0.75, [0 0 0]);
    
    % Flip to the screen. This command basically draws all of our previous
    % commands onto the screen. See later demos in the animation section on more
    % timing details. And how to demos in this section on how to draw multiple
    % rects at once.
    % For help see: Screen Flip?
    Screen('Flip', window,0,1);
    
    %Get positions of Yes/No text to draw outline around chosen value
    X_theRect = [0 0 100 50];
    %Position it in X center and 4/6th way from top.
    X1_dst_rect = CenterRectOnPointd(X_theRect,0.32*screenXpixels,0.77*screenYpixels);
    X2_dst_rect = CenterRectOnPointd(X_theRect,0.72*screenXpixels,0.77*screenYpixels);
    
    if observer_mode ~= true
        %accept input and get time
        initsec = GetSecs;
        while(true)
            [secs,keycode,deltasec] = KbStrokeWait;
            yes = KbName('Y');
            no = KbName('N');
            escape = KbName('ESCAPE');
            if keycode(yes) || keycode(no)
                %Capture time
                endsec = GetSecs;
                out_recorder.input_timing = [out_recorder.input_timing (endsec-initsec)];
                
                %Record correct answer
                out_recorder.correct_ans = [out_recorder.correct_ans disp_matrix(trial,4)];
                %Draw frame around selected value in grey - If not needed
                %simply comment the 2 Screen('FrameRect'...) comands below.
                display_color = [0.6,0.6,0.6];
                %Record moves - 1 = yes, 2 = no
                if keycode(yes)
                    out_recorder.moves = [out_recorder.moves 1];
                    Screen('FrameRect',window,display_color,X1_dst_rect,3);
                else
                    out_recorder.moves = [out_recorder.moves 2];
                    Screen('FrameRect',window,display_color,X2_dst_rect,3);
                end
                Screen('Flip', window);
                WaitSecs(1);
                break
            elseif keycode(escape)
                disp('Exit by escape')
                sca;
                return
            end
        end
    else    %Replay stuff
        %Detect if correct answer
        if recorder.correct_ans(move_index) == recorder.moves(move_index)
            display_color = [0 1 0];
            DrawFormattedText(window, 'Correct', 'center',...
                screenYpixels * 0.85, display_color);
        else
            display_color = [1 0 0];
            DrawFormattedText(window, 'Incorrect', 'center',...
                screenYpixels * 0.85, display_color);
        end
        %Draw appropriate circle
        if recorder.moves(move_index)==1
            Screen('FrameRect',window,display_color,X1_dst_rect,3);
        else
            Screen('FrameRect',window,display_color,X2_dst_rect,3);
        end
        %Wait as long as input user did before display.
        WaitSecs(recorder.input_timing(move_index));
        move_index = move_index+1;
        Screen('Flip', window);
        %Wait 1 sec before clearing like in non-social input
        WaitSecs(1);
    end
    %Clear screen and display blank for 1 sec
    Screen('Flip', window);
    WaitSecs(1);
end

out_rngstate = rng;
end