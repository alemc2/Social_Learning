function PresentLearning(fid,fid2,social,observer_mode)
% fid - first file name where data is stored for non-social leraning/ read
% from for social learning.
% fid2 - second file name where data will be stored for stages 4 and above
% social - true/false to indicate if social learning
% observer_mode - true/false to indicate if just observing as experimenter.Defaults to false

% Set default observer_mode to false if unavailable
if nargin<4
    observer_mode = false;
end

% Clear the workspace and the screen
sca;
close all;

% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

% Seed the random number generator.
if(social ~= true && observer_mode ~= true)
    rng('shuffle');
    out_rngstate = rng;
else
    loaded_values = load(fid);
    if observer_mode == true
        loaded_values2 = load(fid2);
    end
    rng(loaded_values.out_rngstate);
end

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

% Open an on screen window and color it white.
% For help see: Screen OpenWindow?
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, white);

% Get the size of the on screen window in pixels.
% For help see: Screen WindowSize?
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Get the centre coordinate of the window in pixels
% For help see: help RectCenter
[xCenter, yCenter] = RectCenter(windowRect);

% Instruction rect is 70% at center
Instr_dst_rect = CenterRectOnPointd([0,0,0.7*screenXpixels,0.7*screenYpixels],xCenter,yCenter);

% Enable alpha blending for anti-aliasing
% For help see: Screen BlendFunction?
% Also see: Chapter 6 of the OpenGL programming guide
Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

%Load Images
image_dir = ['Images' filesep];
%Define cells to suggest mapping from face to fish
faces = cell(2);
fish = cell(2);
%Permute to generate a mapping and load the images
facepermutations = randperm(4);
fishpermutations = randperm(4);

%For faces along column is associated faces
faces{1,1} = imread([image_dir 'Face' num2str(facepermutations(1)) '.png']);
faces{1,2} = imread([image_dir 'Face' num2str(facepermutations(2)) '.png']);
faces{2,1} = imread([image_dir 'Face' num2str(facepermutations(3)) '.png']);
faces{2,2} = imread([image_dir 'Face' num2str(facepermutations(4)) '.png']);

%For fishes first row are the initial 2 fishes and next row are the fishes
%that come next
fish{1,1} = imread([image_dir 'Fish' num2str(fishpermutations(1)) '.png']);
fish{1,2} = imread([image_dir 'Fish' num2str(fishpermutations(2)) '.png']);
fish{2,1} = imread([image_dir 'Fish' num2str(fishpermutations(3)) '.png']);
fish{2,2} = imread([image_dir 'Fish' num2str(fishpermutations(4)) '.png']);

%Setup parameters for experiment
numblocks = [8 8 8 1 1]; %TODO: For stage 4, 1 block/16 blocks?


continuous_correct_expected = [8 8 12 16 16]; %TODO: Not clear for stage 4, clarify.
numtrials = [4 8 12 16 16];
numfaces = [2 4 4 4 4];
numfishes = [2 2 4 4 4];
%Create face,fish indice for easy cell access, each row in the indices
%correspond to a face/fish
[p,q] = meshgrid(1:size(faces,1),1:size(faces,2));
faceindices = [p(:) q(:)];
[p,q] = meshgrid(1:size(fish,1),1:size(fish,2));
fishindices = [p(:) q(:)];

%Input recording/display variables
if (social ~= true && observer_mode ~= true)
    first_recorder = outholder;
    curr_recorder = first_recorder;
else
    curr_recorder = loaded_values.first_recorder;
    move_index = 1;
end
if observer_mode == true
    second_recorder = loaded_values2.second_recorder;
else
    second_recorder = outholder;
end

%Display/hide feedback
feedback = true;

%my (Dave's) attempt at instruction screens for beginning
    
if social ~= true
    instr_text = ['Welcome! \n\nIn this study, you will be playing a simple game where your job is to learn new',...
        ' information about different people. You will see drawings of people who each have some pet',...
        ' fish. Different people have different kinds of fish. Your job is to learn which kinds of fish each',...
        ' person has. This study has two parts. Part 1 will be a learning phase, while Part 2 will be a test phase.',...
        '\n\nIn the first section, you will learn which kinds of fish each person has by making guesses and ',...
        'receiving feedback on your guesses. After you complete this initial learning section, you will ',...
        'proceed onto the testing phase of the experiment. In this part of the experiment, you will not ',...
        'receive feedback. Your goal is to use what you learned during the first section to perform as well ',...
        'as you can during this testing phase.',...
        '\n\n\n Press any button to continue.'];
    Screen('TextSize', window, 25);
    Screen('TextFont', window, 'Times');
    DrawFormattedText(window, instr_text,'wrapat', 'center', black, 70, [], [], 1.3, [], Instr_dst_rect);
    Screen('Flip', window);
    WaitSecs(.5);
    KbStrokeWait;
    
    instr_texttwo = ['Part 1',...
        '\n\n\n On each trial of this section, you will see a drawing of a person along with two fish. For each ',...
        'trial, your task is to indicate which fish you think the person has. At first, you will have to guess. ',...
        'You will indicate your responses using the LEFT and RIGHT arrow keys on the keyboard.',...
        '\n\nAfter you make your decision by pressing the corresponding key, your selection will be circled ',...
        'on the screen and you will receive a message that will say whether your selection was correct or incorrect. ',...
        '\n\n Your goal is to learn which kinds of fish each person has. You will be tested on what you learn in part 2 of this study.',...
        '\n\n\n Press the space bar to continue.']
    Screen('TextSize', window, 25);
    Screen('TextFont', window, 'Times');
    DrawFormattedText(window, instr_texttwo,'wrapat', 'center', black, 70, [], [], 1.3, [], Instr_dst_rect);
    Screen('Flip', window);
    WaitSecs(.5);
    KbStrokeWait;
else
    instr_text = ['Welcome \n\n In this study, you will be playing a simple game where your job is to learn new ',...
         'information about different people. You will see drawings of people who each have some pet ',...
         'fish. Different people have different kinds of fish. Your job is to learn which kinds of fish each ',...
         'person has. This study has two parts. Part 1 will be a learning phase, while Part 2 will be a test phase. ',...
         '\n\nYou have been assigned to the social learning condition. This means that in the first section, you ',...
         'will learn which kinds of fish each person has by observing the screen of a previous participant ',...
         'from when they completed the learning phase. You will see them make decisions and see the ',...
         'feedback they received on each decision. After you complete this initial learning section, you ',...
         'will proceed onto the testing phase of the experiment. In this part of the experiment, you will ',...
         'make decisions yourself and will not receive feedback. Your goal is to use what you learned ',...
         'from observing the other participant during the first section to perform as well as you can during this testing phase.',...
         '\n\n\n Press any button to continue.'];
    Screen('TextSize', window, 25);
    Screen('TextFont', window, 'Times');
    DrawFormattedText(window, instr_text,'wrapat', 'center', black, 70, [], [], 1.3, [], Instr_dst_rect);
    Screen('Flip', window);
    WaitSecs(.5);
    KbStrokeWait;
    
    instr_texttwo = ['Part 1',...
        '\n\n\n In this section, you will just watch the other participant�s screen and observe how they responded ',...
        'to a series of trials. On each trial, you will see the other participant being presented with a ',...
        'drawing of a person along with two fish. Their task was to indicate which fish they thought the ',...
        'person on the screen has. ',...
        '\n\nWhen they make a selection, a circle will appear on the screen indicating which fish they chose ',...
        'and you will see a message they received that says whether their selection was correct or incorrect. ',...
        '\n\nYour goal is to learn which kinds of fish each person has by watching this participant. You ',...
        'will be tested on what you learn in part 2 of this study.',...
        '\n\n\n Press the space bar to continue.']
    Screen('TextSize', window, 25);
    Screen('TextFont', window, 'Times');
    DrawFormattedText(window, instr_texttwo,'wrapat', 'center', black, 70, [], [], 1.3, [], Instr_dst_rect);
    Screen('Flip', window);
    WaitSecs(.5);
    KbStrokeWait;
end 


% Stage 1 to 7 which in code terms is upto 5 as actual 5,6 handled in a
% different function
for stage=1:5
    %Generate all possible combinations then permute for the order.
    % first 2 colums contain face indices, next two contain left fish, next
    % two the right fish, last column contains the correct fish detail.
    all_combo = [faceindices(1:numfaces(stage),:) , repmat(fishindices(1:2,:),numfaces(stage)/2,1), repmat(flipud(fishindices(1:2,:)),numfaces(stage)/2,1), ones(numfaces(stage),1);
                 faceindices(1:numfaces(stage),:) , repmat(flipud(fishindices(1:2,:)),numfaces(stage)/2,1), repmat(fishindices(1:2,:),numfaces(stage)/2,1), 2*ones(numfaces(stage),1)
                ];
    if stage >= 3
        all_combo = [all_combo;
                     faceindices(1:2,:) , fishindices(3:4,:), flipud(fishindices(3:4,:)), ones(2,1);
                     faceindices(1:2,:) , flipud(fishindices(3:4,:)), fishindices(3:4,:), 2*ones(2,1)
                    ];
    end
    
    if stage>=4
        all_combo=[all_combo;
            faceindices(3:4,:) , fishindices(3:4,:), flipud(fishindices(3:4,:)), ones(2,1);
            faceindices(3:4,:) , flipud(fishindices(3:4,:)), fishindices(3:4,:), 2*ones(2,1)
        ];
        % Set social false from now as we want them to also learn normally
        social = false;
        % No feedback from now on
        feedback = false;
        % Start recording separately from stage 4 as no feedback so only
        % for analytical reasons. This'll be recorded even for social so
        % separate.
        curr_recorder = second_recorder;
        
        %If in observer mode we want to reset move_index at this point as
        %we start reading a new file
        if observer_mode == true
            move_index = 1;
        end
        
        %For 4th stage display some instructions
        if stage == 4
            if social ~= true
                instr_text = ['Part 2\n\n\n',...
                    'Good! Now you will move onto the test part of the experiment. In this part of the experiment you ',...
                    'will need to remember what you have learned so far. You will NOT be shown the correct ',...
                    'answers. At the end of the experiment, the computer will tell you how many you got right. Good Luck!',...
                    '\n\n Press any button to continue'];
                Screen('TextSize', window, 25);
                Screen('TextFont', window, 'Times');
                DrawFormattedText(window, instr_text,'wrapat', 'center', black, 70, [], [], 1.3, [], Instr_dst_rect);
                Screen('Flip', window);
                KbStrokeWait;
            else 
                instr_text = ['Part 2\n\n\n',...
                    'Good! Now you will move onto the test part of the experiment. In this part of the experiment, ',...
                    'you will need to remember what you have learned so far. You will respond yourself and will ',...
                    'NOT be shown the correct answers. At the end of the experiment, the computer will tell you how ',...
                    'many you got right. Good Luck!',...
                    '\n\n Press any button to continue'];
                Screen('TextSize', window, 25);
                Screen('TextFont', window, 'Times');
                DrawFormattedText(window, instr_text,'wrapat', 'center', black, 70, [], [], 1.3, [], Instr_dst_rect);
                Screen('Flip', window);
                KbStrokeWait;  
            end
        end
        
        %For 7th stage (5th stage in the terms used in code) display some instructions
        if stage == 5
            instr_text = ['Good! You have completed the memory test.\n\n',...
                'In this final part of the experiment you will be tested the last time on what you have learned.',...
                'Again, you will NOT be shown the correct answers.Good Luck!',...
                '\n\n Press any button to continue'];
            Screen('TextSize', window, 25);
            Screen('TextFont', window, 'Times');
            DrawFormattedText(window, instr_text,'wrapat', 'center', black, 70, [], [], 1.3, [], Instr_dst_rect);
            Screen('Flip', window);
            KbStrokeWait;
        end
    end
    
    
    displayperm = randperm(size(all_combo,1));
    %Variable to track continuous correct answers for premature exit
    continuous_correct = 0;
    
    %Begin process to each trial 
    for blocks=1:numblocks(stage)
        for trial=1:numtrials(stage)
            %Debug print
            disp(['In trial ' num2str(trial) ' block ' num2str(blocks) ' stage' num2str(stage)]);
            %Calculate image sizes and scaling.
            [As1,As2,As3] = size(faces{all_combo(displayperm(trial),1),all_combo(displayperm(trial),2)});
            A_asp_ratio = As2/As1;
            A_newh = screenYpixels/6;
            A_neww = A_asp_ratio*A_newh;
            A_theRect = [0 0 A_neww A_newh];
            %Position it in X center and 1/4th way from top.
            A_dst_rect = CenterRectOnPointd(A_theRect,screenXpixels/2,screenYpixels/6);
            
            [Xs1,Xs2,Xs3] = size(fish{all_combo(displayperm(trial),3),all_combo(displayperm(trial),4)});
            X_asp_ratio = Xs2/Xs1;
            X_newh = screenYpixels/8;
            X_neww = X_asp_ratio*X_newh;
            X_theRect = [0 0 X_neww X_newh];
            %Position it in X center and 4/6th way from top.
            X1_dst_rect = CenterRectOnPointd(X_theRect,screenXpixels/4,0.5*screenYpixels);
            X2_dst_rect = CenterRectOnPointd(X_theRect,3*screenXpixels/4,0.5*screenYpixels);
            
            %Draw the face
            imageTexture = Screen('MakeTexture',window,faces{all_combo(displayperm(trial),1),all_combo(displayperm(trial),2)});
            Screen('DrawTexture', window, imageTexture, [], A_dst_rect, 0);
            
            %Draw the fishes
            imageTexture = Screen('MakeTexture',window,fish{all_combo(displayperm(trial),3),all_combo(displayperm(trial),4)});
            Screen('DrawTexture', window, imageTexture, [], X1_dst_rect, 0);
            imageTexture = Screen('MakeTexture',window,fish{all_combo(displayperm(trial),5),all_combo(displayperm(trial),6)});
            Screen('DrawTexture', window, imageTexture, [], X2_dst_rect, 0);
            
            % Draw text in the bottom of the screen in black
            Screen('TextSize', window, 40);
            Screen('TextFont', window, 'Times');
            DrawFormattedText(window, 'Which fish does this person have?', 'center',...
                screenYpixels * 0.65, [0 0 0]);
            DrawFormattedText(window, 'Use Left or Right key to choose.', 'center',...
                screenYpixels * 0.75, [0 0 0]);
            
            % Flip to the screen. This command basically draws all of our previous
            % commands onto the screen. See later demos in the animation section on more
            % timing details. And how to demos in this section on how to draw multiple
            % rects at once.
            % For help see: Screen Flip?
            Screen('Flip', window,0,1);
            
            %Start timing input if in non-social mode
            % Now we have drawn to the screen we wait for a keyboard button press (any
            % key) to terminate the demo. For help see: help KbStrokeWait
            %For now putting while loop but needs to be done as multiple
            %inputs.. Or maybe not to avoid unwanted inputs
            if(social~=true && observer_mode~= true)    %Take input and give feedback
                initsec = GetSecs;
                while(true)
                    [secs,keycode,deltasec] = KbStrokeWait;
                    rightarrow = KbName('RightArrow');
                    leftarrow = KbName('LeftArrow');
                    escape = KbName('ESCAPE');
                    if keycode(rightarrow) || keycode(leftarrow)
                        %Capture time
                        endsec = GetSecs;
                        curr_recorder.input_timing = [curr_recorder.input_timing (endsec-initsec)];
                        %Detect if correct answer
                        if (keycode(leftarrow) && all_combo(displayperm(trial),7) == 1) || (keycode(rightarrow) && all_combo(displayperm(trial),7) == 2)
                            if feedback==true
                                display_color = [0 1 0];
                                DrawFormattedText(window, 'Correct', 'center',...
                                    screenYpixels * 0.85, display_color);
                            end
                            continuous_correct = continuous_correct+1;
                        else
                            if feedback==true
                                display_color = [1 0 0];
                                DrawFormattedText(window, 'Incorrect', 'center',...
                                    screenYpixels * 0.85, display_color);
                            end
                            continuous_correct = 0;
                        end
                        
                        curr_recorder.correct_ans = [curr_recorder.correct_ans all_combo(displayperm(trial),7)];
                        % If in any phase we don't want feedback, we will
                        % still circle their choice but show it in grey
                        if feedback == false
                            display_color = [0.6,0.6,0.6];
                        end
                        %Draw circles and record moves - 1 = left, 2 = right
                        if keycode(leftarrow)
                            curr_recorder.moves = [curr_recorder.moves 1];
                            Screen('FrameOval',window,display_color,GrowRect(X1_dst_rect,15,15),3,3);
                        else
                            curr_recorder.moves = [curr_recorder.moves 2];
                            Screen('FrameOval',window,display_color,GrowRect(X2_dst_rect,15,15),3,3);
                        end
                        Screen('Flip', window);
                        WaitSecs(1);
                        break
%                     elseif keycode(escape)
%                         disp('Exit by escape')
%                         sca;
%                         return
                    end
                end
            else    %Replay stuff
                %Detect if correct answer
                if curr_recorder.correct_ans(move_index) == curr_recorder.moves(move_index)
                    display_color = [0 1 0];
                    DrawFormattedText(window, 'Correct', 'center',...
                        screenYpixels * 0.85, display_color);
                    continuous_correct = continuous_correct+1;
                else
                    display_color = [1 0 0];
                    DrawFormattedText(window, 'Incorrect', 'center',...
                        screenYpixels * 0.85, display_color);
                    continuous_correct = 0;
                end
                %Draw appropriate circle
                if curr_recorder.moves(move_index)==1
                    Screen('FrameOval',window,display_color,GrowRect(X1_dst_rect,15,15),3,3);
                else
                    Screen('FrameOval',window,display_color,GrowRect(X2_dst_rect,15,15),3,3);
                end
                %Wait as long as input user did before display.
                WaitSecs(curr_recorder.input_timing(move_index));
                move_index = move_index+1;
                Screen('Flip', window);
                %Wait 1 sec before clearing like in non-social input
                WaitSecs(1);
            end
            %Clear screen and display blank for 1 sec
            Screen('Flip', window);
            WaitSecs(1);
            %Premature exit if correct for required number of times
            if continuous_correct >= continuous_correct_expected(stage)
                break
            end
        end
        if continuous_correct >= continuous_correct_expected(stage)
            break
        end
    end
    
    %put in result text for stage 4
    if stage == 4
        % (1:16) added in the next command to help it identify the counts
        % correctly in observer mode.. Hackish needs to be refined.
        instr_text = ['You got ',num2str(sum(curr_recorder.moves(1:16) == curr_recorder.correct_ans(1:16))),...
            '/',num2str(size(curr_recorder.moves(1:16),2)), ' correct'];
        Screen('TextSize', window, 35);
        Screen('TextFont', window, 'Times');
        DrawFormattedText(window, instr_text,'center', 'center', black);
        Screen('Flip', window);
        WaitSecs(1);
        
        %Call function for actual stage 5 (words round)
        %rng states maybe redundant but better be safe
        cur_rngstate = rng;
        if observer_mode == true
            [word_recorder,cur_rngstate] = PresentWords(cur_rngstate,window,windowRect,faces,observer_mode,loaded_values2.word_recorder);
        else
            [word_recorder,cur_rngstate] = PresentWords(cur_rngstate,window,windowRect,faces);
        end
        rng(cur_rngstate);
    end
end
% Clear the screen. "sca" is short hand for "Screen CloseAll". This clears
% all features related to PTB. Note: we leave the variables in the
% workspace so you can have a look at them if you want.
% For help see: help sca
sca;
% If social learning mode then don't save the first part as it is just a
% replay
% If observer mode then don't save anything, it is purely observation
if observer_mode ~= true
    if social~=true
        save(fid,'out_rngstate','first_recorder');
    end
    % Save second part for everyone
    save(fid2,'out_rngstate','second_recorder','word_recorder');
end
end
