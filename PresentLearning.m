function PresentLearning(fid,social,rngstate)
% Clear the workspace and the screen
sca;
close all;
clearvars;

% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

% Seed the random number generator.
if(nargin < 3)
    rng('shuffle')
    out_rngstate = rng;
else
    rng(rngstate)
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
%For now loading onto separate variables but need to refine this to allow
%for permutations
image_dir = ['Images' filesep];
A1 = imread([image_dir 'A1.png']);
A2 = imread([image_dir 'A2.png']);
B1 = imread([image_dir 'B1.png']);
B2 = imread([image_dir 'B2.png']);
X1 = imread([image_dir 'X1.png']);
X2 = imread([image_dir 'X2.png']);
Y1 = imread([image_dir 'Y1.png']);
Y2 = imread([image_dir 'Y2.png']);

%Calculate image sizes and scaling.
%Here too for now using one exampl but needs to be generalized
[As1,As2,As3] = size(A1);
A_asp_ratio = As2/As1;
A_newh = screenYpixels/6;
A_neww = A_asp_ratio*A_newh;
A_theRect = [0 0 A_neww A_newh];
%Position it in X center and 1/4th way from top.
A_dst_rect = CenterRectOnPointd(A_theRect,screenXpixels/2,screenYpixels/4);

[Xs1,Xs2,Xs3] = size(X1);
X_asp_ratio = Xs2/Xs1;
X_newh = screenYpixels/8;
X_neww = X_asp_ratio*X_newh;
X_theRect = [0 0 X_neww X_newh];
%Position it in X center and 4/6th way from top.
X1_dst_rect = CenterRectOnPointd(X_theRect,screenXpixels/4,4*screenYpixels/6);
X2_dst_rect = CenterRectOnPointd(X_theRect,3*screenXpixels/4,4*screenYpixels/6);

%Draw the face
imageTexture = Screen('MakeTexture',window,A1);
Screen('DrawTexture', window, imageTexture, [], A_dst_rect, 0);

%Draw the fishes
imageTexture = Screen('MakeTexture',window,X1);
Screen('DrawTexture', window, imageTexture, [], X1_dst_rect, 0);
imageTexture = Screen('MakeTexture',window,X2);
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
%For now putting while loop but needs to be done as multiple inputs
while(true)
    [secs,keycode,deltasec] = KbStrokeWait;
    rightarrow = KbName('RightArrow');
    leftarrow = KbName('LeftArrow');
    escape = KbName('ESCAPE');
    if keycode(rightarrow)
        Screen('FrameOval',window,[0,1,0],GrowRect(X1_dst_rect,15,15),3,3);
        DrawFormattedText(window, 'Incorrect', 'center',...
            screenYpixels * 0.65, [1 0 0]);
        Screen('Flip', window);
    elseif keycode(leftarrow)
        disp('Answered No')
        Screen('FrameOval',window,[0,1,0],GrowRect(X1_dst_rect,15,15),3,3);
        DrawFormattedText(window, 'Correct', 'center',...
            screenYpixels * 0.65, [0 1 0]);
        Screen('Flip', window);
    elseif keycode(escape)
        disp('Exit by escape')
        break
    end
end
% Clear the screen. "sca" is short hand for "Screen CloseAll". This clears
% all features related to PTB. Note: we leave the variables in the
% workspace so you can have a look at them if you want.
% For help see: help sca
sca;
end