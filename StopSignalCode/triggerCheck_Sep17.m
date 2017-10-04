notrigger=1;
%
while notrigger
    test = GetChar;
    if test == '5'; notrigger=0; end;
    %[keyIsDown,secs,keyCode] = KbCheck();
    %if keyIsDown && find(keyCode)==triggerkey, notrigger=0; end;
end