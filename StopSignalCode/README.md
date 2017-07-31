
Many thanks to Gui Xue for this code.

*1. Testing on your computer*

First get to the appropriate directory on your computer

```
cd StopSignalCode/
```

Test that the signal plays. Use headphones as the stop signal may otherwise be picked up in the vocal conditions as a sound. Try and play this on the softest and most comfortable level for the participant.
```
test_sound.m
```
Test that the screen works
```
TestScreen.m
```
Then test that the voice key works. You should make sure that the microphone you want to use is selected as the default option. 
```
test_voicekey.m
```

*2. Behavioural version:*

Start by running the demo version
The options are
1. manual (T/D); 
2. vocal (T/D), 
3. word (pseudoword lists)
Data from the demo does not get saved or logged, so this is just to show the participant what to do. 

Give the participant some instructions. These are adapted from instructions by Jess Cohen on the Poldrack lab website.

"You will see some letters flash up on screen. As soon as you see the letter, respond as quickly and as accurately as possible."
In the manual case: "You respond by pressing “n” if a T is displayed and “m” if a D is displayed. Use the index and middle fingers of your right hand."
In the vocal case: "You respond by saying "tee" is a T is displayed and "dee" if a D is displayed"
In the pseudoword case: "You will see some made up words on screen. You respond by saying these out loud, as quickly as you can"
"When you hear a beep, that signals to you stop your response immediately and not to respond to that particular letter/ word. You need to continue to respond to the others after it, unless there is another tone. Both going and stopping are equally important.
This task is designed to be difficult and for subjects to make mistakes, because we are interested in looking at those mistakes. So don’t get frustrated if it’s difficult. Just make sure not to slow down your responses to wait for the beep so that you are no longer going when you are supposed to, because then you are no longer doing the task.
You won’t always be able to stop when you hear a beep, so just try your best. As long as you go quickly all of the time without pushing the wrong button for arrow direction, and can stop some of the time you’re doing the task correctly.
It’s also important to concentrate and not to talk while you’re doing the task. Do you have any questions?
If not, let’s begin the demo program."

When the demo completes, you can look at the speed at which participants are responding, the number of errors they are making, the SSD, the percent inhibition and give them feedback. An RT between 400-500ms is good for the manual and vocal tasks, participants may take a little longer for the pseudoword tasks (500-600ms).

If the subject falls within that range, say: “You’re doing a great job; keep your speed constant and keep up the good work.”
If they’re a little slower, say: “Remember that going and stopping are equally important and don’t slow down on the go task to wait for the beeps or you aren’t doing the go portion of the task, which is just as important as the stopping portion. You won’t be able to stop every time you hear a beep, we design the task that way, so just try your best and keep your speed constant.”
If they have too many arrow direction errors or never stop when there’s a beep, say: ”Remember that going and stopping are both important, so maybe you should slow down a bit on the go task so you push the correct buttons for the arrows and can stop some of the time, but remember not to continue slowing down so you’re waiting for the beep.”


```
demo.m
```
Ask if participants have understood the task. If yes, get started, and run the main task
A. Enter the subject number 
B. The options are 1. manual (T/D); 2. vocal (T/D), 3. word (pseudoword lists)
C. use 1 for the jitter question (use 2 if you want to use preset jitter)
D. If wordlist, pick if you want to use wordlist 1 or 2
Press any key to start
```
prescan_stop3cond.m
```

3. Analysis
Enter the subject code followed by the condition.

```
Analysis.m
```
