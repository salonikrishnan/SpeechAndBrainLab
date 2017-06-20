fname = sprintf('feedbackpic%d.jpg',1);
fbimage = {imread(fname, 'jpg')};

   %% close screen then reopen
%    fbimage = {imread(fname, 'jpg')};
%    fbimage = imread(fname, 'jpg');
%    imagedata=fbimage(:,:,1:3);
%    Screen(w, 'TextFont', theFont);
%    Screen(w,'TextSize', 24);
%    Screen(w, 'DrawText','Press any key to continue.',300,720,255);
%    Screen(scr,'PutImage',imagedata,[xcenter-300 ycenter-300 xcenter+300 ycenter+300]);
%    Screen('Flip',w);
%    GetChar;
    %%% wait for key press to begin
	%while GetChar~='Space'; end	%-use so can press any key to begin
    
    %Screen('CloseAll');
    pixelSize=32;
    [w, screenRect]=Screen(0, 'OpenWindow', 0, [], pixelSize);
    black=BlackIndex(w);
    white=WhiteIndex(w);
    blank_screen=Screen(w, 'OpenOffscreenWindow', 0, screenRect);
    scr=Screen(w, 'OpenOffscreenWindow', 0, screenRect);
    xcenter=screenRect(3)/2;
    ycenter=screenRect(4)/2;
    
    texture1 = Screen('MakeTexture',w,fbimage{1});
    Screen('DrawTexture',w, texture1);
    Screen(w, 'DrawText','Press any key to continue.',320,800,255);
    Screen('Flip',w);

    %GetChar;
    sca;