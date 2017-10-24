DisableKeysForKbCheck(KbName('5%'));
RestrictKeysForKbCheck([KbName('1!'),KbName('2@')]);

notrigger = 1;

while notrigger
    [keyIsDown,secs,keyCode] = KbCheck(inputDevice);
    
    if keyIsDown
        notrigger = 0;
    end
end

disp('Works!')

FlushEvents;