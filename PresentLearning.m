function PresentLearning(fid,social)
% Clear the workspace and the screen
sca;
close all;

% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

% Seed the random number generator.
if(social ~= true)
    rng('shuffle');
    out_rngstate = rng;
else
    loaded_values = load(fid);
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
faces{1,1} = imread([image_dir 'Face' num2str(facepermutations(1)) '.png']);
faces{1,2} = imread([image_dir 'Face' num2str(facepermutations(2)) '.png']);
faces{2,1} = imread([image_dir 'Face' num2str(facepermutations(3)) '.png']);
faces{2,2} = imread([image_dir 'Face' num2str(facepermutations(4)) '.png']);
fish{1,1} = imread([image_dir 'Fish' num2str(fishpermutations(1)) '.png']);
fish{1,2} = imread([image_dir 'Fish' num2str(fishpermutations(2)) '.png']);
fish{2,1} = imread([image_dir 'Fish' num2str(fishpermutations(3)) '.png']);
fish{2,2} = imread([image_dir 'Fish' num2str(fishpermutations(4)) '.png']);

%Setup parameters for experiment
numblocks = 8;
continuous_correct_expected = [8 8 12];
numtrials = [4 8 12];
numfaces = [2 4 4];
numfishes = [2 2 4];
%Create face,fish indice for easy cell access
[p,q] = meshgrid(1:size(faces,1),1:size(faces,2));
faceindices = [p(:) q(:)];
[p,q] = meshgrid(1:size(fish,1),1:size(fish,2));
fishindices = [p(:) q(:)];

%Input recording/display variables
moves = [];
correct_ans = [];
if social==true
    move_index = 1;
end

for stage=1:3
    %Generate all possible combinations then permute for the order.
    all_combo = [faceindices(1:numfaces(stage),:) , repmat(fishindices(1:2,:),numfaces(stage)/2,1), repmat(flipud(fishindices(1:2,:)),numfaces(stage)/2,1), ones(numfaces(stage),1);
                 faceindices(1:numfaces(stage),:) , repmat(flipud(fishindices(1:2,:)),numfaces(stage)/2,1), repmat(fishindices(1:2,:),numfaces(stage)/2,1), 2*ones(numfaces(stage),1)
                ];
    if stage == 3
        all_combo = [all_combo;
                     faceindices(1:2,:) , fishindices(3:4,:), flipud(fishindices(3:4,:)), ones(2,1);
                     faceindices(1:2,:) , flipud(fishindices(3:4,:)), fishindices(3:4,:), 2*ones(2,1)
                    ];
    end
    displayperm = randperm(size(all_combo,1));
    %Variable to track continuous correct answers for premature exit
    continuous_correct = 0;
    for blocks=1:numblocks
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
            A_dst_rect = CenterRectOnPointd(A_theRect,screenXpixels/2,screenYpixels/4);
            
            [Xs1,Xs2,Xs3] = size(fish{all_combo(displayperm(trial),3),all_combo(displayperm(trial),4)});
            X_asp_ratio = Xs2/Xs1;
            X_newh = screenYpixels/8;
            X_neww = X_asp_ratio*X_newh;
            X_theRect = [0 0 X_neww X_newh];
            %Position it in X center and 4/6th way from top.
            X1_dst_rect = CenterRectOnPointd(X_theRect,screenXpixels/4,4*screenYpixels/6);
            X2_dst_rect = CenterRectOnPointd(X_theRect,3*screenXpixels/4,4*screenYpixels/6);
            
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
                screenYpixels * 0.75, [0 0 0]);
            DrawFormattedText(window, 'Use “Left” or “Right” key to choose. Press escape to exit', 'center',...
                screenYpixels * 0.85, [0 0 0]);
            
            % Flip to the screen. This command basically draws all of our previous
            % commands onto the screen. See later demos in the animation section on more
            % timing details. And how to demos in this section on how to draw multiple
            % rects at once.
            % For help see: Screen Flip?
            Screen('Flip', window,0,1);
            
            % Now we have drawn to the screen we wait for a keyboard button press (any
            % key) to terminate the demo. For help see: help KbStrokeWait
            %For now putting while loop but needs to be done as multiple
            %inputs.. Or maybe not to avoid unwanted inputs
            if(social~=true)    %Take input and give feedback
                while(true)
                    [secs,keycode,deltasec] = KbStrokeWait;
                    rightarrow = KbName('RightArrow');
                    leftarrow = KbName('LeftArrow');
                    escape = KbName('ESCAPE');
                    if keycode(rightarrow) || keycode(leftarrow)
                        if all_combo(displayperm(trial),7) == 1
                            Screen('FrameOval',window,[0,1,0],GrowRect(X1_dst_rect,15,15),3,3);
                        elseif all_combo(displayperm(trial),7) == 2
                            Screen('FrameOval',window,[0,1,0],GrowRect(X2_dst_rect,15,15),3,3);
                        end
                        if (keycode(leftarrow) && all_combo(displayperm(trial),7) == 1) || (keycode(rightarrow) && all_combo(displayperm(trial),7) == 2)
                            DrawFormattedText(window, 'Correct', 'center',...
                                screenYpixels * 0.65, [0 1 0]);
                            continuous_correct = continuous_correct+1;
                        else
                            DrawFormattedText(window, 'Incorrect', 'center',...
                                screenYpixels * 0.65, [1 0 0]);
                            continuous_correct = 0;
                        end
                        
                        correct_ans = [correct_ans all_combo(displayperm(trial),7)];
                        if keycode(leftarrow)
                            moves = [moves 1];
                        else
                            moves = [moves 2];
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
                if loaded_values.correct_ans(move_index) == 1
                    Screen('FrameOval',window,[0,1,0],GrowRect(X1_dst_rect,15,15),3,3);
                elseif loaded_values.correct_ans(move_index) == 2
                    Screen('FrameOval',window,[0,1,0],GrowRect(X2_dst_rect,15,15),3,3);
                end
                if loaded_values.correct_ans(move_index) == loaded_values.moves(move_index)
                    continuous_correct = continuous_correct+1;
                    DrawFormattedText(window, 'Correct', 'center',...
                        screenYpixels * 0.65, [0 1 0]);
                else
                    DrawFormattedText(window, 'Incorrect', 'center',...
                        screenYpixels * 0.65, [1 0 0]);
                    continuous_correct = 0;
                end
                move_index = move_index+1;
                Screen('Flip', window);
                %For now waiting for constant 5 sec.
                WaitSecs(5);
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
end
% Clear the screen. "sca" is short hand for "Screen CloseAll". This clears
% all features related to PTB. Note: we leave the variables in the
% workspace so you can have a look at them if you want.
% For help see: help sca
sca;
if social~=true
    save(fid,'out_rngstate','moves','correct_ans');
end
end