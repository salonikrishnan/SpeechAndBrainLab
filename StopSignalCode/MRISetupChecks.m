function ready = MRISetupChecks()

% This checks OHBA hardware setup

ready = 0;

clc;

disp('The password for the stim PCs is MRadmin');

display1 = input('Have you switched the MRI display to laptop, 0 if yes, 1 if no:');
display2 = input('Have you switched display2 to laptop, 0 if yes, 1 if no:');
pp1 = input('Have you switched parallel port 1 to PC1, 0 if yes, 1 if no:');
pp2 = input('Have you switched parallel port 2 to Optical, 0 if yes, 1 if no:');
pp3 = input('Have you switched parallel port 3 to PC, 0 if yes, 1 if no:');

if display1 == 0 && display1 == 0 && pp1 == 0 && pp2 == 0 && pp3 == 0
    
    ready = 1;
else
    
    ready = 0;
end



end
